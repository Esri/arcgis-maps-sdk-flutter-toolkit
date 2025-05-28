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

  runApp(const MaterialApp(home: ExampleCompassScene()));
}

class ExampleCompassScene extends StatefulWidget {
  const ExampleCompassScene({super.key});

  @override
  State<ExampleCompassScene> createState() => _ExampleCompassSceneState();
}

class _ExampleCompassSceneState extends State<ExampleCompassScene> {
  final _sceneViewController = ArcGISSceneView.createController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Compass Scene')),
      body: Stack(
        children: [
          ArcGISSceneView(
            controllerProvider: () => _sceneViewController,
            onSceneViewReady: onSceneViewReady,
          ),
          // Default Compass.
          Compass(controllerProvider: () => _sceneViewController),
          // Compass with custom settings.
          Compass(
            controllerProvider: () => _sceneViewController,
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

  void onSceneViewReady() {
    // Create a scene with an imagery basemap style and initial viewpoint.
    final scene = ArcGISScene.withBasemapStyle(BasemapStyle.arcGISImagery);

    // Add surface elevation to the scene.
    final surface = Surface();
    final worldElevationService = Uri.parse(
      'https://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer',
    );
    final elevationSource = ArcGISTiledElevationSource.withUri(
      worldElevationService,
    );
    surface.elevationSources.add(elevationSource);
    scene.baseSurface = surface;

    // Add the scene to the view controller.
    _sceneViewController.arcGISScene = scene;

    // Set a viewpoint camera for the scene.
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
