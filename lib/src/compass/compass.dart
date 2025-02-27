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
    this.icon,
  });

  /// A function that provides an [ArcGISMapViewController] to listen to and
  /// control.
  ///
  /// This should return the same controller that is provided to the
  /// corresponding [ArcGISMapView].
  final ArcGISMapViewController Function() controllerProvider;

  /// Whether the compass should automatically hide when the map is oriented
  /// north.
  ///
  /// Defaults to `true`. If set to `false`, the compass will always be visible.
  final bool automaticallyHides;

  /// The alignment of the compass within the parent widget.
  ///
  /// Defaults to [Alignment.topRight]. The compass should generally be placed
  /// in a [Stack] on top of the corresponding [ArcGISMapView].
  final Alignment alignment;

  /// The padding around the compass.
  ///
  /// Defaults to 10 pixels on all sides.
  final EdgeInsets padding;

  /// The icon to be used for the compass.
  ///
  /// If not provided, a default compass icon will be used. Provide any Widget
  /// to customize the icon, though generally with a circular shape and fixed
  /// size.
  final Widget? icon;

  @override
  State<Compass> createState() => _CompassState();
}

class _CompassState extends State<Compass> {
  late ArcGISMapViewController _controller;

  late StreamSubscription<double> _rotationSubscription;

  var _rotation = 0.0;

  late Widget _icon;

  @override
  void initState() {
    super.initState();

    _controller = widget.controllerProvider();

    _rotation = _controller.rotation;
    _rotationSubscription = _controller.onRotationChanged.listen((rotation) {
      setState(() => _rotation = rotation);
    });

    _icon = widget.icon ?? defaultIcon();
  }

  @override
  void dispose() {
    _rotationSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !widget.automaticallyHides || _rotation != 0,
      child: Align(
        alignment: widget.alignment,
        child: Padding(
          padding: widget.padding,
          child: Transform.rotate(
            angle: _rotation * -math.pi / 180,
            child: IconButton(onPressed: onPressed, icon: _icon),
          ),
        ),
      ),
    );
  }

  void onPressed() => _controller.setViewpointRotation(angleDegrees: 0);

  Widget defaultIcon() {
    return CustomPaint(
      foregroundPainter: NeedlePainter(),
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
