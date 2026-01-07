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

part of '../../../arcgis_maps_toolkit.dart';

/// Controls the state and behavior of a [BasemapGallery].
final class BasemapGalleryController with ChangeNotifier {
  /// Creates a gallery with default basemaps.
  ///
  /// If no custom items or portal is provided, this controller loads ArcGIS
  /// Online's developer basemaps by default. These basemaps are secured and
  /// typically require an API key or named-user authentication.
  BasemapGalleryController({GeoModel? geoModel})
    : _geoModel = geoModel,
      _portal = null,
      _isPortalProvidedByUser = false {
    _initFromGeoModel();
    unawaited(_populateDefaultBasemaps());
  }

  /// Creates a gallery using basemaps from a [Portal].
  ///
  /// If [portal] is valid, the controller fetches portal basemaps asynchronously
  /// and copies them into [gallery].
  ///
  BasemapGalleryController.withPortal({GeoModel? geoModel, Portal? portal})
    : _geoModel = geoModel,
      _portal = portal,
      _isPortalProvidedByUser = true {
    _initFromGeoModel();
    unawaited(_populateFromPortal());
  }

  /// Creates a gallery using provided [basemaps].
  BasemapGalleryController.withItems({
    required List<BasemapGalleryItem> basemaps,
    GeoModel? geoModel,
  }) : _geoModel = geoModel,
       _portal = null,
       _isPortalProvidedByUser = false {
    _initFromGeoModel();

    if (basemaps.isEmpty) {
      unawaited(_populateDefaultBasemaps());
    } else {
      _gallery = List<BasemapGalleryItem>.unmodifiable(basemaps.toList());
    }
  }

  GeoModel? _geoModel;
  final Portal? _portal;
  final bool _isPortalProvidedByUser;

  BasemapGalleryViewStyle _viewStyle = BasemapGalleryViewStyle.automatic;

  late List<BasemapGalleryItem> _gallery = const [];

  bool _isFetchingBasemaps = false;
  Object? _fetchBasemapsError;

  final ValueNotifier<_SpatialReferenceMismatchError?>
  spatialReferenceMismatchErrorNotifier =
      ValueNotifier<_SpatialReferenceMismatchError?>(null);

  final ValueNotifier<BasemapGalleryItem?> currentBasemapNotifier =
      ValueNotifier<BasemapGalleryItem?>(null);

  final StreamController<Basemap> _currentBasemapChangedController =
      StreamController<Basemap>.broadcast();

  /// The associated geo model.
  ///
  /// If it is not loaded when set, it will be loaded immediately.
  ///
  GeoModel? get geoModel => _geoModel;

  set geoModel(GeoModel? value) {
    _geoModel = value;
    _initFromGeoModel();
    notifyListeners();
  }

  /// The portal used for basemaps when constructed with a portal.
  Portal? get portal => _portal;

  /// The currently applied basemap on the associated [GeoModel].
  BasemapGalleryItem? get currentBasemap => currentBasemapNotifier.value;

  /// The list of basemaps visible in the gallery.
  List<BasemapGalleryItem> get gallery => _gallery;

  /// True while basemap items are being fetched from a portal.
  bool get isFetchingBasemaps => _isFetchingBasemaps;

  /// Error (if any) from fetching basemaps.
  Object? get fetchBasemapsError => _fetchBasemapsError;

  /// Current view style.
  BasemapGalleryViewStyle get viewStyle => _viewStyle;

  /// Stream emitting the selected [Basemap] whenever selection changes.
  Stream<Basemap> get onCurrentBasemapChanged =>
      _currentBasemapChangedController.stream;

  /// Updates the view style.
  void setViewStyle(BasemapGalleryViewStyle style) {
    if (_viewStyle == style) return;
    _viewStyle = style;
    notifyListeners();
  }

  /// Selects a basemap item.
  ///
  /// This will:
  /// - Ensure the associated [GeoModel] is loaded (if provided).
  /// - Check spatial reference compatibility when a [GeoModel] is provided.
  /// - Update [currentBasemap], synchronize [GeoModel.basemap], and emit on
  ///   [onCurrentBasemapChanged] when selection succeeds.
  Future<void> select(BasemapGalleryItem item) async {
    if (item.isBasemapLoading) return;
    if (item.loadBasemapError != null) return;

    spatialReferenceMismatchErrorNotifier.value = null;

    final gm = _geoModel;
    if (gm != null) {
      await gm.load();
      await item.updateSpatialReferenceStatus(gm.actualSpatialReference);

      if (item.spatialReferenceStatus ==
          BasemapGalleryItemSpatialReferenceStatus.noMatch) {
        spatialReferenceMismatchErrorNotifier.value =
            _SpatialReferenceMismatchError(
              basemapSpatialReference: item.spatialReference,
              geoModelSpatialReference: gm.actualSpatialReference,
            );
        return;
      }
    }

    currentBasemapNotifier.value = item;

    if (gm != null) {
      // Clone unless the basemap originated from a user-provided portal.
      gm.basemap = _isPortalProvidedByUser
          ? item.basemap
          : item.basemap.clone();
    }

    _currentBasemapChangedController.add(item.basemap);
    notifyListeners();
  }

  /// Clears the current spatial reference mismatch error.
  void clearSpatialReferenceMismatchError() {
    spatialReferenceMismatchErrorNotifier.value = null;
  }

  /// Adds an item to the gallery.
  void addItem(BasemapGalleryItem item) {
    _gallery = List<BasemapGalleryItem>.unmodifiable(<BasemapGalleryItem>[
      ..._gallery,
      item,
    ]);
    notifyListeners();
  }

  /// Removes an item from the gallery.
  bool removeItem(BasemapGalleryItem item) {
    final next = _gallery.toList()..remove(item);
    if (next.length == _gallery.length) return false;
    _gallery = List<BasemapGalleryItem>.unmodifiable(next);
    notifyListeners();
    return true;
  }

  /// Disposes resources.
  @override
  void dispose() {
    currentBasemapNotifier.dispose();
    spatialReferenceMismatchErrorNotifier.dispose();
    _currentBasemapChangedController.close();
    super.dispose();
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
        currentBasemapNotifier.value = BasemapGalleryItem(basemap: basemap);
      }
    }
  }

  Future<void> _populateFromPortal() async {
    final p = _portal;
    if (p == null) {
      _gallery = const [];
      return;
    }

    _isFetchingBasemaps = true;
    _fetchBasemapsError = null;
    notifyListeners();

    try {
      if (p.loadStatus == LoadStatus.notLoaded) {
        await p.load();
      }
      final basemaps = await p.basemaps();
      _gallery = List<BasemapGalleryItem>.unmodifiable(
        basemaps.map((b) => BasemapGalleryItem(basemap: b)).toList(),
      );
    } on Object catch (e) {
      _fetchBasemapsError = e;
      _gallery = const [];
    } finally {
      _isFetchingBasemaps = false;
      notifyListeners();
    }
  }

  Future<void> _populateDefaultBasemaps() async {
    _isFetchingBasemaps = true;
    _fetchBasemapsError = null;
    _gallery = const [];
    notifyListeners();

    // Load developer basemaps from ArcGIS Online by default (API-key metered basemaps).
    final portal = Portal.arcGISOnline();

    try {
      if (portal.loadStatus == LoadStatus.notLoaded) {
        await portal.load();
      }
      final basemaps = await portal.developerBasemaps();
      _gallery = List<BasemapGalleryItem>.unmodifiable(
        basemaps.map((b) => BasemapGalleryItem(basemap: b)).toList(),
      );
    } on Object catch (e) {
      _fetchBasemapsError = e;
      _gallery = const [];
    } finally {
      _isFetchingBasemaps = false;
      notifyListeners();
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
