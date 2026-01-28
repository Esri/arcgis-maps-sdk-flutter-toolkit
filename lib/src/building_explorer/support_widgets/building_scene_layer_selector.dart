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

/// Widget to select the building scene layer that the Building Explorer is editing.
/// If the scene only has one building scene layer, the dropdown will be replaced
/// with a label with the name of the layer.
class _BuildingSceneLayerSelector extends StatelessWidget {
  const _BuildingSceneLayerSelector({
    required BuildingExplorerController buildingExplorerController,
    this.onBuildingSceneChanged,
  }) : widgetController = buildingExplorerController;

  final BuildingExplorerController widgetController;
  final void Function(BuildingSceneLayer? selectedBuildingSceneLayer)?
  onBuildingSceneChanged;

  @override
  Widget build(BuildContext context) {
    // Building scene layer name centered
    if (widgetController._buildingSceneLayerStates.length == 1) {
      return Text(
        widgetController._selectedLayer!.name,
        style: Theme.of(context).textTheme.headlineSmall,
        textAlign: TextAlign.center,
      );
    } else {
      // Dropdown to select building from scene.
      return DropdownButton(
        value: widgetController._selectedLayer,
        items: widgetController._buildingSceneLayerStates.keys
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
            )
            .toList(),
        onChanged: onBuildingSceneChanged,
      );
    }
  }
}
