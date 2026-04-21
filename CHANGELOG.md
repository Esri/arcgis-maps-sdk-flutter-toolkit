## 0.0.0+0 # version will be set during export in ci/stamp_toolkit.sh

### Enhancements to PopupView

* This release includes support for navigating through utility network associations. It uses the newly available `UtilityAssociationsPopupElement` API with the toolkit component.
  * To enable this change, the main `PopupView` is now wrapped in a `Navigator` widget. No behavior changes are expected to existing apps using the `PopupView` from the `arcgis_maps_toolkit` package on pub.dev. However, if you maintain custom implementations of the `PopupView` and wish to update, you may need to review them to take into account of this change.
* Support for edit summary: The localized summary of when the popup was last edited or created by a known editor or author.

### Support for Local Scene View

* New `BuildingExplorer` Toolkit component: A widget that enables a user to explore a building model in a building scene layer.
* `Compass` and `Overview Map` components enhanced with support for local scene view.

### Enhancements to Authenticator
* `Authenticator` enhanced with support for Identity Aware Proxy (IAP) authentication.

## 200.8.0+4672

* First release of ArcGIS Maps SDK for Flutter Toolkit

### New Toolkit Components
* Authenticator 
* Compass
* OverviewMap
* PopupView
