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
    required this.popupTitle,
  });

  /// The utility associations filter result to expand.
  final UtilityAssociationsFilterResult associationsFilterResult;

  /// The title of the pop-up that contains this pop-up element.
  final String popupTitle;

  @override
  _UtilityAssociationsFilterResultViewState createState() =>
      _UtilityAssociationsFilterResultViewState();
}

class _UtilityAssociationsFilterResultViewState
    extends State<_UtilityAssociationsFilterResultView> {
  /// Build the [UtilityAssociationsFilterResult] detail view.
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UtilityAssociationHeader(
            title: widget.associationsFilterResult.filter.title,
            subtitle: widget.popupTitle,
          ),
          const Divider(),
          Expanded(child: _buildListUtilityAssociationGroupResult()),
        ],
      ),
    );
  }

  Widget _buildListUtilityAssociationGroupResult() {
    final groupResults = widget.associationsFilterResult.groupResults;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: groupResults.length,
        itemBuilder: (context, index) {
          // Get a UtilityAssociationGroupResult.
          final groupResult = groupResults[index];
          return _UtilityAssociationGroupResultWidget(
            utilityAssociationGroupResult: groupResult,
          );
        },
      ),
    );
  }
}
