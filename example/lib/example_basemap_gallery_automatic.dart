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

  runApp(const MaterialApp(home: ExampleBasemapGalleryAutomatic()));
}

class ExampleBasemapGalleryAutomatic extends StatefulWidget {
  const ExampleBasemapGalleryAutomatic({super.key});

  @override
  State<ExampleBasemapGalleryAutomatic> createState() =>
      _ExampleBasemapGalleryAutomaticState();
}

class _ExampleBasemapGalleryAutomaticState
    extends State<ExampleBasemapGalleryAutomatic> {
  final _mapViewController = ArcGISMapView.createController();

  late final ArcGISMap _map;
  late final BasemapGalleryController _controller;

  @override
  void initState() {
    super.initState();

    _map = ArcGISMap.withBasemapStyle(BasemapStyle.arcGISImagery)
      ..initialViewpoint = Viewpoint.fromCenter(
        ArcGISPoint(
          x: -93.258133,
          y: 44.986656,
          spatialReference: SpatialReference.wgs84,
        ),
        scale: 1000000,
      );

    final galleryItems = _makeBasemapGalleryItems();

    _controller = BasemapGalleryController.withItems(
      geoModel: _map,
      items: galleryItems,
    )..viewStyle = BasemapGalleryViewStyle.automatic;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BasemapGallery (Automatic)'),
        actions: [
          IconButton(
            tooltip: 'Show basemap gallery',
            icon: const Icon(Icons.layers_outlined),
            onPressed: _showBasemapGallery,
          ),
        ],
      ),
      body: _buildMapPane(),
    );
  }

  Widget _buildMapPane() {
    return ArcGISMapView(
      controllerProvider: () => _mapViewController,
      onMapViewReady: () {
        _mapViewController.arcGISMap = _map;
      },
    );
  }

  List<BasemapGalleryItem> _makeBasemapGalleryItems() {
    const identifiers = <String>[
      '46a87c20f09e4fc48fa3c38081e0cae6',
      'f33a34de3a294590ab48f246e99958c9',
      '52bdc7ab7fb044d98add148764eaa30a', // mismatched spatial reference
      '3a8d410a4a034a2ba9738bb0860d68c4', // incorrect portal item type
    ];

    final portal = Portal.arcGISOnline();
    return identifiers
        .map((id) {
          final portalItem = PortalItem.withPortalAndItemId(
            portal: portal,
            itemId: id,
          );
          return BasemapGalleryItem(basemap: Basemap.withItem(portalItem));
        })
        .toList(growable: false);
  }

  Future<void> _showBasemapGallery() async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: BasemapGallery(controller: _controller),
          ),
        );
      },
    );
  }
}
