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
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook show UseCase;

void main() {
  runApp(const MaterialApp(home: ExampleAuthenticator()));
}

enum AuthenticationType { oauth, token }

// Define a use case for OAuth authentication.
@widgetbook.UseCase(
  name: 'Authenticator(oauth)',
  type: ExampleAuthenticator,
  path: '[Authenticator]',
)
Widget authenticatorOAuthUseCase(BuildContext context) {
  return const ExampleAuthenticator(widgetbook: true);
}

// Define a use case for Token authentication.
@widgetbook.UseCase(
  name: 'Authenticator(token)',
  type: ExampleAuthenticator,
  path: '[Authenticator]',
)
Widget authenticatorTokenUseCase(BuildContext context) {
  return const ExampleAuthenticator(type: AuthenticationType.token, widgetbook: true);
}

class ExampleAuthenticator extends StatefulWidget {
  const ExampleAuthenticator({
    super.key,
    this.type = AuthenticationType.oauth,
    this.widgetbook = false,
  });
  final AuthenticationType type;
  final bool widgetbook;
  @override
  State<ExampleAuthenticator> createState() => _ExampleAuthenticatorState();
}

// Whether the map is loaded or not.
enum _MapState { unloaded, loaded }

class _ExampleAuthenticatorState extends State<ExampleAuthenticator> {
  // Create a map view controller.
  final _mapViewController = ArcGISMapView.createController();

  // Empty map to display until data is loaded.
  final _emptyMap = ArcGISMap(spatialReference: SpatialReference.wgs84);

  // Holds the selected authentication type.
  late AuthenticationType _authenticationType;

  // Current map state.
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
  void initState() {
    super.initState();
    _authenticationType = widget.type;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Authenticator')),
      body: SafeArea(
        left: false,
        right: false,
        child: Column(
          children: [
            Expanded(
              // Add an Authenticator widget to handle authentication challenges.
              child: Authenticator(
                oAuthUserConfigurations:
                    _authenticationType == AuthenticationType.oauth
                    ? _oAuthUserConfigurations
                    : [],
                // Add a map view as the child to the Authenticator, and set a controller.
                child: ArcGISMapView(
                  controllerProvider: () => _mapViewController,
                  onMapViewReady: () =>
                      _mapViewController.arcGISMap = _emptyMap,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Toggle between OAuth and Token authentication.
                Visibility(
                  visible: !widget.widgetbook,
                  child: SegmentedButton(
                    segments: const [
                      ButtonSegment(
                        value: AuthenticationType.oauth,
                        label: Text('OAuth'),
                      ),
                      ButtonSegment(
                        value: AuthenticationType.token,
                        label: Text('Token'),
                      ),
                    ],
                    selected: {_authenticationType},
                    onSelectionChanged: (selection) {
                      setState(() => _authenticationType = selection.first);
                    },
                  ),
                ),
                // Load or unload the map. Loading the map will trigger an
                // authentication challenge. Unloading the map will additionally
                // revoke any OAuth tokens and remove all credentials.
                ElevatedButton(
                  onPressed: _mapState == _MapState.unloaded ? load : unload,
                  child: _mapState == _MapState.unloaded
                      ? const Text('Load')
                      : const Text('Unload'),
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
