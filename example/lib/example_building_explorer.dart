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

void main() {
  runApp(const MaterialApp(home: ExampleBuildingExplorer()));
}

class ExampleBuildingExplorer extends StatefulWidget {
  const ExampleBuildingExplorer({super.key});

  @override
  State<ExampleBuildingExplorer> createState() =>
      _ExampleBuildingExplorerState();
}

class _ExampleBuildingExplorerState extends State<ExampleBuildingExplorer> {
  // Create a controller for the local scene view.
  final _localSceneViewController = ArcGISLocalSceneView.createController();

  // Building scene layer that will be filtered. Set after the WebScene is loaded.
  late final BuildingSceneLayer _buildingSceneLayer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Building Explorer')),
      body: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  // Add a local scene view to the widget tree and set a controller.
                  child: ArcGISLocalSceneView(
                    controllerProvider: () => _localSceneViewController,
                    onLocalSceneViewReady: onLocalSceneViewReady,
                  ),
                ),
                Center(
                  // Button to show the building filter settings sheet.
                  child: ElevatedButton(
                    onPressed: showBuildingExplorerModal,
                    child: const Text('Building Filter Settings'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showBuildingExplorerModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 400, // Define the height of the bottom sheet
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Expanded(
                  child: BuildingExplorer(
                    buildingSceneLayer: _buildingSceneLayer,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> onLocalSceneViewReady() async {
    // Create the local scene from a ArcGISOnline web scene.
    final sceneUri = Uri.parse(
      'https://arcgisruntime.maps.arcgis.com/home/item.html?id=b7c387d599a84a50aafaece5ca139d44',
    );
    final scene = ArcGISScene.withUri(sceneUri)!;

    // Load the scene so the underlying layers can be accessed.
    await scene.load();

    // Get the BuildingSceneLayer from the webmap.
    _buildingSceneLayer = scene.operationalLayers
        .whereType<BuildingSceneLayer>()
        .first;

    // Apply the scene to the local scene view controller.
    _localSceneViewController.arcGISScene = scene;
  }
}
