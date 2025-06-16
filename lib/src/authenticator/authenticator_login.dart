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

// A _LoginChallenge can either be an ArcGIS challenge (at the server level), or a
// Network challenge. The _AuthenticatorLogin widget handles both types.
sealed class _LoginChallenge {
  // Common functionality to be overridden in the type-specific classes.
  String get host;
  String? get realm;
  void continueAndFail();
  void cancel();
}

class _ArcGISLoginChallenge extends _LoginChallenge {
  _ArcGISLoginChallenge(this.challenge);

  final ArcGISAuthenticationChallenge challenge;

  @override
  String get host => challenge.requestUri.host;

  @override
  String? get realm => null;

  @override
  void continueAndFail() => challenge.continueAndFail();

  @override
  void cancel() => challenge.cancel();
}

class _NetworkLoginChallenge extends _LoginChallenge {
  _NetworkLoginChallenge(this.challenge);

  final NetworkAuthenticationChallenge challenge;

  @override
  String get host => challenge.host;

  @override
  String? get realm {
    switch (challenge) {
      case BasicAuthenticationChallenge(realm: final realm):
        return realm;
      case DigestAuthenticationChallenge(realm: final realm):
        return realm;
      default:
        return null;
    }
  }

  @override
  void continueAndFail() => challenge.continueAndFail();

  @override
  void cancel() => challenge.cancel();
}

// A dialog that prompts the user to log in with a username and password and
// answers the given challenge with a TokenCredential.
class _AuthenticatorLogin extends StatefulWidget {
  const _AuthenticatorLogin({required this.challenge});

  final _LoginChallenge challenge;

  @override
  State<_AuthenticatorLogin> createState() => _AuthenticatorLoginState();
}

class _AuthenticatorLoginState extends State<_AuthenticatorLogin> {
  // Controllers for the username and password text fields.
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // An error message to display.
  String? _errorMessage;

  // The result: true if the user logged in, false if the user canceled.
  bool? _loginResult;

  @override
  void dispose() {
    // If the widget was dismissed without a result, the challenge should fail.
    if (_loginResult == null) widget.challenge.continueAndFail();

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
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(
                'Authentication Required',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              // Show the host that is requiring authentication.
              Text(widget.challenge.host),
              // Show realm (if applicable).
              if (widget.challenge.realm != null)
                Text('Realm: ${widget.challenge.realm}'),
              // Text fields for the username and password.
              TextField(
                controller: _usernameController,
                autocorrect: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                ),
              ),
              TextField(
                controller: _passwordController,
                autocorrect: false,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
              // Buttons to cancel or log in.
              Row(
                spacing: 10,
                children: [
                  TextButton(onPressed: cancel, child: const Text('Cancel')),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: login,
                      child: const Text('Login'),
                    ),
                  ),
                ],
              ),
              // Display an error message if there is one.
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    setState(() => _errorMessage = null);

    // Username and password are required.
    final username = _usernameController.text;
    if (username.isEmpty) {
      setState(() => _errorMessage = 'Username is required.');
      return;
    }
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Password is required.');
      return;
    }

    // Attempt to log in with the provided username and password, using the appropriate type.
    switch (widget.challenge) {
      case _ArcGISLoginChallenge(challenge: final challenge):
        await _loginArcGIS(challenge, username, password);
      case _NetworkLoginChallenge(challenge: final challenge):
        await _loginNetwork(challenge, username, password);
    }
  }

  Future<void> _loginArcGIS(
    ArcGISAuthenticationChallenge challenge,
    String username,
    String password,
  ) async {
    try {
      // Attempt to create a credential with the provided username and password.
      final credential = await TokenCredential.createWithChallenge(
        challenge,
        username: username,
        password: password,
      );
      if (!mounted) return;

      // If successful, continue with the credential.
      challenge.continueWithCredential(credential);
      Navigator.of(context).pop(_loginResult = true);
    } on ArcGISException catch (e) {
      // If there was an error, display the error message.
      setState(() => _errorMessage = e.message);
    }
  }

  Future<void> _loginNetwork(
    NetworkAuthenticationChallenge challenge,
    String username,
    String password,
  ) async {
    // Create the appropriate credential based on the challenge type.
    switch (challenge) {
      case BasicAuthenticationChallenge():
        final credential = BasicNetworkCredential.forChallenge(
          challenge,
          username,
          password,
        );
        challenge.continueWithCredential(credential);
      case DigestAuthenticationChallenge():
        final credential = DigestNetworkCredential.forChallenge(
          challenge,
          username,
          password,
        );
        challenge.continueWithCredential(credential);
      case NtlmAuthenticationChallenge():
        final credential = NtlmNetworkCredential.forChallenge(
          challenge,
          username,
          password,
        );
        challenge.continueWithCredential(credential);
      default:
        throw UnsupportedError(
          'Unsupported NetworkAuthenticationChallenge type: ${challenge.runtimeType}',
        );
    }
    Navigator.of(context).pop(_loginResult = true);
  }

  void cancel() {
    // If the user cancels, cancel the challenge and dismiss the dialog.
    widget.challenge.cancel();
    Navigator.of(context).pop(_loginResult = false);
  }
}
