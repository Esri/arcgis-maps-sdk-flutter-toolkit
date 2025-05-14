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
  final _mapViewController = ArcGISMapView.createController();
  Popup? _popup;

  final webmaps = [
    (id: 'f4ea5041f73b40f5ac241035664eff7e', title: 'Fields Popup', secured: false),
    (id: '66c1d496ae354fd79e174f8e3074c3f9', title: 'All Charts Popup', secured: false),
    (id: 'bfce95f294c341a580c608567956806d', title: 'Attachments1(Qt)', secured: true),
    (id: '70abf39d396147c4bb958f0340e3ff54', title: 'Attachments2(Android)', secured: true),
    (id: '9f3a674e998f461580006e626611f9ad', title: 'Design demo popup', secured: false), // keep this as the last one
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
              final selectedWebmap = webmaps.firstWhere((webmap) => webmap.id == valueId);
              if (selectedWebmap.secured) {
                ArcGISEnvironment.apiKey ='';
              }
              reloadMap(
                selectedWebmap.id,
                secured: selectedWebmap.secured,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Authenticator(
            child: ArcGISMapView(
              controllerProvider: () => _mapViewController,
              onMapViewReady: onMapViewReady,
              onTap: identifyArcGISPopup,
            ),
          ),
        ],
      ),
      bottomSheet: getBottomSheet(context),
    );
  }

  @override
  void dispose() {
    ArcGISEnvironment.authenticationManager.arcGISCredentialStore.removeAll();
    ArcGISEnvironment
        .authenticationManager
        .arcGISAuthenticationChallengeHandler = null;
    super.dispose();
  }

  void onMapViewReady() {
    reloadMap(webmaps.last.id, secured: webmaps.last.secured);
  }

  Widget? getBottomSheet(BuildContext context) {
    return _popup != null
        ? Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
          child: Theme(
            data: popupViewThemeData,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: PopupView(
                popup: _popup!,
                onClose: () {
                  setState(() {
                    _popup = null;
                  });
                },
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
      tolerance: 42,
      returnPopupsOnly: true,
    );
    if (result.popups.isNotEmpty) {
      final popup = result.popups.first;
      await popup.evaluateExpressions();

      setState(() {
        _popup = popup;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No popups found'),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() {
        _popup = null;
      });
    }
  }

  void reloadMap(String valueId, {bool secured = false}) {
    if (secured) {
      _mapViewController.arcGISMap = ArcGISMap.withItem(
        PortalItem.withPortalAndItemId(
          portal: Portal.arcGISOnline(connection: PortalConnection.authenticated),
          itemId: valueId,
        ),
      );
    } else {
      _mapViewController.arcGISMap = ArcGISMap.withItem(
        PortalItem.withUri(
          Uri.parse('https://www.arcgis.com/home/item.html?id=$valueId'),
        )!,
      );
    }
  }
}
