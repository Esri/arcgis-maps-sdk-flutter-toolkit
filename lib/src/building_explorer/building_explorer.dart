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
/// * buildingSceneLayer: The [BuildingSceneLayer] that this widget will be exploring
/// * fullModelSublayerName: An optional [String] that is the name of the full model sublayer. Default is “Full Model”.
/// * onClose: An optional callback that is called when the close button of the widget is tapped. If a callback is not provided, the close button will be hidden.
///
/// The widget can be inserted into a widget tree by calling the constructor and supplying a [BuildlingSceneLayer] and an optional onClose callback function.
/// ```dart
/// ...
///   BuildingExplorer(
///     buildingSceneLayer: _buildingSceneLayer!,
///     onClose: () => Navigator.pop(context),
///   ),
/// ...
/// ```
class BuildingExplorer extends StatefulWidget {
  const BuildingExplorer({
    required this.localScene,
    // required this.buildingSceneLayer,
    this.fullModelSublayerName = 'Full Model',
    this.onClose,
    super.key,
  });

  /// Local Scene that contains BuildingSceneLayers.
  final ArcGISScene localScene;

  /// BuildingSceneLayer that this widget explores
  // final BuildingSceneLayer buildingSceneLayer;

  /// Name of the full model group sublayer
  final String fullModelSublayerName;

  /// Optional onClose callback. If set, a close [IconButton] will appear at the top right of the widget.
  final VoidCallback? onClose;

  @override
  State<BuildingExplorer> createState() => _BuildingExplorerState();
}

class _BuildingExplorerState extends State<BuildingExplorer> {
  var _buildingSceneLayers = <BuildingSceneLayer>[];
  BuildingSceneLayer? _selectedBuildingSceneLayer;

  StreamSubscription<LoadStatus>? _sceneOnLoadSubscription;

  @override
  void initState() {
    super.initState();

    if (widget.localScene.loadStatus == LoadStatus.loaded) {
      final buildingSceneLayers = widget.localScene.operationalLayers
          .whereType<BuildingSceneLayer>()
          .toList();
      _buildingSceneLayers = buildingSceneLayers;
      _selectedBuildingSceneLayer = _buildingSceneLayers.first;
    } else {
      _sceneOnLoadSubscription = widget.localScene.onLoadStatusChanged.listen((
        loadStatus,
      ) {
        if (loadStatus == LoadStatus.loaded) {
          final buildingSceneLayers = widget.localScene.operationalLayers
              .whereType<BuildingSceneLayer>()
              .toList();

          setState(() {
            _buildingSceneLayers = buildingSceneLayers;
            _selectedBuildingSceneLayer = _buildingSceneLayers.first;
          });

          // We've heard enough. Cancel the subscription and null the variable.
          _sceneOnLoadSubscription!.cancel();
          _sceneOnLoadSubscription = null;
        }
      });
    }
  }

  @override
  void dispose() {
    if (_sceneOnLoadSubscription != null) {
      _sceneOnLoadSubscription!.cancel().then(
        (_) => _sceneOnLoadSubscription = null,
      );
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Building scene layer name centered
            if (_buildingSceneLayers.length == 1)
              Text(
                _selectedBuildingSceneLayer!.name,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              )
            else
              DropdownButton(
                value:
                    _selectedBuildingSceneLayer ?? _buildingSceneLayers.first,
                items: _buildingSceneLayers
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (layer) =>
                    setState(() => _selectedBuildingSceneLayer = layer),
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
        _BuildingLevelSelector(
          buildingSceneLayer: _selectedBuildingSceneLayer!,
        ),
        const Divider(),
        Text(
          'Disciplines & Categories:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Expanded(
          child: _BuildingCategoryList(
            buildingSceneLayer: _selectedBuildingSceneLayer!,
            fullModelSublayerName: widget.fullModelSublayerName,
          ),
        ),
      ],
    );
  }
}
