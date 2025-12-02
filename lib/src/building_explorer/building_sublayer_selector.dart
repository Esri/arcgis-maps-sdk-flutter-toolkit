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

// Widget to show and select building sublayers.
class _BuildingSublayerSelector extends StatefulWidget {
  const _BuildingSublayerSelector({
    required this.buildingSceneLayer,
    required this.fullModelSublayerName,
  });
  final BuildingSceneLayer buildingSceneLayer;
  final String fullModelSublayerName;

  @override
  State<_BuildingSublayerSelector> createState() =>
      _BuildingSublayerSelectorState();
}

class _BuildingSublayerSelectorState extends State<_BuildingSublayerSelector> {
  @override
  Widget build(BuildContext context) {
    final fullModelSublayer =
        widget.buildingSceneLayer.sublayers.firstWhere(
              (sublayer) => sublayer.name == 'Full Model',
            )
            as BuildingGroupSublayer;
    final categorySublayers = fullModelSublayer.sublayers;
    return ListView(
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
              enabled: categorySublayer.isVisible,
              onChanged: (val) {
                setState(() {
                  componentSublayer.isVisible = val ?? false;
                });
              },
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
