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

// A dialog that prompts the user to browse for a client certificate.
class _AuthenticatorCertificateRequired extends StatefulWidget {
  const _AuthenticatorCertificateRequired({required this.challenge});

  final ClientCertificateAuthenticationChallenge challenge;

  @override
  State<_AuthenticatorCertificateRequired> createState() =>
      _AuthenticatorCertificateRequiredState();
}

class _AuthenticatorCertificateRequiredState
    extends State<_AuthenticatorCertificateRequired> {
  // The result: true if the user wants to browse for a certificate, false if the user canceled.
  bool? _certificateResult;

  @override
  void dispose() {
    // If the widget was dismissed without a result, the challenge should fail.
    if (_certificateResult == null) widget.challenge.continueAndFail();

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
                'Certificate Required',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              // Show the server URL that is requiring authentication.
              Text(widget.challenge.host),
              const Text('A certificate is required to access this server.'),
              // Buttons to cancel or browse for the certificate.
              Row(
                spacing: 10,
                children: [
                  TextButton(onPressed: cancel, child: const Text('Cancel')),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: browse,
                      child: const Text('Browse'),
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

  void browse() {
    // The user intends to browse for a certificate. The challenge remains unanswered.
    Navigator.of(context).pop(_certificateResult = true);
  }

  void cancel() {
    // If the user cancels, cancel the challenge and dismiss the dialog.
    widget.challenge.cancel();
    Navigator.of(context).pop(_certificateResult = false);
  }
}
