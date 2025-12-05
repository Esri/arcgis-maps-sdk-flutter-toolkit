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

class BuildingExplorer extends StatelessWidget {
  const BuildingExplorer({
    required this.buildingSceneLayer,
    this.fullModelSublayerName = 'Full Model',
    this.onClose,
    super.key,
  });

  // BuildingSceneLayer that this widget explores
  final BuildingSceneLayer buildingSceneLayer;

  // Name of the full model group sublayer
  final String fullModelSublayerName;

  // Optional onClose callback. If set, a close IconButton will appear to the
  // right of the widget title.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Centered title
            Text(
              buildingSceneLayer.name,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            // Right-justified icon button
            if (onClose != null)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  tooltip: 'Close',
                ),
              ),
          ],
        ),
        const Divider(),
        _BuildingFloorLevelSelector(buildingSceneLayer: buildingSceneLayer),
        const Divider(),
        Text(
          'Disciplines & Categories:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Expanded(
          child: _BuildingCategoryList(
            buildingSceneLayer: buildingSceneLayer,
            fullModelSublayerName: fullModelSublayerName,
          ),
        ),
      ],
    );
  }
}
