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

  runApp(const MaterialApp(home: ExampleCompassScene()));
}

class ExampleCompassScene extends StatefulWidget {
  const ExampleCompassScene({super.key});

  @override
  State<ExampleCompassScene> createState() => _ExampleCompassSceneState();
}

@widgetbook.UseCase(
  name: 'Compass (scene)',
  type:  ExampleCompassScene,
  path: '[Compass]',
)
Widget defaultCompassSceneUseCase(BuildContext context) {
  return const ExampleCompassScene();
}

class _ExampleCompassSceneState extends State<ExampleCompassScene> {
  // Create a scene view controller.
  final _sceneViewController = ArcGISSceneView.createController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compass Scene')),
      body: Stack(
        children: [
          // Add a scene view to the widget tree and set a controller.
          ArcGISSceneView(
            controllerProvider: () => _sceneViewController,
            onSceneViewReady: onSceneViewReady,
          ),
          // Create a compass and display on top of the scene view in a stack.
          // Pass the compass the corresponding scene view controller.
          Compass(controllerProvider: () => _sceneViewController),
        ],
      ),
    );
  }

  void onSceneViewReady() {
    // Create a scene with an imagery basemap style.
    final scene = ArcGISScene.withBasemapStyle(BasemapStyle.arcGISImagery);

    // Add surface elevation to the scene.
    final elevationSource = ArcGISTiledElevationSource.withUri(
      Uri.parse(
        'https://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer',
      ),
    );
    scene.baseSurface.elevationSources.add(elevationSource);

    // Add the scene to the view controller.
    _sceneViewController.arcGISScene = scene;

    // Set an initial viewpoint camera for the scene.
    final viewpointCamera = Camera.withLocation(
      location: ArcGISPoint(
        x: 4,
        y: 51,
        z: 5000000,
        spatialReference: SpatialReference.wgs84,
      ),
      heading: -45,
      pitch: 0,
      roll: 0,
    );
    _sceneViewController.setViewpointCamera(viewpointCamera);
  }
}
