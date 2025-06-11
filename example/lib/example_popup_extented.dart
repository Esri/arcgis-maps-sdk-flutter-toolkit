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

import 'dart:async';

import 'package:arcgis_maps_toolkit/arcgis_maps_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:arcgis_maps/arcgis_maps.dart';

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

  runApp(const MaterialApp(home: PopupExampleWithProperties()));
}

class PopupExampleWithProperties extends StatefulWidget {
  const PopupExampleWithProperties({super.key});

  @override
  State<PopupExampleWithProperties> createState() =>
      _PopupExampleWithPropertiesState();
}

class _PopupExampleWithPropertiesState
    extends State<PopupExampleWithProperties> {
  final _mapViewController = ArcGISMapView.createController();
  Popup? _popup;

  final webmaps = [
    (
    id: 'f4ea5041f73b40f5ac241035664eff7e',
    title: 'Popup - Hawaii big island',
    ),
    (
    id: '66c1d496ae354fd79e174f8e3074c3f9',
    title: 'Popup with all chart types',
    ),
    (id: '00570dfb5ff043efae7be3fee0536361', title: 'Popup with attachments'),
    (
    id: '67c72e385e6e46bc813e0b378696aba8',
    title: 'Popup with image interval',
    ),
    (
    id: '9f3a674e998f461580006e626611f9ad',
    title: 'Popup design demo',
    ), // keep this as the last one
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Popup Examples'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return List.generate(webmaps.length, (index) {
                return PopupMenuItem(
                  value: webmaps[index].id,
                  child: Text(webmaps[index].title),
                );
              });
            },
            onSelected: (valueId) {
              final selectedWebmap = webmaps.firstWhere(
                    (webmap) => webmap.id == valueId,
              );
              reloadMap(selectedWebmap.id);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ArcGISMapView(
              controllerProvider: () => _mapViewController,
              onMapViewReady: onMapViewReady,
              onTap: identifyArcGISPopup,
            ),
          ),
          if (_popup != null) Expanded(child: getBottomSheet()!),
        ],
      ),
      bottomSheet: getBottomSheet(),
    );
  }

  void onMapViewReady() {
    reloadMap(webmaps.last.id);
  }

  Widget? getBottomSheet() {
    return _popup != null
        ? PopupView(
      popup: _popup!,
      // Optional spacing between popup elements (like attachments, media, fields...)
      spacing: 0,
      // What to do when the close button is pressed
      onClose: () {
        print('Popup closed!');
        setState(() {
          _popup = null;
        });
      },
      // Replace the default close icon with your own
      closeIconBuilder:
          (context, onClose) => IconButton(
        icon: Icon(Icons.cancel_rounded, color: Colors.red),
        onPressed: onClose,
      ),
      // Replace the default divider with your custom widget
      divider: (context) => const SizedBox(height: 10,),

      // Custom "loading" widget while popup content is loading
      waitingBuilder:
          (context) => const Center(
        child: CircularProgressIndicator(color: Colors.deepPurple),
      ),
      scrollEntirePopup: false,
      // Custom error widget if something goes wrong
      errorBuilder:
          (context, error) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, color: Colors.orange),
            const SizedBox(height: 8),
            Text('Oops! Failed to load data.\n$error'),
          ],
        ),
      ),
      // Custom scroll behavior (e.g., bouncing on iOS)
      physics: const BouncingScrollPhysics(),

      // Padding around the title row
      titlePadding: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15),

      // Alignment of elements inside the title row (e.g., title and close icon)
      titleMainAlignment: MainAxisAlignment.start,
      titleCrossAlignment: CrossAxisAlignment.center,

      // Custom message when no popup elements are available
      noElementsText: 'Nothing to show in this popup.',
      elementStyle: PopupElementStyle(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 8),
        chartColor: Colors.yellow,
        chartForegroundColor: Colors.transparent,
        tile: PopupExpansionTileStyle(
          backgroundColor: Colors.green,
          collapsedBackgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.hardEdge,
          textColor: Colors.black,
          iconColor: Colors.indigo,
          trailing: Icon(Icons.chevron_right),
          leading: const Icon(Icons.person, color: Colors.blueAccent),
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          childrenPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    )
        : null;
  }

  Future<void> identifyArcGISPopup(Offset localPosition) async {
    final map = _mapViewController.arcGISMap;
    final firstFeatureLayer =
    map?.operationalLayers.firstWhere((layer) => layer is FeatureLayer)
    as FeatureLayer;
    final result = await _mapViewController.identifyLayer(
      firstFeatureLayer,
      screenPoint: localPosition,
      tolerance: 20,
      returnPopupsOnly: true,
    );
    if (result.popups.isNotEmpty) {
      final popup = result.popups.first;
      setState(() => _popup = popup);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          content: const Text('No Popup found'),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() => _popup = null);
    }
  }

  void reloadMap(String valueId) {
    setState(() => _popup = null);
    _mapViewController.arcGISMap = ArcGISMap.withItem(
      PortalItem.withUri(
        Uri.parse('https://www.arcgis.com/home/item.html?id=$valueId'),
      )!,
    );
  }
}
