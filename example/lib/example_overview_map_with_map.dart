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

import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:arcgis_maps_toolkit/arcgis_maps_toolkit.dart';
import 'package:arcgis_maps_toolkit_example/widget_book/common_util.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

void main() {
  // Supply your apiKey using the --dart-define-from-file command line argument.
  const apiKey = String.fromEnvironment('API_KEY');
  // Alternatively, replace the above line with the following and hard-code your apiKey here:
  // const apiKey = ''; // Your API Key here.
  if (apiKey.isEmpty) {
    throw Exception('apiKey undefined');
  } else {
    ArcGISEnvironment.apiKey = apiKey;
  }

  runApp(const MaterialApp(home: ExampleOverviewMapWithMap()));
}

// Define a use case for widgetbook for the overview map with map example.
@widgetbook.UseCase(
  name: 'OverviewMap (map custom)',
  type: ExampleOverviewMapWithMap,
  path: '[OverviewMap]',
)
Widget defaultOverviewMapWithMapUseCase(BuildContext context) {
  return ExampleOverviewMapWithMap(
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

class ExampleOverviewMapWithMap extends StatefulWidget {
  const ExampleOverviewMapWithMap({
    super.key,
    this.alignment = Alignment.bottomRight,
    this.padding = const EdgeInsets.all(10),
    this.scaleFactor = 25,
    this.outlineColor = Colors.red,
    this.outlineWidth = 1,
    this.map,
  });
  final Alignment alignment;
  final EdgeInsets padding;
  final double scaleFactor;
  final Color outlineColor;
  final double outlineWidth;
  final ArcGISMap? map;

  @override
  State<ExampleOverviewMapWithMap> createState() =>
      _ExampleOverviewMapWithMapState();
}

class _ExampleOverviewMapWithMapState extends State<ExampleOverviewMapWithMap> {
  // Create a map view controller.
  final _mapViewController = ArcGISMapView.createController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OverviewMap with Map')),
      body: Stack(
        children: [
          // Add a map view to the widget tree and set a controller.
          ArcGISMapView(
            controllerProvider: () => _mapViewController,
            onMapViewReady: onMapViewReady,
          ),
          // Create an overview map and display on top of the map view in a stack.
          // Pass the overview map the corresponding map view controller.
          OverviewMap(
            controllerProvider: () => _mapViewController,
            alignment: widget.alignment,
            padding: widget.padding,
            scaleFactor: widget.scaleFactor,
            symbol: SimpleFillSymbol(
              color: Colors.transparent,
              outline: SimpleLineSymbol(
                color: widget.outlineColor,
                width: widget.outlineWidth,
              ),
            ),
            map: widget.map,
          ),
        ],
      ),
    );
  }

  void onMapViewReady() {
    // Set a map with a basemap style and initial viewpoint to the map view controller.
    final map = ArcGISMap.withBasemapStyle(BasemapStyle.arcGISTopographic)
      ..initialViewpoint = Viewpoint.fromCenter(
        ArcGISPoint(x: 4, y: 40, spatialReference: SpatialReference.wgs84),
        scale: 40000000,
      );
    _mapViewController.arcGISMap = map;
  }
}
