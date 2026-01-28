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
import 'package:arcgis_maps_toolkit_example/example_basemap_gallery_map_grid.dart';
import 'package:arcgis_maps_toolkit_example/example_basemap_gallery_map_list.dart';
import 'package:arcgis_maps_toolkit_example/example_basemap_gallery_scene_grid.dart';
import 'package:arcgis_maps_toolkit_example/example_basemap_gallery_scene_list.dart';
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

  final colorScheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple);
  runApp(
    MaterialApp(
      theme: ThemeData(
        colorScheme: colorScheme,
        appBarTheme: AppBarTheme(backgroundColor: colorScheme.inversePrimary),
      ),
      home: const ExampleBasemapGallery(),
    ),
  );
}

enum BasemapGalleryExample {
  mapGrid(
    'BasemapGallery for a map (grid layout)',
    'Example of showing the default basemaps in a grid and applying one to a map.',
    ExampleBasemapGalleryMapGrid.new,
  ),
  mapList(
    'BasemapGallery for a map (list layout)',
    'Example of showing a list of basemaps from a portal and applying one to a map.',
    ExampleBasemapGalleryMapList.new,
  ),
  sceneGrid(
    'BasemapGallery for a scene (grid layout)',
    'Example of showing the default basemaps in a grid and applying one to a scene (includes 3D basemaps).',
    ExampleBasemapGallerySceneGrid.new,
  ),
  sceneList(
    'BasemapGallery for a scene (list layout)',
    'Example of showing a list of basemaps from a portal. 2D items only (no 3D basemaps).',
    ExampleBasemapGallerySceneList.new,
  );

  const BasemapGalleryExample(this.title, this.subtitle, this.constructor);

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
          );
        },
      ),
    );
  }
}

class ExampleBasemapGallery extends StatelessWidget {
  const ExampleBasemapGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BasemapGallery')),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: BasemapGalleryExample.values.length,
        itemBuilder: (context, index) =>
            BasemapGalleryExample.values[index].buildCard(context),
      ),
    );
  }
}
