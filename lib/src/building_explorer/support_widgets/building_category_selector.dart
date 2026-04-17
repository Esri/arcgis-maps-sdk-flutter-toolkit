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

/// A widget that provides a discipline and a collapsible list of categories under
/// the discipline. Each item has a checkbox that will show/hide the discipline or
/// category. If the discipline is hidden, the underlying category checkboxes are
/// disabled.
class _BuildingCategorySelector extends StatefulWidget {
  const _BuildingCategorySelector({required this.buildingDiscipline});

  final BuildingGroupSublayer buildingDiscipline;

  @override
  State<StatefulWidget> createState() => _BuildingCategorySelectorState();
}

class _BuildingCategorySelectorState extends State<_BuildingCategorySelector> {
  @override
  Widget build(BuildContext context) {
    final sortedCategories = widget.buildingDiscipline.sublayers.toList();
    sortedCategories.sort(
      (sublayer1, sublayer2) => sublayer1.name.compareTo(sublayer2.name),
    );

    return ExpansionTile(
      title: Row(
        children: [
          Text(widget.buildingDiscipline.name),
          const Spacer(),
          Checkbox(
            value: widget.buildingDiscipline.isVisible,
            onChanged: (val) {
              setState(() {
                widget.buildingDiscipline.isVisible = val ?? false;
              });
            },
          ),
        ],
      ),
      children: sortedCategories.map((componentSublayer) {
        return CheckboxListTile(
          title: Text(componentSublayer.name),
          value: componentSublayer.isVisible,
          enabled: widget.buildingDiscipline.isVisible,
          onChanged: (val) {
            setState(() {
              componentSublayer.isVisible = val ?? false;
            });
          },
        );
      }).toList(),
    );
  }
}
