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
import 'package:material_ui/material_ui.dart';

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

  runApp(const MaterialApp(home: ExampleFloorFilterScene()));
}

class ExampleFloorFilterScene extends StatefulWidget {
  const ExampleFloorFilterScene({super.key});

  @override
  State<ExampleFloorFilterScene> createState() =>
      _ExampleFloorFilterSceneState();
}

class _ExampleFloorFilterSceneState extends State<ExampleFloorFilterScene> {
  // Create a map view controller.
  final _sceneViewController = ArcGISSceneView.createController();

  // Create a controller for the FloorFilter widget.
  late final _floorFilterController = FloorFilter.createController(
    _sceneViewController,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Floor Filter Scene')),
      body: SafeArea(
        left: false,
        right: false,
        child: Stack(
          children: [
            // Add a map view to the widget tree and set a controller.
            ArcGISSceneView(
              controllerProvider: () => _sceneViewController,
              onSceneViewReady: onSceneViewReady,
            ),
            // Create a floor filter and display on top of the map view in a stack.
            // Pass the floor filter the corresponding floor filter controller.
            Positioned(
              bottom: 50,
              left: 20,
              child: FloorFilter(floorFilterController: _floorFilterController),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onSceneViewReady() async {
    // Create the map from an ArcGISOnline web map.
    final scene = ArcGISScene.withUri(
      // Uri.parse(
      //   'https://arcgisruntime.maps.arcgis.com/home/item.html?id=895e482788b04483b558af493b39b03f',
      // ),
      Uri.parse(
        'https://arcgisruntime.maps.arcgis.com/home/item.html?id=3d8ff4683ab44478a022f79d4fc21d98',
      ),
    )!;

    // Load the map and set it on the view controller.
    await scene.load();
    _sceneViewController.arcGISScene = scene;

    // Refresh the floor filter now that the map has been set.
    await _floorFilterController.refresh().onError((e, stackTrace) {
      if (!mounted) return;

      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Refresh Failed'),
          content: Text('$e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }
}
