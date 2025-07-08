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

  runApp(const MaterialApp(home: PopupExample()));
}

class PopupExample extends StatefulWidget {
  const PopupExample({super.key});

  @override
  State<PopupExample> createState() => _PopupExampleState();
}

class _PopupExampleState extends State<PopupExample> {
  // Create a map view controller.
  final _mapViewController = ArcGISMapView.createController();
  // Create a variable to capture a popup when identified.
  Popup? _identifiedPopup;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PopupView')),
      // Add a map view to the widget tree and set a controller.
      body: ArcGISMapView(
        controllerProvider: () => _mapViewController,
        onMapViewReady: onMapViewReady,
        // Respond to taps on the map view.
        onTap: identifyPopups,
      ),
      // This example accesses the bottom sheet to display the popup view.
      bottomSheet: getBottomSheet(context),
    );
  }

  void onMapViewReady() {
    // Configure a webmap containing popups and set to the map view controller.
    final webmapContainingPopups = ArcGISMap.withItem(
      PortalItem.withUri(
        Uri.parse(
          'https://www.arcgis.com/home/item.html?id=9f3a674e998f461580006e626611f9ad',
        ),
      )!,
    );
    _mapViewController.arcGISMap = webmapContainingPopups;
  }

  // Display a popup view in the bottom sheet when a popup is identified.
  Widget? getBottomSheet(BuildContext context) {
    return _identifiedPopup != null
        ? SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.7,
            child: PopupView(
              // Pass a popup to the popup view widget to display it.
              popup: _identifiedPopup!,
              // Optionally, pass a callback for when the popup view is closed.
              // Here we reset the identifiedPopup variable back to null.
              onClose: () {
                setState(() {
                  _identifiedPopup = null;
                });
              },
            ),
          )
        : null;
  }

  Future<void> identifyPopups(Offset localPosition) async {
    // Perform an identify operation on the map.
    final result = await _mapViewController.identifyLayers(
      screenPoint: localPosition,
      tolerance: 20,
      returnPopupsOnly: true,
    );
    // Check whether popups have been identified.
    if (result.isNotEmpty && result.first.popups.isNotEmpty) {
      // Get the first popup from the identify result.
      final popup = result.first.popups.first;
      // Set the identified popup to the state variable.
      // This causes the bottom sheet to display containing a popupview.
      setState(() => _identifiedPopup = popup);
    } else if (mounted) {
      // If no popup identified, show a message and reset the state.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          content: const Text('No Popup found'),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() => _identifiedPopup = null);
    }
  }
}
