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

enum _LoginState { none, oauth, token }

class _ExampleAuthenticatorState extends State<ExampleAuthenticator> {
  final _mapViewController = ArcGISMapView.createController();

  var _loginState = _LoginState.none;

  //fixme comments
  Authenticator? _authenticator;

  @override
  void dispose() {
    _authenticator?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Authenticator')),
      body: SafeArea(
        left: false,
        right: false,
        child: Column(
          children: [
            Expanded(
              child: ArcGISMapView(
                controllerProvider: () => _mapViewController,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _loginState == _LoginState.none ? oAuth : null,
                  child: Text('OAuth'),
                ),
                ElevatedButton(
                  onPressed: _loginState == _LoginState.none ? token : null,
                  child: Text('Token'),
                ),
                ElevatedButton(
                  onPressed: _loginState != _LoginState.none ? unload : null,
                  child: Text('Unload'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void oAuth() {
    _authenticator = Authenticator(
      context: context,
      oAuthUserConfigurations: [
        OAuthUserConfiguration(
          portalUri: Uri.parse('https://www.arcgis.com'),
          clientId: 'T0A3SudETrIQndd2',
          redirectUri: Uri.parse('my-ags-flutter-app://auth'),
        ),
      ],
    );

    loadSecureMap();

    setState(() => _loginState = _LoginState.oauth);
  }

  void token() {
    _authenticator = Authenticator(context: context);

    loadSecureMap();

    setState(() => _loginState = _LoginState.token);
  }

  void loadSecureMap() {
    // Set a portal item map that has a secure layer (traffic).
    // Loading the secure layer will trigger an authentication challenge.
    final map = ArcGISMap.withItem(
      PortalItem.withPortalAndItemId(
        portal: Portal.arcGISOnline(connection: PortalConnection.authenticated),
        itemId: 'e5039444ef3c48b8a8fdc9227f9be7c1',
      ),
    );
    _mapViewController.arcGISMap = map;
  }

  Future<void> unload() async {
    _mapViewController.arcGISMap = ArcGISMap();

    _authenticator?.dispose();
    _authenticator = null;

    if (_loginState == _LoginState.oauth) {
      await Authenticator.revokeOAuthTokens();
    }
    Authenticator.clearCredentials();

    setState(() => _loginState = _LoginState.none);
  }
}
