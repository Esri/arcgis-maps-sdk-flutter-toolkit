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

/// Class that records the state of a single building scene layer. The
/// properties of this class drive UI elements for a specific building scene layer.
class _BuildingSceneLayerState {
  /// Private constructor. Instantiate with factory constructor.
  _BuildingSceneLayerState._({
    required this.buildingSceneLayer,
    this.selectedLevel = 'All',
    this.selectedConstructionPhase = 'All',
    this.overviewSublayer,
  });

  /// Creates and initializes a [BuildingSceneLayerState] object for the
  /// privided [BuildingSceneLayer].
  factory _BuildingSceneLayerState.withBuildingSceneLayer(
    BuildingSceneLayer layer, {
    String selectedLevel = 'All',
    String selectedConstructionPhase = 'All',
  }) {
    // Check if the layer has an overview model
    final overviewSublayerIndex = layer.sublayers.indexWhere(
      (layer) => layer.name == 'Overview',
    );

    return _BuildingSceneLayerState._(
      buildingSceneLayer: layer,
      selectedLevel: selectedLevel,
      selectedConstructionPhase: selectedConstructionPhase,
      overviewSublayer: overviewSublayerIndex > -1
          ? layer.sublayers[overviewSublayerIndex]
          : null,
    );
  }

  /// The [BuildingSceneLayer] for this [BuildingSceneLayerState].
  BuildingSceneLayer buildingSceneLayer;

  /// The currently selected building level. This can be 'All' or the level name.
  String selectedLevel;

  /// The currently selected construction phase. This can be 'All' or the phase name.
  String selectedConstructionPhase;

  /// The current [BuildingFilter] for the selected level. If the selected level
  /// is 'All' this filter will be null.
  BuildingFilter? currentBuildingFilter;

  /// Flag for the state of the Show Overview toggle control.
  bool get showOverview => overviewSublayer?.isVisible ?? false;

  /// Overview sublayer if one exists in the building scene layer.
  final BuildingSublayer? overviewSublayer;

  /// Function to build a [BuildingFilter] based on the currently selected level
  /// and construction phase.
  void updateBuildingFilter() {
    if (selectedLevel == 'All' && selectedConstructionPhase == 'All') {
      currentBuildingFilter = null;
      buildingSceneLayer.activeFilter = null;
      return;
    }

    // Construct the where clauses based on state.
    var solidFilterWhere = '';
    var xrayFilterWhere = '';

    if (selectedConstructionPhase != 'All') {
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
