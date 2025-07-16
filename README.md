# ArcGIS Maps SDK for Flutter Toolkit

ArcGIS Maps SDK for Flutter Toolkit contains ready-made widgets to simplify the development of mapping and GIS apps with Flutter. Use with the [ArcGIS Maps SDK for Flutter](https://developers.arcgis.com/flutter/).

## Toolkit components

* Authenticator: A widget that handles authentication challenges. It will display a user interface when network and ArcGIS authentication challenges occur.
* Compass: A widget that visualizes the current rotation of the map or scene and allows the user to reset the rotation to north by tapping on it.
* OverviewMap: A small inset map displaying a representation of the current viewpoint of the target map or scene.
* PopupView: A widget that will display a pop-up for an individual feature. This includes showing the feature's title, attributes, custom description, media, and attachments.

## Platform support
* Use a macOS development host to deploy to iOS & Android mobile devices.
* Use a Windows development host to deploy to Android mobile devices.

For more information, view our detailed [System requirements](https://developers.arcgis.com/flutter/system-requirements/).

## Get started

The `arcgis_maps_toolkit` package requires [arcgis_maps](https://pub.dev/packages/arcgis_maps) to be [installed](https://developers.arcgis.com/flutter/install-and-set-up/) before use.

Once you have [added arcgis_maps_toolkit to your app as a dependency](https://developers.arcgis.com/flutter/toolkit#install-from-pubdev), import the package and start using the provided widgets.

```dart
import 'package:arcgis_maps_toolkit/arcgis_maps_toolkit.dart';
```

## Examples

Example applications demonstrating each of the toolkit components can be found in the `arcgis-maps-sdk-flutter-toolkit` Github repository. Clone the repository and then within the `example` directory you will find a readme detailing how to run the example applications.

Alternatively, run the following command:
`dart pub unpack arcgis_maps_toolkit`
This will download and unpack the package, including the examples, into the current directory. 

## API reference

API reference for each of the toolkit components can be found via the ArcGIS Maps SDK for Flutter [developer guide](https://developers.arcgis.com/flutter).

# Additional resources

* New to ArcGIS? Explore our documentation: [Guide](https://developers.arcgis.com/flutter) | [API Reference](https://links.esri.com/flutter-api-ref)
* Got a question? Ask the community on our [forum](https://links.esri.com/flutter-community).

# Contributing
Esri welcomes contributions from anyone and everyone. Please see our [guidelines for contributing](https://github.com/esri/contributing).
