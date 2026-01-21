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

/// The [BasemapGallery] is a widget that displays a collection of basemaps from ArcGIS Online,
/// a user-defined portal, or an array of [BasemapGalleryItem] objects.
///
/// # Overview
/// When a new [Basemap] is selected from the [BaemapGallery] and a [GeoModel] ([ArcGISMap]/[ArcGISScene]) was provided
/// when the basemap gallery was created, the basemap of the map/scene is replaced with the
/// basemap in the gallery.
///
/// # Features
/// * Displays a name and thumbnail for each basemap.
/// * Can be configured to use a list or grid layout.
/// * Displays basemaps from a portal or a custom collection. If neither a custom portal or array of basemaps is provided,
/// the list of basemaps will be loaded from ArcGIS Online.
/// * If the connected geo model is an [ArcGISScene], it also fetches [Portal.basemaps3D] and overlays a "3D" badge when a basemap contains an
/// [ArcGISSceneLayer] in its base layers.
/// * If a map/scene is provided to the [BasemapGallery], selecting an item in the gallery will set that basemap on the map/scene.
/// * Selecting a basemap with a spatial reference that does not match that of the geo model will display an error.
/// It will also display an error if a provided basemap cannot be loaded.
///

///
/// ## Usage
/// When constructing a [BasemapGallery] widget, provide a [BasemapGalleryController].
/// The basemaps shown in the gallery are provided by the controller (defaults, a portal, or custom items), and the current selection is tracked by the controller.
/// The [BasemapGalleryController] should be disposed of when no longer required.
/// Provide an optional [GeoModel] to the controller to link it up the [BasemapGallery] and automatically update the basemap shown in the view.
///
/// Display the [BasemapGallery] contents in a widget, such as a [Dialog], a [Drawer], or another sized widget in the widget tree such as a [Container].
/// The visibility of the basemap gallery can be controlled within the application. See our example implementations for more information.
///
/// Example construction of a [BasemapGallery] and [BasemapGalleryController] using an [ArcGISMap] with default basemaps from ArcGIS Online.
///
/// ```dart
/// late final BasemapGalleryController _basemapGalleryController;
/// late final ArcGISMap _map;
///
/// @override
/// void initState() {
///   super.initState();
///   _map = ArcGISMap.withBasemapStyle(BasemapStyle.arcGISTopographic);
///   _basemapGalleryController = BasemapGalleryController(geoModel: _map);
/// }
///
/// @override
/// void dispose() {
///    _basemapGalleryController.dispose();
///    super.dispose();
/// }
///
/// @override
/// Widget build(BuildContext context) {
///   return BasemapGallery(
///     controller: _basemapGalleryController,
///   );
/// }
///
/// ```
final class BasemapGallery extends StatefulWidget {
  /// Creates a [BasemapGallery] widget.
  const BasemapGallery({required this.controller, super.key});

  /// The controller for the basemap gallery which controls the state and behavior of the associated [BasemapGallery].
  final BasemapGalleryController controller;

  /// Default outer padding.
  static const EdgeInsetsGeometry _padding = EdgeInsets.all(8);

  /// Default minimum grid tile width.
  static const double _gridMinTileWidth = 80;

  /// Default grid tile spacing.
  static const double _gridSpacing = 8;

  @override
  State<BasemapGallery> createState() => _BasemapGalleryState();
}

final class _BasemapGalleryState extends State<BasemapGallery> {
  @override
  void initState() {
    super.initState();
    widget.controller._spatialReferenceMismatchErrorNotifier.addListener(
      _onSpatialReferenceMismatchErrorChanged,
    );
  }

  @override
  void didUpdateWidget(covariant BasemapGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller._spatialReferenceMismatchErrorNotifier
          .removeListener(_onSpatialReferenceMismatchErrorChanged);
      widget.controller._spatialReferenceMismatchErrorNotifier.addListener(
        _onSpatialReferenceMismatchErrorChanged,
      );
    }
  }

  @override
  void dispose() {
    widget.controller._spatialReferenceMismatchErrorNotifier.removeListener(
      _onSpatialReferenceMismatchErrorChanged,
    );
    super.dispose();
  }

  Future<void> _onSpatialReferenceMismatchErrorChanged() async {
    if (!mounted) return;
    final error =
        widget.controller._spatialReferenceMismatchErrorNotifier.value;
    if (error == null) return;

    final message = _spatialReferenceMismatchMessage(error);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Spatial reference mismatch.'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _spatialReferenceMismatchMessage(
    _SpatialReferenceMismatchError error,
  ) {
    final basemapSr = error.basemapSpatialReference;
    final geoModelSr = error.geoModelSpatialReference;

    if (basemapSr == null && geoModelSr != null) {
      return 'The basemap does not have a spatial reference.';
    }
    if (basemapSr != null && geoModelSr == null) {
      return 'The map does not have a spatial reference.';
    }
    if (basemapSr == null && geoModelSr == null) {
      return 'The spatial references could not be determined.';
    }

    return 'The basemap has a spatial reference that is incompatible with the map.';
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return AnimatedBuilder(
      animation: controller._galleryListenable,
      builder: (context, _) {
        if (controller._isFetchingBasemaps && controller.gallery.isEmpty) {
          return const Padding(
            padding: BasemapGallery._padding,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return Padding(
          padding: BasemapGallery._padding,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final style = controller.viewStyle;

              final useGrid = switch (style) {
                BasemapGalleryViewStyle.grid => true,
                BasemapGalleryViewStyle.list => false,
              };

              if (useGrid) {
                return _buildGrid(constraints.maxWidth);
              }
              return _buildList();
            },
          ),
        );
      },
    );
  }

  Widget _buildGrid(double width) {
    final items = widget.controller.gallery;
    const spacing = BasemapGallery._gridSpacing;

    // Calculate number of columns based on available width.
    final crossAxisCount =
        (width / (BasemapGallery._gridMinTileWidth + spacing)).floor().clamp(
          1,
          6,
        );

    return GridView.builder(
      primary: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        // We use a taller tile so the thumbnail has more vertical space.
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _BasemapTile(
          key: ValueKey(item._basemap),
          item: item,
          isSelected: _isSelected(item),
          onTap: () => unawaited(_select(item)),
          dense: false,
        );
      },
    );
  }

  Widget _buildList() {
    final items = widget.controller.gallery;

    return ListView.separated(
      primary: true,
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return _BasemapTile(
          key: ValueKey(item._basemap),
          item: item,
          isSelected: _isSelected(item),
          onTap: () => unawaited(_select(item)),
          dense: true,
        );
      },
    );
  }

  bool _isSelected(BasemapGalleryItem item) {
    final current = widget.controller.currentBasemap;
    if (current == null) return false;
    return identical(current, item.basemap) || current.name == item.name;
  }

  Future<void> _select(BasemapGalleryItem item) async {
    if (item._isBasemapLoading) return;

    if (item._loadBasemapError != null) {
      unawaited(
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error loading basemap.'),
            content: Text(item._loadBasemapError.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      );
      return;
    }

    await widget.controller._select(item);
  }
}

/// Tile for a basemap item; shows thumbnail, name, selection outline, and load/error state.
final class _BasemapTile extends StatelessWidget {
  /// Creates a tile for the basemap gallery item. Tap is disabled while loading.
  const _BasemapTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.dense,
    super.key,
  });

  /// Gallery item backing this tile.
  final BasemapGalleryItem item;

  /// Whether this item is currently selected.
  final bool isSelected;

  /// Called when the tile is tapped (if enabled).
  final VoidCallback onTap;

  /// Compact list style when `true`; grid style when `false`.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: item._tileListenable,
      builder: (context, _) {
        final isEnabled = !item._isBasemapLoading;
        final show3DBadge = item.basemap._is3D;

        final tile = InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: isEnabled ? onTap : null,
          child: dense
              ? _buildListContent(context, show3DBadge: show3DBadge)
              : _buildGridContent(context, show3DBadge: show3DBadge),
        );

        return Semantics(
          button: true,
          selected: isSelected,
          enabled: isEnabled,
          label: item.name,
          child: Tooltip(
            message: item.name,
            waitDuration: const Duration(milliseconds: 500),
            child: tile,
          ),
        );
      },
    );
  }

  Widget _buildGridContent(BuildContext context, {required bool show3DBadge}) {
    const titleAreaHeight = 50.0;
    final style = Theme.of(context).textTheme.bodySmall;

    return LayoutBuilder(
      builder: (context, constraints) {
        // If the tile is extremely small (e.g., a forced grid in a very narrow
        // container), we don't render the fixed-height title area.
        final showTitle = constraints.maxHeight >= titleAreaHeight + 24;
        if (!showTitle) {
          return _buildThumbnail(
            context,
            fit: BoxFit.cover,
            show3DBadge: show3DBadge,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildThumbnail(
                context,
                fit: BoxFit.cover,
                show3DBadge: show3DBadge,
              ),
            ),
            SizedBox(
              height: titleAreaHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    item.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListContent(BuildContext context, {required bool show3DBadge}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        const minThumbWidth = 40.0;
        const maxThumbWidth = 96.0;
        const spacerWidth = 12.0;
        const minHorizontalTextWidth = 80.0;
        const minWidthForTitle = 56.0;

        // Responsive thumbnail width for very narrow containers.
        final preferred = maxWidth * 0.45;
        final thumbWidth = preferred
            .clamp(minThumbWidth, maxThumbWidth)
            .clamp(0.0, maxWidth);

        final showSpacer = maxWidth >= thumbWidth + spacerWidth + 40;

        final availableTextWidth =
            maxWidth - thumbWidth - (showSpacer ? spacerWidth : 0);
        final useVerticalLayout =
            maxWidth < minThumbWidth + minHorizontalTextWidth;

        if (useVerticalLayout) {
          final showTitle = maxWidth >= minWidthForTitle;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: _buildThumbnail(
                  context,
                  fit: BoxFit.cover,
                  show3DBadge: show3DBadge,
                ),
              ),
              if (showTitle)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    item.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          );
        }

        // If we can render horizontally but the remaining width would be too
        // small for readable text, fall back to vertical layout.
        if (availableTextWidth < minHorizontalTextWidth) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: _buildThumbnail(
                  context,
                  fit: BoxFit.cover,
                  show3DBadge: show3DBadge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  item.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            SizedBox(
              width: thumbWidth,
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: _buildThumbnail(
                  context,
                  fit: BoxFit.cover,
                  show3DBadge: show3DBadge,
                ),
              ),
            ),
            if (showSpacer) const SizedBox(width: spacerWidth),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThumbnail(
    BuildContext context, {
    required BoxFit fit,
    required bool show3DBadge,
  }) {
    final base = _LoadableImageUtils.thumbnailOrPlaceholder(
      thumbnail: item.thumbnail,
      fit: fit,
    );

    final theme = Theme.of(context);
    final showSelectedOutline = isSelected && !item._hasError;

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        Stack(
          fit: StackFit.expand,
          children: [
            base,
            if (item._isBasemapLoading)
              const Center(
                child: SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            if (showSelectedOutline)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (item._hasError)
          Positioned(
            top: -4,
            right: -4,
            child: IgnorePointer(
              child: Icon(Icons.error, color: theme.colorScheme.error),
            ),
          ),
        if (show3DBadge)
          Positioned(
            top: 6,
            left: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  '3D',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

extension on Basemap {
  /// Whether this basemap supports 3D visualization.
  bool get _is3D => baseLayers.any((layer) => layer is ArcGISSceneLayer);
}
