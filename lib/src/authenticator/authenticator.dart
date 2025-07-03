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

/// The [Authenticator] widget handles authentication challenges.
///
/// # Overview
/// A user interface is displayed when network and ArcGIS authentication challenges occur.
///
/// ## Features
/// The [Authenticator] will handle many different types of authentication, for example:
/// * ArcGIS authentication (token and OAuth)
/// * Integrated Windows Authentication (IWA)
/// * Client Cerfificate (PKI)
/// * If credentials were persisted to the keychain, the authenticator will use those instead of requiring the user to re-enter credentials.
///
/// ## Usage
/// An [Authenticator] can be placed anywhere in your widget tree, though it makes the most sense to use it as the parent of the [ArcGISMapView] widget.
/// It will then handle authentication challenges from loading network resources.
///
/// To use OAuth, provide one or more [OAuthUserConfiguration]s in the
/// [Authenticator.oAuthUserConfigurations] parameter. Otherwise, the user will be prompted to
/// sign in using a username and password to obtain a [TokenCredential].
///
/// ```dart
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: Authenticator(
///         oAuthUserConfigurations: [
///           OAauthUserConfiguration(
///             portalUri: Uri.parse('https://www.arcgis.com'),
///             clientId: 'YOUR-CLIENT-ID',
///             redirectUri: Uri.parse('YOUR-REDIRECT-URL'),
///           ),
///         ],
///         child: ArcGISMapView(
///           controllerProvider: () => _mapViewController,
///         ),
///       ),
///     );
///   }
/// ```
///
/// ## More information
/// To learn more about using OAuth with ArcGIS accounts, see:
/// https://developers.arcgis.com/documentation/security-and-authentication/user-authentication/
///
/// To configure OAuth for use in your ArcGIS Maps SDK for Flutter app, see:
/// https://developers.arcgis.com/flutter/install-and-set-up/#enabling-user-authentication
class Authenticator extends StatefulWidget {
  /// Creates an [Authenticator] widget with the optional child and optional
  /// `oAuthUserConfigurations`.
  const Authenticator({
    super.key,
    this.child,
    this.oAuthUserConfigurations = const [],
  });

  /// An optional child widget.
  ///
  /// The [Authenticator] can be placed anywhere in the widget tree, but it is
  /// recommended to make it the parent widget of an [ArcGISMapView].
  final Widget? child;

  /// The list of OAuth configurations to use for authentication.
  ///
  /// If a challenge is received that matches a configuration, the user will be
  /// prompted to sign in using that OAuth configuration. Otherwise, the user
  /// will be prompted to sign in using a username and password to obtain a
  /// [TokenCredential].
  final List<OAuthUserConfiguration> oAuthUserConfigurations;

  /// Revoke all OAuth tokens. The returned [Future] completes when all tokens
  /// have been successfully revoked.
  static Future<void> revokeOAuthTokens() async {
    await Future.wait(
      ArcGISEnvironment.authenticationManager.arcGISCredentialStore
          .getCredentials()
          .whereType<OAuthUserCredential>()
          .map((credential) => credential.revokeToken()),
    );
  }

  /// Clear all credentials from the credential store.
  static Future<void> clearCredentials() async {
    ArcGISEnvironment.authenticationManager.arcGISCredentialStore.removeAll();
    await ArcGISEnvironment.authenticationManager.networkCredentialStore
        .removeAll();
  }

  @override
  State<Authenticator> createState() => _AuthenticatorState();
}

class _AuthenticatorState extends State<Authenticator>
    implements
        ArcGISAuthenticationChallengeHandler,
        NetworkAuthenticationChallengeHandler {
  var _errorMessage = '';

  @override
  void initState() {
    super.initState();

    final manager = ArcGISEnvironment.authenticationManager;

    if (manager.arcGISAuthenticationChallengeHandler != null) {
      _errorMessage =
          'Authenticator failed to load: another AuthenticationChallengeHandler has already been set, of type ${manager.arcGISAuthenticationChallengeHandler.runtimeType}';
    } else if (manager.networkAuthenticationChallengeHandler != null) {
      _errorMessage =
          'Authenticator failed to load: another NetworkAuthenticationChallengeHandler has already been set, of type ${manager.networkAuthenticationChallengeHandler.runtimeType}';
    } else {
      manager.arcGISAuthenticationChallengeHandler = this;
      manager.networkAuthenticationChallengeHandler = this;
    }
  }

  @override
  void dispose() {
    if (_errorMessage.isEmpty) {
      ArcGISEnvironment
              .authenticationManager
              .arcGISAuthenticationChallengeHandler =
          null;
      ArcGISEnvironment
              .authenticationManager
              .networkAuthenticationChallengeHandler =
          null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    return widget.child ?? const SizedBox.shrink();
  }

  @override
  void handleArcGISAuthenticationChallenge(
    ArcGISAuthenticationChallenge challenge,
  ) {
    // If an OAuth configuration matches, use it. Else use token login.
    final configuration = widget.oAuthUserConfigurations
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
    // Show an _AuthenticatorLogin dialog, which will answer the challenge.
    showDialog(
      context: context,
      builder: (context) =>
          _AuthenticatorLogin(challenge: _ArcGISLoginChallenge(challenge)),
    );
  }

  @override
  FutureOr<void> handleNetworkAuthenticationChallenge(
    NetworkAuthenticationChallenge challenge,
  ) async {
    switch (challenge) {
      case ServerTrustAuthenticationChallenge():
        // Show an _AuthenticatorTrust dialog, which will answer the challenge.
        await showDialog(
          context: context,
          builder: (context) => _AuthenticatorTrust(challenge: challenge),
        );
      case BasicAuthenticationChallenge():
      case DigestAuthenticationChallenge():
      case NtlmAuthenticationChallenge():
        // Show an _AuthenticatorLogin dialog, which will answer the challenge.
        await showDialog(
          context: context,
          builder: (context) =>
              _AuthenticatorLogin(challenge: _NetworkLoginChallenge(challenge)),
        );
      case ClientCertificateAuthenticationChallenge():
        await _clientCertificateWorkflow(challenge);
    }
  }

  Future<void> _clientCertificateWorkflow(
    ClientCertificateAuthenticationChallenge challenge,
  ) async {
    // Show an _AuthenticatorCertificateRequired dialog.
    final browse = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _AuthenticatorCertificateRequired(challenge: challenge),
    );

    if (browse == null || !browse) {
      // If the user choose not to browse for a certificate, end here.
      return;
    }

    // Browse for a pfx file.
    final filePickerResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pfx'],
    );

    if (filePickerResult == null ||
        filePickerResult.files.isEmpty ||
        !mounted) {
      // If the user canceled the file picker, cancel the challenge and end here.
      challenge.cancel();
      return;
    }

    final file = filePickerResult.files.single;

    // Show a dialog to prompt the user for the certificate file's password, which
    // will answer the challenge.
    await showDialog(
      context: context,
      builder: (context) =>
          _AuthenticatorCertificatePassword(challenge: challenge, file: file),
    );
  }
}
