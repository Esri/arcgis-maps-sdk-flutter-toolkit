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

/// A widget for selecting a floor filter site.
/// - floorFilterController: the [FloorFilterController] for this widget
/// - onClose: optional [VoidCallback] called when X button in top right is
/// tapped. If no callback is provided, the button will not appear.
class _SiteSelector extends StatefulWidget {
  /// Creates a site selector.
  const _SiteSelector({
    required FloorFilterController floorFilterController,
    this.onClose,
  }) : _widgetController = floorFilterController;

  final FloorFilterController _widgetController;
  final VoidCallback? onClose;

  @override
  State<_SiteSelector> createState() => _SiteSelectorState();
}

class _SiteSelectorState extends State<_SiteSelector> {
  // The currently selected site.
  FloorSite? _selectedSite;

  // Site list from the floor manager.
  List<FloorSite> get _sites =>
      widget._widgetController._floorManager?.sites ?? <FloorSite>[];

  // Mutable site list for filtering and sorting.
  var _filterdSites = <FloorSite>[];

  @override
  void initState() {
    super.initState();
    _selectedSite = widget._widgetController._selectedSiteNotifier.value;
    widget._widgetController._selectedSiteNotifier.addListener(
      _onSelectedSiteChanged,
    );

    _filterdSites = List.from(_sites)
      ..sort((site1, site2) => site1.name.compareTo(site2.name));
  }

  @override
  void didUpdateWidget(covariant _SiteSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget._widgetController == widget._widgetController) return;

    // Rebind valueNotifier listeners
    oldWidget._widgetController._selectedSiteNotifier.removeListener(
      _onSelectedSiteChanged,
    );
    // Get the selected site from the current widget controller.
    _selectedSite = widget._widgetController._selectedSite;
    widget._widgetController._selectedSiteNotifier.addListener(
      _onSelectedSiteChanged,
    );

    // Refresh filtered sites list.
    _filterdSites = List.from(_sites)
      ..sort((site1, site2) => site1.name.compareTo(site2.name));
  }

  @override
  void dispose() {
    widget._widgetController._selectedSiteNotifier.removeListener(
      _onSelectedSiteChanged,
    );

    super.dispose();
  }

  void _onSelectedSiteChanged() {
    setState(() {
      _selectedSite = widget._widgetController._selectedSiteNotifier.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sites'),
        automaticallyImplyLeading: false,
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
              onChanged: _filterSitesByName,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search',
                prefixIcon: Icon(Icons.search_outlined),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filterdSites.length,
              itemBuilder: (context, index) {
                final site = _filterdSites[index];
                return ListTile(
                  title: site == _selectedSite
                      ? Text(
                          site.name,
                          style: const TextStyle(fontWeight: .w800),
                        )
                      : Text(site.name),
                  onTap: () => _onSiteSelected(site),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _onAllSites,
            child: const Text('All Sites'),
          ),
        ],
      ),
    );
  }

  // Function called when the search text is changed to filter the sites in
  // the list by name.
  void _filterSitesByName(String filterText) {
    final List<FloorSite> tmpSites;

    if (filterText.isEmpty) {
      // If nothing is in the search field, pull straight from the full list.
      tmpSites = List.from(_sites);
    } else {
      // Otherwise, filter the sites by the search text.
      tmpSites = _sites.where((site) {
        final siteName = site.name.toUpperCase();
        return siteName.contains(filterText.toUpperCase());
      }).toList();
    }

    // Sort alphabetically.
    tmpSites.sort((site1, site2) => site1.name.compareTo(site2.name));

    setState(() {
      _filterdSites = tmpSites;
    });
  }

  // Function to handle when a site is selected from the list.
  void _onSiteSelected(FloorSite? site) {
    // Set the selected site on the controller.
    widget._widgetController._selectSite(site);

    // Only list facilities for this site.
    widget._widgetController._listAllFacilities = false;

    // Navigate to facility selector sheet.
    _SiteAndFacilitySelectorNavigator.showFacilitySelector(context);
  }

  // Function to handle when the All Sites button is tapped.
  void _onAllSites() {
    // Set the selected site on the controller.
    widget._widgetController._listAllFacilities = true;

    // Navigate to facility selector sheet.
    _SiteAndFacilitySelectorNavigator.showFacilitySelector(context);
  }
}
