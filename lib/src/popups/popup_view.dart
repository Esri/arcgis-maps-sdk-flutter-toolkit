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

/// A PopupView that displays a Popup with its various popup elements.
/// The popup view is built using a ListView and contains a header with the title
/// and a close button. The body of the popup view consists of different types of popup elements,
/// such as text (HTML), fields, media, and attachments elements.
/// parameters:
/// - [popup]: The Popup object to be displayed.
/// - [onClose]: An optional callback function that is called when the popup is closed.
/// - [theme]: An optional parameter that specifies custom theme data for the popup.
class PopupView extends StatelessWidget {
  const PopupView({required this.popup, this.onClose, this.theme, super.key});

  final VoidCallback? onClose;
  final Popup popup;
  final ThemeData? theme;

  @override
  Widget build(BuildContext context) {
    final themeData = theme ?? Theme.of(context);
    return Theme(
      data: themeData,
      child: Container(
        decoration: BoxDecoration(
          color: themeData.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            _buildTitleWidget(
              style: themeData.textTheme.titleMedium,
              onClosePressed: () {
                if (onClose != null) {
                  onClose!();
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
            const Divider(),
            Expanded(
              child: FutureBuilder(
                // Evaluate the popup expressions asynchronously,
                // it needs to be done before displaying the popup elements.
                future: popup.evaluateExpressions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return _buildListView();
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Unable to evaluate popup expressions.',
                        style: themeData.textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleWidget({
    required VoidCallback onClosePressed,
    TextStyle? style,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      // Header with title and close button
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              popup.title,
              style: style,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          IconButton(icon: const Icon(Icons.close), onPressed: onClosePressed),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        spacing: 8,
        children: popup.evaluatedElements.isNotEmpty
            ? popup.evaluatedElements.map((element) {
                if (element is FieldsPopupElement) {
                  return _FieldsPopupElementView(
                    fieldsElement: element,
                    isExpanded: true,
                  );
                } else if (element is AttachmentsPopupElement) {
                  return _AttachmentsPopupElementView(
                    attachmentsElement: element,
                    isExpanded: true,
                  );
                } else if (element is MediaPopupElement) {
                  return _MediaPopupElementView(
                    mediaElement: element,
                    isExpanded: true,
                  );
                } else if (element is TextPopupElement) {
                  return _TextPopupElementView(textElement: element);
                } else {
                  return const Text('Element not supported');
                }
              }).toList()
            : [const Text('No popup elements available.')],
      ),
    );
  }
}
