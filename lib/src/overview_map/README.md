# OverviewMap

## Usage

An `OverviewMap` is generally placed in a `Stack` on top of an `ArcGISMapView`. The `OverviewMap` must use the same `controllerProvider` as the `ArcGISMapView`.

Use `alignment` and `padding` to position the overview map on the target map. The overview map's scale will be set to the scale of the target map multiplied by the `scaleFactor`. The `symbol` will be used to draw the visible area of the target map on the overview map. By default, it is a 1 pixel red outline. Use `map` to specify the `ArcGISMap` used by the overview map. By default, the map uses the ArcGIS Topographic basemap style.

Set `containerBuilder` to provide your own `Widget` to customize the presentation of the overview map. The returned `Widget` must include the provided `child`, which will be the overview map itself. By default, the overview map will be 150x100 pixels with a 1 pixel black border.

### When using `ArcGISMapViewController`:
```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ArcGISMapView(
            controllerProvider: () => _mapViewController,
          ),
          OverviewMap.withMapView(
            controllerProvider: () => _mapViewController,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.zero,
            scaleFactor: 10,
            symbol: SimpleFillSymbol(
              color: Colors.transparent,
              outline: SimpleLineSymbol(
                color: Colors.deepPurple,
                width: 2,
                style: SimpleLineSymbolStyle.dot,
              ),
            ),
            map: ArcGISMap.withBasemapStyle(
              BasemapStyle.arcGISLightGrayBase,
            ),
            containerBuilder:
                (context, child) => Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple, width: 3),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Opacity(opacity: .8, child: child),
            ),
          ),
        ],
      ),
    );
  }
```
### When using `ArcGISSceneViewController`:

```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ArcGISSceneView(
            controllerProvider: () => _sceneViewController,
          ),
          OverviewMap.withSceneView(
            controllerProvider: () => _sceneViewController,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.zero,
            scaleFactor: 10,
            symbol: SimpleMarkerSymbol(
              style: SimpleMarkerSymbolStyle.cross,
              size: 30,
              color: Colors.blue,
            ),
            map: ArcGISMap.withBasemapStyle(
              BasemapStyle.arcGISLightGrayBase,
            ),
            containerBuilder:
                (context, child) => Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple, width: 3),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Opacity(opacity: .8, child: child),
            ),
          ),
        ],
      ),
    );
  }
```