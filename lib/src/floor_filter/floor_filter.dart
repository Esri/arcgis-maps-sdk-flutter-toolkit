//
// Copyright 2026 Esri
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

/// A widget for filtering map content by floor.
class FloorFilter extends StatefulWidget {
  /// Creates a floor filter.
  const FloorFilter({
    required this.floorFilterController,
    this.maxHeight,
    super.key,
  });

  /// The [FloorFilterController] for the widget.
  final FloorFilterController floorFilterController;

  /// The maximum height of the widget. If not set, a default of 80% of the
  /// screen height will be used.
  final double? maxHeight;

  /// Static function used to create the [FloorFilterController] for the widget.
  static FloorFilterController createController(
    GeoViewController geoViewController,
  ) {
    // Create the widget controller with the GeoView controller.
    final floorFilterController = FloorFilterController._(
      geoViewController: geoViewController,
    );

    // Initialize the widget controller.
    floorFilterController.refresh();

    return floorFilterController;
  }

  @override
  State<FloorFilter> createState() => _FloorFilterState();
}

class _FloorFilterState extends State<FloorFilter> {
  FloorManager? _floorManager;
  var _isNavigating = false;
  StreamSubscription<void>? _onViewpointChangedSubscription;
  StreamSubscription<bool>? _onNavigationChangedSubscription;

  @override
  void initState() {
    super.initState();
    // Get the current floor manager from the controller.
    _floorManager = widget.floorFilterController._floorManagerNotifier.value;

    // Listen for a refresh notification from the controller. When notified,
    // refresh the controller data and update the widget state.
    widget.floorFilterController._floorManagerNotifier.addListener(
      _onFloorManagerChanged,
    );

    // Listen for navigation and viewpoint changes in the GeoView.
    final geoViewController = widget.floorFilterController.geoViewController;
    _onNavigationChangedSubscription = geoViewController.onNavigationChanged
        .listen((isNavigating) {
          if (isNavigating == _isNavigating) return;
          _isNavigating = isNavigating;
        });
    _onViewpointChangedSubscription = geoViewController.onViewpointChanged
        .listen((_) {
          if (_isNavigating) {
            // Check autoselection for the changed viewpoint.
            widget.floorFilterController._autoSelect();
          }
        });
  }

  @override
  void didUpdateWidget(covariant FloorFilter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.floorFilterController == widget.floorFilterController) {
      return;
    }

    // Rebind value notifier listener and set new value.
    oldWidget.floorFilterController._floorManagerNotifier.removeListener(
      _onFloorManagerChanged,
    );
    _floorManager = widget.floorFilterController._floorManager;
    widget.floorFilterController._floorManagerNotifier.addListener(
      _onFloorManagerChanged,
    );
  }

  @override
  void dispose() {
    widget.floorFilterController._floorManagerNotifier.removeListener(
      _onFloorManagerChanged,
    );

    _onViewpointChangedSubscription?.cancel().ignore();
    _onViewpointChangedSubscription = null;
    _onNavigationChangedSubscription?.cancel().ignore();
    _onNavigationChangedSubscription = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_floorManager == null) {
      // Do not show the widget if this map or scene has no floor manager.
      return const SizedBox.shrink();
    }

    // Values for widget dimensions.
    final maxWidgetHeight =
        widget.maxHeight ?? MediaQuery.sizeOf(context).height * 0.8;
    const widgetWidth = 50.0;
    const decorationExtra = 22.0;

    // The height of the level selector is the height of the widget (maxWidgetHeight)
    // minus the height of the IconButton (widgetWidth) and the extra padding
    // and border heights (decorationExtra).
    final levelSelectorMaxHeight =
        maxWidgetHeight - widgetWidth - decorationExtra;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxWidgetHeight),
      child: Container(
        width: widgetWidth,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LevelSelector(
              floorFilterController: widget.floorFilterController,
              maxHeight: levelSelectorMaxHeight,
            ),
            SizedBox.square(
              dimension: widgetWidth,
              child: IconButton.filled(
                onPressed: _showSiteAndFacitliySelector,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.business_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onFloorManagerChanged() {
    setState(() {
      _floorManager = widget.floorFilterController._floorManager;
    });
  }

  // Function to show the bottom sheet containing the site and facility selectors.
  Future<void> _showSiteAndFacitliySelector() {
    return showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _SiteAndFacilitySelectorNavigator(
          floorFilterController: widget.floorFilterController,
          onClose: () => Navigator.pop(context),
        );
      },
    );
  }
}
