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
  final _mapViewController = ArcGISMapView.createController();
  Widget? _popupView;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Popup Example')),
      body: Stack(
        children: [
          ArcGISMapView(
            controllerProvider: () => _mapViewController,
            onMapViewReady: onMapViewReady,
            onTap: identifyArcGISPopup,
          ),
        ],
      ),
      bottomSheet: getBottomSheet(context),
    );
  }

  void onMapViewReady() {
    _mapViewController.arcGISMap = ArcGISMap.withItem(
      PortalItem.withUri(
        Uri.parse(
          'https://www.arcgis.com/home/item.html?id=9f3a674e998f461580006e626611f9ad',
        ),
      )!,
    );
  }

  Widget? getBottomSheet(BuildContext context) {
    return _popupView != null
        ? Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: _popupView,
          ),
        )
        : null;
  }

  Future<void> identifyArcGISPopup(Offset localPosition) async {
    final map = _mapViewController.arcGISMap;
    final californiaPeaks = map!.operationalLayers[0] as FeatureLayer;
    final result = await _mapViewController.identifyLayer(
      californiaPeaks,
      screenPoint: localPosition,
      tolerance: 42,
      returnPopupsOnly: true,
    );
    if (result.popups.isNotEmpty) {
      final popup = result.popups.first;
      await popup.evaluateExpressions();

      setState(() {
        _popupView = PopupView(
          popup: popup,
          onClose: () {
            setState(() {
              _popupView = null;
            });
          },
        );
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No popups found'),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() {
        _popupView = null;
      });
    }
  }
}
