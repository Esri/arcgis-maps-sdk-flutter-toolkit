## 0.0.0+0 # version will be set during export in ci/stamp_toolkit.sh

### Enhancements to PopupView

* Support for navigating through associations in a utility network has been added in this release. This integrates the newly exposed `UtilityAssociationsPopupElement` API with the toolkit component.
* To enable this change, the main `PopupView` is now wrapped in a `Navigator` widget. No behavior changes are expected to existing apps using the `PopupView` from the `arcgis_maps_toolkit` package on pub.dev. However this may need to be taken into account if any custom implementations of the `PopupView` are updated.

## 200.8.0+4672

* First release of ArcGIS Maps SDK for Flutter Toolkit

### New Toolkit Components
* Authenticator 
* Compass
* OverviewMap
* PopupView
