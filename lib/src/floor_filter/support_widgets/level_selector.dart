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

part of '../../../arcgis_maps_toolkit.dart';

/// A widget for selecting a floor level in the selected facility.
/// - floorFilterController: the [FloorFilterController] for this widget.
/// - maxHeight: the maximum height of this widget provided by the parent.
class _LevelSelector extends StatefulWidget {
  const _LevelSelector({
    required FloorFilterController floorFilterController,
    required this.maxHeight,
  }) : _widgetController = floorFilterController;

  final FloorFilterController _widgetController;

  // The maximum height that the LevelSelector can occupy.
  final double maxHeight;

  @override
  State<_LevelSelector> createState() => _LevelSelectorState();
}

class _LevelSelectorState extends State<_LevelSelector> {
  // All levels for the current facility.
  var _facilityLevels = <_LevelListDetail>[];

  // Currently selected level.
  FloorLevel? _selectedLevel;

  // Flag indicating whether the expanded or collapsed view is showing.
  var _expandedView = true;

  @override
  void initState() {
    super.initState();
    // Set the initial selectedLevel.
    _selectedLevel = widget._widgetController._selectedLevelNotifier.value;

    // Get the levels from the currently selected facility.
    _facilityLevels = _refreshFacilityLevelListDetails();

    // Listen for any changes to the selected facility.
    widget._widgetController._selectedFacilityNotifier.addListener(
      _onSelectedFacilityChanged,
    );

    // Listen for any changes to the selected level.
    widget._widgetController._selectedLevelNotifier.addListener(
      _onSelectedLevelChanged,
    );
  }

  @override
  void didUpdateWidget(covariant _LevelSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget._widgetController == widget._widgetController) return;

    // Rebind value notifier listeners.
    oldWidget._widgetController._selectedFacilityNotifier.removeListener(
      _onSelectedFacilityChanged,
    );
    _facilityLevels = _refreshFacilityLevelListDetails();
    widget._widgetController._selectedFacilityNotifier.addListener(
      _onSelectedFacilityChanged,
    );
    oldWidget._widgetController._selectedLevelNotifier.removeListener(
      _onSelectedLevelChanged,
    );
    _selectedLevel = widget._widgetController._selectedLevel;
    widget._widgetController._selectedLevelNotifier.addListener(
      _onSelectedLevelChanged,
    );
  }

  @override
  void dispose() {
    widget._widgetController._selectedFacilityNotifier.removeListener(
      _onSelectedFacilityChanged,
    );
    widget._widgetController._selectedLevelNotifier.removeListener(
      _onSelectedLevelChanged,
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_facilityLevels.isEmpty) {
      return const SizedBox.shrink();
    }

    // The maximum height of the level listing. It is the maximum height of the
    // widget minus the height of the button.
    const padding = 24.0;
    final listViewMaxHeight = widget.maxHeight - padding;

    // Text style for selected level.
    final selectedLevelTextStyle = DefaultTextStyle.of(context).style
        .apply(fontWeightDelta: 2, fontSizeFactor: 1.3);

    // Text style for unselected level.
    final unselectedLevelTextStyle = DefaultTextStyle.of(context).style;

    // Button style applied to the level selection buttons.
    final buttonStyle = OutlinedButton.styleFrom(
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: const BorderSide(color: Colors.white),
      backgroundColor: Colors.white,
    );

    return listViewMaxHeight < padding
        // If listViewMaxHeight too small, don't show the widget.
        ? const SizedBox.shrink()
        : Column(
            children: [
              Padding(
                padding: EdgeInsets.zero,
                child: SizedBox(
                  height: 24,
                  child: OutlinedButton(
                    onPressed: () =>
                        setState(() => _expandedView = !_expandedView),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      side: const BorderSide(color: Colors.black12),
                      backgroundColor: Colors.white,
                    ),
                    child: _expandedView
                        ? const Icon(Icons.expand_more_outlined, size: 18)
                        : const Icon(Icons.expand_less_outlined, size: 18),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: listViewMaxHeight,
                  minHeight: padding,
                ),
                child: _expandedView
                    // Show the whole list for the expandedView.
                    ? ListView.builder(
                        shrinkWrap: true,
                        reverse: true,
                        padding: EdgeInsets.zero,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _facilityLevels.length,
                        itemBuilder: (context, index) {
                          final levelDetail = _facilityLevels[index];
                          return OutlinedButton(
                            onPressed: () => widget._widgetController
                                ._selectLevel(levelDetail.level),
                            style: buttonStyle,
                            child: Text(
                              levelDetail.shortName,
                              style: levelDetail.level == _selectedLevel
                                  ? selectedLevelTextStyle
                                  : unselectedLevelTextStyle,
                            ),
                          );
                        },
                      )
                    // Only show the selected level for non-expandedView.
                    : _selectedLevel == null &&
                          widget._widgetController.geoViewController
                              is ArcGISMapViewController
                    ? const SizedBox.shrink()
                    : OutlinedButton(
                        onPressed: () =>
                            setState(() => _expandedView = !_expandedView),
                        style: buttonStyle,
                        child: Text(
                          _selectedLevel?.shortName ?? 'All',
                          style: selectedLevelTextStyle,
                        ),
                      ),
              ),
            ],
          );
  }

  void _onSelectedFacilityChanged() {
    final levels = _refreshFacilityLevelListDetails();
    setState(() {
      _facilityLevels = levels;
    });
  }

  void _onSelectedLevelChanged() {
    setState(() {
      _selectedLevel = widget._widgetController._selectedLevelNotifier.value;
    });
  }

  List<_LevelListDetail> _refreshFacilityLevelListDetails() {
    final facilityLevels =
        widget._widgetController._selectedFacilityNotifier.value?.levels ??
        <FloorLevel>[];

    final levelDetails = <_LevelListDetail>[];
    if (facilityLevels.isNotEmpty) {
      if (widget._widgetController.geoViewController
              is ArcGISLocalSceneViewController ||
          widget._widgetController.geoViewController
              is ArcGISSceneViewController) {
        // Add "All" option for 3D views.
        levelDetails.add(_LevelListDetail(level: null, shortName: 'All'));
      }
      for (final level in facilityLevels) {
        levelDetails.add(_LevelListDetail.fromFloorLevel(level));
      }
    }

    return levelDetails;
  }
}

class _LevelListDetail {
  _LevelListDetail({required this.level, required this.shortName});

  factory _LevelListDetail.fromFloorLevel(FloorLevel level) {
    return _LevelListDetail(level: level, shortName: level.shortName);
  }

  final FloorLevel? level;
  final String shortName;
}
