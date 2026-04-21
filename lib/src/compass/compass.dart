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

/// A [Compass] (also known as a "north arrow") is a widget that visualizes the
/// current rotation of an [ArcGISMapView], [ArcGISSceneView], or [ArcGISLocalSceneView].
///
/// # Overview
///
/// ## Features
/// * Automatically hides when the rotation is zero / oriented North.
/// * Can be configured to be always visible.
/// * Will reset the map/scene rotation to North when tapped on.
///
/// ## Usage
/// A [Compass] is generally placed in a [Stack] on top of an [ArcGISMapView], [ArcGISSceneView], or [ArcGISLocalSceneView].
/// The compass must be provided the same [ArcGISMapViewController], [ArcGISSceneViewController], or [ArcGISLocalSceneViewController] as the corresponding map view, scene view, or local scene view.
/// ```dart
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: Stack(
///         children: [
///           ArcGISMapView(
///             controllerProvider: controllerProvider,
///            ),
///           Compass(
///             controllerProvider: controllerProvider,
///            ),
///          ],
///        ),
///      );
///    }
/// ```
///
class Compass extends StatefulWidget {
  /// Create a Compass widget.
  const Compass({
    required this.controllerProvider,
    super.key,
    this.automaticallyHides = true,
    this.alignment = Alignment.topRight,
    this.padding = const EdgeInsets.all(10),
    this.size = 50,
    this.iconBuilder,
  });

  /// A function that provides a [GeoViewController] to listen to and
  /// control. This should return the same controller that is provided to the
  /// corresponding [ArcGISMapView], [ArcGISSceneView], or [ArcGISLocalSceneView].
  final GeoViewController Function() controllerProvider;

  /// Whether the compass should automatically hide when the map is oriented
  /// north. Defaults to `true`. If set to `false`, the compass will always be visible.
  final bool automaticallyHides;

  /// The alignment of the compass within the parent widget. Defaults to [Alignment.topRight]. The compass should generally be placed
  /// in a [Stack] on top of the corresponding [ArcGISMapView], [ArcGISSceneView], or [ArcGISLocalSceneView].
  final Alignment alignment;

  /// The padding around the compass. Defaults to 10 pixels on all sides.
  final EdgeInsets padding;

  /// The width and height of the compass icon in pixels. Defaults to 50 pixels.
  final double size;

  /// A function to build the compass icon. If not provided, a default compass icon will be used. Provide a function
  /// to customize the icon. The returned icon must be a [Widget] with
  /// width and height of `size` and some element rotated to `angleRadians` to indicate north.
  final Widget Function(BuildContext context, double size, double angleRadians)?
  iconBuilder;

  @override
  State<Compass> createState() => _CompassState();
}

class _CompassState extends State<Compass> {
  late GeoViewController _controller;

  StreamSubscription<double>? _rotationSubscription;
  StreamSubscription<void>? _viewpointSubscription;

  var _angleDegrees = 0.0;

  late Widget Function(BuildContext context, double size, double angleRadians)
  _iconBuilder;

  static double rotationToAngle(double rotation) => rotation * -math.pi / 180;

  @override
  void initState() {
    super.initState();

    _controller = widget.controllerProvider();

    switch (_controller) {
      case final ArcGISMapViewController controller:
        _angleDegrees = controller.rotation;
        _rotationSubscription = controller.onRotationChanged.listen((rotation) {
          setState(() => _angleDegrees = rotation);
        });
      case final ArcGISSceneViewController controller:
        _angleDegrees = controller.getCurrentViewpointCamera().heading;
        _viewpointSubscription = controller.onViewpointChanged.listen((_) {
          final heading = controller.getCurrentViewpointCamera().heading;
          if (heading != _angleDegrees) {
            setState(() => _angleDegrees = heading);
          }
        });
      case final ArcGISLocalSceneViewController controller:
        _angleDegrees = controller.getCurrentViewpointCamera().heading;
        _viewpointSubscription = controller.onViewpointChanged.listen((_) {
          final heading = controller.getCurrentViewpointCamera().heading;
          if (heading != _angleDegrees) {
            setState(() => _angleDegrees = heading);
          }
        });
    }

    _iconBuilder = widget.iconBuilder ?? defaultIconBuilder;
  }

  @override
  void dispose() {
    _rotationSubscription?.cancel();
    _rotationSubscription = null;
    _viewpointSubscription?.cancel();
    _viewpointSubscription = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !widget.automaticallyHides || _angleDegrees != 0,
      child: Align(
        alignment: widget.alignment,
        child: Padding(
          padding: widget.padding,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: onPressed,
            icon: _iconBuilder(
              context,
              widget.size,
              rotationToAngle(_angleDegrees),
            ),
          ),
        ),
      ),
    );
  }

  void onPressed() {
    switch (_controller) {
      case final ArcGISMapViewController controller:
        controller.setViewpointRotation(angleDegrees: 0);
      case final ArcGISSceneViewController controller:
        final currentCamera = controller.getCurrentViewpointCamera();
        controller.setViewpointCameraAnimated(
          camera: currentCamera.rotateTo(
            heading: 0,
            pitch: currentCamera.pitch,
            roll: currentCamera.roll,
          ),
        );
      case final ArcGISLocalSceneViewController controller:
        final currentCamera = controller.getCurrentViewpointCamera();
        controller.setViewpointCameraAnimated(
          camera: currentCamera.rotateTo(
            heading: 0,
            pitch: currentCamera.pitch,
            roll: currentCamera.roll,
          ),
        );
    }
  }

  Widget defaultIconBuilder(
    BuildContext context,
    double size,
    double angleRadians,
  ) {
    return CustomPaint(
      foregroundPainter: _CompassNeedlePainter(angleRadians),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color.fromARGB(192, 228, 240, 244),
          border: Border.all(
            color: const Color.fromARGB(255, 127, 127, 127),
            width: 1.25,
          ),
        ),
      ),
    );
  }
}
