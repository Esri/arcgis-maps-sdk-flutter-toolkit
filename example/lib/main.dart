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
import 'package:arcgis_maps_toolkit_example/example_authenticator.dart';
import 'package:arcgis_maps_toolkit_example/example_compass.dart';
import 'package:arcgis_maps_toolkit_example/example_overview_map.dart';
import 'package:arcgis_maps_toolkit_example/example_popup.dart';
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
      home: const ExampleApp(),
    ),
  );
}

enum ComponentExample {
  authenticator(
    'Authenticator',
    'Handles authentication challenges',
    ExampleAuthenticator.new,
  ),
  compass(
    'Compass',
    'Visualizes current rotation of map/scene and resets the rotation to north on tap',
    ExampleCompass.new,
  ),
  overviewMap(
    'OverviewMap',
    'Small inset map showing the current viewpoint of the target map/scene',
    ExampleOverviewMap.new,
  ),
  popupView(
    'PopupView',
    'Displays a popup for a feature, including fields, media, and attachments',
    PopupExample.new,
  );

  const ComponentExample(this.title, this.subtitle, this.constructor);

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
            MaterialPageRoute(
              builder: (_) => constructor(),
              settings: RouteSettings(name: '/$title')
            ),
          );
        },
      ),
    );
  }
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Toolkit Examples')),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: ComponentExample.values.length,
        itemBuilder: (context, index) =>
            ComponentExample.values[index].buildCard(context),
      ),
    );
  }
}
