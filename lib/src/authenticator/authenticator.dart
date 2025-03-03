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

part of '../../arcgis_maps_toolkit.dart';

//fixme doc
//fixme dispose
//fixme redirectUri in AndroidManifest.xml
//fixme This document describes the steps to configure OAuth for your app:
//fixme https://developers.arcgis.com/documentation/security-and-authentication/user-authentication/flows/authorization-code-with-pkce/
class Authenticator implements ArcGISAuthenticationChallengeHandler {
  Authenticator({
    required BuildContext context,
    List<OAuthUserConfiguration> oAuthUserConfigurations = const [],
  }) : _context = context,
       _oAuthUserConfigurations = oAuthUserConfigurations {
    ArcGISEnvironment
        .authenticationManager
        .arcGISAuthenticationChallengeHandler = this;
  }

  void dispose() {
    ArcGISEnvironment
        .authenticationManager
        .arcGISAuthenticationChallengeHandler = null;
  }

  final BuildContext _context;
  final List<OAuthUserConfiguration> _oAuthUserConfigurations;

  @override
  void handleArcGISAuthenticationChallenge(
    ArcGISAuthenticationChallenge challenge,
  ) {
    final configuration =
        _oAuthUserConfigurations
            .where(
              (configuration) =>
                  configuration.canBeUsedForUri(challenge.requestUri),
            )
            .firstOrNull;

    if (configuration != null) {
      _oauthLogin(challenge, configuration);
    } else {
      _tokenLogin(challenge);
    }
  }

  Future<void> _oauthLogin(
    ArcGISAuthenticationChallenge challenge,
    OAuthUserConfiguration configuration,
  ) async {
    try {
      // Initiate the sign in process to the OAuth server using the defined user configuration.
      final credential = await OAuthUserCredential.create(
        configuration: configuration,
      );

      // Sign in was successful, so continue with the provided credential.
      challenge.continueWithCredential(credential);
    } on ArcGISException catch (error) {
      // An exception occurred.
      final e = (error.wrappedException as ArcGISException?) ?? error;
      if (e.errorType == ArcGISExceptionType.commonUserCanceled) {
        // User canceled.
        challenge.cancel();
      } else {
        // Some other error.
        challenge.continueAndFail();
      }
    }
  }

  void _tokenLogin(ArcGISAuthenticationChallenge challenge) {
    showDialog(
      context: _context,
      builder: (context) => LoginWidget(challenge: challenge),
    );
  }

  Future<void> revokeOAuthTokens() async {
    await Future.wait(
      ArcGISEnvironment.authenticationManager.arcGISCredentialStore
          .getCredentials()
          .whereType<OAuthUserCredential>()
          .map((credential) => credential.revokeToken()),
    );
  }

  void clearCredentials() {
    ArcGISEnvironment.authenticationManager.arcGISCredentialStore.removeAll();
  }

  //fixme persistent?? (w/ios options)
}

// A widget that handles an authentication challenge by prompting the user to log in.
class LoginWidget extends StatefulWidget {
  const LoginWidget({required this.challenge, super.key});

  final ArcGISAuthenticationChallenge challenge;

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  // Controllers for the username and password text fields.
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  // An error message to display.
  String? _error;
  // The result: true if the user logged in, false if the user canceled.
  bool? _result;

  @override
  void dispose() {
    // If the widget was dismissed without a result, the challenge should fail.
    if (_result == null) widget.challenge.continueAndFail();

    // Text editing controllers must be disposed.
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Authentication Required',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              // Show the server URL that is requiring authentication.
              Text(widget.challenge.requestUri.toString()),
              // Text fields for the username and password.
              TextField(
                controller: _usernameController,
                autocorrect: false,
                decoration: const InputDecoration(hintText: 'Username'),
              ),
              TextField(
                controller: _passwordController,
                autocorrect: false,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Password'),
              ),
              const SizedBox(height: 10),
              // Buttons to cancel or log in.
              Row(
                children: [
                  ElevatedButton(
                    onPressed: cancel,
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  ElevatedButton(onPressed: login, child: const Text('Login')),
                ],
              ),
              // Display an error message if there is one.
              Text(_error ?? '', style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    setState(() => _error = null);

    // Username and password are required.
    final username = _usernameController.text;
    if (username.isEmpty) {
      setState(() => _error = 'Username is required.');
      return;
    }
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _error = 'Password is required.');
      return;
    }

    try {
      // Attempt to create a credential with the provided username and password.
      final credential = await TokenCredential.createWithChallenge(
        widget.challenge,
        username: username,
        password: password,
      );
      if (!mounted) return;

      // If successful, continue with the credential.
      widget.challenge.continueWithCredential(credential);
      Navigator.of(context).pop(_result = true);
    } on ArcGISException catch (e) {
      // If there was an error, display the error message.
      setState(() => _error = e.message);
    }
  }

  void cancel() {
    // If the user cancels, cancel the challenge and dismiss the dialog.
    widget.challenge.cancel();
    Navigator.of(context).pop(_result = false);
  }
}
