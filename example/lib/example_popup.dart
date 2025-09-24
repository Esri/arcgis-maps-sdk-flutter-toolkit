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

  FeatureLayer? _featureLayer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PopupView')),
      // Add a map view to the widget tree and set a controller.
      body: ArcGISMapView(
        controllerProvider: () => _mapViewController,
        onMapViewReady: onMapViewReady,
        // Respond to taps on the map view.
        onTap: identifyPopups,
        //onTap: identifyPopupsAll,
      ),
      // This example accesses the bottom sheet to display the popup view.
      bottomSheet: getBottomSheet(context),
    );
  }

  void onMapViewReady() {
    // Configure authentication challenge handler
    ArcGISEnvironment
        .authenticationManager
        .arcGISAuthenticationChallengeHandler = _AuthenticationHandler(
      'publisher1',
      'test.publisher01',
    );

    ArcGISEnvironment
            .authenticationManager
            .networkAuthenticationChallengeHandler =
        _NetworkChallengeHandler();

    // Configure a webmap containing popups and set to the map view controller.
    final webmapContainingPopups = ArcGISMap.withItem(
      PortalItem.withPortalAndItemId(
        portal: Portal(
          Uri.parse('https://rt-server115.esri.com/portal'),
          connection: PortalConnection.authenticated,
        ),
        itemId: '077c3ad7029647829420274011c9514e',
      ),
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
    setState(() {
      _identifiedPopup = null;
    });
    _featureLayer ??=
        _mapViewController.arcGISMap!.operationalLayers.firstWhere((layer) {
              //print('${layer.name}');
               return layer.name == 'ElecDist Junction';

              // return layer.name == 'Structure Boundary';
              //return layer.name == 'Structure Junction';
            })
            as FeatureLayer;

    print('>>>>> identifyPopups..at $localPosition ${_featureLayer!.name}');
    // Perform an identify operation on the map.
    if (_featureLayer != null) {
      _featureLayer!.clearSelection();

      final result = await _mapViewController.identifyLayer(
        _featureLayer!,
        screenPoint: localPosition,
        tolerance: 100,
        returnPopupsOnly: true,
      );

      print('>>>>> identify ${_featureLayer!.name}...result=$result');

      showPopup(result);
    } else {
      final results = await _mapViewController.identifyLayers(
        screenPoint: localPosition,
        tolerance: 100,
        returnPopupsOnly: true,
      );
      showPopup(results.first);
      print('>>>>> identify all layers...result=${results.length}');
    }

    print('>>>>> identifyPopups..end');
  }

   Future<void> identifyPopupsAll(Offset localPosition) async {
   print('>>>>> identifyPopupsAll.at $localPosition');
   final results = await _mapViewController.identifyLayers(
      screenPoint: localPosition,
      tolerance: 22,
      returnPopupsOnly: true,
    );

    print('>>>>> identifyPopups...result=${results.length}');
    // Check whether popups have been identified.
    if (results.isNotEmpty) {
      // Get the first popup from the identify result.
      final result = results.first;
      showPopup(result);
    }

    print('>>>>> identifyPopups..end');
  }

  void showPopup(IdentifyLayerResult result) {
    // Check whether popups have been identified.
    // Get the first popup from the identify result.
    if (result.popups.isNotEmpty) {
      final popup = result.popups.first;
      //final layer = result.layerContent;
      final geoElement = popup.geoElement;

      if (_featureLayer != null && geoElement is ArcGISFeature) {
        _featureLayer!.selectFeature(geoElement);
      }
      // Set the identified popup to the state variable.
      // This causes the bottom sheet to display containing a popupview.
      setState(() => _identifiedPopup = popup);
    } else {
      if (mounted) {
        // If no popup identified, show a message and reset the state.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            content: const Text('No identified Popup found'),
            duration: const Duration(seconds: 5),
          ),
        );
        setState(() => _identifiedPopup = null);
      }
    }
  }
}

class _AuthenticationHandler implements ArcGISAuthenticationChallengeHandler {
  _AuthenticationHandler(this.username, this.password);

  final String username;
  final String password;
  @override
  Future<void> handleArcGISAuthenticationChallenge(
    ArcGISAuthenticationChallenge challenge,
  ) async {
    final c = await TokenCredential.createWithChallenge(
      challenge,
      username: username,
      password: password,
    );

    challenge.continueWithCredential(c);
  }
}

class _NetworkChallengeHandler
    implements NetworkAuthenticationChallengeHandler {
  @override
  FutureOr<void> handleNetworkAuthenticationChallenge(
    NetworkAuthenticationChallenge challenge,
  ) async {
    if (challenge is ServerTrustAuthenticationChallenge) {
      challenge.continueWithCredential(
        ServerTrustNetworkCredential.forChallenge(challenge),
      );
    } else {
      challenge.continueAndFail();
    }
  }
}

/**
 * UtilityNetwork Associations:
 * https://devtopia.esri.com/runtime/nautilus/blob/main/prototypes/PopupViewerSample/PopupViewerSample/MainWindow.xaml.cs
 * https://rt-server115.esri.com/portal/home/item.html?id=077c3ad7029647829420274011c9514e

   new Uri("https://rt-server115.esri.com/portal/sharing/rest"),
                         "publisher1",
                         "test.publisher01");


  https://rt-server115.esri.com/portal/apps/mapviewer/index.html?webmap=077c3ad7029647829420274011c9514e
 *
 */
