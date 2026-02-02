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

part of '../../../arcgis_maps_toolkit.dart';

/// Widget to list and select building level. Selecting a level will apply
/// a filter to the building layer to highlight the selected level.
class _BuildingLevelSelector extends StatefulWidget {
  const _BuildingLevelSelector({required this.buildingSceneLayerState});

  final _BuildingSceneLayerState buildingSceneLayerState;

  @override
  State<StatefulWidget> createState() => _BuildingLevelSelectorState();
}

class _BuildingLevelSelectorState extends State<_BuildingLevelSelector> {
  // A listing of all levels in the building scene layer.
  var _levelList = <String>[];

  @override
  void initState() {
    super.initState();

    // Get the state for the new BuidlingSceneLayer
    _initLevelList();

    // Check if the selected level is still valid for the current state of the
    // building layer.
    _checkSelectedLevel();
  }

  @override
  void didUpdateWidget(_BuildingLevelSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset the state variables
    _levelList = <String>[];

    // Get the state for the new BuidlingSceneLayer
    _initLevelList();

    // Check if the selected level is still valid for the current state of the
    // building layer.
    _checkSelectedLevel();
  }

  @override
  Widget build(BuildContext context) {
    final options = ['All', ..._levelList];
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 20, 0),
      child: Row(
        children: [
          const Text('Level:'),
          const Spacer(),
          DropdownButton(
            value: options.length == 1
                ? 'All'
                : widget.buildingSceneLayerState.selectedLevel,
            items: options
                .map(
                  (value) => DropdownMenuItem(value: value, child: Text(value)),
                )
                .toList(),
            onChanged: onLevelChanged,
          ),
        ],
      ),
    );
  }

  Future<void> _initLevelList() async {
    // Get the level listing from the statistics.
    final statistics = await widget.buildingSceneLayerState.buildingSceneLayer
        .fetchStatistics();
    if (statistics[_BUILDING_LEVEL_ATTRIBUTE] != null) {
      final levelList = <String>[];
      levelList.addAll(
        statistics[_BUILDING_LEVEL_ATTRIBUTE]!.mostFrequentValues,
      );
      levelList.sort((a, b) {
        final intA = int.tryParse(a) ?? 0;
        final intB = int.tryParse(b) ?? 0;
        return intB.compareTo(intA);
      });

      // Setting state after await. Check if the widget is mounted.
      if (context.mounted) {
        setState(() {
          _levelList = levelList;
        });
      }
    }
  }

  void _checkSelectedLevel() {
    if (!identical(
      widget.buildingSceneLayerState.buildingSceneLayer.activeFilter,
      widget.buildingSceneLayerState.currentBuildingFilter,
    )) {
      // The active filter for the layer was not set by this widget. The
      // selected layer is invalid.
      widget.buildingSceneLayerState.selectedLevel = 'All';
    }

    // Update the building filter to the currently selected level.
    widget.buildingSceneLayerState.updateBuildingFilter();
  }

  void onLevelChanged(String? level) {
    if (level == null) return;

    setState(() => widget.buildingSceneLayerState.selectedLevel = level);
    widget.buildingSceneLayerState.updateBuildingFilter();
  }
}
