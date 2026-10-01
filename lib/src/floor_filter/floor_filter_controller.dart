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
/// the [FloorFilter] in the widget tree and provides the interface to the
/// widget during use.
class FloorFilterController {
  FloorFilterController._({required this.geoViewController});

  /// The [GeoViewController] for the view showing the floor information.
  final GeoViewController geoViewController;

  // Flag to show all facilities or just facilities for the selected site.
  var _listAllFacilities = false;

  // The floor manager for the GeoModel.
  FloorManager? get _floorManager => _floorManagerNotifier.value;
  // The currently selected site.
  FloorSite? get _selectedSite => _selectedSiteNotifier.value;
  // The currently selected facility.
  FloorFacility? get _selectedFacility => _selectedFacilityNotifier.value;
  // The currently selected level.
  FloorLevel? get _selectedLevel => _selectedLevelNotifier.value;

  // Cancelable operation to ensure only one refresh call at a time.
  CancelableOperation<void>? _cancelableRefresh;

  /// The siteId of the currently selected site.
  String? get selectedSiteId => _selectedSite?.siteId;
  set selectedSiteId(String selectedSiteId) {
    if (_floorManager != null) {
      final selectedSite = _floorManager!.sites.firstWhere(
        (site) => site.siteId == selectedSiteId,
      );
      _selectSite(selectedSite);
    } else {
      throw StateError('This ArcGISMap or ArcGISScene has no FloorManager.');
    }
  }

  /// The facilityId of the currently selected facility.
  String? get selectedFacilityId => _selectedFacility?.facilityId;
  set selectedFacilityId(String selectedFacilityId) {
    if (_floorManager != null) {
      final selectedFacility = _floorManager!.facilities.firstWhere(
        (facility) => facility.facilityId == selectedFacilityId,
      );
      _selectFacility(selectedFacility);
    } else {
      throw StateError('This ArcGISMap or ArcGISScene has no FloorManager.');
    }
  }

  /// The levelId of the currently selected level.
  String? get selectedLevelId => _selectedLevel?.levelId;
  set selectedLevelId(String selectedLevelId) {
    if (_floorManager != null) {
      final selectedLevel = _floorManager!.levels.firstWhere(
        (level) => level.levelId == selectedLevelId,
      );
      _selectLevel(selectedLevel);
    } else {
      throw StateError('This ArcGISMap or ArcGISScene has no FloorManager.');
    }
  }

  /// Apps will call this function when the [FloorManager] has been changed.
  void refresh() {
    // If there is a current refresh run in progress, cancel it.
    _cancelableRefresh?.cancel().ignore();

    // Start a new refresh operation.
    _cancelableRefresh = CancelableOperation.fromFuture(_refresh()).then((
      floorManager,
    ) {
      // Notify listeners of the updated floor manager.
      _floorManagerNotifier.value = floorManager;
    });
  }

  // Function that does the work of refreshing. Called by the public refresh() function.
  Future<FloorManager?> _refresh() async {
    // Setting the selected Site/Facility/Level to null
    _selectSite(null, notifySelectionChanged: false);
    _selectFacility(null, notifySelectionChanged: false);
    _selectLevel(null, notifySelectionChanged: false);
    _onSelectedChangedController.add(null);

    // Clear the floor manager property.
    FloorManager? floorManager;

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
      floorManager = geoModel.floorManager;
      await floorManager?.load();
    }

    return floorManager;
  }

  /// Notification that the Site/Facility/Floor selection has changed.
  Stream<Null> get onSelectedChanged => _onSelectedChangedController.stream;
  final _onSelectedChangedController = StreamController<Null>.broadcast();

  // Internal notifier for changes to the selected site.
  final _selectedSiteNotifier = ValueNotifier<FloorSite?>(null);

  // Internal notifier for changes to the selected facility.
  final _selectedFacilityNotifier = ValueNotifier<FloorFacility?>(null);

  // Internal notifier for changes to the selected level.
  final _selectedLevelNotifier = ValueNotifier<FloorLevel?>(null);

  // Internal notifier for updates to the floor manager.
  final _floorManagerNotifier = ValueNotifier<FloorManager?>(null);

  // Function to set the selected site and handle actions related to the change.
  // The notifySelectionChanged parameter states whether the public
  // onSelectedChanged stream should be notified. The internal onSiteChanged
  // notification will always set if the site changed.
  void _selectSite(FloorSite? site, {bool notifySelectionChanged = true}) {
    if (_selectedSite == site) return;

    // Clear the currently selected facility.
    _selectFacility(null, notifySelectionChanged: false);

    // Notify listeners that the site changed.
    _selectedSiteNotifier.value = site;

    if (site != null) {
      _zoomToSite(site);
    }

    if (notifySelectionChanged) {
      _onSelectedChangedController.add(null);
    }
  }

  // Function to set the selected facility and handle actions related to the change.
  // The notifySelectionChanged parameter states whether the public
  // onSelectedChanged stream should be notified. The internal onFacilityChanged
  // notification will always set if the facility changed.
  void _selectFacility(
    FloorFacility? facility, {
    bool notifySelectionChanged = true,
  }) {
    if (_selectedFacility == facility) return;

    // Notify listeners that the facility changed.
    _selectedFacilityNotifier.value = facility;

    if (facility != null) {
      // Adjust viewpoint to facility extent.
      _zoomToFacility(facility);

      // Set the level to the default level.
      _selectDefaultLevel(facility, notifySelectionChanged: false);
    } else {
      // Clear the selected floor.
      _selectLevel(null, notifySelectionChanged: false);
    }

    if (notifySelectionChanged) {
      _onSelectedChangedController.add(null);
    }
  }

  // Selects the default level for the facility. The level with verticalOrder 0.
  // If the facility has no levels or no level with verticalOrder 0, the selected
  // level is set to null.
  void _selectDefaultLevel(
    FloorFacility facility, {
    bool notifySelectionChanged = true,
  }) {
    FloorLevel? defaultLevel;

    // Find the default level
    if (facility.levels.isNotEmpty) {
      defaultLevel = facility.levels
          .where((level) => level.verticalOrder == 0)
          .firstOrNull;
    }

    // Select the default level or null.
    _selectLevel(defaultLevel, notifySelectionChanged: notifySelectionChanged);
  }

  // Function to set the selected level and handle actions related to the change.
  // The notifySelectionChanged parameter states whether the public
  // onSelectedChanged stream should be notified. The internal onLevelChanged
  // notification will always set if the level changed.
  void _selectLevel(FloorLevel? level, {bool notifySelectionChanged = true}) {
    if (_selectedLevel == level) return;

    // Notify listeners that the level changed.
    _selectedLevelNotifier.value = level;

    // Update the visible levels
    if (level != null) {
      _showLevelsWithVerticalOrder(level.verticalOrder);
    } else {
      // Default to the 0th level.
      _showLevelsWithVerticalOrder(0);
    }

    if (notifySelectionChanged) {
      _onSelectedChangedController.add(null);
    }
  }

  // Function to set the visibility of layers that have the specified
  // verticalOrder. This will span all facilities. Facilities that do not have
  // a level with this verticalOrder will not show any floor.
  void _showLevelsWithVerticalOrder(int verticalOrder) {
    if (_floorManager == null) return;

    for (final floorManagerLevel in _floorManager!.levels) {
      // Levels on with the verticalOrder of the selected level are set to visible.
      floorManagerLevel.isVisible =
          floorManagerLevel.verticalOrder == verticalOrder;
    }
  }

  // Function to zoom the GeoView to the site extent.
  void _zoomToSite(FloorSite site) {
    final geometry = site.geometry;
    if (geometry != null) {
      _zoomViewToExtent(geometry.extent);
    }
  }

  // Function to zoom the GeoView to the facility extent.
  void _zoomToFacility(FloorFacility facility) {
    final geometry = facility.geometry;
    if (geometry != null) {
      _zoomViewToExtent(geometry.extent);
    }
  }

  // Utility function to call the correct zoom function based on the type of the
  // GeoViewController.
  void _zoomViewToExtent(Envelope extent) {
    switch (geoViewController) {
      case final ArcGISMapViewController mapViewController:
        _zoomMapToExtent(extent, mapViewController);
      case final ArcGISSceneViewController sceneViewController:
        _zoomSceneToExtent(extent, sceneViewController);
      case final ArcGISLocalSceneViewController localSceneViewController:
        _zoomLocalSceneToExtent(extent, localSceneViewController);
    }
  }

  // Function to set the viewpoint to the extent of a facility in an ArcGISMapView.
  void _zoomMapToExtent(
    Envelope extent,
    ArcGISMapViewController mapViewController,
  ) {
    // Pad the extent by a factor of 1.5.
    final builder = EnvelopeBuilder.fromEnvelope(extent);
    builder.expandBy(1.5);
    final targetExtent = builder.toGeometry();

    // Set the viewpoint of the map view.
    mapViewController.setViewpointAnimated(
      Viewpoint.fromTargetExtent(targetExtent),
      duration: 0.5,
    );
  }

  // Function to set the viewpoint to the extent of a facility in an ArcGISSceneView.
  void _zoomSceneToExtent(
    Envelope extent,
    ArcGISSceneViewController sceneViewController,
  ) {
    // TODO(kmueller-gis): zoom to extent with camera.
  }

  // Function to set the viewpoint to the extent of a facility in an ArcGISLocalSceneView.
  void _zoomLocalSceneToExtent(
    Envelope extent,
    ArcGISLocalSceneViewController localSceneViewController,
  ) {
    // TODO(kmueller-gis): zoom to extent with camera.
  }
}
