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

import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:arcgis_maps_toolkit/arcgis_maps_toolkit.dart';
import 'package:flutter/material.dart';

import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
void main() {
  // Supply your apiKey using the --dart-define-from-file command line argument.
  const apiKey = String.fromEnvironment('API_KEY');
  // Alternatively, replace the above line with the following and hard-code your apiKey here:
  // const apiKey = ''; // Your API Key here.
  if (apiKey.isEmpty) {
    throw Exception('apiKey undefined');
  } else {
    ArcGISEnvironment.apiKey = apiKey;
  }

  runApp(const MaterialApp(home: ExampleCompassMap()));
}
@widgetbook.UseCase(
  name: 'Compass (map)',
  type: ExampleCompassMap,
  path: '[Compass]',
)
Widget defaultCompassMapUseCase(BuildContext context) {
  return const ExampleCompassMap();
}
class ExampleCompassMap extends StatefulWidget {
  const ExampleCompassMap({super.key});

  @override
  State<ExampleCompassMap> createState() => _ExampleCompassMapState();
}

class _ExampleCompassMapState extends State<ExampleCompassMap> {
  // Create a map view controller.
  final _mapViewController = ArcGISMapView.createController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compass Map')),
      body: Stack(
        children: [
          // Add a map view to the widget tree and set a controller.
          ArcGISMapView(
            controllerProvider: () => _mapViewController,
            onMapViewReady: onMapViewReady,
          ),
          // Create a compass and display on top of the map view in a stack.
          // Pass the compass the corresponding map view controller.
          Compass(controllerProvider: () => _mapViewController),
        ],
      ),
    );
  }

  void onMapViewReady() {
    // Set a map with a basemap style and initial viewpoint to the map view controller.
    final map = ArcGISMap.withBasemapStyle(BasemapStyle.arcGISTopographic)
      ..initialViewpoint = Viewpoint.fromCenter(
        ArcGISPoint(x: 4, y: 51, spatialReference: SpatialReference.wgs84),
        scale: 20000000,
        rotation: -45,
      );
    _mapViewController.arcGISMap = map;
  }
}
