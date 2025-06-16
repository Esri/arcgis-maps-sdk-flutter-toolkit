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

import 'package:flutter/material.dart';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:arcgis_maps_toolkit/arcgis_maps_toolkit.dart';

void main() {
  runApp(const MaterialApp(home: ExampleAuthenticator()));
}

class ExampleAuthenticator extends StatefulWidget {
  const ExampleAuthenticator({super.key});

  @override
  State<ExampleAuthenticator> createState() => _ExampleAuthenticatorState();
}

// Which authentication type to use.
enum _AuthenticationType { oauth, token }

// Whether the map is loaded or not.
enum _MapState { unloaded, loaded }

class _ExampleAuthenticatorState extends State<ExampleAuthenticator> {
  final _mapViewController = ArcGISMapView.createController();

  final _emptyMap = ArcGISMap(spatialReference: SpatialReference.wgs84);

  var _authenticationType = _AuthenticationType.oauth;

  var _mapState = _MapState.unloaded;

  // Configurations to use when OAuth is requested.
  final _oAuthUserConfigurations = [
    OAuthUserConfiguration(
      portalUri: Uri.parse('https://www.arcgis.com'),
      clientId: 'T0A3SudETrIQndd2',
      redirectUri: Uri.parse('my-ags-flutter-app://auth'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Authenticator')),
      body: SafeArea(
        left: false,
        right: false,
        child: Column(
          children: [
            Expanded(
              // Add an Authenticator widget to handle authentication challenges.
              child: Authenticator(
                oAuthUserConfigurations:
                    _authenticationType == _AuthenticationType.oauth
                        ? _oAuthUserConfigurations
                        : [],
                child: ArcGISMapView(
                  controllerProvider: () => _mapViewController,
                  onMapViewReady:
                      () => _mapViewController.arcGISMap = _emptyMap,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Toggle between OAuth and Token authentication.
                SegmentedButton(
                  segments: [
                    ButtonSegment(
                      value: _AuthenticationType.oauth,
                      label: Text('OAuth'),
                    ),
                    ButtonSegment(
                      value: _AuthenticationType.token,
                      label: Text('Token'),
                    ),
                  ],
                  selected: {_authenticationType},
                  onSelectionChanged: (selection) {
                    setState(() => _authenticationType = selection.first);
                  },
                ),
                // Load or unload the map. Loading the map will trigger an
                // authentication challenge. Unloading the map will additionally
                // revoke any OAuth tokens and remove all credentials.
                ElevatedButton(
                  onPressed: _mapState == _MapState.unloaded ? load : unload,
                  child:
                      _mapState == _MapState.unloaded
                          ? Text('Load')
                          : Text('Unload'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Set a portal item map that has a secure layer (traffic). Loading the secure
  // layer will trigger an authentication challenge.
  void loadSecureMap() {
    _mapViewController.arcGISMap = ArcGISMap.withItem(
      PortalItem.withPortalAndItemId(
        portal: Portal.arcGISOnline(connection: PortalConnection.authenticated),
        itemId: 'e5039444ef3c48b8a8fdc9227f9be7c1',
      ),
    );
  }

  // Load the secure map and set the map state to loaded.
  void load() {
    if (_mapState == _MapState.loaded) return;

    loadSecureMap();
    setState(() => _mapState = _MapState.loaded);
  }

  // Unload the map, revoke any OAuth tokens, remove all credentials, and set the
  // map state to unloaded.
  Future<void> unload() async {
    if (_mapState == _MapState.unloaded) return;

    _mapViewController.arcGISMap = _emptyMap;

    await Authenticator.revokeOAuthTokens();
    await Authenticator.clearCredentials();

    setState(() => _mapState = _MapState.unloaded);
  }
}
