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
final class BasemapGalleryController {
  /// Creates a gallery with default basemaps.
  ///
  /// If no custom items or portal is provided, this controller loads ArcGIS
  /// Online's developer basemaps by default. These basemaps are secured and
  /// typically require an API key or named-user authentication.
  BasemapGalleryController({GeoModel? geoModel})
    : _geoModel = geoModel,
      _portal = null {
    _initFromGeoModel();
    unawaited(_populateDefaultBasemaps());
  }

  /// Creates a gallery using basemaps from a [Portal].
  ///
  /// If [portal] is valid, the controller fetches portal basemaps asynchronously
  /// and copies them into [gallery].
  ///
  BasemapGalleryController.withPortal(Portal portal, {GeoModel? geoModel})
    : _geoModel = geoModel,
      _portal = portal {
    _initFromGeoModel();
    unawaited(_populateFromPortal());
  }

  /// Creates a gallery using provided [items].
  BasemapGalleryController.withItems({
    required List<BasemapGalleryItem> items,
    GeoModel? geoModel,
  }) : _geoModel = geoModel,
       _portal = null {
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
  final _viewStyleNotifier = ValueNotifier<BasemapGalleryViewStyle>(
    BasemapGalleryViewStyle.automatic,
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
  /// If it is not loaded when set, it will be loaded immediately.
  ///
  GeoModel? get geoModel => _geoModel;

  set geoModel(GeoModel? value) {
    _geoModel = value;
    _initFromGeoModel();
  }

  /// The portal used for basemaps when constructed with a portal.
  Portal? get portal => _portal;

  /// The currently applied basemap on the associated [GeoModel].
  Basemap? get currentBasemap => _currentBasemapNotifier.value?.basemap;

  /// Event invoked when the currently selected basemap changes.
  ///
  /// This only updates when the user selects a new basemap from the gallery.
  Stream<Basemap> get onCurrentBasemapChanged =>
      _currentBasemapChangedController.stream;

  /// The list of basemaps visible in the gallery.
  List<BasemapGalleryItem> get gallery => _galleryNotifier.value;

  bool get _isFetchingBasemaps => _isFetchingBasemapsNotifier.value;

  /// Current view style.
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

  Future<void> _populateFromPortal() async {
    final p = _portal;
    if (p == null) {
      _galleryNotifier.value = const [];
      return;
    }

    _isFetchingBasemapsNotifier.value = true;
    _fetchBasemapsErrorNotifier.value = null;

    try {
      if (p.loadStatus == LoadStatus.notLoaded) {
        await p.load();
      }
      final basemaps = await p.basemaps();
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

    // Load developer basemaps from ArcGIS Online by default (API-key metered basemaps).
    final portal = Portal.arcGISOnline();

    try {
      if (portal.loadStatus == LoadStatus.notLoaded) {
        await portal.load();
      }
      final basemaps = await portal.developerBasemaps();
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
