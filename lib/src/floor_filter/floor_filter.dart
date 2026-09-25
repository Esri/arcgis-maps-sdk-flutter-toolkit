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
    return FloorFilterController._(geoViewController: geoViewController);
  }

  @override
  State<FloorFilter> createState() => _FloorFilterState();
}

class _FloorFilterState extends State<FloorFilter> {
  FloorManager? _floorManager;
  StreamSubscription<Null>? _onRequestFloorFilterRefreshSubscription;
  late final double _maxWidgetHeight =
      widget.maxHeight ?? MediaQuery.sizeOf(context).height * 0.8;

  @override
  void initState() {
    super.initState();

    // Listen for a refresh notification from the controller. When notified,
    // refresh the controller data and update the widget state.
    _onRequestFloorFilterRefreshSubscription = widget
        .floorFilterController
        ._onRequestFloorFilterRefresh
        .listen((_) async {
          await widget.floorFilterController._resetFloorManager();
          if (mounted) {
            setState(() {
              _floorManager = widget.floorFilterController._floorManager;
            });
          }
        });
  }

  @override
  void dispose() {
    _onRequestFloorFilterRefreshSubscription?.cancel().ignore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_floorManager == null) {
      // Do not show the widget if this map or scene has no floor manager.
      return const SizedBox.shrink();
    }

    const widgetWidth = 50.0;
    const decorationExtra = 22.0;

    // The height of the level selector is the height of the widget (_maxWidgetHeight)
    // minus the height of the IconButton (widgetWidth) and the extra padding
    // and border heights (decorationExtra).
    final levelSelectorMaxHeight =
        _maxWidgetHeight - widgetWidth - decorationExtra;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: _maxWidgetHeight),
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
                onPressed: showSiteAndFacitliySelector,
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

  Future<void> showSiteAndFacitliySelector() {
    return showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _SiteAndFacilitySelectorNavigator(
          floorFilterController: widget.floorFilterController,
        );
      },
    );
  }
}
