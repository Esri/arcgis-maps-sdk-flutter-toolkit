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

part of '../../arcgis_maps_toolkit.dart';

/// A view that displays a [UtilityAssociationsPopupElement] and allows
/// navigating through its filter results.
class _UtilityAssociationsPopupElementView extends StatefulWidget {
  const _UtilityAssociationsPopupElementView({
    required this.geoElement,
    required this.popupElement,
    this.isExpanded = false,
  });

  /// Original geoElement of the popup.
  final GeoElement geoElement;

  /// The utility associations pop-up element to be displayed.
  final UtilityAssociationsPopupElement popupElement;

  /// A boolean indicating whether the expansion tile should be initially expanded.
  final bool isExpanded;

  @override
  _UtilityAssociationsPopupElementViewState createState() =>
      _UtilityAssociationsPopupElementViewState();
}

class _UtilityAssociationsPopupElementViewState
    extends State<_UtilityAssociationsPopupElementView> {
  late bool isExpanded;
  late final Future<void> _fetchAssociationsFuture;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.isExpanded;

    _fetchAssociationsFuture = widget.popupElement
        .fetchAssociationsFilterResults();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchAssociationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to fetch utility associations filter results.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            );
          }

          // The UtilityAssociationsFilterResult is ready to retrieve.
          return buildAssociationsPopupElementCard(context);
        } else {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              spacing: 20,
              children: [
                const Text('Building the UtilityAssociationPopup View'),
                // Connection state label
                Text(snapshot.connectionState.name),
                Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: widget.popupElement.title,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget buildAssociationsPopupElementCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color:
          Theme.of(context).cardTheme.color ??
          Theme.of(context).colorScheme.surface,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          backgroundColor:
              Theme.of(context).expansionTileTheme.backgroundColor ??
              Colors.transparent,
          collapsedBackgroundColor:
              Theme.of(context).expansionTileTheme.collapsedBackgroundColor ??
              Colors.transparent,
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          // The Popup title and description.
          title: _PopupElementHeader(
            title: widget.popupElement.displayTitle,
            description: widget.popupElement.description,
          ),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() => isExpanded = expanded);
          },
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          tilePadding: const EdgeInsets.symmetric(horizontal: 10),
          childrenPadding: const EdgeInsets.all(2),
          children: [_buildUtilityAssociationsFilterResultContent(context)],
        ),
      ),
    );
  }

  /// Build the contents from the list of [UtilityAssociationsFilterResult].
  Widget _buildUtilityAssociationsFilterResultContent(BuildContext context) {
    final associationsFilterResults =
        widget.popupElement.associationsFilterResults;
    // No results for any of the filters, show no associations widget.
    final noAssociations = associationsFilterResults.every(
      (r) => r.resultCount == 0,
    );
    if (noAssociations) {
      return buildNoAssociationsWidget();
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: associationsFilterResults.length,
      separatorBuilder: (context, index) {
        final filterResult = associationsFilterResults[index + 1];
        return (filterResult.resultCount > 0)
            ? _buildDivider(context)
            : const SizedBox.shrink();
      },
      itemBuilder: (context, index) {
        final filterResult = associationsFilterResults[index];
        if (filterResult.resultCount > 0) {
          return _AssociationsFilterResultTile(
            associationsFilterResult: filterResult,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // Build a no-association widget.
  Widget buildNoAssociationsWidget() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.warning,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'No associations were found',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// A view that displays a list of [UtilityAssociationsFilterResult]
/// and allows navigating to its group results.
class _AssociationsFilterResultTile extends StatelessWidget {
  const _AssociationsFilterResultTile({required this.associationsFilterResult});
  final UtilityAssociationsFilterResult associationsFilterResult;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        associationsFilterResult.displayTitle,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Text(
        associationsFilterResult.filter.description,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      onTap: () => routeToFilterResultDetailView(context),
      trailing: IconButton(
        icon: const Icon(Icons.chevron_right),
        onPressed: () => routeToFilterResultDetailView(context),
      ),
      contentPadding: const EdgeInsets.only(left: 30),
    );
  }

  void routeToFilterResultDetailView(BuildContext context) {
    final state = context.findAncestorStateOfType<_PopupViewState>()!;
    state._push(
      MaterialPage<Widget>(
        key: ValueKey(
          'UtilityAssociationsFilterResultView_${associationsFilterResult.filter.filterType.name}',
        ),
        child: _UtilityAssociationsFilterResultView(
          associationsFilterResult: associationsFilterResult,
        ),
      ),
    );
  }
}

// Get the display title of UtilityAssociationsFilterResult.
extension on UtilityAssociationsFilterResult {
  String get displayTitle =>
      filter.title.isEmpty ? filter.filterType.name : filter.title;
}

// Get the display title of UtilityAssociationsPopupElement.
extension on UtilityAssociationsPopupElement {
  String get displayTitle => (title.isEmpty) ? 'Associations' : title;
}

// Create a Divider for the given context
Widget _buildDivider(BuildContext context) {
  return Divider(
    color: Theme.of(context).dividerTheme.color ?? Colors.grey,
    height: 1,
    thickness: Theme.of(context).dividerTheme.thickness ?? 1,
  );
}
