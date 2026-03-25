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
class _LayerVisibilityToggle extends StatefulWidget {
  const _LayerVisibilityToggle({
    required this.layerState,
    this.onLayerVisibilityChanged,
  });

  /// The state info for the selected buidling scene layer.
  final _BuildingSceneLayerState layerState;
  final void Function(bool isLayerVisible)? onLayerVisibilityChanged;

  @override
  State<_LayerVisibilityToggle> createState() => _LayerVisibilityToggleState();
}

class _LayerVisibilityToggleState extends State<_LayerVisibilityToggle> {
  @override
  Widget build(BuildContext context) {
    if (widget.layerState.fullModelSublayer == null) {
      // Show nothing if there is no overview model.
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        const Text('Visible'),
        const Spacer(),
        Switch(
          value: widget.layerState.buildingSceneLayer.isVisible,
          onChanged: (newValue) {
            setState(() {
              // Set the layer's visiblity.
              widget.layerState.buildingSceneLayer.isVisible = newValue;
            });

            widget.onLayerVisibilityChanged?.call(newValue);
          },
        ),
      ],
    );
  }
}
