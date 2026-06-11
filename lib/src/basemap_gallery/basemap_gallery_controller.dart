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

/// The [BasemapGalleryController] contains the state data and properties for the associated [BasemapGallery].
/// The controller is used to define the list of [BasemapGalleryItem] to display within the [BasemapGallery], manage the view style of the gallery, and
/// listen to events when the current basemap changes.
/// Once the [BasemapGalleryController] is configured, it is used to construct the [BasemapGallery] widget.
final class BasemapGalleryController {
  /// Creates a [BasemapGalleryController] with default basemaps from ArcGIS Online's developer basemaps.
  /// Provide a [GeoModel] to automatically apply the [BasemapGalleryController.currentBasemap] to the respective map or scene.
  ///
  /// These basemaps are secured and typically require an API key or named-user authentication.
  BasemapGalleryController({this._geoModel}) : _portal = null {
    _initFromGeoModel();
    unawaited(_populateDefaultBasemaps());
  }

  /// Creates a [BasemapGalleryController] using basemaps from the provided [Portal].
  /// Provide a [GeoModel] to automatically apply the [BasemapGalleryController.currentBasemap] to the respective map or scene.
  ///
  /// If the [portal] is valid, the controller fetches basemaps from the portal asynchronously and populates the [gallery].
  BasemapGalleryController.withPortal(Portal portal, {this._geoModel})
    : _portal = portal {
    _initFromGeoModel();
    unawaited(_populateFromPortal());
  }

  /// Creates a [BasemapGalleryController] using the provided custom list of [BasemapGalleryItem].
  /// Provide a [GeoModel] to automatically apply the [BasemapGalleryController.currentBasemap] to the respective map or scene.
  BasemapGalleryController.withItems({
    required List<BasemapGalleryItem> items,
    this._geoModel,
  }) : _portal = null {
    _initFromGeoModel();

    if (items.isEmpty) {
      throw ArgumentError.value(
        items,
        'items',
        'BasemapGalleryController.withItems requires a non-empty list. '
            'Use the unnamed BasemapGalleryController() constructor for defaults.',
      );
    }

    _replaceGalleryItems(items);
  }

  GeoModel? _geoModel;
  final Portal? _portal;
  final _viewStyleNotifier = ValueNotifier<BasemapGalleryViewStyle>(
    BasemapGalleryViewStyle.automatic,
  );

  // The list of basemap items in the gallery.
  final _gallery = _BasemapGalleryNotifyingList<BasemapGalleryItem>();
  final _isFetchingBasemapsNotifier = ValueNotifier<bool>(false);
  final _fetchBasemapsErrorNotifier = ValueNotifier<Object?>(null);

  final _spatialReferenceMismatchErrorNotifier =
      ValueNotifier<_SpatialReferenceMismatchError?>(null);

  final _currentBasemapNotifier = ValueNotifier<BasemapGalleryItem?>(null);

  bool _isDisposed = false;

  late final Listenable _galleryListenable = Listenable.merge(<Listenable>[
    _gallery,
    _isFetchingBasemapsNotifier,
    _fetchBasemapsErrorNotifier,
    _viewStyleNotifier,
    _currentBasemapNotifier,
  ]);

  /// The associated [GeoModel]. This is either an [ArcGISMap] or [ArcGISScene].
  /// Associate a geo model with the [BasemapGalleryController] to automatically apply the selected basemap to the map or scene.
  ///
  /// If the geo model is not loaded when set, it will be loaded by the [BasemapGalleryController].
  GeoModel? get geoModel => _geoModel;

  set geoModel(GeoModel? value) {
    _geoModel = value;
    _initFromGeoModel();
  }

  /// The portal used to populate the [gallery], if provided in the constructor.
  Portal? get portal => _portal;

  /// Called after a basemap selection is applied.
  ValueChanged<Basemap>? onCurrentBasemapChanged;

  /// The basemap that is currently applied on the associated [GeoModel].
  Basemap? get currentBasemap => _currentBasemapNotifier.value?.basemap;

  BasemapGalleryItem? get _currentBasemapItem => _currentBasemapNotifier.value;

  /// The list of basemap gallery items associated with this [BasemapGalleryController].
  ///
  /// When the controller is attached to a [BasemapGallery] widget, items added or removed from this list will update the visible gallery.
  List<BasemapGalleryItem> get gallery => _gallery;

  bool get _isFetchingBasemaps => _isFetchingBasemapsNotifier.value;

  /// The current view style for the basemap gallery.
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

    onCurrentBasemapChanged?.call(item.basemap);
  }

  /// Disposes resources.
  void dispose() {
    _isDisposed = true;

    final galleryItems = List<BasemapGalleryItem>.from(_gallery);
    final currentItem = _currentBasemapItem;
    _disposeItems(galleryItems);
    if (currentItem != null && !galleryItems.contains(currentItem)) {
      currentItem.dispose();
    }

    _viewStyleNotifier.dispose();
    _gallery.dispose();
    _isFetchingBasemapsNotifier.dispose();
    _fetchBasemapsErrorNotifier.dispose();
    _currentBasemapNotifier.dispose();
    _spatialReferenceMismatchErrorNotifier.dispose();
  }

  void _replaceGalleryItems(Iterable<BasemapGalleryItem> items) {
    final newItems = items is List<BasemapGalleryItem>
        ? items
        : items.toList(growable: false);
    final previousItems = List<BasemapGalleryItem>.from(_gallery);

    _gallery.replaceAll(newItems);

    for (final item in previousItems) {
      if (!newItems.contains(item) && !identical(item, _currentBasemapItem)) {
        item.dispose();
      }
    }
  }

  void _clearGalleryItems() {
    if (_gallery.isEmpty) return;

    final previousItems = List<BasemapGalleryItem>.from(_gallery);
    _gallery.clear();
    _disposeItems(previousItems);
  }

  void _disposeItems(Iterable<BasemapGalleryItem> items) {
    for (final item in items) {
      if (identical(item, _currentBasemapItem)) continue;
      item.dispose();
    }
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
    if (_isDisposed) return;

    final p = _portal;
    if (p == null) {
      if (_isDisposed) return;
      _clearGalleryItems();
      return;
    }

    if (_isDisposed) return;
    _isFetchingBasemapsNotifier.value = true;
    _fetchBasemapsErrorNotifier.value = null;

    try {
      if (p.loadStatus == LoadStatus.notLoaded) {
        await p.load();
      }
      final basemaps = await p.basemaps();
      if (_isDisposed) return;
      _replaceGalleryItems(basemaps.map((b) => BasemapGalleryItem(basemap: b)));
    } on Object catch (e) {
      if (_isDisposed) return;
      _fetchBasemapsErrorNotifier.value = e;
      _clearGalleryItems();
    } finally {
      if (!_isDisposed) {
        _isFetchingBasemapsNotifier.value = false;
      }
    }
  }

  Future<void> _populateDefaultBasemaps() async {
    if (_isDisposed) return;

    _isFetchingBasemapsNotifier.value = true;
    _fetchBasemapsErrorNotifier.value = null;
    _clearGalleryItems();

    // Load developer basemaps from ArcGIS Online by default (API-key metered basemaps).
    final portal = Portal.arcGISOnline();

    try {
      if (portal.loadStatus == LoadStatus.notLoaded) {
        await portal.load();
      }
      final basemaps = await portal.developerBasemaps();
      if (_isDisposed) return;
      _replaceGalleryItems(basemaps.map((b) => BasemapGalleryItem(basemap: b)));
    } on Object catch (e) {
      if (_isDisposed) return;
      _fetchBasemapsErrorNotifier.value = e;
      _clearGalleryItems();
    } finally {
      if (!_isDisposed) {
        _isFetchingBasemapsNotifier.value = false;
      }
    }
  }
}

/// BasemapGallery-specific list that notifies listeners when it changes.
final class _BasemapGalleryNotifyingList<E> extends ChangeNotifier
    with ListMixin<E> {
  final List<E> _inner = <E>[];

  bool _disposed = false;

  int _mutationDepth = 0;
  bool _notifyPending = false;

  T _batch<T>(T Function() fn) {
    if (_disposed) {
      return fn();
    }

    _mutationDepth++;
    try {
      return fn();
    } finally {
      _mutationDepth--;

      if (_mutationDepth == 0 && _notifyPending && !_disposed) {
        _notifyPending = false;
        notifyListeners();
      }
    }
  }

  void _changed() {
    if (_disposed) return;
    if (_mutationDepth > 0) {
      _notifyPending = true;
      return;
    }
    notifyListeners();
  }

  void _mutate(void Function() fn) {
    _batch<void>(() {
      _notifyPending = true;
      fn();
    });
  }

  T _mutateReturn<T>(T Function() fn) {
    return _batch<T>(() {
      _notifyPending = true;
      return fn();
    });
  }

  void replaceAll(Iterable<E> items) {
    _mutate(() {
      _inner
        ..clear()
        ..addAll(items);
    });
  }

  @override
  int get length => _inner.length;

  @override
  set length(int newLength) {
    if (_inner.length == newLength) return;
    _inner.length = newLength;
    _changed();
  }

  @override
  E operator [](int index) => _inner[index];

  @override
  void operator []=(int index, E value) {
    _inner[index] = value;
    _changed();
  }

  @override
  void add(E value) => _mutate(() => _inner.add(value));

  @override
  void addAll(Iterable<E> iterable) {
    final previousLength = _inner.length;
    _inner.addAll(iterable);
    if (_inner.length != previousLength) {
      _changed();
    }
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    final items = iterable is List<E> ? iterable : iterable.toList();
    if (items.isEmpty) {
      _inner.insertAll(index, items);
      return;
    }
    _mutate(() => _inner.insertAll(index, items));
  }

  @override
  void setAll(int index, Iterable<E> iterable) {
    final items = iterable is List<E> ? iterable : iterable.toList();
    if (items.isEmpty) {
      _inner.setAll(index, items);
      return;
    }
    _mutate(() => _inner.setAll(index, items));
  }

  @override
  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    if (start == end) {
      _inner.setRange(start, end, iterable, skipCount);
      return;
    }
    _mutate(() => _inner.setRange(start, end, iterable, skipCount));
  }

  @override
  void replaceRange(int start, int end, Iterable<E> replacements) {
    final items = replacements is List<E>
        ? replacements
        : replacements.toList();
    if (start == end && items.isEmpty) {
      _inner.replaceRange(start, end, items);
      return;
    }
    _mutate(() => _inner.replaceRange(start, end, items));
  }

  @override
  void fillRange(int start, int end, [E? fillValue]) {
    if (start == end) {
      _inner.fillRange(start, end, fillValue);
      return;
    }
    _mutate(() => _inner.fillRange(start, end, fillValue));
  }

  @override
  void removeRange(int start, int end) {
    if (start == end) {
      _inner.removeRange(start, end);
      return;
    }
    _mutate(() => _inner.removeRange(start, end));
  }

  @override
  void removeWhere(bool Function(E element) test) {
    final previousLength = _inner.length;
    _inner.removeWhere(test);
    if (_inner.length != previousLength) {
      _changed();
    }
  }

  @override
  void retainWhere(bool Function(E element) test) {
    final previousLength = _inner.length;
    _inner.retainWhere(test);
    if (_inner.length != previousLength) {
      _changed();
    }
  }

  @override
  void sort([int Function(E a, E b)? compare]) {
    _mutate(() => _inner.sort(compare));
  }

  @override
  void shuffle([math.Random? random]) {
    _mutate(() => _inner.shuffle(random));
  }

  @override
  void clear() {
    if (_inner.isEmpty) return;
    _inner.clear();
    _changed();
  }

  @override
  bool remove(Object? value) {
    final removed = _inner.remove(value);
    if (removed) {
      _changed();
    }
    return removed;
  }

  @override
  E removeAt(int index) => _mutateReturn(() => _inner.removeAt(index));

  @override
  void insert(int index, E element) =>
      _mutate(() => _inner.insert(index, element));

  @override
  E removeLast() => _mutateReturn(_inner.removeLast);

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
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
