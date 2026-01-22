//
// Copyright 2025 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

part of '../../arcgis_maps_toolkit.dart';

/// Controls the state and behavior of a [BasemapGallery].
///
/// A [BasemapGalleryController] is required to construct a [BasemapGallery].
/// It can be configured with an optional [GeoModel]. If a geo model is attached, a basemap selected in the basemap gallery
/// will automatically update in the view.
/// By default, the basemap gallery will display basemaps from ArcGISOnline. If a scene is provided, this will include 3D basemaps.
/// Alternatively, construct the [BasemapGalleryController] with a portal Uri or custom list of [BasemapGalleryItem] to display custom
/// basemaps.
///
/// Toggle the [BasemapGalleryViewStyle] to display the thumbnails in a grid or list.
///
/// The [BasemapGalleryController] should be disposed of when no longer required.
final class BasemapGalleryController {
  /// Creates a basemap gallery controller.
  ///
  /// The list of gallery items is populated with default basemaps from ArcGIS Online.
  ///
  /// If a [GeoModel] is provided, when an enabled basemap is selected by the user, the geo model
  /// will have its basemap replaced with the selected basemap.
  /// If the [geoModel] is an [ArcGISScene], default 3D basemaps are also provided.
  BasemapGalleryController({GeoModel? geoModel})
    : _geoModel = geoModel,
      _portal = null,
      _usesCustomItems = false {
    _initFromGeoModel();
    unawaited(_populateDefaultBasemaps());
  }

  /// Creates a basemap gallery controller using basemaps from a [Portal].
  ///
  /// Uses the given [Portal] (if valid) to retrieve the list of gallery items.
  /// If a [GeoModel] is provided, when an enabled basemap is selected by the user, the geo model
  /// will have its basemap replaced with the selected basemap.
  BasemapGalleryController.withPortal(Portal portal, {GeoModel? geoModel})
    : _geoModel = geoModel,
      _portal = portal,
      _usesCustomItems = false {
    _initFromGeoModel();
    unawaited(_populateFromPortal());
  }

  /// Creates a basemap gallery controller using the given list of basemap gallery items.
  /// The portal property is set to null.
  ///
  /// If a [GeoModel] is provided, when an enabled basemap is selected by the user, the geo model
  /// will have its basemap replaced with the selected basemap.
  BasemapGalleryController.withItems({
    required List<BasemapGalleryItem> items,
    GeoModel? geoModel,
  }) : _geoModel = geoModel,
       _portal = null,
       _usesCustomItems = true {
    _initFromGeoModel();

    if (items.isEmpty) {
      throw ArgumentError.value(
        items,
        'items',
        'BasemapGalleryController.withItems requires a non-empty list. '
            'Use the unnamed BasemapGalleryController() constructor for defaults.',
      );
    }

    _galleryNotifier.value = List<BasemapGalleryItem>.unmodifiable(
      items.toList(),
    );
  }

  GeoModel? _geoModel;
  final Portal? _portal;
  final bool _usesCustomItems;

  final _viewStyleNotifier = ValueNotifier<BasemapGalleryViewStyle>(
    BasemapGalleryViewStyle.grid,
  );

  final _galleryNotifier = ValueNotifier<List<BasemapGalleryItem>>(const []);
  final _isFetchingBasemapsNotifier = ValueNotifier<bool>(false);
  final _fetchBasemapsErrorNotifier = ValueNotifier<Object?>(null);

  final _spatialReferenceMismatchErrorNotifier =
      ValueNotifier<_SpatialReferenceMismatchError?>(null);

  final _currentBasemapNotifier = ValueNotifier<BasemapGalleryItem?>(null);
  final _currentBasemapChangedController =
      StreamController<Basemap>.broadcast();

  late final Listenable _galleryListenable = Listenable.merge(<Listenable>[
    _galleryNotifier,
    _isFetchingBasemapsNotifier,
    _fetchBasemapsErrorNotifier,
    _viewStyleNotifier,
    _currentBasemapNotifier,
  ]);

  /// The associated geo model.
  ///
  /// If the [GeoModel] is not loaded when passed to the [BasemapGalleryController],
  /// then the map/scene will be automatically loaded.
  /// The spatial reference of geo model dictates which basemaps from the gallery are enabled.
  /// When an enabled basemap is selected by the user, the geo model will have its basemap replaced with the selected basemap.
  GeoModel? get geoModel => _geoModel;

  set geoModel(GeoModel? value) {
    if (identical(_geoModel, value)) return;

    _geoModel = value;
    _initFromGeoModel();

    if (_usesCustomItems) return;

    // If the GeoModel changes after construction, refresh the gallery so the
    // correct 2D/3D basemap sources are used.
    if (_portal != null) {
      unawaited(_populateFromPortal());
    } else {
      unawaited(_populateDefaultBasemaps());
    }
  }

  /// The portal object, if set in the constructor of the [BasemapGalleryController].
  Portal? get portal => _portal;

  /// Currently applied basemap on the associated [GeoModel]. This may be a basemap which does not exist in the gallery.
  Basemap? get currentBasemap => _currentBasemapNotifier.value?.basemap;

  /// Event invoked when the currently selected basemap changes.
  ///
  /// Notifies when the user selects a different basemap from the gallery.
  Stream<Basemap> get onCurrentBasemapChanged =>
      _currentBasemapChangedController.stream;

  /// The list of basemaps currently visible in the gallery. Items added or removed from this list will update the gallery.
  List<BasemapGalleryItem> get gallery => _galleryNotifier.value;

  bool get _isFetchingBasemaps => _isFetchingBasemapsNotifier.value;

  /// The current view style of the basemap gallery.
  /// The gallery can be displayed as a list or grid,
  BasemapGalleryViewStyle get viewStyle => _viewStyleNotifier.value;

  set viewStyle(BasemapGalleryViewStyle style) {
    if (_viewStyleNotifier.value == style) return;
    _viewStyleNotifier.value = style;
  }

  /// Selects a basemap item.
  ///
  /// This will:
  /// - Ensure the associated [GeoModel] is loaded (if provided).
  /// - Check spatial reference compatibility when a [GeoModel] is provided.
  /// - Update [currentBasemap], synchronize [GeoModel.basemap], and emit on
  ///   [onCurrentBasemapChanged] when selection succeeds.
  Future<void> _select(BasemapGalleryItem item) async {
    if (item._isBasemapLoading) return;
    if (item._loadBasemapError != null) return;

    _spatialReferenceMismatchErrorNotifier.value = null;

    final gm = _geoModel;
    if (gm != null) {
      await gm.load();
      await item._updateSpatialReferenceStatus(gm.actualSpatialReference);

      if (item._spatialReferenceStatus ==
          BasemapGalleryItemSpatialReferenceStatus.noMatch) {
        _spatialReferenceMismatchErrorNotifier.value =
            _SpatialReferenceMismatchError(
              basemapSpatialReference: item._spatialReference,
              geoModelSpatialReference: gm.actualSpatialReference,
            );
        return;
      }
    }

    _currentBasemapNotifier.value = item;

    if (gm != null) {
      gm.basemap = item.basemap;
    }

    _currentBasemapChangedController.add(item.basemap);
  }

  /// Disposes resources.
  void dispose() {
    _viewStyleNotifier.dispose();
    _galleryNotifier.dispose();
    _isFetchingBasemapsNotifier.dispose();
    _fetchBasemapsErrorNotifier.dispose();
    _currentBasemapNotifier.dispose();
    _currentBasemapChangedController.close();
    _spatialReferenceMismatchErrorNotifier.dispose();
  }

  void _initFromGeoModel() {
    final gm = _geoModel;

    if (gm != null) {
      // Trigger load immediately if not already loaded.
      if (gm.loadStatus == LoadStatus.notLoaded) {
        // Fire-and-forget; controller itself does not await.
        unawaited(gm.load());
      }

      final basemap = gm.basemap;
      if (basemap != null) {
        _currentBasemapNotifier.value = BasemapGalleryItem(basemap: basemap);
      }
    }
  }

  /// Fetches basemaps from the given [portal].
  ///
  /// The returned list includes:
  /// - 3D basemaps when the current [GeoModel] is an [ArcGISScene].
  /// - Exactly one 2D basemap set:
  ///   - developer basemaps when [useDeveloperBasemaps] is true
  ///   - otherwise the portal's standard basemaps.
  Future<List<Basemap>> _fetchBasemaps({
    required Portal portal,
    required bool useDeveloperBasemaps,
  }) async {
    if (portal.loadStatus == LoadStatus.notLoaded) {
      await portal.load();
    }

    final basemaps = <Basemap>[];

    final gm = _geoModel;
    if (gm is ArcGISScene) {
      basemaps.addAll(await portal.basemaps3D());
    }

    if (useDeveloperBasemaps) {
      basemaps.addAll(await portal.developerBasemaps());
    } else {
      basemaps.addAll(await portal.basemaps());
    }

    return List<Basemap>.unmodifiable(basemaps);
  }

  Future<void> _populateFromPortal() async {
    final p = _portal;
    if (p == null) {
      _galleryNotifier.value = const [];
      return;
    }

    _isFetchingBasemapsNotifier.value = true;
    _fetchBasemapsErrorNotifier.value = null;

    try {
      final basemaps = await _fetchBasemaps(
        portal: p,
        useDeveloperBasemaps: false,
      );
      _galleryNotifier.value = List<BasemapGalleryItem>.unmodifiable(
        basemaps.map((b) => BasemapGalleryItem(basemap: b)).toList(),
      );
    } on Object catch (e) {
      _fetchBasemapsErrorNotifier.value = e;
      _galleryNotifier.value = const [];
    } finally {
      _isFetchingBasemapsNotifier.value = false;
    }
  }

  Future<void> _populateDefaultBasemaps() async {
    _isFetchingBasemapsNotifier.value = true;
    _fetchBasemapsErrorNotifier.value = null;
    _galleryNotifier.value = const [];

    // Load developer basemaps from ArcGIS Online by default.
    final portal = Portal.arcGISOnline();

    try {
      final basemaps = await _fetchBasemaps(
        portal: portal,
        useDeveloperBasemaps: true,
      );
      _galleryNotifier.value = List<BasemapGalleryItem>.unmodifiable(
        basemaps.map((b) => BasemapGalleryItem(basemap: b)).toList(),
      );
    } on Object catch (e) {
      _fetchBasemapsErrorNotifier.value = e;
      _galleryNotifier.value = const [];
    } finally {
      _isFetchingBasemapsNotifier.value = false;
    }
  }
}

/// An error describing a spatial reference mismatch between a geo model and a basemap.
final class _SpatialReferenceMismatchError {
  const _SpatialReferenceMismatchError({
    required this.basemapSpatialReference,
    required this.geoModelSpatialReference,
  });

  final SpatialReference? basemapSpatialReference;
  final SpatialReference? geoModelSpatialReference;
}

extension on GeoModel {
  /// The spatial reference used for basemap compatibility checks.
  ///
  /// For [ArcGISScene], if the scene view tiling scheme is web mercator,
  /// returns [SpatialReference.webMercator]. Otherwise returns
  /// [GeoModel.spatialReference].
  SpatialReference? get actualSpatialReference {
    final self = this;
    if (self is ArcGISScene &&
        self.sceneViewTilingScheme == SceneViewTilingScheme.webMercator) {
      return SpatialReference.webMercator;
    }
    return spatialReference;
  }
}
