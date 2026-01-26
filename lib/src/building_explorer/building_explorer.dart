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

/// A widget that enables a user to explore a building model in a [BuildingSceneLayer].
///
/// # Overview
/// The Building Explorer widget provides a tool for users to browse the levels and sublayers of a building scene layer. The widget can highlight specified levels and show or hide building features of different categories and subcategories.
///
/// ## Features
/// Features of the Building Explorer widget include:
/// * Showing the name of the layer as the title of the widget.
/// * Selecting a level of the building to highlight in the view.
///     * The selected level and all of the features of the level are rendered normally.
///     * Levels above are hidden.
///     * Levels below are given an Xray style.
/// * Visibility of building feature categories and subcategories can be toggled on and off.
/// * The widget can present a close button when provided with an onClose callback function.
///
/// ## Usage
/// A [BuildingExplorer] widget is created with the following parameters:
/// * buildingExplorerControllerProvider: A Function that returns the [BuildingExplorerController] that contains state data for this widget.
/// * onClose: An optional callback that is called when the close button of the widget is tapped. If a callback is not provided, the close button will be hidden.
///
/// The widget can be inserted into a widget tree by calling the constructor and supplying a [BuildlingSceneLayer] and an optional onClose callback function.
/// ```dart
/// ...
/// final localSceneViewController = ArcGISLocalSceneView.createController();
/// final buildingExplorerController = BuildingExplorer.createController(viewController: localSceneViewController);
/// ...
///
/// ...
///   BuildingExplorer(
///     buildingExplorerControllerProvider: () => buildingExplorerController),
///     onClose: () => setState(() => _showBottomSheet = false),
///   ),
/// ...
/// ```
class BuildingExplorer extends StatefulWidget {
  const BuildingExplorer({
    required this.buildingExplorerControllerProvider,
    this.onClose,
    super.key,
  });

  final BuildingExplorerController Function()
  buildingExplorerControllerProvider;

  /// Optional onClose callback. If set, a close [IconButton] will appear at
  /// the top right of the widget.
  final VoidCallback? onClose;

  /// Static function used to create the BuildingExplorerController that will
  /// be used between widget instances.
  static BuildingExplorerController createController(
    ArcGISLocalSceneViewController viewController,
  ) {
    return BuildingExplorerController._(
      localSceneViewController: viewController,
    );
  }

  @override
  State<BuildingExplorer> createState() => _BuildingExplorerState();
}

class _BuildingExplorerState extends State<BuildingExplorer> {
  late final BuildingExplorerController widgetController;
  StreamSubscription<Null>? onRequestSceneRefreshSubscription;
  var _refreshFuture = Future<void>.value();

  @override
  void initState() {
    super.initState();
    widgetController = widget.buildingExplorerControllerProvider();

    // Refresh the scene layers in the controller just in case layers have been
    // added or removed.
    _refreshFuture = widgetController._refreshBuildingSceneLayers();

    onRequestSceneRefreshSubscription = widgetController._onRequestSceneRefresh
        .listen(
          (_) => setState(() {
            _refreshFuture = widgetController._refreshBuildingSceneLayers();
          }),
        );
  }

  @override
  void dispose() {
    onRequestSceneRefreshSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _refreshFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _selectBuildingExplorerWidget(context);
        } else {
          return _buildLoadingExplorer(context);
        }
      },
    );
  }

  Widget _selectBuildingExplorerWidget(BuildContext context) {
    if (widgetController._buildingSceneLayerStates.isEmpty) {
      return _buildEmptyBuildingExplorer(context);
    } else {
      return _buildFullBuildingExplorer(context);
    }
  }

  Widget _buildLoadingExplorer(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: AlignmentGeometry.center,
          children: [
            Text(
              'Building Explorer',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            // Right-justified close icon button
            if (widget.onClose != null)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                  tooltip: 'Close',
                ),
              ),
          ],
        ),
        const Divider(),
        const Expanded(
          child: Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyBuildingExplorer(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: AlignmentGeometry.center,
          children: [
            Text(
              'Building Explorer',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            // Right-justified close icon button
            if (widget.onClose != null)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                  tooltip: 'Close',
                ),
              ),
          ],
        ),
        const Divider(),
        Expanded(
          child: Center(
            child: Text(
              'No BuildingSceneLayers in the Scene.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullBuildingExplorer(BuildContext context) {
    var overviewShowing =
        widgetController._selectedBuildingSceneLayerState!.showOverview;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            _BuildingSceneLayerSelector(
              buildingExplorerController: widgetController,
              onBuildingSceneChanged: (layer) =>
                  setState(() => widgetController._selectedLayer = layer),
            ),
            // Right-justified close icon button
            if (widget.onClose != null)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                  tooltip: 'Close',
                ),
              ),
          ],
        ),
        const Divider(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 20, 0),
                  child: Column(
                    children: [
                      // Zoom to Building widget.
                      _ZoomToBuildingControl(
                        buildingExplorerController: widgetController,
                      ),
                      // Overview model toggle widget.
                      _OverviewModelToggle(
                        layerState:
                            widgetController._selectedBuildingSceneLayerState!,
                        onOverviewVisibilityChanged: (newValue) =>
                            setState(() => overviewShowing = newValue),
                      ),
                    ],
                  ),
                ),
                // Hide the rest of the controls if the overview is showing.
                if (!overviewShowing)
                  Column(
                    children: [
                      // Widget for selecting the level to highlight.
                      _BuildingLevelSelector(
                        buildingSceneLayerState:
                            widgetController._selectedBuildingSceneLayerState!,
                      ),
                      _ConstructionPhaseSelector(
                        buildingSceneLayerState:
                            widgetController._selectedBuildingSceneLayerState!,
                      ),
                      const Divider(),
                      // Categories sublayer selection widget.
                      Text(
                        'Disciplines & Categories:',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      _BuildingCategoryList(
                        buildingSceneLayer: widgetController._selectedLayer!,
                        shrinkWrap: true,
                        scrollPhysics: const NeverScrollableScrollPhysics(),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
