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

class _BuildingLevelSelector extends StatefulWidget {
  const _BuildingLevelSelector({required this.buildingSceneLayer});

  final BuildingSceneLayer buildingSceneLayer;

  @override
  State<StatefulWidget> createState() => _BuildingLevelSelectorState();
}

// Widget to list and select building level.
class _BuildingLevelSelectorState extends State<_BuildingLevelSelector> {
  // The currently selected level.
  var _selectedLevel = 'All';

  // A listing of all levels in the building scene layer.
  var _levelList = <String>[];

  // Name constants
  final _filterName = 'Level filter';
  final _levelBlockName = 'solid block';
  final _xrayBlockName = 'xray block';
  final _buildingLevelAttribute = 'BldgLevel';

  @override
  void initState() {
    super.initState();

    // Get the level listing from the layer statistics, then look for a
    // currently selected level level.
    _initLevelList().then((_) => _initSelectedLevel());
  }

  @override
  Widget build(BuildContext context) {
    final options = ['All', ..._levelList];
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 20, 0),
      child: Row(
        children: [
          Text('Level:', style: Theme.of(context).textTheme.bodyLarge),
          const Spacer(),
          DropdownButton(
            value: _selectedLevel,
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
    final statistics = await widget.buildingSceneLayer.fetchStatistics();
    if (statistics[_buildingLevelAttribute] != null) {
      final levelList = <String>[];
      levelList.addAll(statistics[_buildingLevelAttribute]!.mostFrequentValues);
      levelList.sort((a, b) {
        final intA = int.tryParse(a) ?? 0;
        final intB = int.tryParse(b) ?? 0;
        return intB.compareTo(intA);
      });
      setState(() {
        _levelList = levelList;
      });
    }
  }

  void _initSelectedLevel() {
    final activeFilter = widget.buildingSceneLayer.activeFilter;
    if (activeFilter != null) {
      if (activeFilter.name == _filterName) {
        // Get the selected level from the where clause of the solid filter block.
        final levelBlock = activeFilter.blocks
            .where((block) => block.title == _levelBlockName)
            .firstOrNull;
        if (levelBlock != null) {
          setState(
            () => _selectedLevel = levelBlock.whereClause.split(' ').last,
          );
        }
      }
    }
  }

  void onLevelChanged(String? level) {
    if (level == null) return;

    setState(() => _selectedLevel = level);
    updateLevelFilters();
  }

  // Utility function to update the building filters based on the selected level.
  void updateLevelFilters() {
    if (_selectedLevel == 'All') {
      // No filtering applied if 'All' levels are selected.
      widget.buildingSceneLayer.activeFilter = null;
      return;
    }

    // Build a building filter to show the selected level and an xray view of the levels below.
    // levels above the selected level are not shown at all.
    final buildingFilter = BuildingFilter(
      name: _filterName,
      description: 'Show selected level and xray filter for lower levels.',
      blocks: [
        BuildingFilterBlock(
          title: _levelBlockName,
          whereClause: '$_buildingLevelAttribute = $_selectedLevel',
          mode: BuildingSolidFilterMode(),
        ),
        BuildingFilterBlock(
          title: _xrayBlockName,
          whereClause: '$_buildingLevelAttribute < $_selectedLevel',
          mode: BuildingXrayFilterMode(),
        ),
      ],
    );

    // Apply the filter to the building scene layer.
    widget.buildingSceneLayer.activeFilter = buildingFilter;
  }
}
