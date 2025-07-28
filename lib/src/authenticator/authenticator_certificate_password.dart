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

  // An error message to display.
  String? _errorMessage;

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
              // Display an error message if there is one.
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void accept() {
    final bytes = File(widget.file.path!).readAsBytesSync();
    final password = _passwordController.text;

    // Check that the certificate/password is valid before accepting it.
    if (!_validateCertificate(bytes, password)) {
      return;
    }

    // Respond to the challenge with the provided certificate and password.
    widget.challenge.continueWithCredential(
      ClientCertificateNetworkCredential.forChallenge(
        widget.challenge,
        bytes,
        password,
      ),
    );
    Navigator.of(context).pop(_passwordResult = true);
  }

  bool _validateCertificate(Uint8List bytes, String password) {
    // Check whether the certificate/password can be successfully applied to a SecurityContext.
    String? errorMessage;
    try {
      final securityContext = SecurityContext();
      securityContext.useCertificateChainBytes(bytes, password: password);
      securityContext.usePrivateKeyBytes(bytes, password: password);
    } on TlsException catch (e) {
      if (e.osError?.message.toLowerCase().contains('incorrect_password') ??
          false) {
        errorMessage = 'The password is incorrect.';
      } else {
        // Some other TLS error occurred.
        errorMessage = e.toString();
      }
    } on Exception catch (e) {
      // Some other error occurred.
      errorMessage = e.toString();
    }

    if (errorMessage != null) {
      setState(() => _errorMessage = errorMessage);
      return false;
    }

    return true;
  }

  void cancel() {
    // If the user cancels, cancel the challenge and dismiss the dialog.
    widget.challenge.cancel();
    Navigator.of(context).pop(_passwordResult = false);
  }
}
