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

import 'example_compass_map.dart';
import 'example_compass_scene.dart';
import 'example_compass_custom.dart';

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
      home: const ExampleCompass(),
    ),
  );
}

enum CompassExample {
  compassMap(
    'Compass Map',
    'Example of compass used with a map. Default styling.',
    ExampleCompassMap.new,
  ),
  compassScene(
    'Compass Scene',
    'Example of compass used with a scene. Default styling.',
    ExampleCompassScene.new,
  ),
  compassCustom(
    'Compass Custom',
    'Example of compass used with a map with custom styling.',
    ExampleCompassCustom.new,
  );

  const CompassExample(this.title, this.subtitle, this.constructor);

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

class ExampleCompass extends StatelessWidget {
  const ExampleCompass({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Compass')),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: CompassExample.values.length,
        itemBuilder: (context, index) =>
            CompassExample.values[index].buildCard(context),
      ),
    );
  }
}
