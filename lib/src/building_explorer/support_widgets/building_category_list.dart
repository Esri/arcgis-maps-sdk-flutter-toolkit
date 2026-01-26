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

/// Widget that lists the Disciplines in the Full Model in the building scene layer.
class _BuildingCategoryList extends StatelessWidget {
  const _BuildingCategoryList({
    required this.buildingSceneLayer,
    this.shrinkWrap = false,
    this.scrollPhysics,
  });

  final BuildingSceneLayer buildingSceneLayer;

  // shrinkWrap and scrollPhysics values will be applied to the ListView builder.
  final bool shrinkWrap;
  final ScrollPhysics? scrollPhysics;

  @override
  Widget build(BuildContext context) {
    final fullModelGroupSublayer = buildingSceneLayer.sublayers
        .whereType<BuildingGroupSublayer>()
        .where((sublayer) => sublayer.name == 'Full Model')
        .firstOrNull;

    final disciplineGroupSublayers =
        fullModelGroupSublayer?.sublayers
            .whereType<BuildingGroupSublayer>()
            .toList() ??
        [];

    disciplineGroupSublayers.sort(
      (discipline1, discipline2) =>
          discipline1.name.compareTo(discipline2.name),
    );

    return ListView.builder(
      itemCount: disciplineGroupSublayers.length,
      shrinkWrap: shrinkWrap,
      physics: scrollPhysics,
      itemBuilder: (context, index) {
        final categoryGroupSublayer = disciplineGroupSublayers[index];
        return _BuildingCategorySelector(
          buildingDiscipline: categoryGroupSublayer,
        );
      },
    );
  }
}
