# Compass

## Usage

A `Compass` is generally placed in a `Stack` on top of an `ArcGISMapView`. The `Compass` must use the same `controllerProvider` as the `ArcGISMapView`.

Use `alignment` and `padding` to position the compass on the map. Set `automaticallyHides` to `false` to keep the compass visible even when the map is rotated to north (0 degrees). Set `iconBuilder` to provide your own `Widget` to represent the compass.

```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ArcGISMapView(
            controllerProvider: () => _mapViewController,
          ),
          Compass(
            controllerProvider: () => _mapViewController,
            automaticallyHides: false,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(40),
            iconBuilder:
                (context, angleRadians) => Transform.rotate(
                  angle: angleRadians,
                  child: Icon(
                    Icons.arrow_circle_up,
                    size: 80,
                    color: Colors.purple,
                  ),
                ),
          ),
        ],
      ),
    );
  }
```
