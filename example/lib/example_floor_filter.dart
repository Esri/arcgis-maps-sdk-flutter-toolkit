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
import 'package:arcgis_maps_toolkit_example/floor_filter/example_floor_filter_local_scene.dart';
import 'package:arcgis_maps_toolkit_example/floor_filter/example_floor_filter_map.dart';
import 'package:arcgis_maps_toolkit_example/floor_filter/example_floor_filter_scene.dart';
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

  runApp(const MaterialApp(home: ExampleFloorFilter()));
}

enum FloorFilterExample {
  map(
    'Floor Filter Map',
    'Example of floor filter with map.',
    ExampleFloorFilterMap.new,
  ),
  scene(
    'Floor Filter Scene',
    'Example of floor filter with scene.',
    ExampleFloorFilterScene.new,
  ),
  localScene(
    'Floor Filter Local Scene',
    'Example of floor filter with local scene.',
    ExampleFloorFilterLocalScene.new,
  );

  const FloorFilterExample(this.title, this.subtitle, this.constructor);

  final String title;
  final String subtitle;
  final Widget Function({Key? key}) constructor;

  Card buildCard(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => constructor()),
          ).ignore();
        },
      ),
    );
  }
}

class ExampleFloorFilter extends StatelessWidget {
  const ExampleFloorFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Floor Filter')),
      body: SafeArea(
        left: false,
        right: false,
        child: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: FloorFilterExample.values.length,
          itemBuilder: (context, index) =>
              FloorFilterExample.values[index].buildCard(context),
        ),
      ),
    );
  }
}
