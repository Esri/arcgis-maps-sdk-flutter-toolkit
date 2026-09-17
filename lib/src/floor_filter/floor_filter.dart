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

/// A widget for filtering map content by floor.
class FloorFilter extends StatefulWidget {
  /// Creates a floor filter.
  const FloorFilter({required this.geoViewController, super.key});

  /// The [GeoViewController] for the view showing the floor data. This provides
  /// the map or scene that contains the [FloorManager].
  final GeoViewController geoViewController;

  @override
  State<FloorFilter> createState() => _FloorFilterState();
}

class _FloorFilterState extends State<FloorFilter> {
  FloorManager? _floorManager;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 50,
      child: IconButton.filled(
        onPressed: () => print('FloorFilter online!'),
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.business_outlined),
      ),
    );
  }
}
