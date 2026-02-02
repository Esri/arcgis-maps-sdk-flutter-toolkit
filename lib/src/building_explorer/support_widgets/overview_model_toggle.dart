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

/// Widget to toggle Overview/Full Model sublayer visibility.
class _OverviewModelToggle extends StatefulWidget {
  const _OverviewModelToggle({
    required this.layerState,
    this.onOverviewVisibilityChanged,
  });

  /// The state info for the selected buidling scene layer.
  final _BuildingSceneLayerState layerState;
  final void Function(bool isOverviewVisible)? onOverviewVisibilityChanged;

  @override
  State<_OverviewModelToggle> createState() => _OverviewModelToggleState();
}

class _OverviewModelToggleState extends State<_OverviewModelToggle> {
  @override
  Widget build(BuildContext context) {
    if (widget.layerState.overviewSublayer == null) {
      // Show nothing if there is no overview model.
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        const Text('Show Overview'),
        const Spacer(),
        Switch(
          value: widget.layerState.showOverview,
          onChanged: (newValue) {
            // Set the Full Model sublayer visibility
            widget.layerState.buildingSceneLayer.sublayers
                    .firstWhere((layer) => layer.name == 'Full Model')
                    .isVisible =
                !newValue;

            // If the Overview is visible, remove the applied layer filters.
            if (newValue) {
              widget.layerState.buildingSceneLayer.activeFilter = null;
            }

            setState(() {
              // Set the Overview sublayer visiblity.
              widget.layerState.overviewSublayer!.isVisible = newValue;
            });

            widget.onOverviewVisibilityChanged?.call(newValue);
          },
        ),
      ],
    );
  }
}
