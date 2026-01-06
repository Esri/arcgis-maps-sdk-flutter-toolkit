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

/// Creates a CompassKnobHost instance with properties driven by Widgetbook knobs.
/// This allows for interactive adjustment of the compass properties
/// in the Widgetbook UI. If other use cases need test the properties for a Compass,
/// they can call this function to get one with the same knob-driven properties.
CompassKnobHost createCompassKnobHost(BuildContext context) {
  return CompassKnobHost(
    alignment: alignmentKnob(context),
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
      context.knobs.double.slider(label: 'Padding', initialValue: 40, max: 100),
    ),
  );
}

/// Hosts Widgetbook knobs and updates a stable CompassDelegate instance
/// so changes are reflected live without recreating the delegate.
class CompassKnobHost extends StatefulWidget {
  const CompassKnobHost({
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

  /// Factory method to create a [Compass] configured with this delegate's values.
  ///
  /// Provide the same `controllerProvider` that is used by the corresponding
  /// ArcGIS view (e.g., [ArcGISMapView], [ArcGISSceneView], or [ArcGISLocalSceneView]).
  Compass createCompass({
    required GeoViewController Function() controllerProvider,
  }) {
    return Compass(
      controllerProvider: controllerProvider,
      automaticallyHides: automaticallyHides,
      alignment: alignment,
      padding: padding,
      size: size.toDouble(),
      iconBuilder: (context, sz, angleRadians) => Transform.rotate(
        angle: angleRadians,
        child: Icon(compassIcon, size: sz, color: compassColor),
      ),
    );
  }

  @override
  State<CompassKnobHost> createState() => _CompassKnobHostState();
}

class _CompassKnobHostState extends State<CompassKnobHost> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
