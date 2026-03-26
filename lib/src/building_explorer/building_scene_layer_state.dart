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

// Defining constant names as UPPER_SNAKE_CASE
// ignore_for_file: constant_identifier_names

part of '../../arcgis_maps_toolkit.dart';

/// Building Explorer constants.
const _FILTER_NAME = 'Building Explorer level filter';
const _SOLID_BLOCK_NAME = 'solid block';
const _XRAY_BLOCK_NAME = 'xray block';
const _BUILDING_LEVEL_ATTRIBUTE = 'BldgLevel';
const _CONSTRUCTION_PHASE_ATTRIBUTES = 'CreatedPhase';
const _FULL_MODEL_SUBLAYER_MODEL_NAME = 'FullModel';
const _OVERVIEW_SUBLAYER_MODEL_NAME = 'Overview';

/// Class that records the state of a single building scene layer. The
/// properties of this class drive UI elements for a specific building scene layer.
class _BuildingSceneLayerState {
  /// Private constructor. Instantiate with factory constructor.
  _BuildingSceneLayerState._({
    required this.buildingSceneLayer,
    this.selectedLevel = 'All',
    this.selectedConstructionPhase,
  });

  /// Creates and initializes a [BuildingSceneLayerState] object for the
  /// privided [BuildingSceneLayer].
  factory _BuildingSceneLayerState.withBuildingSceneLayer(
    BuildingSceneLayer layer, {
    String selectedLevel = 'All',
    String? selectedConstructionPhase,
  }) {
    return _BuildingSceneLayerState._(
      buildingSceneLayer: layer,
      selectedLevel: selectedLevel,
      selectedConstructionPhase: selectedConstructionPhase,
    );
  }

  /// The [BuildingSceneLayer] for this [BuildingSceneLayerState].
  BuildingSceneLayer buildingSceneLayer;

  /// The currently selected building level. This can be 'All' or the level name.
  String selectedLevel;

  /// The currently selected construction phase. This can be 'null' or the phase name.
  String? selectedConstructionPhase;

  /// The current [BuildingFilter] for the selected level. If the selected level
  /// is 'All' this filter will be null.
  BuildingFilter? currentBuildingFilter;

  /// Full Model sublayer if one exists in the building scene layer.
  BuildingGroupSublayer? get fullModelSublayer {
    // Check if the layer has an Full Model sublayer
    final fullModelSublayerIndex = buildingSceneLayer.sublayers.indexWhere(
      (layer) => layer.modelName == _FULL_MODEL_SUBLAYER_MODEL_NAME,
    );
    return fullModelSublayerIndex > -1
        ? buildingSceneLayer.sublayers[fullModelSublayerIndex]
              as BuildingGroupSublayer
        : null;
  }

  /// Overview sublayer if one exists in the building scene layer.
  BuildingSublayer? get overviewSublayer {
    // Check if the layer has an Full Model sublayer
    final overviewSublayerIndex = buildingSceneLayer.sublayers.indexWhere(
      (layer) => layer.modelName == _OVERVIEW_SUBLAYER_MODEL_NAME,
    );
    return overviewSublayerIndex > -1
        ? buildingSceneLayer.sublayers[overviewSublayerIndex]
        : null;
  }

  /// Flag for the state of the Show Full Model toggle control.
  bool get showFullModel => fullModelSublayer?.isVisible ?? true;

  /// Function to build a [BuildingFilter] based on the currently selected level
  /// and construction phase.
  void updateBuildingFilter() {
    if (selectedLevel == 'All' && selectedConstructionPhase == null) {
      currentBuildingFilter = null;
      buildingSceneLayer.activeFilter = null;
      return;
    }

    // Construct the where clauses based on state.
    var solidFilterWhere = '';
    var xrayFilterWhere = '';

    if (selectedConstructionPhase != null) {
      // Construction phase where clause.
      final constructionPhaseWhere =
          '$_CONSTRUCTION_PHASE_ATTRIBUTES <= $selectedConstructionPhase';

      // Create the filter block where clauses.
      solidFilterWhere = constructionPhaseWhere;
      xrayFilterWhere = constructionPhaseWhere;
    }

    if (selectedLevel != 'All') {
      // Selected level where clause.
      final levelEqualsWhere = '$_BUILDING_LEVEL_ATTRIBUTE = $selectedLevel';
      final levelLessThanWhere = '$_BUILDING_LEVEL_ATTRIBUTE < $selectedLevel';

      // Create or expand the filter block where clauses.
      if (solidFilterWhere.isNotEmpty) {
        solidFilterWhere = '$solidFilterWhere AND $levelEqualsWhere';
        xrayFilterWhere = '$xrayFilterWhere AND $levelLessThanWhere';
      } else {
        solidFilterWhere = levelEqualsWhere;
        xrayFilterWhere = levelLessThanWhere;
      }
    }

    // Create the building filter.
    currentBuildingFilter = BuildingFilter(
      name: _FILTER_NAME,
      description: 'Show selected level and xray filter for lower levels.',
      blocks: [
        BuildingFilterBlock(
          title: _SOLID_BLOCK_NAME,
          whereClause: solidFilterWhere,
          mode: BuildingSolidFilterMode(),
        ),
        BuildingFilterBlock(
          title: _XRAY_BLOCK_NAME,
          whereClause: xrayFilterWhere,
          mode: BuildingXrayFilterMode(),
        ),
      ],
    );

    // Apply the building filter to the building scene layer.
    buildingSceneLayer.activeFilter = currentBuildingFilter;
  }
}
