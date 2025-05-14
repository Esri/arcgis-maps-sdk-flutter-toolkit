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
  // // Supply your apiKey using the --dart-define-from-file command line argument.
  // const apiKey = String.fromEnvironment('API_KEY');
  // // Alternatively, replace the above line with the following and hard-code your apiKey here:
  // // const apiKey = ''; // Your API Key here.
  // if (apiKey.isEmpty) {
  //   throw Exception('apiKey undefined');
  // } else {
  //   ArcGISEnvironment.apiKey = apiKey;
  // }

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

  final webmapIds = [
    'f4ea5041f73b40f5ac241035664eff7e',
    '66c1d496ae354fd79e174f8e3074c3f9',
    '9f3a674e998f461580006e626611f9ad', // keep this as the last one
  ];
  final webmapTitles = [
    'Fields Popup',
    'All Charts Popup',
    'Design demo popup', // keep this as the last one
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Popup Example'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return List.generate(webmapIds.length, (index) {
                return PopupMenuItem(
                  value: webmapIds[index],
                  child: Text(webmapTitles[index]),
                );
              });
            },
            onSelected: (valueId) {
              reloadMap(valueId);
            },
          ),
        ],
      ),
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

  @override
  void dispose() {
    
    ArcGISEnvironment.authenticationManager.arcGISCredentialStore.removeAll();
    ArcGISEnvironment
        .authenticationManager
        .arcGISAuthenticationChallengeHandler = null;
    super.dispose();
  }

  void onMapViewReady() {
    //reloadMap('bfce95f294c341a580c608567956806d');

    // _mapViewController.arcGISMap = ArcGISMap.withItem(
    //   PortalItem.withPortalAndItemId(
    //     portal: Portal.arcGISOnline(connection: PortalConnection.authenticated),
    //     itemId: 'bfce95f294c341a580c608567956806d',
    //   ),
    // );

    // QT sample
    // _mapViewController.arcGISMap = ArcGISMap.withItem(
    //   PortalItem.withUri(
    //     Uri.parse(
    //       'https://runtimecoretest.maps.arcgis.com/home/item.html?id=bfce95f294c341a580c608567956806d',
    //     ),
    //   )!,
    // );

    // android sample
    _mapViewController.arcGISMap = ArcGISMap.withItem(
      PortalItem.withUri(
        Uri.parse(
          'https://runtimecoretest.maps.arcgis.com/home/item.html?id=70abf39d396147c4bb958f0340e3ff54',
        ),
      )!,
    );

    final tokenChallengeHandler = TokenChallengeHandler(
      'android_2',
      'android@100',
    );
    ArcGISEnvironment
        .authenticationManager
        .arcGISAuthenticationChallengeHandler = tokenChallengeHandler;
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

  void reloadMap(String valueId) {
    _mapViewController.arcGISMap = ArcGISMap.withItem(
      PortalItem.withUri(
        Uri.parse('https://www.arcgis.com/home/item.html?id=$valueId'),
      )!,
    );
  }
}

class TokenChallengeHandler implements ArcGISAuthenticationChallengeHandler {
  TokenChallengeHandler(
    this.username,
    this.password, {
    this.rememberChallenges = true,
  });

  final String username;
  final String password;
  bool rememberChallenges;

  final challenges = <ArcGISAuthenticationChallenge>[];

  @override
  Future<void> handleArcGISAuthenticationChallenge(
    ArcGISAuthenticationChallenge challenge,
  ) async {
    print('TokenChallengeHandler.handleArcGISAuthenticationChallenge: '
        'challenge: ${challenge.error}');
    if (rememberChallenges) challenges.add(challenge);

    final credential = await TokenCredential.createWithChallenge(
      challenge,
      username: username,
      password: password,
    );
    challenge.continueWithCredential(credential);
  }
}
