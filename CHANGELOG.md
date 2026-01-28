## 0.0.0+0 # version will be set during export in ci/stamp_toolkit.sh

### Enhancements to PopupView

* This release includes support for navigating through utility network associations. It uses the newly available `UtilityAssociationsPopupElement` API with the toolkit component.
* To enable this change, the main `PopupView` is now wrapped in a `Navigator` widget. No behavior changes are expected to existing apps using the `PopupView` from the `arcgis_maps_toolkit` package on pub.dev. However, if you maintain custom implementations of the `PopupView` and wish to update, you may need to review them to take into account of this change.

## 200.8.0+4672

* First release of ArcGIS Maps SDK for Flutter Toolkit

### New Toolkit Components
* Authenticator
* Compass
* OverviewMap
* PopupView
