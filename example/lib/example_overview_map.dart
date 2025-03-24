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

  runApp(const MaterialApp(home: ExampleOverviewMap()));
}

class ExampleOverviewMap extends StatefulWidget {
  const ExampleOverviewMap({super.key});

  @override
  State<ExampleOverviewMap> createState() => _ExampleOverviewMapState();
}

class _ExampleOverviewMapState extends State<ExampleOverviewMap> {
  final _mapViewController = ArcGISMapView.createController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OverviewMap')),
      body: Stack(
        children: [
          ArcGISMapView(
            controllerProvider: () => _mapViewController,
            onMapViewReady: onMapViewReady,
          ),
          // Default OverviewMap.
          OverviewMap(controllerProvider: () => _mapViewController),
          // Custom OverviewMap.
          OverviewMap(
            controllerProvider: () => _mapViewController,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.zero,
            scaleFactor: 10,
            extentSymbol: SimpleFillSymbol(
              color: Colors.transparent,
              outline: SimpleLineSymbol(
                color: Colors.deepPurple,
                width: 2,
                style: SimpleLineSymbolStyle.dot,
              ),
            ),
            map: ArcGISMap.withBasemapStyle(BasemapStyle.arcGISLightGrayBase),
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

  void onMapViewReady() {
    _mapViewController.arcGISMap = ArcGISMap.withBasemapStyle(
        BasemapStyle.arcGISTopographic,
      )
      ..initialViewpoint = Viewpoint.fromCenter(
        ArcGISPoint(x: 4, y: 40, spatialReference: SpatialReference.wgs84),
        scale: 40000000,
      );
  }
}
