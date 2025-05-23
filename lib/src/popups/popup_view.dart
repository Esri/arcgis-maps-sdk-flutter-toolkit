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
class PopupView extends StatefulWidget {
  const PopupView({required this.popup, this.onClose, super.key});
  final Popup popup;
  final VoidCallback? onClose;

  @override
  State<PopupView> createState() => _PopupViewState();
}

class _PopupViewState extends State<PopupView> {
  late final Future<List<PopupExpressionEvaluation>>
  _evaluatedExpressionsFuture;

  @override
  void initState() {
    super.initState();
    _evaluatedExpressionsFuture = widget.popup.evaluateExpressions();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTitleWidget(),
        const Divider(color: Colors.grey, height: 2, thickness: 2),
        Expanded(
          child: FutureBuilder(
            future: _evaluatedExpressionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return _buildListView();
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTitleWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      // Header with title and close button
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.popup.title,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              if (widget.onClose != null) {
                widget.onClose!();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView(
      children: [
        // Body with popup elements
        Column(
          spacing: 8,
          children:
              widget.popup.evaluatedElements.isNotEmpty
                  ? widget.popup.evaluatedElements.map((element) {
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
      ],
    );
  }
}
