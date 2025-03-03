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
class Authenticator implements ArcGISAuthenticationChallengeHandler {
  Authenticator({
    List<OAuthUserConfiguration> oAuthUserConfigurations = const [],
  }) : _oAuthUserConfigurations = oAuthUserConfigurations {
    ArcGISEnvironment
        .authenticationManager
        .arcGISAuthenticationChallengeHandler = this;
  }

  void dispose() {
    ArcGISEnvironment
        .authenticationManager
        .arcGISAuthenticationChallengeHandler = null;
  }

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
    //fixme
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
