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
import 'package:widgetbook/widgetbook.dart' as widgetbook;
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

  runApp(const MaterialApp(home: ExampleCompassCustom()));
}

@widgetbook.UseCase(
  name: 'Compass (custom)',
  type: ExampleCompassCustom,
  path: '[Compass]',
)
Widget defaultCompassCustomUseCase(BuildContext context) {
  return ExampleCompassCustom(
    size: context.knobs.int.slider(
      label: 'Size',
      initialValue: 80,
      min: 10,
      max: 200,
    ),
    automaticallyHides: context.knobs.boolean(label: 'Automatically Hides'),
    compassColor: context.knobs.color(
      label: 'Compass Color',
      initialValue: Colors.purple,
    ),
    compassIcon: context.knobs.object.segmented<IconData>(
      label: 'Compass Icon',
      options: const [
        Icons.arrow_circle_up,
        Icons.navigation,
        Icons.arrow_upward,
      ],
      initialOption: Icons.arrow_circle_up,
      labelBuilder: (value) {
        if (value == Icons.arrow_circle_up) {
          return 'Circle Up';
        } else if (value == Icons.navigation) {
          return 'Navigation';
        } else if (value == Icons.arrow_upward) {
          return 'Arrow Upward';
        } else {
          return 'Unknown';
        }
      },
    ),
    padding: EdgeInsets.all(
      context.knobs.double.slider(
        label: 'Padding',
        initialValue: 40,
        max: 100,
      ),
    ),
    alignment: alignmentKnob(context)
  );
}

class ExampleCompassCustom extends StatefulWidget {
  const ExampleCompassCustom({
    super.key,
    this.size = 80,
    this.automaticallyHides = false,
    this.compassColor = Colors.purple,
    this.compassIcon = Icons.arrow_circle_up,
    this.padding = const EdgeInsets.all(40),
    this.alignment = Alignment.centerLeft,
  });
  final int size;
  final bool automaticallyHides;
  final Color compassColor;
  final IconData compassIcon;
  final EdgeInsets padding;
  final Alignment alignment;

  @override
  State<ExampleCompassCustom> createState() => _ExampleCompassCustomState();
}

class _ExampleCompassCustomState extends State<ExampleCompassCustom> {
  // Create a map view controller.
  final _mapViewController = ArcGISMapView.createController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compass Custom')),
      body: Stack(
        children: [
          // Add a map view to the widget tree and set a controller.
          ArcGISMapView(
            controllerProvider: () => _mapViewController,
            onMapViewReady: onMapViewReady,
          ),
          // Create a compass and display on top of the map view in a stack.
          // Pass the compass the corresponding map view controller.
          // This compass implementation amends default properties, such as alignment and icon style.
          Compass(
            controllerProvider: () => _mapViewController,
            // Optionally, always show the compass. Defaults to true, which hides the compass when the map is oriented north.
            automaticallyHides: widget.automaticallyHides,
            // Optionally, apply an alternative alignment. Default is top right.
            alignment: widget.alignment,
            // Optionally, apply custom padding. Default is 10.
            padding: widget.padding,
            // Optionally, set the size of the compass icon. Default is 50.
            size: widget.size.toDouble(),
            // Optionally, apply a custom icon builder to style the icon representing the compass.
            // See the other examples for the default compass style.
            iconBuilder: (context, size, angleRadians) => Transform.rotate(
              angle: angleRadians,
              child: Icon(
                widget.compassIcon,
                size: size,
                color: widget.compassColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onMapViewReady() {
    // Set a map with a basemap style and initial viewpoint to the map view controller.
    final map = ArcGISMap.withBasemapStyle(BasemapStyle.arcGISTopographic)
      ..initialViewpoint = Viewpoint.fromCenter(
        ArcGISPoint(x: 4, y: 51, spatialReference: SpatialReference.wgs84),
        scale: 20000000,
        rotation: -45,
      );
    _mapViewController.arcGISMap = map;
  }
}
