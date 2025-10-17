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
  State<StatefulWidget> createState() => _PopupViewState();
}

// State for [PopupView] that manages a stack of pages for pop-up navigation.
// This state class maintains a list of [Page]s to support navigation
// within the pop-up view, allowing for pushing and popping of detail pages
// (such as related records or associations) on top of the root pop-up.
// It handles back navigation, closing the pop-up, and provides utility methods
// for navigation and root pop-up checks.
class _PopupViewState extends State<PopupView> {
  final _pages = <Page<Widget>>[];

  @override
  void initState() {
    super.initState();
    _pages.add(
      MaterialPage(
        child: _PopupViewInternal(popup: widget.popup, onClose: widget.onClose),
        key: ValueKey(_getPopupViewKey(widget.popup.geoElement)),
      ),
    );
  }

  @override
  void dispose() {
    _pages.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _popupViewThemeData,
      child: Navigator(
        pages: List.of(_pages),
        // Handle the back button press to pop the last page.
        onDidRemovePage: (page) {
          if (_pages.isEmpty) {
            // Defer to avoid setState during build of PopupView / Navigator.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                widget.onClose?.call();
              }
            });
          }
        },
      ),
    );
  }

  // Navigate to a pop-up view with the specified key, removing other pages.
  void _popupWithKey(String key) {
    setState(() {
      _pages.removeWhere((page) => page.key != ValueKey(key));
    });
  }

  // Push a new page onto the navigation stack.
  void _push(Page<Widget> page) {
    setState(() {
      _pages.add(page);
    });
  }

  // Pop the last page from the navigation stack.
  void _pop() {
    if (_pages.length > 1) {
      setState(_pages.removeLast);
      return;
    }

    // At root: treat as close request instead of popping (avoids empty pages list).
    widget.onClose?.call();
  }

  // Signal to parent to close the PopupView.
  void _close() {
    widget.onClose?.call();
  }

  // Whether the current page is the home (root) page.
  bool get isHome => _pages.length == 1;

  // Tests if the GeoElement PopupView have been shown.
  bool _isExistingPopupPage(String key) {
    return _pages.any((page) => page.key == ValueKey(key));
  }

  void _popToRoot() {
    if (_pages.length > 1) {
      setState(() {
        _pages.removeRange(1, _pages.length);
      });
    }
  }
}

// The view that displays the content of a [Popup].
class _PopupViewInternal extends StatefulWidget {
  const _PopupViewInternal({required this.popup, this.onClose});

  /// The [Popup] object to be displayed.
  final Popup popup;

  final VoidCallback? onClose;

  @override
  State<StatefulWidget> createState() => _PopupStateInternal();
}

/// State for [_PopupViewInternal] that handles the evaluation
/// of pop-up expressions
/// and builds the UI for displaying the pop-up content.
class _PopupStateInternal extends State<_PopupViewInternal> {
  late Future<List<PopupExpressionEvaluation>> _futurePopupExprEvaluation;
  @override
  void initState() {
    super.initState();
    _futurePopupExprEvaluation = widget.popup.evaluateExpressions();
  }

  @override
  void didUpdateWidget(covariant _PopupViewInternal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.popup != widget.popup) {
      _futurePopupExprEvaluation = widget.popup.evaluateExpressions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _UtilityAssociationHeader(title: widget.popup.title),
          const Divider(),
          Expanded(
            child: FutureBuilder(
              // Evaluate the pop-up expressions asynchronously,
              // it needs to be done before displaying the pop-up elements.
              future: _futurePopupExprEvaluation,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Unable to evaluate pop-up expressions.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  return _buildElementsView();
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
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
                    popupTitle: widget.popup.title,
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

// Generate a unique key for the PopupView based on the GeoElement's objectId.
String _getPopupViewKey(GeoElement geoElement) {
  return 'PopupView_${geoElement.attributes['objectId'] ?? '0'}';
}
