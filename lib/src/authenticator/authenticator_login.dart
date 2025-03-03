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

// A dialog that prompts the user to log in with a username and password and
// answers the given challenge with a TokenCredential.
class _AuthenticatorLogin extends StatefulWidget {
  const _AuthenticatorLogin({required this.challenge});

  final ArcGISAuthenticationChallenge challenge;

  @override
  State<_AuthenticatorLogin> createState() => _AuthenticatorLoginState();
}

class _AuthenticatorLoginState extends State<_AuthenticatorLogin> {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(
                'Authentication Required',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              // Show the server URL that is requiring authentication.
              Text(widget.challenge.requestUri.toString()),
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
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
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
