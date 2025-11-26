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

class BuildingExplorer extends StatefulWidget {
  const BuildingExplorer({
    required this.buildingSceneLayer,
    super.key,
    this.overviewSublayerName = 'Overview',
    this.fullModelSublayerName = 'Full Model',
  });

  final BuildingSceneLayer buildingSceneLayer;
  final String overviewSublayerName;
  final String fullModelSublayerName;

  @override
  State<StatefulWidget> createState() => _BuildingExplorerState();
}

class _BuildingExplorerState extends State<BuildingExplorer> {
  // The currently selected floor.
  var _selectedFloor = 'All';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
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

// Widget to list and select building floor.
class _FloorLevelSelector extends StatelessWidget {
  const _FloorLevelSelector({
    required this.floorList,
    required this.selectedFloor,
    required this.onChanged,
  });

  final List<String> floorList;
  final String selectedFloor;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = ['All', ...floorList];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Text('Floor:'),
        DropdownButton<String>(
          value: selectedFloor,
          items: options
              .map(
                (value) => DropdownMenuItem(value: value, child: Text(value)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ],
    );
  }
}

// Widget to show and select building sublayers.
class _SublayerSelector extends StatefulWidget {
  const _SublayerSelector({
    required this.buildingSceneLayer,
    required this.fullModelSublayerName,
  });
  final BuildingSceneLayer buildingSceneLayer;
  final String fullModelSublayerName;

  @override
  State<_SublayerSelector> createState() => _SublayerSelectorState();
}

class _SublayerSelectorState extends State<_SublayerSelector> {
  @override
  Widget build(BuildContext context) {
    final fullModelSublayer =
        widget.buildingSceneLayer.sublayers.firstWhere(
              (sublayer) => sublayer.name == 'Full Model',
            )
            as BuildingGroupSublayer;
    final categorySublayers = fullModelSublayer.sublayers;
    return SizedBox(
      height: 200,
      child: ListView(
        children: categorySublayers.map((categorySublayer) {
          final componentSublayers =
              (categorySublayer as BuildingGroupSublayer).sublayers;
          return ExpansionTile(
            title: Row(
              children: [
                Text(categorySublayer.name),
                const Spacer(),
                Checkbox(
                  value: categorySublayer.isVisible,
                  onChanged: (val) {
                    setState(() {
                      categorySublayer.isVisible = val ?? false;
                    });
                  },
                ),
              ],
            ),
            children: componentSublayers.map((componentSublayer) {
              return CheckboxListTile(
                title: Text(componentSublayer.name),
                value: componentSublayer.isVisible,
                onChanged: (val) {
                  setState(() {
                    componentSublayer.isVisible = val ?? false;
                  });
                },
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
