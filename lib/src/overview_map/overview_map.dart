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

///
class OverviewMap extends StatefulWidget {
  ///
  const OverviewMap({
    required this.controllerProvider,
    super.key,
    this.alignment = Alignment.topRight,
    this.padding = const EdgeInsets.all(10),
    this.containerBuilder,
    this.extentSymbol,
  });

  /// A function that provides an [ArcGISMapViewController] to listen to and
  /// control.
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

  ///
  final Widget Function(BuildContext context, Widget child)? containerBuilder;

  ///
  final SimpleLineSymbol? extentSymbol;

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
    _overviewController.arcGISMap = ArcGISMap.withBasemapStyle(
      BasemapStyle.arcGISTopographic,
    );
    _overviewController.isAttributionTextVisible = false;
    _overviewController.interactionOptions.enabled = false;

    _viewpointChangedSubscription = _controller.onViewpointChanged.listen(
      onViewpointChanged,
    );
  }

  void onViewpointChanged(_) {
    //fixme
    final viewpoint = _controller.getCurrentViewpoint(
      ViewpointType.boundingGeometry,
    );
    //fixme scale

    _extentGraphic.geometry = _controller.visibleArea;
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
