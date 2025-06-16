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

// A dialog that prompts the user to trust a server certificate and
// answers the given challenge with a ServerTrustNetworkCredential.
class _AuthenticatorTrust extends StatefulWidget {
  const _AuthenticatorTrust({required this.challenge});

  final ServerTrustAuthenticationChallenge challenge;

  @override
  State<_AuthenticatorTrust> createState() => _AuthenticatorTrustState();
}

class _AuthenticatorTrustState extends State<_AuthenticatorTrust> {
  // The result: true if the user trusted the server, false if the user canceled.
  bool? _trustResult;

  @override
  void dispose() {
    // If the widget was dismissed without a result, the challenge should fail.
    if (_trustResult == null) widget.challenge.continueAndFail();

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
                'Untrusted Host',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              // Show the server URL that is requiring authentication.
              Text(widget.challenge.host),
              const Text(
                'The server certificate could not be verified. Trust this host and continue?',
              ),
              // Buttons to cancel or accept the certificate.
              Row(
                spacing: 10,
                children: [
                  TextButton(onPressed: cancel, child: const Text('Cancel')),
                  const Spacer(),
                  ElevatedButton(onPressed: trust, child: const Text('Trust')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> trust() async {
    // Trust the server certificate and provide a credential for the challenge.
    widget.challenge.continueWithCredential(
      ServerTrustNetworkCredential.forChallenge(widget.challenge),
    );
    Navigator.of(context).pop(_trustResult = true);
  }

  void cancel() {
    // If the user cancels, cancel the challenge and dismiss the dialog.
    widget.challenge.cancel();
    Navigator.of(context).pop(_trustResult = false);
  }
}
