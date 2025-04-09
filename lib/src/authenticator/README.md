# Authenticator

An `Authenticator` can be placed anywhere in your widget tree, though it makes the most sense to use it as the parent of the `ArcGISMapView` widget. It will handle authentication challenges from loading network resources.

Use `oAuthUserConfigurations` to use the OAuth workflow for resources loaded from the given `portalUri`. Other authentication challenges are handled with a login dialog prompting the user for a username and password.

## Usage

```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Authenticator(
        oAuthUserConfigurations: [
          OAauthUserConfiguration(
            portalUri: Uri.parse('https://www.arcgis.com'),
            clientId: 'YOUR-CLIENT-ID',
            redirectUri: Uri.parse('YOUR-REDIRECT-URL'),
          ),
        ],
        child: ArcGISMapView(
          controllerProvider: () => _mapViewController,
        ),
      ),
    );
  }
```