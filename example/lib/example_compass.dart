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

import 'package:flutter/material.dart';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:arcgis_maps_toolkit/arcgis_maps_toolkit.dart';

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

  runApp(const MaterialApp(home: ExampleCompass()));
}

class ExampleCompass extends StatefulWidget {
  const ExampleCompass({super.key});

  @override
  State<ExampleCompass> createState() => _ExampleCompassState();
}

class _ExampleCompassState extends State<ExampleCompass> {
  final _mapViewController = ArcGISMapView.createController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Compass')),
      body: Stack(
        children: [
          ArcGISMapView(
            controllerProvider: () => _mapViewController,
            onMapViewReady: onMapViewReady,
          ),
          // Default Compass.
          Compass(controllerProvider: () => _mapViewController),
          // Compass with custom settings.
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

  void onMapViewReady() {
    _mapViewController.arcGISMap = ArcGISMap.withBasemapStyle(
        BasemapStyle.arcGISTopographic,
      )
      ..initialViewpoint = Viewpoint.fromCenter(
        ArcGISPoint(x: 4, y: 51, spatialReference: SpatialReference.wgs84),
        scale: 20000000,
        rotation: -45,
      );
  }
}
