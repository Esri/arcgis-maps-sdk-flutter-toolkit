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
import 'package:arcgis_maps_toolkit_example/widget_book/compass_delegate.dart';
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

  runApp(const MaterialApp(home: ExampleCompassLocalScene()));
}

// Define a use case for widgetbook for the local scene compass example.
@widgetbook.UseCase(
  name: 'Compass (local scene)',
  type: ExampleCompassLocalScene,
  path: '[Compass]',
)
ExampleCompassLocalScene defaultCompassLocalSceneUseCase(BuildContext context) {
  return ExampleCompassLocalScene(delegate: createCompassKnobHost(context));
}

class ExampleCompassLocalScene extends StatefulWidget {
  const ExampleCompassLocalScene({super.key, this.delegate});

  /// Optional delegate providing configuration for the Compass widget.
  final CompassKnobHost? delegate;

  @override
  State<ExampleCompassLocalScene> createState() =>
      _ExampleCompassLocalSceneState();
}

class _ExampleCompassLocalSceneState extends State<ExampleCompassLocalScene> {
  // Create a local scene view controller.
  final _localSceneViewController = ArcGISLocalSceneView.createController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compass Local Scene')),
      body: Stack(
        children: [
          // Add a local scene view to the widget tree and set a controller.
          ArcGISLocalSceneView(
            controllerProvider: () => _localSceneViewController,
            onLocalSceneViewReady: onLocalSceneViewReady,
          ),
          // Create a compass and display on top of the local scene view in a stack.
          // Prefer the delegate factory if provided, otherwise fall back to defaults.
          widget.delegate?.createCompass(
                controllerProvider: () => _localSceneViewController,
              ) ??
              Compass(controllerProvider: () => _localSceneViewController),
        ],
      ),
    );
  }

  void onLocalSceneViewReady() {
    // Create a scene with a topographic basemap and a local scene viewing mode.
    final scene = ArcGISScene.withBasemapStyle(
      BasemapStyle.arcGISTopographic,
      viewingMode: SceneViewingMode.local,
    );

    // Create the 3d scene layer.
    final sceneLayer = ArcGISSceneLayer.withUri(
      Uri.parse(
        'https://www.arcgis.com/home/item.html?id=61da8dc1a7bc4eea901c20ffb3f8b7af',
      ),
    );

    // Add world elevation source to the scene's surface.
    final elevationSource = ArcGISTiledElevationSource.withUri(
      Uri.parse(
        'https://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer',
      ),
    );
    scene.baseSurface.elevationSources.add(elevationSource);

    // Add the scene layer to the scene's operational layers.
    scene.operationalLayers.add(sceneLayer);

    // Set the scene's initial viewpoint.
    final camera = Camera.withLocation(
      location: ArcGISPoint(
        x: 19455578.6821,
        y: -5056336.2227,
        z: 1699.3366,
        spatialReference: SpatialReference.webMercator,
      ),
      heading: 338.7410,
      pitch: 40.3763,
      roll: 0,
    );
    scene.initialViewpoint = Viewpoint.withPointScaleCamera(
      center: ArcGISPoint(
        x: 19455026.8116,
        y: -5054995.7415,
        spatialReference: SpatialReference.webMercator,
      ),
      scale: 8314.6991,
      camera: camera,
    );

    // Apply the scene to the local scene view controller.
    _localSceneViewController.arcGISScene = scene;
  }
}
