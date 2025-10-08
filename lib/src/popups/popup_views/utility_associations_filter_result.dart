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
/// lists the [UtilityAssociationGroupResult] elements.
class _UtilityAssociationsFilterResultView extends StatefulWidget {
  const _UtilityAssociationsFilterResultView({
    required this.associationsFilterResult,
  });

  /// The utility associations filter result to expand.
  final UtilityAssociationsFilterResult associationsFilterResult;

  @override
  _UtilityAssociationsFilterResultViewState createState() =>
      _UtilityAssociationsFilterResultViewState();
}

class _UtilityAssociationsFilterResultViewState
    extends State<_UtilityAssociationsFilterResultView> {
  /// Build the [UtilityAssociationFilterResult] detail view.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNavigationHeader(context),
            _buildListUtilityAssociationGroupResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildListUtilityAssociationGroupResult() {
    final groupResults = widget.associationsFilterResult.groupResults;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        separatorBuilder: (context, index) => _buildDivider(context),
        itemCount: groupResults.length,
        itemBuilder: (context, index) {
          // Get a UtilityAssociationGroupResult
          final groupResult = groupResults[index];
          return _UtilityAssociationGroupResultWidget(
            utilityAssociationGroupResult: groupResult,
          );
        },
      ),
    );
  }

  // Build the navigation header.
  Widget _buildNavigationHeader(BuildContext context) {
    final state = context.findAncestorStateOfType<_PopupViewState>()!;
    return ListTile(
      // (^) back to the initial page.
      leading: IconButton(
        onPressed: state._popToRoot,
        icon: const Icon(Icons.arrow_upward),
      ),
      title: Text(
        // UtilityAssociationsFilter title
        widget.associationsFilterResult.filter.title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        // UtilityAssociationsFilter description
        widget.associationsFilterResult.filter.description,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
      ),
      // (x) close the page.
      trailing: IconButton(
        icon: const Icon(Icons.close),
        onPressed: state._pop,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}
