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
/// BuildingExplorer.createController(localSceneViewController). The controller
/// object is used when creating the BuildingExplorer in the widget tree.
class BuildingExplorerController {
  BuildingExplorerController._({
    required ArcGISLocalSceneViewController localSceneViewController,
  }) : _localSceneViewController = localSceneViewController;

  /// The [ArcGISLocalSceneViewController] for the view showing the building
  /// scene layers. This provides the scene that contains the layers.
  final ArcGISLocalSceneViewController _localSceneViewController;

  /// Map of relevent state for each of the building scene layers. The [BuildingSceneLayer]
  /// is used as the key, and the value is a [_BuildingSceneLayerState] object.
  var _buildingSceneLayerStates =
      <BuildingSceneLayer, _BuildingSceneLayerState>{};

  /// The [BuildingSceneLayer] currently active in the [BuildingExplorer].
  BuildingSceneLayer? _selectedLayer;

  /// Convenience property to get the state object for the currently selected building layer.
  _BuildingSceneLayerState? get _selectedBuildingSceneLayerState {
    return _buildingSceneLayerStates[_selectedLayer];
  }

  /// Stream that notifies listeners that they need to call
  /// _refreshBuildingSceneLayers due to a change in the scene of the view controller.
  Stream<Null> get _onRequestSceneRefresh =>
      _onRequestSceneRefreshController.stream;
  final _onRequestSceneRefreshController = StreamController<Null>.broadcast();

  /// Public function called when there has been an update to the scene that
  /// requires the BuildingExplorerController to refresh it's data.
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
      _buildingSceneLayerStates = {};
      return;
    }

    // Get the BuildingSceneLayers in the scene.
    final buildingSceneLayers = scene.operationalLayers
        .whereType<BuildingSceneLayer>()
        .toList();

    // If none, return.
    if (buildingSceneLayers.isEmpty) return;

    // Refresh the state records for the building scene layers.
    _buildingSceneLayerStates = await _refreshBuildingSceneLayerStates(
      buildingSceneLayers,
    );

    // Set selectedLayer.
    // If a layer has not yet been selected, or the selection is no longer in
    // the scene, set selectedLayer to the first layer in the scene.
    if (!buildingSceneLayers.contains(_selectedLayer)) {
      _selectedLayer = buildingSceneLayers.first;
    }
  }

  Future<Map<BuildingSceneLayer, _BuildingSceneLayerState>>
  _refreshBuildingSceneLayerStates(
    List<BuildingSceneLayer> buildingSceneLayers,
  ) async {
    final refreshFutures = <Future<void>>[];
    final refreshedLayerStates =
        <BuildingSceneLayer, _BuildingSceneLayerState>{};

    // Create BuildingSceneLayerStates from the layers.
    for (final layer in buildingSceneLayers) {
      final refreshFuture = layer.load().then((_) {
        refreshedLayerStates[layer] =
            _buildingSceneLayerStates[layer] ??
            _BuildingSceneLayerState.withBuildingSceneLayer(layer);
      });

      refreshFutures.add(refreshFuture);
    }

    // Wait for all the building scene layers to load.
    await Future.wait(refreshFutures);

    return refreshedLayerStates;
  }
}
