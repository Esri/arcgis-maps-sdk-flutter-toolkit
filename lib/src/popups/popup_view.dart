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

/// A widget that will display a pop-up for an individual feature.
/// This includes showing the feature's title, attributes, custom description, media, and attachments.
///
/// The new online Map Viewer allows users to create a pop-up definition by assembling a list of pop-up elements.
/// PopupView will support the display of pop-up elements created by the Map Viewer, including:
/// Text, Fields, Attachments, and Media (Images and Charts).
///
/// # Overview
/// Thanks to the backwards compatibility support in the API, it will also work with the legacy pop-up definitions created
/// by the classic Map Viewer. It does not support editing.
///
/// ## Features
/// * Display a pop-up for a feature based on the pop-up definition defined in a web map.
/// * Supports image refresh intervals on image pop-up media, refreshing the image at a given interval defined in the pop-up element.
/// * Supports elements containing Arcade expression and automatically evaluates expressions.
/// * Displays media (images and charts) full-screen.
/// * Supports hyperlinks in text, media, and fields elements.
///
/// ## Usage
///
/// The [PopupView] contains:
/// * A header section with title defined in the [Popup].
/// * A body, built using a [Column] and combination of [Card] and [ExpansionTile] widgets, consisting of different types of
/// pop-up elements, including text (HTML), fields, media, attachments, and utility network associations.
///
/// A pop-up is usually obtained from an identify result and then a [PopupView] can be created to wrap the pop-up and display its contents in a sized widget, such as a [Dialog] or a [Container]:
/// ```dart
/// PopupView(
///   popup: popup,
///   onClose: () {
///     // Optional: handle close action
///   },
/// )
/// ```
class PopupView extends StatefulWidget {
  /// Creates a [PopupView] widget to display a [Popup] with optional `onClose` callback.
  const PopupView({required this.popup, this.onClose, super.key});

  /// An optional callback function that is called when the [PopupView] is closed. By default, it closes the view.
  final VoidCallback? onClose;

  /// The [Popup] object to be displayed.
  final Popup popup;
  
  @override
  State<StatefulWidget> createState() => PopupState();
}

class PopupState extends State<PopupView> {
  late Future<List<PopupExpressionEvaluation>> _futurePopupExprEvaluation;
  @override
  void initState() {
    super.initState();
    _futurePopupExprEvaluation = widget.popup.evaluateExpressions();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = _popupViewThemeData;
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
                if (widget.onClose != null) {
                  widget.onClose!();
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
            const Divider(),
            Expanded(
              child: FutureBuilder(
                // Evaluate the pop-up expressions asynchronously,
                // it needs to be done before displaying the pop-up elements.
                future: _futurePopupExprEvaluation,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return _buildElementsView();
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Unable to evaluate pop-up expressions.',
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
      // Header with title and close button.
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.popup.title,
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

  /// A list view of different pop-up elements displayed in their respective views.
  Widget _buildElementsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        spacing: 8,
        children: widget.popup.evaluatedElements.isNotEmpty
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
                } else if (element is UtilityAssociationsPopupElement) {         
                  return _UtilityAssociationsPopupElementView(
                    geoElement: widget.popup.geoElement,
                    popupElement: element,
                    isExpanded: true,
                  );
                } else {
                  return const Text('Element not supported');
                }
              }).toList()
            : [const Text('No pop-up elements available.')],
      ),
    );
  }
}

/// This is used to assign a name to the route that displays the first `PopupView`.
/// Naming the route allows for navigating back to it from other pages,
/// such as from a related utility association popup, using `Navigator.popUntil`.
///
/// ### Example
///
/// ```dart
/// Navigator.of(context).push(MaterialPageRoute(
///   settings: const RouteSettings(name: '/$popupRouteName'),
///   builder: (_) {
///     return Scaffold(
///       appBar: AppBar(title: Text(popup.title)),
///       body: PopupView(popup: popup),
///     );
///   },
/// ));
/// ```
const popupRouteName = 'popupView';
