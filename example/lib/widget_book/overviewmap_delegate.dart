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

import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:arcgis_maps_toolkit/arcgis_maps_toolkit.dart';
import 'package:arcgis_maps_toolkit_example/widget_book/common_util.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

// Create an OverviewMapKnobsHost configured with knobs from the provided context.
OverviewMapKnobsHost createOverviewMapWithKnobs(BuildContext context) {
  return OverviewMapKnobsHost(
    alignment: alignmentKnob(context),
    padding: EdgeInsets.all(
      context.knobs.double.slider(label: 'Padding', initialValue: 10, max: 100),
    ),
    scaleFactor: context.knobs.double.slider(
      label: 'Scale Factor',
      initialValue: 25,
      min: 1,
      max: 100,
    ),
    outlineColor: context.knobs.color(
      label: 'Outline Color',
      initialValue: Colors.red,
    ),
    outlineWidth: context.knobs.double.slider(
      label: 'Outline Width',
      initialValue: 1,
      min: 1,
      max: 10,
    ),
    map: context.knobs.object.segmented<ArcGISMap>(
      label: 'Overview Map',
      options: [
        ArcGISMap.withBasemapStyle(BasemapStyle.arcGISTopographic),
        ArcGISMap.withBasemapStyle(BasemapStyle.arcGISImagery),
        ArcGISMap.withBasemapStyle(BasemapStyle.arcGISStreets),
      ],
      initialOption: ArcGISMap.withBasemapStyle(BasemapStyle.arcGISTopographic),
      labelBuilder: (value) {
        final lastSegment = value.basemap?.uri.toString().split('/').last;
        if (lastSegment == 'topographic') {
          return 'Topographic';
        } else if (lastSegment == 'imagery') {
          return 'Imagery';
        } else if (lastSegment == 'streets') {
          return 'Streets';
        } else {
          return 'Unknown';
        }
      },
    ),
  );
}

class OverviewMapKnobsHost extends StatefulWidget {
  const OverviewMapKnobsHost({
    super.key,
    this.alignment = Alignment.centerLeft,
    this.padding = const EdgeInsets.all(10),
    this.scaleFactor = 0.25,
    this.outlineColor = Colors.black,
    this.outlineWidth = 2.0,
    this.map,
  });
  final Alignment alignment;
  final EdgeInsets padding;
  final double scaleFactor;
  final Color outlineColor;
  final double outlineWidth;
  final ArcGISMap? map;

  /// Factory method to create an [OverviewMap] configured with this host's values.
  ///
  /// Provide the same `controllerProvider` that is used by the corresponding
  /// ArcGIS view (e.g., [ArcGISMapView], [ArcGISSceneView], or [ArcGISLocalSceneView]).
  OverviewMap createOverviewMap({
    required GeoViewController Function() controllerProvider,
  }) {
    // Choose a default symbol based on the controller type.
    ArcGISSymbol? symbol;
    final controller = controllerProvider();
    switch (controller) {
      case ArcGISMapViewController():
        symbol = SimpleFillSymbol(
          color: Colors.transparent,
          outline: SimpleLineSymbol(color: outlineColor, width: outlineWidth),
        );
      default:
        symbol = SimpleMarkerSymbol(
          style: SimpleMarkerSymbolStyle.cross,
          color: outlineColor,
          size: 20,
        );
    }

    return OverviewMap(
      controllerProvider: controllerProvider,
      alignment: alignment,
      padding: padding,
      scaleFactor: scaleFactor,
      symbol: symbol,
      map: map,
    );
  }

  @override
  State<OverviewMapKnobsHost> createState() => _OverviewMapKnobsHostState();
}

class _OverviewMapKnobsHostState extends State<OverviewMapKnobsHost> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
