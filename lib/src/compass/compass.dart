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

/// A `Compass` (also known as a "north arrow") is a widget that visualizes the
/// current rotation of the map and allows the user to reset the rotation to
/// north by tapping on it.
class Compass extends StatefulWidget {
  /// Create a Compass widget.
  const Compass({
    required this.controllerProvider,
    super.key,
    this.automaticallyHides = true,
    this.alignment = Alignment.topRight,
    this.padding = const EdgeInsets.all(10),
    this.iconBuilder,
  });

  /// A function that provides an [GeoViewController] to listen to and
  /// control.
  ///
  /// This should return the same controller that is provided to the
  /// corresponding [ArcGISMapView] or [ArcGISSceneView].
  final GeoViewController Function() controllerProvider;

  /// Whether the compass should automatically hide when the map is oriented
  /// north.
  ///
  /// Defaults to `true`. If set to `false`, the compass will always be visible.
  final bool automaticallyHides;

  /// The alignment of the compass within the parent widget.
  ///
  /// Defaults to [Alignment.topRight]. The compass should generally be placed
  /// in a [Stack] on top of the corresponding [ArcGISMapView] or [ArcGISSceneView].
  final Alignment alignment;

  /// The padding around the compass.
  ///
  /// Defaults to 10 pixels on all sides.
  final EdgeInsets padding;

  /// A function to build the compass icon.
  ///
  /// If not provided, a default compass icon will be used. Provide a function
  /// to customize the icon. The returned icon should be a [Widget] with some
  /// element rotated to `angleRadians` to indicate north.
  final Widget Function(BuildContext context, double angleRadians)? iconBuilder;

  @override
  State<Compass> createState() => _CompassState();
}

class _CompassState extends State<Compass> {
  late GeoViewController _controller;

  StreamSubscription<double>? _rotationSubscription;
  StreamSubscription<void>? _viewpointSubscription;

  var _angleDegrees = 0.0;

  late Widget Function(BuildContext context, double angleRadians) _iconBuilder;

  static double rotationToAngle(double rotation) => rotation * -math.pi / 180;

  @override
  void initState() {
    super.initState();

    _controller = widget.controllerProvider();

    if (_controller is ArcGISMapViewController) {
      final controller = _controller as ArcGISMapViewController;
      _angleDegrees = controller.rotation;
      _rotationSubscription = controller.onRotationChanged.listen((rotation) {
        setState(() => _angleDegrees = rotation);
      });
    } else {
      final controller = _controller as ArcGISSceneViewController;
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
    _viewpointSubscription?.cancel();

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
            icon: _iconBuilder(context, rotationToAngle(_angleDegrees)),
          ),
        ),
      ),
    );
  }

  void onPressed() {
    if (_controller is ArcGISMapViewController) {
      (_controller as ArcGISMapViewController).setViewpointRotation(
        angleDegrees: 0,
      );
    } else {
      final controller = _controller as ArcGISSceneViewController;
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

  Widget defaultIconBuilder(BuildContext context, double angleRadians) {
    return CustomPaint(
      foregroundPainter: CompassNeedlePainter(angleRadians),
      child: Container(
        width: 50,
        height: 50,
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
