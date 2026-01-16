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
  // Supply your apiKey using the --dart-define-from-file command line argument.
  const apiKey = String.fromEnvironment('API_KEY');
  // Alternatively, replace the above line with the following and hard-code your apiKey here:
  // const apiKey = ''; // Your API Key here.
  if (apiKey.isEmpty) {
    throw Exception('apiKey undefined');
  } else {
    ArcGISEnvironment.apiKey = apiKey;
  }

  runApp(const MaterialApp(home: ExampleBasemapGallerySceneDefaultsGrid()));
}

class ExampleBasemapGallerySceneDefaultsGrid extends StatefulWidget {
  const ExampleBasemapGallerySceneDefaultsGrid({super.key});

  @override
  State<ExampleBasemapGallerySceneDefaultsGrid> createState() =>
      _ExampleBasemapGallerySceneDefaultsGridState();
}

class _ExampleBasemapGallerySceneDefaultsGridState
    extends State<ExampleBasemapGallerySceneDefaultsGrid> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _sceneViewController = ArcGISSceneView.createController();

  late final ArcGISScene _scene;
  late final BasemapGalleryController _controller;

  @override
  void initState() {
    super.initState();

    _scene = ArcGISScene.withBasemapStyle(BasemapStyle.arcGISImagery)
      ..initialViewpoint = Viewpoint.fromCenter(
        ArcGISPoint(
          x: -93.258133,
          y: 44.986656,
          spatialReference: SpatialReference.wgs84,
        ),
        scale: 1000000,
      );

    // Default controller: for scenes this loads developerBasemaps() +
    // basemaps3D() from ArcGIS Online.
    _controller = BasemapGalleryController(geoModel: _scene)
      ..viewStyle = BasemapGalleryViewStyle.grid;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('BasemapGallery (Scene Defaults Grid)'),
        actions: [
          IconButton(
            tooltip: 'Basemap Gallery',
            icon: const Icon(Icons.layers_outlined),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Text(
                        'Basemap Gallery',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: BasemapGallery(controller: _controller),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ArcGISSceneView(
        controllerProvider: () => _sceneViewController,
        onSceneViewReady: () {
          _sceneViewController.arcGISScene = _scene;
        },
      ),
    );
  }
}
