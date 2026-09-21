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

  /// Notification that the Site/Facility/Floor selection has changed.
  Stream<FloorSite?> get onSelectedChanged =>
      _onSelectedChangedController.stream;
  final _onSelectedChangedController = StreamController<Null>.broadcast();

  // Internal stream notifying listeners that the selected site has changed.
  Stream<FloorSite?> get _onSiteChanged => _onSiteChangedController.stream;
  final _onSiteChangedController = StreamController<FloorSite?>.broadcast();
  // Internal stream notifying listeners that the selected facility has changed.
  Stream<FloorFacility?> get _onFacilityChanged =>
      _onFacilityChangedController.stream;
  final _onFacilityChangedController =
      StreamController<FloorFacility?>.broadcast();
  // Internal stream notifying listeners that the selected level has changed.
  Stream<FloorLevel?> get _onLevelChanged => _onLevelChangedController.stream;
  final _onLevelChangedController = StreamController<FloorLevel?>.broadcast();
  // Internal stream that notifies listeners that they need to call
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

    // Obtain the GeoModel (map or scene) for this view.
    GeoModel? geoModel;
    switch (geoViewController) {
      case final ArcGISMapViewController mapViewController:
        geoModel = mapViewController.arcGISMap;
      case final ArcGISSceneViewController sceneViewController:
        geoModel = sceneViewController.arcGISScene;
      case final ArcGISLocalSceneViewController localSceneViewController:
        geoModel = localSceneViewController.arcGISScene;
    }

    // Obtain and load the FloorManager for this GeoView.
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

  // Funciton to set the selected site and handle actions related to the change.
  void _selectSite(FloorSite? site) {
    if (_selectedSite == site) return;

    _selectedSite = site;

    // Clear the currently selected facility.
    _selectFacility(null, notifySelectionChanged: false);

    // Notify the streams that the site changed.
    _onSiteChangedController.add(site);
    _onSelectedChangedController.add(null);
  }

  // Funciton to set the selected facility and handle actions related to the change.
  void _selectFacility(
    FloorFacility? facility, {
    bool notifySelectionChanged = true,
  }) {
    if (_selectedFacility == facility) return;

    _selectedFacility = facility;

    // Notify stream that the facility changed.
    _onFacilityChangedController.add(_selectedFacility);
    if (notifySelectionChanged) {
      _onSelectedChangedController.add(null);
    }

    if (facility != null) {
      // Set the level to the default level.
      _selectDefaultLevel(facility, notifySelectionChanged: false);

      // Adjust viewpoint to facility extent.
      _zoomToFacility(facility);
    } else {
      // Clear the selected floor.
      _selectLevel(null, notifySelectionChanged: false);
    }
  }

  // Function to select the default level of a facility.
  void _selectDefaultLevel(
    FloorFacility facility, {
    bool notifySelectionChanged = true,
  }) {
    // The level with verticalOrder set to 0 is the default, ground floor.
    if (facility.levels.isNotEmpty) {
      _selectLevel(
        facility.levels.firstWhere((level) => level.verticalOrder == 0),
        notifySelectionChanged: notifySelectionChanged,
      );
    } else {
      // Facility has no levels.
      _selectLevel(null, notifySelectionChanged: notifySelectionChanged);
    }
  }

  // Funciton to set the selected level and handle actions related to the change.
  void _selectLevel(FloorLevel? level, {bool notifySelectionChanged = true}) {
    if (_selectedLevel == level) return;

    _selectedLevel = level;

    // Notify the streams that the level changed.
    _onLevelChangedController.add(level);
    if (notifySelectionChanged) {
      _onSelectedChangedController.add(null);
    }
  }

  void _zoomToFacility(FloorFacility facility) {
    if (facility.geometry != null) {
      final geometry = facility.geometry!;

      switch (geoViewController) {
        case final ArcGISMapViewController mapViewController:
          _zoomMapToExtent(geometry.extent, mapViewController);
      }
    }
  }

  void _zoomMapToExtent(
    Envelope extent,
    ArcGISMapViewController mapViewController,
  ) {
    final builder = EnvelopeBuilder.fromEnvelope(extent);
    builder.expandBy(1.5);
    final targetExtent = builder.toGeometry();
    mapViewController.setViewpoint(Viewpoint.fromTargetExtent(targetExtent));
  }
}
