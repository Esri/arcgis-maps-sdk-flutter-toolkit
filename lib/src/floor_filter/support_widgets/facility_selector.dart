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

/// A widget for selecting a floor facility.
class _FacilitySelector extends StatefulWidget {
  /// Creates a FacilitySelector.
  const _FacilitySelector({
    required FloorFilterController floorFilterController,
  }) : _widgetController = floorFilterController;

  final FloorFilterController _widgetController;

  @override
  State<_FacilitySelector> createState() => _FacilitySelectorState();
}

class _FacilitySelectorState extends State<_FacilitySelector> {
  StreamSubscription<FloorFacility?>? _onFacilityChangedSubscription;
  FloorFacility? _selectedFacility;
  late final List<FloorFacility> _facilities;
  late List<FloorFacility> _filterdFacilities;

  @override
  void initState() {
    super.initState();
    _selectedFacility = widget._widgetController._selectedFacility;
    _facilities =
        widget._widgetController._floorManager?.facilities ?? <FloorFacility>[];
    _filterdFacilities = List.from(_facilities);
    _filterdFacilities.sort(
      (facility1, facility2) => facility1.name.compareTo(facility2.name),
    );

    _onFacilityChangedSubscription = widget._widgetController._onFacilityChanged
        .listen((newFacility) {
          if (mounted) {
            setState(() => _selectedFacility = newFacility);
          }
        });
  }

  @override
  void dispose() {
    _onFacilityChangedSubscription?.cancel().ignore();
    _onFacilityChangedSubscription = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Facilities')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              onChanged: _filterFacilitiesByName,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search',
                prefixIcon: Icon(Icons.search_outlined),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filterdFacilities.length,
              itemBuilder: (context, index) {
                final facility = _filterdFacilities[index];
                return ListTile(
                  title: facility == _selectedFacility
                      ? Text(
                          facility.name,
                          style: const TextStyle(fontWeight: .w800),
                        )
                      : Text(facility.name),
                  subtitle: facility.site != null
                      ? Text(facility.site!.name)
                      : null,
                  onTap: () => _onFacilitySelected(facility),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _filterFacilitiesByName(String filterText) {
    final List<FloorFacility> tmpFacilities;

    if (filterText.isEmpty) {
      tmpFacilities = List.from(_facilities);
    } else {
      tmpFacilities = _facilities.where((facility) {
        final facilityName = facility.name.toUpperCase();
        return facilityName.contains(filterText.toUpperCase());
      }).toList();
    }

    // Sort alphabetically.
    tmpFacilities.sort((site1, site2) => site1.name.compareTo(site2.name));

    if (mounted) {
      setState(() {
        _filterdFacilities = tmpFacilities;
      });
    }
  }

  void _onFacilitySelected(FloorFacility? facility) {
    // Set the selected facility on the controller.
    widget._widgetController._selectFacility(facility);
  }
}
