# Compass

## Usage

A `Compass` is generally placed in a `Stack` on top of an `ArcGISMapView` or an `ArcGISSceneView`. The `Compass` must provided the same `ArcGISMapViewController` or `ArcGISSceneViewController` as the `ArcGISMapView` or `ArcGISSceneView`.

Use `alignment` and `padding` to position the compass on the map. Set `automaticallyHides` to `false` to keep the compass visible even when the map is rotated to north (0 degrees). Set `iconBuilder` to provide your own `Widget` to represent the compass.

```dart
  // Provides ArcGISMapViewController to the ArcGISMapView and Compass
  ArcGISMapViewController controllerProvider() {
    return _mapViewController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ArcGISMapView(
            controllerProvider: controllerProvider,
          ),
          Compass(
            controllerProvider: controllerProvider,
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
