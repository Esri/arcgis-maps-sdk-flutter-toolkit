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

/// This class stores state for the [FloorFilter] widget. Get an instance of
/// this class by calling [FloorFilter.createController] and passing in the
/// relevant [GeoViewController]. The controller object is used when creating
/// the [FloorFilter] in the widget tree.
class FloorFilterController {
  FloorFilterController._({required this.geoViewController});

  /// The [GeoViewController] for the view showing the floor information.
  final GeoViewController geoViewController;

  FloorManager? floorManager;
  FloorSite? selectedSite;
  FloorFacility? selectedFacility;
  FloorLevel? selectedFloor;

  /// Stream that notifies internal listeners that they need to call
  /// _refreshBuildingSceneLayers due to a change in the scene of the view controller.
  Stream<Null> get _onRequestFloorFilterRefresh =>
      _onRequestFloorFilterRefreshController.stream;
  final _onRequestFloorFilterRefreshController =
      StreamController<Null>.broadcast();

  /// Call this function when there has been an update on the GeoView that
  /// requires the [FloorFilterController] to refresh its data.
  void refresh() {
    _onRequestFloorFilterRefreshController.add(null);
  }

  void _resetFloorManager() {
    floorManager = null;
    selectedSite = null;
    selectedFacility = null;
    selectedFloor = null;

    GeoModel? geoModel;
    switch (geoViewController) {
      case final ArcGISMapViewController mapViewController:
        geoModel = mapViewController.arcGISMap;
      case final ArcGISSceneViewController sceneViewController:
        geoModel = sceneViewController.arcGISScene;
      case final ArcGISLocalSceneViewController localSceneViewController:
        geoModel = localSceneViewController.arcGISScene;
    }

    if (geoModel != null) {
      floorManager = geoModel.floorManager;
    }
  }
}
