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
  /// - floorFilterController: the [FloorFilterController] for this widget
  /// - onClose: optional [VoidCallback] called when X button in top right is
  /// tapped. If no callback is provided, the button will not appear.
  const _FacilitySelector({
    required FloorFilterController floorFilterController,
    this.onClose,
  }) : _widgetController = floorFilterController;

  final FloorFilterController _widgetController;
  final VoidCallback? onClose;

  @override
  State<_FacilitySelector> createState() => _FacilitySelectorState();
}

class _FacilitySelectorState extends State<_FacilitySelector> {
  // The currenlty selected facility.
  FloorFacility? _selectedFacility;

  // Facility list from the floor manager.
  List<FloorFacility> get _facilities {
    // If there is a selected site, pull facilities from the site. Otherwise
    // list all facilities in the floor manager.
    if (widget._widgetController._selectedSite != null) {
      return widget._widgetController._selectedSite!.facilities;
    } else {
      return widget._widgetController._floorManager?.facilities ??
          <FloorFacility>[];
    }
  }

  // Mutable facility list for filtering and sorting.
  var _filterdFacilities = <FloorFacility>[];

  @override
  void initState() {
    super.initState();
    _selectedFacility =
        widget._widgetController._selectedFacilityNotifier.value;

    // Create a mutable list from the facilities list for filtering and sorting.
    _filterdFacilities = List.from(
      _facilities,
    )..sort((facility1, facility2) => facility1.name.compareTo(facility2.name));

    // Listen for a change in the selected facility from the widget controller.
    widget._widgetController._selectedFacilityNotifier.addListener(
      _onSelectedFacilityChanged,
    );
  }

  @override
  void didUpdateWidget(covariant _FacilitySelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget._widgetController == widget._widgetController) return;

    // Rebind value notifier listeners
    oldWidget._widgetController._selectedFacilityNotifier.removeListener(
      _onSelectedFacilityChanged,
    );
    // Get the selected facility from the current widget controller.
    _selectedFacility = widget._widgetController._selectedFacility;
    widget._widgetController._selectedFacilityNotifier.addListener(
      _onSelectedFacilityChanged,
    );

    // Create a mutable list from the facilities list for filtering and sorting.
    _filterdFacilities = List.from(
      _facilities,
    )..sort((facility1, facility2) => facility1.name.compareTo(facility2.name));
  }

  @override
  void dispose() {
    widget._widgetController._selectedFacilityNotifier.removeListener(
      _onSelectedFacilityChanged,
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facilities'),
        actions: [
          if (widget.onClose != null) ...[
            IconButton(
              icon: const Icon(Icons.close_outlined),
              onPressed: widget.onClose?.call,
            ),
          ],
        ],
      ),
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

  void _onSelectedFacilityChanged() {
    setState(() {
      _selectedFacility =
          widget._widgetController._selectedFacilityNotifier.value;
    });
  }

  // Function called when the search text is changed to filter the
  // facilites in the list by name.
  void _filterFacilitiesByName(String filterText) {
    final List<FloorFacility> tmpFacilities;

    if (filterText.isEmpty) {
      // If nothing is in the search field, pull straight from the full list.
      tmpFacilities = List.from(_facilities);
    } else {
      // Otherwise, filter the sites by the search text.
      tmpFacilities = _facilities.where((facility) {
        final facilityName = facility.name.toUpperCase();
        return facilityName.contains(filterText.toUpperCase());
      }).toList();
    }

    // Sort alphabetically.
    tmpFacilities.sort((site1, site2) => site1.name.compareTo(site2.name));

    setState(() {
      _filterdFacilities = tmpFacilities;
    });
  }

  // Function to handle when a facility is selected from the list.
  void _onFacilitySelected(FloorFacility? facility) {
    // Set the selected facility on the controller.
    widget._widgetController._selectFacility(facility);

    // If on onClose callback was set, call it.
    widget.onClose?.call();
  }
}
