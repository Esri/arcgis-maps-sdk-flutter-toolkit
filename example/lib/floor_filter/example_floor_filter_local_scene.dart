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

  runApp(const MaterialApp(home: ExampleFloorFilterLocalScene()));
}

class ExampleFloorFilterLocalScene extends StatefulWidget {
  const ExampleFloorFilterLocalScene({super.key});

  @override
  State<ExampleFloorFilterLocalScene> createState() =>
      _ExampleFloorFilterLocalSceneState();
}

class _ExampleFloorFilterLocalSceneState
    extends State<ExampleFloorFilterLocalScene> {
  // Create a map view controller.
  final _localSceneViewController = ArcGISLocalSceneView.createController();

  // Create a controller for the FloorFilter widget.
  late final _floorFilterController = FloorFilter.createController(
    _localSceneViewController,
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
            ArcGISLocalSceneView(
              controllerProvider: () => _localSceneViewController,
              onLocalSceneViewReady: onLocalSceneViewReady,
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

  Future<void> onLocalSceneViewReady() async {
    // Create the map from an ArcGISOnline web map.
    final scene = ArcGISScene.withUri(
      Uri.parse(
        'https://arcgisruntime.maps.arcgis.com/home/item.html?id=dc53c38cc0ed4982a66b3844984a29fe',
      ),
    )!;

    // Load the map and set it on the view controller.
    await scene.load();
    _localSceneViewController.arcGISScene = scene;

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
