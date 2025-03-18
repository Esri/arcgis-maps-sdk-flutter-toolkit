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

/// A small "overview" (or "inset") map displaying a representation of the current
/// viewpoint of the target map. The current viewpoint will be represented by a
/// polygon displaying the visible area of the target map.
class OverviewMap extends StatefulWidget {
  /// Create an OverviewMap widget.
  const OverviewMap({
    required this.controllerProvider,
    super.key,
    this.alignment = Alignment.topRight,
    this.padding = const EdgeInsets.all(10),
    this.scaleFactor = 25,
    this.extentSymbol,
    this.map,
    this.containerBuilder,
  });

  /// A function that provides the [ArcGISMapViewController] of the target map.
  ///
  /// This should return the same controller that is provided to the
  /// corresponding [ArcGISMapView].
  final ArcGISMapViewController Function() controllerProvider;

  /// The alignment of the overview map within the parent widget.
  ///
  /// Defaults to [Alignment.topRight]. The overview map should generally be placed
  /// in a [Stack] on top of the corresponding [ArcGISMapView].
  final Alignment alignment;

  /// The padding around the overview map.
  ///
  /// Defaults to 10 pixels on all sides.
  final EdgeInsets padding;

  /// The amount to scale the overview map compared to the target map.
  ///
  /// Defaults to 25.
  final double scaleFactor;

  /// The symbol used to represent the current viewpoint.
  ///
  /// Defaults to a 1 pixel red outline.
  final SimpleLineSymbol? extentSymbol;

  /// The map to use as the overview map.
  ///
  /// Defaults to a map with the ArcGIS Topographic basemap style.
  final ArcGISMap? map;

  /// A function to build the container holding the overview map.
  ///
  /// If not provided, the overview map will be 150x100 pixels with a 1 pixel
  /// black border. Provide a function to return a customized container, such as
  /// having the desired size, border, opacity, etc. The returned [Widget] must
  /// include the provided `child`, which will be the overview map itself.
  final Widget Function(BuildContext context, Widget child)? containerBuilder;

  @override
  State<OverviewMap> createState() => _OverviewMapState();
}

class _OverviewMapState extends State<OverviewMap> {
  late ArcGISMapViewController _controller;

  final _overviewController = ArcGISMapView.createController();

  final _extentGraphic = Graphic();

  StreamSubscription<void>? _viewpointChangedSubscription;

  late Widget Function(BuildContext context, Widget child) _containerBuilder;

  @override
  void initState() {
    super.initState();

    _controller = widget.controllerProvider();

    _extentGraphic.symbol =
        widget.extentSymbol ?? SimpleLineSymbol(color: Colors.red);

    _overviewController.graphicsOverlays.add(
      GraphicsOverlay()..graphics.add(_extentGraphic),
    );

    _containerBuilder = widget.containerBuilder ?? defaultContainerBuilder;
  }

  @override
  void dispose() {
    _viewpointChangedSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: Padding(
        padding: widget.padding,
        child: _containerBuilder(
          context,
          ArcGISMapView(
            controllerProvider: () => _overviewController,
            onMapViewReady: onMapViewReady,
          ),
        ),
      ),
    );
  }

  void onMapViewReady() {
    _overviewController.arcGISMap =
        widget.map ??
        ArcGISMap.withBasemapStyle(BasemapStyle.arcGISTopographic);
    _overviewController.isAttributionTextVisible = false;
    _overviewController.interactionOptions.enabled = false;

    onViewpointChanged(null);
    _viewpointChangedSubscription = _controller.onViewpointChanged.listen(
      onViewpointChanged,
    );
  }

  void onViewpointChanged(_) {
    _extentGraphic.geometry = _controller.visibleArea;

    final viewpoint = _controller.getCurrentViewpoint(
      ViewpointType.centerAndScale,
    );
    if (viewpoint == null) return;

    _overviewController.setViewpoint(
      Viewpoint.fromCenter(
        viewpoint.targetGeometry as ArcGISPoint,
        scale: viewpoint.targetScale * widget.scaleFactor,
      ),
    );
  }

  Widget defaultContainerBuilder(BuildContext context, Widget child) {
    return Container(
      width: 150,
      height: 100,
      decoration: BoxDecoration(border: Border.all()),
      child: child,
    );
  }
}
