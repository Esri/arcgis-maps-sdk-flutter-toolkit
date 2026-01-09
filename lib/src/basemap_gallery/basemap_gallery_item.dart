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

/// An element in a basemap gallery.
///
/// Fallback rules:
/// - If `thumbnail`/`tooltip` overrides are provided and valid, they are used.
/// - Otherwise, fall back to the basemap's associated [Item] (if present).
final class BasemapGalleryItem {
  /// Creates a [BasemapGalleryItem] with a [Basemap].
  ///
  /// If the [Basemap] has an associated [Item] with a thumbnail and
  /// description, they are used for [thumbnail] and [tooltip].
  BasemapGalleryItem({required Basemap basemap})
    : _basemap = basemap,
      _thumbnailOverride = null,
      _tooltipOverride = null {
    _recomputeDerivedFields();
    unawaited(_loadBasemapAndThumbnailIfNeeded());
  }

  /// Creates a [BasemapGalleryItem] with optional thumbnail and tooltip
  /// overrides.
  ///
  /// If [thumbnail] or [tooltip] are not provided (or are empty for [tooltip]),
  /// values from the basemap's associated [Item] are used as fallbacks.
  BasemapGalleryItem.withOverrides(
    Basemap basemap, {
    LoadableImage? thumbnail,
    String? tooltip,
  }) : _basemap = basemap,
       _thumbnailOverride = thumbnail,
       _tooltipOverride = tooltip {
    _recomputeDerivedFields();
    unawaited(_loadBasemapAndThumbnailIfNeeded());
  }

  final Basemap _basemap;

  final LoadableImage? _thumbnailOverride;
  final String? _tooltipOverride;

  final _nameNotifier = ValueNotifier<String>('');
  final _thumbnailNotifier = ValueNotifier<LoadableImage?>(null);
  final _tooltipNotifier = ValueNotifier<String?>(null);
  final _isBasemapLoadingNotifier = ValueNotifier<bool>(true);
  final _loadBasemapErrorNotifier = ValueNotifier<Object?>(null);
  final _spatialReferenceNotifier = ValueNotifier<SpatialReference?>(null);
  final _spatialReferenceStatusNotifier =
      ValueNotifier<BasemapGalleryItemSpatialReferenceStatus>(
        BasemapGalleryItemSpatialReferenceStatus.unknown,
      );

  late final Listenable _tileListenable = Listenable.merge(<Listenable>[
    _nameNotifier,
    _thumbnailNotifier,
    _tooltipNotifier,
    _isBasemapLoadingNotifier,
    _loadBasemapErrorNotifier,
    _spatialReferenceStatusNotifier,
  ]);

  /// The basemap for this gallery item.
  Basemap get basemap => _basemap;

  /// The name of this basemap.
  String get name => _nameNotifier.value;

  /// The thumbnail to display for this gallery item.
  LoadableImage? get thumbnail => _thumbnailNotifier.value;

  /// The tooltip to display for this gallery item.
  String? get tooltip => _tooltipNotifier.value;

  bool get _isBasemapLoading => _isBasemapLoadingNotifier.value;

  Object? get _loadBasemapError => _loadBasemapErrorNotifier.value;

  SpatialReference? get _spatialReference => _spatialReferenceNotifier.value;

  BasemapGalleryItemSpatialReferenceStatus get _spatialReferenceStatus =>
      _spatialReferenceStatusNotifier.value;

  bool get _hasError =>
      _loadBasemapErrorNotifier.value != null ||
      _spatialReferenceStatusNotifier.value ==
          BasemapGalleryItemSpatialReferenceStatus.noMatch;

  Future<void> _loadBasemapAndThumbnailIfNeeded() async {
    // If the basemap is already loaded, just ensure derived properties are
    // consistent.
    if (_basemap.loadStatus == LoadStatus.loaded) {
      _isBasemapLoadingNotifier.value = false;
      _recomputeDerivedFields();
      return;
    }

    _isBasemapLoadingNotifier.value = true;
    _loadBasemapErrorNotifier.value = null;

    String? error;
    try {
      await _basemap.load();

      // If we have a thumbnail (override or from the basemap's item), load it.
      final thumb = _thumbnailNotifier.value;
      if (thumb != null && thumb.loadStatus != LoadStatus.loaded) {
        await thumb.load();
      }
    } on ArcGISException {
      error = 'The basemap failed to load for an unknown reason.';
    }

    _recomputeDerivedFields();
    _loadBasemapErrorNotifier.value = error;
    _isBasemapLoadingNotifier.value = false;
  }

  Future<void> _updateSpatialReferenceStatus(
    SpatialReference? referenceSpatialReference,
  ) async {
    // Only compute status for loaded basemaps.
    if (_basemap.loadStatus != LoadStatus.loaded) return;

    if (_spatialReferenceNotifier.value == null) {
      _isBasemapLoadingNotifier.value = true;
      try {
        final firstLayer = _basemap.baseLayers.isNotEmpty
            ? _basemap.baseLayers.first
            : null;
        if (firstLayer != null && firstLayer.loadStatus != LoadStatus.loaded) {
          await firstLayer.load();
        }

        _spatialReferenceNotifier.value = firstLayer?.spatialReference;
      } on Object {
        _spatialReferenceNotifier.value = null;
      }
    }

    if (referenceSpatialReference == null) {
      _spatialReferenceStatusNotifier.value =
          BasemapGalleryItemSpatialReferenceStatus.unknown;
    } else if (_spatialReferenceNotifier.value == referenceSpatialReference) {
      _spatialReferenceStatusNotifier.value =
          BasemapGalleryItemSpatialReferenceStatus.match;
    } else {
      _spatialReferenceStatusNotifier.value =
          BasemapGalleryItemSpatialReferenceStatus.noMatch;
    }

    _isBasemapLoadingNotifier.value = false;
  }

  void _recomputeDerivedFields() {
    final item = _basemap.item;

    final overrideTooltip = _tooltipOverride;
    final tooltipFromItem = item?.description;

    _tooltipNotifier.value =
        (overrideTooltip != null && overrideTooltip.isNotEmpty)
        ? overrideTooltip
        : (tooltipFromItem != null && tooltipFromItem.isNotEmpty
              ? tooltipFromItem
              : null);

    _thumbnailNotifier.value = _thumbnailOverride ?? item?.thumbnail;

    final basemapName = _basemap.name;
    final itemTitle = item?.title;
    final itemName = item?.name;

    _nameNotifier.value = basemapName.isNotEmpty
        ? basemapName
        : (itemTitle != null && itemTitle.isNotEmpty)
        ? itemTitle
        : (itemName != null && itemName.isNotEmpty)
        ? itemName
        : 'Untitled Basemap';
  }

  void dispose() {
    _nameNotifier.dispose();
    _thumbnailNotifier.dispose();
    _tooltipNotifier.dispose();
    _isBasemapLoadingNotifier.dispose();
    _loadBasemapErrorNotifier.dispose();
    _spatialReferenceNotifier.dispose();
    _spatialReferenceStatusNotifier.dispose();
  }

  @override
  String toString() => 'BasemapGalleryItem(name: $name)';
}

/// The status of a basemap's spatial reference in relation to a reference
/// spatial reference.
enum BasemapGalleryItemSpatialReferenceStatus {
  /// Unknown because spatial references are not available yet.
  unknown,

  /// Basemap spatial reference matches the reference.
  match,

  /// Basemap spatial reference does not match the reference.
  noMatch,
}
