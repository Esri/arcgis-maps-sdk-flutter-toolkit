part of '../../arcgis_maps_toolkit.dart';

class _AuthenticatorCertificateRequired extends StatefulWidget {
  const _AuthenticatorCertificateRequired({required this.challenge});

  final ClientCertificateAuthenticationChallenge challenge;

  @override
  State<_AuthenticatorCertificateRequired> createState() =>
      _AuthenticatorCertificateRequiredState();
}

class _AuthenticatorCertificateRequiredState
    extends State<_AuthenticatorCertificateRequired> {
  // The result: true if the user browsed for a certificate, false if the user canceled.
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
    Navigator.of(context).pop(_certificateResult = true);
  }

  void cancel() {
    // If the user cancels, cancel the challenge and dismiss the dialog.
    widget.challenge.cancel();
    Navigator.of(context).pop(_certificateResult = false);
  }
}
