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
/// - maxHeight: the maximum height of this widget provided by the parent.'.
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
  // Subscription for facility change notifications.
  StreamSubscription<FloorFacility?>? _onFacilityChangedSubscription;
  // Subscription for level change notifications.
  StreamSubscription<FloorLevel?>? _onLevelChangedSubscription;

  // All levels for the current facility.
  var _facilityLevels = <FloorLevel>[];

  // Currenlty selected level.
  FloorLevel? _selectedLevel;

  // Flag indicating whether the expanded or collapsed view is showing.
  bool _expandedView = true;

  @override
  void initState() {
    super.initState();
    // Set the initial selectedLevel.
    _selectedLevel = widget._widgetController._selectedLevel;

    // Get the levels from the currently selected facility.
    _facilityLevels =
        widget._widgetController._selectedFacility?.levels ?? <FloorLevel>[];

    // Listen for any changes to the selected facility.
    _onFacilityChangedSubscription = widget._widgetController._onFacilityChanged
        .listen((newFacility) {
          if (mounted) {
            setState(
              () => _facilityLevels = newFacility?.levels ?? <FloorLevel>[],
            );
          }
        });

    // Listen for any changes to the selected level.
    _onLevelChangedSubscription = widget._widgetController._onLevelChanged
        .listen((newLevel) {
          if (mounted) {
            setState(() => _selectedLevel = newLevel);
          }
        });
  }

  // TODO(kmueller-gis): Add didUpdateWidget override to resize the widget if height changes.

  @override
  void dispose() {
    _onFacilityChangedSubscription?.cancel().ignore();
    _onFacilityChangedSubscription = null;
    _onLevelChangedSubscription?.cancel().ignore();
    _onLevelChangedSubscription = null;

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
    final listViewMaxHeight = widget.maxHeight > padding
        ? widget.maxHeight - padding
        : padding;

    // Text style for selected level.
    final selectedLevelTextStyle = DefaultTextStyle.of(
      context,
    ).style.apply(fontWeightDelta: 2, fontSizeFactor: 1.3);

    // Text style for unselected level.
    final unselectedLevelTextStyle = DefaultTextStyle.of(context).style;

    // Button style applied to the level selection buttons.
    final buttonStyle = OutlinedButton.styleFrom(
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: const BorderSide(color: Colors.white),
      backgroundColor: Colors.white,
    );

    return Column(
      children: [
        Padding(
          // padding: const EdgeInsets.only(bottom: 4),
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: 24,
            child: OutlinedButton(
              onPressed: () => setState(() => _expandedView = !_expandedView),
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
                    final level = _facilityLevels[index];
                    return OutlinedButton(
                      onPressed: () =>
                          widget._widgetController._selectLevel(level),
                      style: buttonStyle,
                      child: level == _selectedLevel
                          ? Text(level.shortName, style: selectedLevelTextStyle)
                          : Text(
                              level.shortName,
                              style: unselectedLevelTextStyle,
                            ),
                    );
                  },
                )
              // Only show the selected level for non-expandedView.
              : _selectedLevel != null
              ? OutlinedButton(
                  onPressed: () =>
                      setState(() => _expandedView = !_expandedView),
                  style: buttonStyle,
                  child: Text(
                    _selectedLevel!.shortName,
                    style: selectedLevelTextStyle,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
