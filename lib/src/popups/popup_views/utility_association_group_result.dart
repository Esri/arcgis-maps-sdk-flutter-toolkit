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

/// Display the [UtilityAssociationGroupResult].
class _UtilityAssociationGroupResultWidget extends StatefulWidget {
  const _UtilityAssociationGroupResultWidget({
    required this.utilityAssociationGroupResult,
  });
  final UtilityAssociationGroupResult utilityAssociationGroupResult;

  @override
  State<StatefulWidget> createState() => _UtilityAssociationGroupResultState();
}

class _UtilityAssociationGroupResultState
    extends State<_UtilityAssociationGroupResultWidget> {
  bool isExpanded = true;

  /// Build the content from a [UtilityAssociationGroupResult]
  /// which has a list of [UtilityAssociationResult].
  @override
  Widget build(BuildContext context) {
    final title = widget.utilityAssociationGroupResult.name;
    final totalCount =
        widget.utilityAssociationGroupResult.associationResults.length;
    if (totalCount == 0) {
      return const SizedBox.shrink();
    }
    // The first UtilityAssociationResult
    final utilityAssociationResult =
        widget.utilityAssociationGroupResult.associationResults[0];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color:
          Theme.of(context).cardTheme.color ??
          Theme.of(context).colorScheme.surface,
      child: ExpansionTile(
        leading: isExpanded
            ? const Icon(Icons.keyboard_arrow_down_rounded)
            : const Icon(Icons.keyboard_arrow_right_rounded),
        title: Text(title),
        initiallyExpanded: isExpanded,
        onExpansionChanged: (value) => setState(() => isExpanded = value),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 10),
        childrenPadding: const EdgeInsets.all(2),
        // Show a totalCount in a grey circle
        trailing: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: SizedBox(
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
        ),

        children: totalCount > 1
            ? [
                _buildDivider(context),
                _UtilityAssociationResultWidget(
                  utilityAssociationResult: utilityAssociationResult,
                ),
                _buildDivider(context),
                buildShowAllWidget(totalCount),
              ]
            : [
                _UtilityAssociationResultWidget(
                  utilityAssociationResult: utilityAssociationResult,
                ),
              ],
      ),
    );
  }

  /// Build the showAll tile.
  Widget buildShowAllWidget(int total) {
    final state = context.findAncestorStateOfType<_PopupViewState>()!;
    return Padding(
      padding: const EdgeInsets.only(left: 40),
      child: ListTile(
        title: const Text('Show all'),
        subtitle: Text('Total: $total'),
        onTap: () {
          state._push(
            MaterialPage(
              child: _AssociationResultSelectionPage(
                groupResult: widget.utilityAssociationGroupResult,
              ),
              key: ValueKey(
                'UtilityAssociationSelectionPage_${widget.utilityAssociationGroupResult.hashCode}',
              ),
            ),
          );
        },
        trailing: const Icon(Icons.list),
      ),
    );
  }
}
