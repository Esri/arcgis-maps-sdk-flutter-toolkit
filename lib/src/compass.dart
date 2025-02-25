part of '../arcgis_maps_toolkit.dart';

//fixme doc (here and constructor and properties)
/// Compass
class Compass extends StatefulWidget {
  const Compass({
    required this.controllerProvider,
    super.key,
    this.automaticallyHides = true,
    this.alignment = Alignment.topRight,
    this.padding = const EdgeInsets.all(10),
    this.icon,
  });

  final ArcGISMapViewController Function() controllerProvider;

  final bool automaticallyHides;

  final Alignment alignment;

  final EdgeInsets padding;

  final Widget? icon;

  @override
  State<Compass> createState() => _CompassState();
}

class _CompassState extends State<Compass> {
  late ArcGISMapViewController _controller;

  late StreamSubscription<double> _rotationSubscription;

  double _rotation = 0;

  late Widget _icon;

  @override
  void initState() {
    super.initState();

    _controller = widget.controllerProvider();

    _rotation = _controller.rotation;
    _rotationSubscription = _controller.onRotationChanged.listen((rotation) {
      setState(() => _rotation = rotation);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _icon =
        widget.icon ??
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: .5),
            border: Border.all(
              color: IconTheme.of(context).color ?? Colors.black,
              width: 2,
            ),
          ),
          child: const Icon(Icons.north, size: 30),
        );
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
            child: IconButton(
              onPressed:
                  () => _controller.setViewpointRotation(angleDegrees: 0),
              icon: _icon,
            ),
          ),
        ),
      ),
    );
  }
}
