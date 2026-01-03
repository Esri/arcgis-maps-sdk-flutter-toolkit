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

/// An element in a basemap gallery.
///
/// Fallback rules:
/// - If `thumbnail`/`tooltip` overrides are provided and valid, they are used.
/// - Otherwise, fall back to the basemap's associated [Item] (if present).
final class BasemapGalleryItem with ChangeNotifier {
  BasemapGalleryItem({required Basemap basemap})
    : _basemap = basemap,
      _thumbnailOverride = null,
      _tooltipOverride = null {
    _recomputeDerivedFields();
    unawaited(_loadBasemapAndThumbnailIfNeeded());
  }

  /// Construct with Basemap + overrides.
  ///
  /// If provided `thumbnail`/`tooltip` overrides are invalid, falls back to the
  /// basemap's associated [Item] (thumbnail/description).
  ///
  BasemapGalleryItem.withOverrides({
    required Basemap basemap,
    LoadableImage? thumbnail,
    String? tooltip,
  }) : _basemap = basemap,
       _thumbnailOverride = thumbnail,
       _tooltipOverride = tooltip {
    _recomputeDerivedFields();
    unawaited(_loadBasemapAndThumbnailIfNeeded());
  }

  Basemap _basemap;

  final LoadableImage? _thumbnailOverride;
  final String? _tooltipOverride;

  late LoadableImage? _resolvedThumbnail;
  late String? _resolvedTooltip;
  late String _resolvedName;

  bool _isBasemapLoading = true;
  Object? _loadBasemapError;

  SpatialReference? _spatialReference;
  BasemapGalleryItemSpatialReferenceStatus _spatialReferenceStatus =
      BasemapGalleryItemSpatialReferenceStatus.unknown;

  bool _nameWasExplicitlySet = false;

  /// The basemap this item represents.
  Basemap get basemap => _basemap;

  set basemap(Basemap value) {
    _basemap = value;
    _recomputeDerivedFields(preserveExplicitName: true);
    _isBasemapLoading = true;
    _loadBasemapError = null;
    _spatialReference = null;
    _spatialReferenceStatus = BasemapGalleryItemSpatialReferenceStatus.unknown;
    notifyListeners();
    unawaited(_loadBasemapAndThumbnailIfNeeded());
  }

  /// Name of this basemap.
  ///
  /// Defaults to `basemap.name`, then `basemap.item?.title`, then
  /// `basemap.item?.name`, and finally `"Untitled Basemap"`.
  ///
  String get name => _resolvedName;

  set name(String value) {
    _nameWasExplicitlySet = true;
    _resolvedName = value.trim().isEmpty ? 'Untitled Basemap' : value;
  }

  /// Thumbnail displayed in the gallery.
  LoadableImage? get thumbnail => _resolvedThumbnail;

  /// Tooltip used in the gallery.
  String? get tooltip => _resolvedTooltip;

  /// True while the basemap or its thumbnail/spatial reference are loading.
  bool get isBasemapLoading => _isBasemapLoading;

  /// Error generated while loading the basemap/thumbnail, if any.
  Object? get loadBasemapError => _loadBasemapError;

  /// Spatial reference of the basemap (derived from the first base layer).
  SpatialReference? get spatialReference => _spatialReference;

  /// Spatial reference status relative to a reference spatial reference.
  BasemapGalleryItemSpatialReferenceStatus get spatialReferenceStatus =>
      _spatialReferenceStatus;

  /// True when the item has a load error or spatial reference mismatch.
  bool get hasError =>
      _loadBasemapError != null ||
      _spatialReferenceStatus ==
          BasemapGalleryItemSpatialReferenceStatus.noMatch;

  Future<void> _loadBasemapAndThumbnailIfNeeded() async {
    // If the basemap is already loaded, just ensure derived properties are
    // consistent.
    if (_basemap.loadStatus == LoadStatus.loaded) {
      _isBasemapLoading = false;
      _recomputeDerivedFields(preserveExplicitName: true);
      notifyListeners();
      return;
    }

    _isBasemapLoading = true;
    _loadBasemapError = null;
    notifyListeners();

    String? error;
    try {
      await _basemap.load();

      // If we have a thumbnail (override or from the basemap's item), load it.
      final thumb = _resolvedThumbnail;
      if (thumb != null && thumb.loadStatus != LoadStatus.loaded) {
        await thumb.load();
      }
    } on ArcGISException {
      error = 'The basemap failed to load for an unknown reason.';
    }

    _recomputeDerivedFields(preserveExplicitName: true);
    _loadBasemapError = error;
    _isBasemapLoading = false;
    notifyListeners();
  }

  /// Updates [spatialReferenceStatus] by loading the first base layer and
  /// comparing its spatial reference to [referenceSpatialReference].
  Future<void> updateSpatialReferenceStatus(
    SpatialReference? referenceSpatialReference,
  ) async {
    // Only compute status for loaded basemaps.
    if (_basemap.loadStatus != LoadStatus.loaded) return;

    if (_spatialReference == null) {
      _isBasemapLoading = true;
      notifyListeners();
      try {
        final firstLayer = _basemap.baseLayers.isNotEmpty
            ? _basemap.baseLayers.first
            : null;
        if (firstLayer != null && firstLayer.loadStatus != LoadStatus.loaded) {
          await firstLayer.load();
        }
      } on Object {
        _spatialReference = null;
      }
    }

    _spatialReference = _basemap.baseLayers.isNotEmpty
        ? _basemap.baseLayers.first.spatialReference
        : null;

    if (referenceSpatialReference == null) {
      _spatialReferenceStatus =
          BasemapGalleryItemSpatialReferenceStatus.unknown;
    } else if (_spatialReference == referenceSpatialReference) {
      _spatialReferenceStatus = BasemapGalleryItemSpatialReferenceStatus.match;
    } else {
      _spatialReferenceStatus =
          BasemapGalleryItemSpatialReferenceStatus.noMatch;
    }

    _isBasemapLoading = false;
    notifyListeners();
  }

  void _recomputeDerivedFields({bool preserveExplicitName = false}) {
    final item = _basemap.item;

    final overrideTooltip = _tooltipOverride?.trim();
    final tooltipFromItem = item?.description.trim();

    _resolvedTooltip = (overrideTooltip != null && overrideTooltip.isNotEmpty)
        ? overrideTooltip
        : (tooltipFromItem != null && tooltipFromItem.isNotEmpty
              ? tooltipFromItem
              : null);

    _resolvedThumbnail = _thumbnailOverride ?? item?.thumbnail;

    if (!preserveExplicitName || !_nameWasExplicitlySet) {
      final basemapName = _basemap.name.trim();
      final itemTitle = item?.title.trim();
      final itemName = item?.name.trim();

      _resolvedName = basemapName.isNotEmpty
          ? basemapName
          : (itemTitle != null && itemTitle.isNotEmpty)
          ? itemTitle
          : (itemName != null && itemName.isNotEmpty)
          ? itemName
          : 'Untitled Basemap';
    }
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
