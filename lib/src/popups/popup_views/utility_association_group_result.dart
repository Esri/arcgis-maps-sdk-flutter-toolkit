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

part of '../../../arcgis_maps_toolkit.dart';

/// A view that displays an expanded [UtilityAssociationsFilterResult]
/// with navigation controls and
/// a lists the [UtilityAssociationGroupResult] elements
class _UtilityAssociationsFilterResultDetailView extends StatefulWidget {
  const _UtilityAssociationsFilterResultDetailView({
    required this.associationsFilterResult,
    required this.displayCount,
  });

  /// The utility associations filter result to expand.
  final UtilityAssociationsFilterResult associationsFilterResult;

  /// Maximum number of associations to display per group.
  final int displayCount;

  @override
  _UtilityAssociationsFilterResultDetailViewState createState() =>
      _UtilityAssociationsFilterResultDetailViewState();
}

class _UtilityAssociationsFilterResultDetailViewState
    extends State<_UtilityAssociationsFilterResultDetailView> {
  late UtilityAssociationsFilterResult associationsFilterResult;

  @override
  void initState() {
    associationsFilterResult = widget.associationsFilterResult;
    super.initState();
  }

  /// Build the [UtilityAssociationFilterResult] detail view.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          associationsFilterResult.displayTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNavigationHeader(context),
          _UtilityAssociationGroupResultWidget(widget.associationsFilterResult),
        ],
      ),
    );
  }

  // Build the navigation header.
  // It will navigate the page to (<) previous page, (^) the original page, (x) close the page.
  Widget _buildNavigationHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          // Add a grey vertical bar
          Container(width: 1, height: 40, color: Colors.grey),
          // TODO: navigate back to original feature.
          // IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_upward)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.associationsFilterResult.displayTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.associationsFilterResult.filter.title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => {Navigator.of(context).pop()},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

///
/// Display the list of the [UtilityAssociationGroupResult].
///
class _UtilityAssociationGroupResultWidget extends StatelessWidget {
  const _UtilityAssociationGroupResultWidget(this.associationsFilterResult);
  final UtilityAssociationsFilterResult associationsFilterResult;

  @override
  Widget build(BuildContext context) {
    final groupResults = associationsFilterResult.groupResults;
    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          separatorBuilder: (context, index) {
            return const Divider(height: 1, thickness: 1);
          },
          itemCount: groupResults.length,
          itemBuilder: (context, index) {
            // Get a UtilityAssociationGroupResult
            final groupResult = associationsFilterResult.groupResults[index];
            return _buildGroupResultTile(context, groupResult);
          },
        ),
      ),
    );
  }

  /// Build the content from a [UtilityAssociationGroupResult]
  /// which has a list of [UtilityAssociationResult].
  Widget _buildGroupResultTile(
    BuildContext context,
    UtilityAssociationGroupResult associationGroupResult,
  ) {
    final title = associationGroupResult.name;
    final totalCount = associationGroupResult.associationResults.length;
    // The last UtilityAssociationResult
    final utilityAssociationResult =
        associationGroupResult.associationResults[totalCount - 1];

    return ExpansionTile(
      leading: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
      ),
      title: Text(title),
      initiallyExpanded: true,
      childrenPadding: const EdgeInsets.only(left: 20),
      // Show a totalCount in a grey circle
      trailing: SizedBox(
        width: 25,
        height: 25,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: const CircleBorder(),
            color: Colors.grey[300],
          ),
          child: Center(
            child: Text(
              '$totalCount',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ),
      ),

      children: totalCount > 1
          ? [
              const Divider(color: Colors.grey, height: 1, thickness: 1),
              _UtilityAssociationResultWidget(utilityAssociationResult),
              const Divider(color: Colors.grey, height: 1, thickness: 1),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: ListTile(
                  title: const Text('Show all'),
                  subtitle: Text('Total: $totalCount'),
                  trailing: IconButton(
                    icon: const Icon(Icons.list),
                    onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          settings: const RouteSettings(
                            name: '/association-selector-view',
                          ),
                          builder: (_) => buildAssociationSelectionPage(
                            associationGroupResult,
                          ),
                        ),
                      ),
                    },
                  ),
                ),
              ),
            ]
          : [_UtilityAssociationResultWidget(utilityAssociationResult)],
    );
  }

  /// Build the association selection page
  Widget buildAssociationSelectionPage(
    UtilityAssociationGroupResult associationGroupResult,
  ) {
    // Get a list of UtilityAssociationResult.
    return Scaffold(
      appBar: AppBar(title: Text(associationsFilterResult.displayTitle)),
      body: _AssociationResultSelectionPage(
        groupResult: associationGroupResult,
      ),
    );
  }
}
