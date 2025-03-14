# OverviewMap

## Usage

...

```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ArcGISMapView(
            controllerProvider: () => _mapViewController,
          ),
          OverviewMap(
            controllerProvider: () => _mapViewController,
          ),
        ],
      ),
    );
  }
```
