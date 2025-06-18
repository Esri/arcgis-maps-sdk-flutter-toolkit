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

// A dialog that prompts the user to specify the password that corresponds to the
// given certificate, then either provides a credential for the challenge or cancels it.
class _AuthenticatorCertificatePassword extends StatefulWidget {
  const _AuthenticatorCertificatePassword({
    required this.challenge,
    required this.file,
  });

  final ClientCertificateAuthenticationChallenge challenge;
  final PlatformFile file;

  @override
  State<_AuthenticatorCertificatePassword> createState() =>
      _AuthenticatorCertificatePasswordState();
}

class _AuthenticatorCertificatePasswordState
    extends State<_AuthenticatorCertificatePassword> {
  // Controller for the password text field.
  final _passwordController = TextEditingController();

  // The result: true if the user provided a password, false if the user canceled.
  bool? _passwordResult;

  @override
  void initState() {
    super.initState();

    if (widget.file.path == null) {
      throw UnsupportedError('The selected file does not have a valid path.');
    }
  }

  @override
  void dispose() {
    // If the widget was dismissed without a result, the challenge should fail.
    if (_passwordResult == null) widget.challenge.continueAndFail();

    // Text editing controllers must be disposed.
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
                'Password Required',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              // Show the name of the file that requires a password.
              Text(widget.file.name),
              // Text field for the password.
              TextField(
                controller: _passwordController,
                autocorrect: false,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
              // Buttons to cancel or accept.
              Row(
                spacing: 10,
                children: [
                  TextButton(onPressed: cancel, child: const Text('Cancel')),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: accept,
                      child: const Text('OK'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void accept() {
    // Provide the password for the certificate and respond to the challenge.
    widget.challenge.continueWithCredential(
      ClientCertificateNetworkCredential.forChallenge(
        widget.challenge,
        File(widget.file.path!).readAsBytesSync(),
        _passwordController.text,
      ),
    );
    Navigator.of(context).pop(_passwordResult = true);
  }

  void cancel() {
    // If the user cancels, cancel the challenge and dismiss the dialog.
    widget.challenge.cancel();
    Navigator.of(context).pop(_passwordResult = false);
  }
}
