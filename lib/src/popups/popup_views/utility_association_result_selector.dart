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

///
/// Display a list of [UtilityAssociationResult] with the text search text field.
///
class _AssociationResultSelectionPage extends StatefulWidget {
  const _AssociationResultSelectionPage({
    required this.groupResult
  });

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
      appBar: AppBar(title: Text(widget.groupResult.name)),
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
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) {
                        return buildDivider(context);
                      },
                      itemCount: filteredResults.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(filteredResults[index].title),
                        trailing: IconButton(
                          onPressed: () {
                            final feature = filteredResults[index].associatedFeature;
                            _navigateToAssociationPopupPage(context, feature);
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
