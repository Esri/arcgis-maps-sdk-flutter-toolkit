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

part of '../../arcgis_maps_toolkit.dart';

class _BuildingFloorLevelSelector extends StatefulWidget {
  const _BuildingFloorLevelSelector({required this.buildingSceneLayer});

  final BuildingSceneLayer buildingSceneLayer;

  @override
  State<StatefulWidget> createState() => _BuildingFloorLevelSelectorState();
}

// Widget to list and select building floor.
class _BuildingFloorLevelSelectorState
    extends State<_BuildingFloorLevelSelector> {
  // The currently selected floor.
  var _selectedFloor = 'All';

  // A listing of all floors in the building scene layer.
  var _floorList = <String>[];

  @override
  void initState() {
    super.initState();

    _initFloorList();
  }

  @override
  Widget build(BuildContext context) {
    final options = ['All', ..._floorList];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Text('Select Level:'),
        DropdownButton<String>(
          value: _selectedFloor,
          items: options
              .map(
                (value) => DropdownMenuItem(value: value, child: Text(value)),
              )
              .toList(),
          onChanged: onFloorChanged,
        ),
      ],
    );
  }

  Future<void> _initFloorList() async {
    // Get the floor listing from the statistics.
    final statistics = await widget.buildingSceneLayer.fetchStatistics();
    if (statistics['BldgLevel'] != null) {
      final floorList = <String>[];
      floorList.addAll(statistics['BldgLevel']!.mostFrequentValues);
      floorList.sort((a, b) => int.parse(b).compareTo(int.parse(a)));
      setState(() {
        _floorList = floorList;
      });
    }
  }

  void onFloorChanged(String? floor) {
    if (floor == null) return;

    setState(() => _selectedFloor = floor);
    updateFloorFilters();
  }

  // Utility function to update the building filters based on the selected floor.
  void updateFloorFilters() {
    if (_selectedFloor == 'All') {
      // No filtering applied if 'All' floors are selected.
      widget.buildingSceneLayer.activeFilter = null;
      return;
    }

    // Build a building filter to show the selected floor and an xray view of the floors below.
    // Floors above the selected floor are not shown at all.
    final buildingFilter = BuildingFilter(
      name: 'Floor filter',
      description: 'Show selected floor and xray filter for lower floors.',
      blocks: [
        BuildingFilterBlock(
          title: 'solid block',
          whereClause: 'BldgLevel = $_selectedFloor',
          mode: BuildingSolidFilterMode(),
        ),
        BuildingFilterBlock(
          title: 'xray block',
          whereClause: 'BldgLevel < $_selectedFloor',
          mode: BuildingXrayFilterMode(),
        ),
      ],
    );

    // Apply the filter to the building scene layer.
    widget.buildingSceneLayer.activeFilter = buildingFilter;
  }
}
