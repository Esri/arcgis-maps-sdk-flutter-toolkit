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
/// with navigation controls and group results.
class _UtilityAssociationsFilterResultDetailView extends StatefulWidget {
  const _UtilityAssociationsFilterResultDetailView({
    required this.associationsFilterResult,
    required this.displayCount,
  });

  /// The utility associations filter result to display.
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
      appBar: AppBar(title: Text(associationsFilterResult.displayTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNavigationHeader(context),
          _buildGroupResults(context),
        ],
      ),
    );
  }

  // 
  Widget _buildNavigationHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
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
          //Add a grey vertical bar
          Container(width: 1, height: 40, color: Colors.grey),
          //const SizedBox(width: 12),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_upward),
          ),
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
            onPressed: () => {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// Build the contents from the list of UtilityAssociationGroupResult.
  Widget _buildGroupResults(BuildContext context) {
    final groupResults = associationsFilterResult.groupResults;

    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          separatorBuilder: (context, index) {
            return const Divider(height: 2, thickness: 1);
          },
          itemCount: groupResults.length,
          itemBuilder: (context, index) {
            final groupResult =
                widget.associationsFilterResult.groupResults[index];
            return _buildGroupResultTile(context, groupResult);
          },
        ),
      ),
    );
  }

  /// Build the content from a UtilityAssociationGroup.
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
              buildWithUtilityAssociationResult(utilityAssociationResult),
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
          : [buildWithUtilityAssociationResult(utilityAssociationResult)],
    );
  }

  // Build the content from the UtilityAssociationResult.
  Widget buildWithUtilityAssociationResult(UtilityAssociationResult result) {
    final utilityAssociate = result.association;
    final popup = result.associatedFeature.toPopup();

    return ListTile(
      leading: getAssociationTypeIcon(utilityAssociate.associationType),
      title: Text(result.title),
      trailing: IconButton(
        icon: const Icon(Icons.chevron_right),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => buildAssociationPopupPage(popup),
            ),
          );
        },
      ),
    );
  }

  // Build the association selection page
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

  // Get the association connection type icon.
  Widget getAssociationTypeIcon(UtilityAssociationType type) {
    const assetsPath = 'packages/arcgis_maps_toolkit/assets/icons';
    switch (type) {
      case UtilityAssociationType.junctionEdgeObjectConnectivityFromSide:
        return const ImageIcon(
          AssetImage('$assetsPath/connection-end-left-24.png'),
          size: 24,
        );
      case UtilityAssociationType.junctionEdgeObjectConnectivityToSide:
        return const ImageIcon(
          AssetImage('$assetsPath/connection-end-right-24.png'),
          size: 24,
        );
      case UtilityAssociationType.junctionEdgeObjectConnectivityMidspan:
        return const ImageIcon(
          AssetImage('$assetsPath/connection-end-middle-24.png'),
          size: 24,
        );
      case UtilityAssociationType.connectivity:
        return const ImageIcon(
          AssetImage('$assetsPath/connection-to-connection-24.png'),
          size: 24,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget getTupIcon() {
    const assetsPath = 'packages/arcgis_maps_toolkit/assets/icons';
    return const ImageIcon(
      AssetImage('$assetsPath/t-up-24.png'),
      size: 24,
    );
      
  }
}

Widget buildAssociationPopupPage(Popup popup) {
  return Scaffold(
    appBar: AppBar(),
    body: PopupView(popup: popup),
  );
}

// Create a Popup from the ArcGISFeature.
extension on ArcGISFeature {
  Popup toPopup() {
    var popupDefinition = featureTable?.popupDefinition;
    if (popupDefinition == null) {
      if (featureTable != null &&
          getFeatureSubtype() != null &&
          featureTable! is ArcGISFeatureTable) {
        final arcgisFeatureTable = featureTable! as ArcGISFeatureTable;
        final subTable = arcgisFeatureTable.subtypeSubtables.firstWhere(
          (it) => it.name == getFeatureSubtype()?.name,
        );
        popupDefinition = subTable.popupDefinition;
      }
    }
    return Popup(geoElement: this, popupDefinition: popupDefinition);
  }
}

/// Display a list of UtilityAssociationResult with the text search text field.
class _AssociationResultSelectionPage extends StatefulWidget {
  const _AssociationResultSelectionPage({required this.groupResult});

  final UtilityAssociationGroupResult groupResult;
  @override
  _AssociationResultSelectionPageState createState() =>
      _AssociationResultSelectionPageState();
}

class _AssociationResultSelectionPageState
    extends State<_AssociationResultSelectionPage> {
  late List<UtilityAssociationResult> selectAssociationResults;
  final _searchController = TextEditingController();

  @override
  void initState() {
    selectAssociationResults = widget.groupResult.associationResults;
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 20,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
            ),

            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, child) {
                final filteredResults = selectAssociationResults
                    .where(
                      (result) => result.title.toLowerCase().contains(
                        value.text.toLowerCase(),
                      ),
                    )
                    .toList();

                return Expanded(
                  child: SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredResults.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(filteredResults[index].title),
                        trailing: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => buildAssociationPopupPage(
                                  filteredResults[index].associatedFeature
                                      .toPopup(),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
