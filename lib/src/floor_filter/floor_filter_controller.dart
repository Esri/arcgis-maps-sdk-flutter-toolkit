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

  FloorManager? _floorManager;
  FloorSite? _selectedSite;
  FloorFacility? _selectedFacility;
  FloorLevel? _selectedLevel;

  /// The ID of the currently selected site.
  String? get selectedSiteId => _selectedSite?.siteId;
  set selectedSiteId(String selectedSiteId) {
    if (_floorManager != null) {
      _selectedSite = _floorManager!.sites.firstWhere(
        (site) => site.siteId == selectedSiteId,
      );
    } else {
      throw StateError('This ArcGISMap or ArcGISScene has no FloorManager.');
    }
  }

  /// The ID of the currently selected facility.
  String? get selectedFacilityId => _selectedFacility?.facilityId;
  set selectedFacilityId(String selectedFacilityId) {
    if (_floorManager != null) {
      _selectedFacility = _floorManager!.facilities.firstWhere(
        (facility) => facility.facilityId == selectedFacilityId,
      );
    } else {
      throw StateError('This ArcGISMap or ArcGISScene has no FloorManager.');
    }
  }

  /// The ID of the currently selected level.
  String? get selectedLevelId => _selectedLevel?.levelId;
  set selectedLevelId(String selectedLevelId) {
    if (_floorManager != null) {
      _selectedLevel = _floorManager!.levels.firstWhere(
        (level) => level.levelId == selectedLevelId,
      );
    } else {
      throw StateError('This ArcGISMap or ArcGISScene has no FloorManager.');
    }
  }

  /// Call this function when there has been an update on the GeoView that
  /// requires the [FloorFilterController] to refresh its data.
  void refresh() {
    _onRequestFloorFilterRefreshController.add(null);
  }

  Stream<FloorSite?> get _onSiteChanged => _onSiteChangedController.stream;
  final _onSiteChangedController = StreamController<FloorSite?>.broadcast();
  Stream<FloorFacility?> get _onFacilityChanged =>
      _onFacilityChangedController.stream;
  final _onFacilityChangedController =
      StreamController<FloorFacility?>.broadcast();
  Stream<FloorLevel?> get _onLevelChanged => _onLevelChangedController.stream;
  final _onLevelChangedController = StreamController<FloorLevel?>.broadcast();

  // Stream that notifies internal listeners that they need to call
  // _refreshBuildingSceneLayers due to a change in the scene of the view controller.
  Stream<Null> get _onRequestFloorFilterRefresh =>
      _onRequestFloorFilterRefreshController.stream;
  final _onRequestFloorFilterRefreshController =
      StreamController<Null>.broadcast();

  Future<void> _resetFloorManager() async {
    _floorManager = null;
    _selectedSite = null;
    _selectedFacility = null;
    _selectedLevel = null;

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
      await geoModel.load();
      _floorManager = geoModel.floorManager;
      await _floorManager?.load();

      if (_floorManager != null) {
        final facilities = _floorManager!.facilities;
        final selectedIdx = facilities.lastIndexWhere(
          (facility) => facility.name == 'Lattice',
        );
        // TODO: Removed this test code. Setting the selected facility to test FloorLevel picker.
        _selectFacility(facilities[selectedIdx]);
      }
    }
  }

  void _selectFacility(FloorFacility facility) {
    if (_selectedFacility != facility) {
      _selectedFacility = facility;

      // Notify stream that the facility changed.
      _onFacilityChangedController.add(_selectedFacility);

      // Set the level to the default level.
      _selectDefaultLevel(facility);
    }

    // Adjust viewpoint to center of facility
    if (facility.geometry != null) {
      final geometry = facility.geometry!;

      switch (geoViewController) {
        case final ArcGISMapViewController mapViewController:
          _zoomToExtent(geometry.extent, mapViewController);
      }
    }
  }

  void _selectDefaultLevel(FloorFacility facility) {
    if (facility.levels.isNotEmpty) {
      _selectedLevel = facility.levels.firstWhere(
        (level) => level.verticalOrder == 0,
      );
      _selectedLevel = null;
    } else {
      _selectedLevel = null;
    }

    // Notify the stream that the level changed
    _onLevelChangedController.add(_selectedLevel);
  }

  void _zoomToExtent(
    Envelope extent,
    ArcGISMapViewController mapViewController,
  ) {
    final builder = EnvelopeBuilder.fromEnvelope(extent);
    builder.expandBy(1.5);
    final targetExtent = builder.toGeometry();
    mapViewController.setViewpoint(Viewpoint.fromTargetExtent(targetExtent));
  }
}
