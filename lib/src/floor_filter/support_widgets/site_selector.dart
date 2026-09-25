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
class _SiteSelector extends StatefulWidget {
  /// Creates a site selector.
  const _SiteSelector({required FloorFilterController floorFilterController})
    : _widgetController = floorFilterController;

  final FloorFilterController _widgetController;

  @override
  State<_SiteSelector> createState() => _SiteSelectorState();
}

class _SiteSelectorState extends State<_SiteSelector> {
  StreamSubscription<FloorSite?>? _onSiteChangedSubscription;
  FloorSite? _selectedSite;
  late final List<FloorSite> _sites;
  late List<FloorSite> _filterdSites;

  @override
  void initState() {
    super.initState();
    _selectedSite = widget._widgetController._selectedSite;
    _sites = widget._widgetController._floorManager?.sites ?? <FloorSite>[];
    _filterdSites = List.from(_sites);
    _filterdSites.sort((site1, site2) => site1.name.compareTo(site2.name));

    _onSiteChangedSubscription = widget._widgetController._onSiteChanged.listen(
      (newSite) {
        if (mounted) {
          setState(() => _selectedSite = newSite);
        }
      },
    );
  }

  @override
  void dispose() {
    _onSiteChangedSubscription?.cancel().ignore();
    _onSiteChangedSubscription = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sites'),
        automaticallyImplyLeading: false,
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
            onPressed: () => _onSiteSelected(null),
            child: const Text('All Facilities'),
          ),
        ],
      ),
    );
  }

  void _filterSitesByName(String filterText) {
    final List<FloorSite> tmpSites;

    if (filterText.isEmpty) {
      tmpSites = List.from(_sites);
    } else {
      tmpSites = _sites.where((site) {
        final siteName = site.name.toUpperCase();
        return siteName.contains(filterText.toUpperCase());
      }).toList();
    }

    tmpSites.sort((site1, site2) => site1.name.compareTo(site2.name));

    if (mounted) {
      setState(() {
        _filterdSites = tmpSites;
      });
    }
  }

  void _onSiteSelected(FloorSite? site) {
    // Set the selected site on the controller.
    widget._widgetController._selectSite(site);

    // Navigate to facility selector sheet.
    _SelectorFlow.showFacilitySelector(context);
  }
}
