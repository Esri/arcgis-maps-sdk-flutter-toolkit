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

part of '../../arcgis_maps_toolkit.dart';

/// This class stores state for the [BuildingExplorer] widget across different
/// instances of the widget. Get an instance of this class by calling
/// [BuildingExplorer.createController] and passing in the relevant [ArcGISLocalSceneViewController].
/// The controller object is used when creating the [BuildingExplorer] in the widget tree.
class BuildingExplorerController {
  BuildingExplorerController._({
    required ArcGISLocalSceneViewController localSceneViewController,
  }) : _localSceneViewController = localSceneViewController;

  /// The [ArcGISLocalSceneViewController] for the view showing the building
  /// scene layers. This provides the scene that contains the layers.
  final ArcGISLocalSceneViewController _localSceneViewController;

  /// Map of relevent state for each of the building scene layers.
  /// [BuildingSceneLayer.id] is used as the key, and the value is the associated
  /// [_BuildingSceneLayerState] object.
  final _buildingSceneLayerStates =
      <String, _BuildingSceneLayerState>{}
          as LinkedHashMap<String, _BuildingSceneLayerState>;

  /// The [BuildingSceneLayer] currently active in the [BuildingExplorer].
  BuildingSceneLayer? _selectedLayer;

  /// Convenience property to get the state object for the currently selected building layer.
  _BuildingSceneLayerState? get _selectedBuildingSceneLayerState {
    return _buildingSceneLayerStates[_selectedLayer?.id];
  }

  /// Stream that notifies listeners that they need to call
  /// _refreshBuildingSceneLayers due to a change in the scene of the view controller.
  Stream<Null> get _onRequestSceneRefresh =>
      _onRequestSceneRefreshController.stream;
  final _onRequestSceneRefreshController = StreamController<Null>.broadcast();

  /// Call this function when there has been an update to the scene that
  /// requires the [BuildingExplorerController] to refresh its data.
  void refreshScene() {
    _onRequestSceneRefreshController.add(null);
  }

  /// Function to reload the layers from the scene. This handles instances where
  /// new layers are added or existing layers removed. This is called once every
  /// time the Building Explorer tool is summoned.
  Future<void> _refreshBuildingSceneLayers() async {
    final scene = _localSceneViewController.arcGISScene;
    if (scene == null) {
      _selectedLayer = null;
      _buildingSceneLayerStates.clear();
      return;
    }

    // Get the BuildingSceneLayers in the scene.
    final buildingSceneLayers = _extractBuildingSceneLayers(
      scene.operationalLayers,
    );

    // If none, clear _selectedLayer and _buildingSceneLayerStates then return.
    if (buildingSceneLayers.isEmpty) {
      _selectedLayer = null;
      _buildingSceneLayerStates.clear();
      return;
    }

    // Refresh the state records for the building scene layers.
    await _refreshBuildingSceneLayerStates(buildingSceneLayers);

    // Set selectedLayer.
    // If a layer has not yet been selected, or the selection is no longer in
    // the scene, set selectedLayer to the first layer in the scene.
    if (!buildingSceneLayers.contains(_selectedLayer)) {
      _selectedLayer = buildingSceneLayers.first;
    }
  }

  Future<void> _refreshBuildingSceneLayerStates(
    List<BuildingSceneLayer> buildingSceneLayers,
  ) async {
    final refreshFutures = <Future<void>>[];

    // Create BuildingSceneLayerStates from the layers.
    for (final layer in buildingSceneLayers) {
      refreshFutures.add(layer.load());
    }

    // Wait for all the building scene layers to load.
    await Future.wait(refreshFutures);

    // Sort the states by building scene layer name.
    buildingSceneLayers.sort(
      (layer1, layer2) => layer1.name.compareTo(layer2.name),
    );

    // Create a map of the building layer state objects based on the sorted buildingSceneLayers.
    final tempStates =
        <String, _BuildingSceneLayerState>{}
            as LinkedHashMap<String, _BuildingSceneLayerState>;
    for (final layer in buildingSceneLayers) {
      // If a state object already exists for this layer, use it. Otherwise,
      // create a new one.
      tempStates[layer.id] =
          _buildingSceneLayerStates[layer.id] ??
          _BuildingSceneLayerState.withBuildingSceneLayer(layer);
    }

    // Replace _buildingSceneLayerStates contents with tempMap. This will remove
    // any layer states no longer in the scene, and add new ones all in the
    // sorted order.
    _buildingSceneLayerStates.clear();
    _buildingSceneLayerStates.addAll(tempStates);
  }

  // Recursive function to find the BuildingSceneLayers in the scene.
  List<BuildingSceneLayer> _extractBuildingSceneLayers(List<Layer> layers) {
    final buildingSceneLayers = <BuildingSceneLayer>[];
    for (final layer in layers) {
      if (layer is BuildingSceneLayer) {
        buildingSceneLayers.add(layer);
      } else if (layer is GroupLayer) {
        buildingSceneLayers.addAll(
          _extractBuildingSceneLayers(
            layer.subLayerContents.whereType<Layer>().toList(),
          ),
        );
      }
    }

    return buildingSceneLayers;
  }
}
