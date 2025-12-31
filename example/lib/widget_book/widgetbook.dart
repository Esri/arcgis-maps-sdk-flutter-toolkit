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
// generated Widgetbook directories (created by widgetbook_generator).
import 'package:arcgis_maps_toolkit_example/widget_book/widgetbook.directories.g.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

void main() {
  // Supply your apiKey using the --dart-define or --dart-define-from-file argument.
  const apiKey = String.fromEnvironment('API_KEY');
  if (apiKey.isNotEmpty) {
    ArcGISEnvironment.apiKey = apiKey;
  } else {
    // Continue running Widgetbook even without API key to allow browsing UI.
    // Map and Scene examples may not load data until an API key is provided.
    debugPrint(
      'API_KEY is undefined. Pass --dart-define API_KEY=... for full functionality.',
    );
  }

  runApp(const _WidgetbookApp());
}

@widgetbook.App()
class _WidgetbookApp extends StatelessWidget {
  const _WidgetbookApp();

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      lightTheme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      addons: [
        ViewportAddon(Viewports.all),
        AlignmentAddon(),       
      ],
      // Use the auto-generated directory tree from annotations.
      directories: directories,
      // Set a custom home page shown when no use-case is selected.
      home: const _WidgetbookHome(),
    );
  }
}

class _WidgetbookHome extends StatelessWidget {
  const _WidgetbookHome();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add a Flutter logo.
          FlutterLogo(size: 100),
          SizedBox(height: 16),
          Text(
            'ArcGIS Maps Toolkit Widgetbook',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text('Select a category and use-case from the left navigation.'),
        ],
      ),
    );
  }
}
