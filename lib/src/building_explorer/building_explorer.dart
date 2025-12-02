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
    this.fullModelSublayerName = 'Full Model',
  });

  final BuildingSceneLayer buildingSceneLayer;
  final String fullModelSublayerName;

  @override
  State<StatefulWidget> createState() => _BuildingExplorerState();
}

class _BuildingExplorerState extends State<BuildingExplorer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.buildingSceneLayer.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const Divider(),
        _BuildingFloorLevelSelector(
          buildingSceneLayer: widget.buildingSceneLayer,
        ),
        const Divider(),
        Text(
          'Disciplines & Categories:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Expanded(
          child: _BuildingSublayerSelector(
            buildingSceneLayer: widget.buildingSceneLayer,
            fullModelSublayerName: widget.fullModelSublayerName,
          ),
        ),
      ],
    );
  }
}
