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
    required this.popupElement,
    this.isExpanded = false,
  });

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
        .fetchAssociationsFilterResults()
        .catchError((Object error) {
          throw error as Exception;
        });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchAssociationsFuture,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
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

          case ConnectionState.done:
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Fail to fetch pop-up utility network associations filter results.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              );
            } else {
              // The UtilityAssociationsFilterResult is ready to retrieve.
              return buildAssociationsPopupElementCard(context);
            }
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
            title: widget.popupElement.displayTitle(),
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
      physics: const NeverScrollableScrollPhysics(),
      itemCount: associationsFilterResults!.length,
      separatorBuilder: (context, index) {
        if (index <= (associationsFilterResults!.length - 1)) {
          final filterResult = associationsFilterResults![index + 1];
          if (filterResult.resultCount > 0) {
            return Divider(
              color: Theme.of(context).dividerTheme.color ?? Colors.grey,
              height: 1,
              thickness: Theme.of(context).dividerTheme.thickness ?? 1,
            );
          }
        }
        return const SizedBox.shrink();
      },
      itemBuilder: (context, index) {
        final filterResult = associationsFilterResults![index];
        if (filterResult.resultCount > 0) {
          return _AssociationsFilterResultTile(
            associationsFilterResult: filterResult,
            associationDisplayCount: filterResult.resultCount,
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
          Container(width: 4, height: 40, color: Colors.red),
          const SizedBox(width: 12),
          const Icon(Icons.warning, color: Colors.red, size: 20),
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
  const _AssociationsFilterResultTile({
    required this.associationsFilterResult,
    required this.associationDisplayCount,
  });
  final UtilityAssociationsFilterResult associationsFilterResult;
  final int associationDisplayCount;
  // The name of next route view name.
  static const nextRouteName = '/filter-detail-view';

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
      trailing: IconButton(
        icon: const Icon(Icons.chevron_right),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              settings: const RouteSettings(name: nextRouteName),
              builder: (_) => _UtilityAssociationsFilterResultDetailView(
                associationsFilterResult: associationsFilterResult,
                displayCount: associationDisplayCount,
              ),
            ),
          );
        },
      ),
      contentPadding: const EdgeInsets.only(left: 30),
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
  String displayTitle() => (title.isEmpty) ? 'Associations' : title;
}
