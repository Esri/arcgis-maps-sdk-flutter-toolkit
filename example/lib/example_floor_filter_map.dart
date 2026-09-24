//
// Copyright 2026 Esri
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

  runApp(const MaterialApp(home: ExampleFloorFilterMap()));
}

class ExampleFloorFilterMap extends StatefulWidget {
  const ExampleFloorFilterMap({super.key});

  @override
  State<ExampleFloorFilterMap> createState() => _ExampleFloorFilterMapState();
}

class _ExampleFloorFilterMapState extends State<ExampleFloorFilterMap> {
  // Create a map view controller.
  final _mapViewController = ArcGISMapView.createController();

  // Create a controller for the FloorFilter widget.
  late final _floorFilterController = FloorFilter.createController(
    _mapViewController,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compass Map')),
      body: SafeArea(
        left: false,
        right: false,
        child: Stack(
          children: [
            // Add a map view to the widget tree and set a controller.
            ArcGISMapView(
              controllerProvider: () => _mapViewController,
              onMapViewReady: onMapViewReady,
            ),
            // Create a floor filter and display on top of the map view in a stack.
            // Pass the floor filter the corresponding map view controller.
            Positioned(
              bottom: 70,
              left: 20,
              child: FloorFilter(floorFilterController: _floorFilterController),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onMapViewReady() async {
    // Create the map from an ArcGISOnline web map.
    final map = ArcGISMap.withUri(
      Uri.parse(
        'https://arcgisruntime.maps.arcgis.com/home/item.html?id=b4b599a43a474d33946cf0df526426f5',
      ),
    )!;

    // Load the map and set it on the view controller.
    await map.load();
    _mapViewController.arcGISMap = map;

    // Refresh the floor filter now that the map has been set.
    _floorFilterController.refresh();
  }
}
