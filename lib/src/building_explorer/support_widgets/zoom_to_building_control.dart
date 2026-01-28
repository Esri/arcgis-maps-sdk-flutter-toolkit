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

part of '../../../arcgis_maps_toolkit.dart';

/// Widget that provides the UI to zoom to the selected building scene layer.
class _ZoomToBuildingControl extends StatelessWidget {
  const _ZoomToBuildingControl({
    required BuildingExplorerController buildingExplorerController,
  }) : widgetController = buildingExplorerController;

  final BuildingExplorerController widgetController;

  @override
  Widget build(BuildContext context) {
    if (widgetController._selectedLayer!.fullExtent == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        const Text('Zoom to building'),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.zoom_in_map),
          onPressed: () {
            final targetExtent = widgetController._selectedLayer!.fullExtent!;
            final currentCamera = widgetController._localSceneViewController
                .getCurrentViewpointCamera();

            final targetCamera = Camera.withLookAtPoint(
              lookAtPoint: targetExtent.center,
              distance: 300,
              heading: currentCamera.heading,
              pitch: currentCamera.pitch,
              roll: 0,
            );
            widgetController._localSceneViewController.setViewpointAnimated(
              Viewpoint.withExtentCamera(
                targetExtent: targetExtent,
                camera: targetCamera,
              ),
            );
          },
        ),
      ],
    );
  }
}
