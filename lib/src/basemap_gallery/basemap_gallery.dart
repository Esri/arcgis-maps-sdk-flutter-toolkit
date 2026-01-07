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

/// The [BasemapGallery] widget displays a gallery of basemap thumbnails.
///
/// # Overview
/// [BasemapGallery] is a UI component that lets a user browse a collection of
/// basemaps and apply a selection to a connected [GeoModel] (such as an
/// [ArcGISMap] or [ArcGISScene]) via a [BasemapGalleryController].
///
/// The basemaps shown in the gallery are provided by the controller (defaults,
/// a portal, or custom items), and the current selection is tracked by the
/// controller.
///
/// ## Features
/// * Displays basemaps as a grid, list, or automatically switches based on
///   available width.
/// * Shows selection state and exposes selection events via the controller.
///
/// ## Usage
/// Provide a [BasemapGalleryController] and place the gallery in your widget
/// tree.
///
/// ```dart
/// late final ArcGISMap _map;
/// late final BasemapGalleryController _controller;
///
/// @override
/// void initState() {
///   super.initState();
///   _map = ArcGISMap.withBasemapStyle(BasemapStyle.arcGISTopographic);
///   _controller = BasemapGalleryController(geoModel: _map);
/// }
///
/// @override
/// Widget build(BuildContext context) {
///   return BasemapGallery(controller: _controller);
/// }
/// ```
final class BasemapGallery extends StatefulWidget {
  /// Creates a [BasemapGallery] widget.
  const BasemapGallery({
    required this.controller,
    super.key,
    this.padding = const EdgeInsets.all(8),
    this.gridMinTileWidth = 120,
    this.gridSpacing = 8,
    this.scrollController,
    this.onItemSelected,
  });

  /// The controller driving this view.
  final BasemapGalleryController controller;

  /// Outer padding.
  final EdgeInsetsGeometry padding;

  /// Minimum width of a grid tile.
  final double gridMinTileWidth;

  /// Spacing between grid tiles.
  final double gridSpacing;

  /// Optional scroll controller.
  final ScrollController? scrollController;

  /// Optional callback invoked when an item is selected.
  final ValueChanged<BasemapGalleryItem>? onItemSelected;

  @override
  State<BasemapGallery> createState() => _BasemapGalleryState();
}

final class _BasemapGalleryState extends State<BasemapGallery> {
  @override
  void initState() {
    super.initState();
    widget.controller.spatialReferenceMismatchErrorNotifier.addListener(
      _onSpatialReferenceMismatchErrorChanged,
    );
  }

  @override
  void didUpdateWidget(covariant BasemapGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.spatialReferenceMismatchErrorNotifier.removeListener(
        _onSpatialReferenceMismatchErrorChanged,
      );
      widget.controller.spatialReferenceMismatchErrorNotifier.addListener(
        _onSpatialReferenceMismatchErrorChanged,
      );
    }
  }

  @override
  void dispose() {
    widget.controller.spatialReferenceMismatchErrorNotifier.removeListener(
      _onSpatialReferenceMismatchErrorChanged,
    );
    super.dispose();
  }

  Future<void> _onSpatialReferenceMismatchErrorChanged() async {
    if (!mounted) return;
    final error = widget.controller.spatialReferenceMismatchErrorNotifier.value;
    if (error == null) return;

    widget.controller.clearSpatialReferenceMismatchError();

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
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;

        if (controller.isFetchingBasemaps && controller.gallery.isEmpty) {
          return Padding(
            padding: widget.padding,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        return Padding(
          padding: widget.padding,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final style = controller.viewStyle;

              final useGrid = switch (style) {
                BasemapGalleryViewStyle.grid => true,
                BasemapGalleryViewStyle.list => false,
                BasemapGalleryViewStyle.automatic =>
                  constraints.maxWidth >=
                      widget.gridMinTileWidth * 2 + widget.gridSpacing,
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
    final spacing = widget.gridSpacing;

    // Calculate number of columns based on available width.
    final crossAxisCount = (width / (widget.gridMinTileWidth + spacing))
        .floor()
        .clamp(2, 6);

    return GridView.builder(
      controller: widget.scrollController,
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
          key: ValueKey(item.basemap),
          item: item,
          isSelected: _isSelected(item),
          onTap: () => _select(item),
          dense: false,
        );
      },
    );
  }

  Widget _buildList() {
    final items = widget.controller.gallery;

    return ListView.separated(
      controller: widget.scrollController,
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return _BasemapTile(
          key: ValueKey(item.basemap),
          item: item,
          isSelected: _isSelected(item),
          onTap: () => _select(item),
          dense: true,
        );
      },
    );
  }

  bool _isSelected(BasemapGalleryItem item) {
    final current = widget.controller.currentBasemap;
    if (current == null) return false;
    return identical(current.basemap, item.basemap) ||
        current.name == item.name;
  }

  void _select(BasemapGalleryItem item) {
    if (item.isBasemapLoading) return;

    if (item.loadBasemapError != null) {
      unawaited(
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error loading basemap.'),
            content: Text(item.loadBasemapError.toString()),
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

    unawaited(widget.controller.select(item));
    widget.onItemSelected?.call(item);
  }
}

final class _BasemapTile extends StatelessWidget {
  const _BasemapTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.dense,
    super.key,
  });

  final BasemapGalleryItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: item,
      builder: (context, _) {
        final isEnabled = !item.isBasemapLoading;

        final tile = InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: isEnabled ? onTap : null,
          child: dense
              ? _buildListContent(context)
              : _buildGridContent(context),
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

  Widget _buildGridContent(BuildContext context) {
    const titleAreaHeight = 50.0;
    final style = Theme.of(context).textTheme.bodySmall;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildThumbnail(context, fit: BoxFit.cover)),
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
  }

  Widget _buildListContent(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 96,
          height: 72,
          child: _buildThumbnail(context, fit: BoxFit.cover),
        ),
        const SizedBox(width: 12),
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
  }

  Widget _buildThumbnail(BuildContext context, {required BoxFit fit}) {
    final base = _LoadableImageUtils.thumbnailOrPlaceholder(
      thumbnail: item.thumbnail,
      fit: fit,
    );

    final theme = Theme.of(context);
    final showSelectedOutline = isSelected && !item.hasError;

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            base,
            if (item.isBasemapLoading)
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
        if (item.hasError)
          Positioned(
            top: -6,
            right: -6,
            child: Icon(Icons.error, color: theme.colorScheme.error),
          ),
      ],
    );
  }
}
