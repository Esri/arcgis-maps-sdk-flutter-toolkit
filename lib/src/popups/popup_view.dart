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
  const PopupView({
    required this.popup,
    this.spacing,
    this.onClose,
    this.closeIconBuilder,
    this.waitingBuilder,
    this.errorBuilder,
    this.divider,
    this.physics,
    this.padding,
    this.titlePadding,
    this.titleMainAlignment,
    this.titleCrossAlignment,
    this.noElementsText,
    this.elementStyle,
    this.scrollEntirePopup = false,
    super.key,
  });

  final double? spacing;
  final Popup popup;
  final VoidCallback? onClose;
  final CrossAxisAlignment? titleCrossAlignment;
  final MainAxisAlignment? titleMainAlignment;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? titlePadding;
  final Widget Function(BuildContext context)? waitingBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final Widget Function(BuildContext context, VoidCallback onClose)?
  closeIconBuilder;
  final WidgetBuilder? divider;
  final ScrollPhysics? physics;
  final String? noElementsText;
  final bool scrollEntirePopup;
  final PopupElementStyle? elementStyle;

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
    return FutureBuilder(
      future: _evaluatedExpressionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.waitingBuilder?.call(context) ??
              const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return widget.errorBuilder?.call(context, snapshot.error!) ??
              Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
        }

        if (widget.scrollEntirePopup) {
          return SingleChildScrollView(
            physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
            child: _buildPopupContent(
              scrollEntirePopup: widget.scrollEntirePopup,
            ),
          );
        } else {
          return _buildPopupContent(
            physics: const AlwaysScrollableScrollPhysics(),
            scrollEntirePopup: widget.scrollEntirePopup,
          );
        }
      },
    );
  }

  Widget _buildPopupContent({
    required bool scrollEntirePopup,
    ScrollPhysics? physics,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTitleWidget(),
        widget.divider?.call(context) ??
            const Divider(color: Colors.grey, height: 2, thickness: 2),
        if (scrollEntirePopup == true)
          _buildListView(physics, widget.spacing, widget.padding)
        else
          Expanded(
            child: _buildListView(physics, widget.spacing, widget.padding),
          ),
      ],
    );
  }

  Widget _buildTitleWidget() {
    return Padding(
      padding: widget.titlePadding ?? const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Row(
        mainAxisAlignment:
            widget.titleMainAlignment ?? MainAxisAlignment.spaceBetween,
        crossAxisAlignment:
            widget.titleCrossAlignment ?? CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              widget.popup.title,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          widget.closeIconBuilder?.call(context, _handleClose) ??
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: _handleClose,
              ),
        ],
      ),
    );
  }

  void _handleClose() {
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.of(context).pop();
    }
  }

  Widget _buildListView(
    ScrollPhysics? physics,
    double? elementSpacing,
    EdgeInsetsGeometry? elementPadding,
  ) {
    final elements = widget.popup.evaluatedElements;

    if (elements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            widget.noElementsText ?? 'No popup elements available.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Body with popup elements
    return SingleChildScrollView(
      physics: physics,
      padding: elementPadding,
      child: Column(
        spacing: elementSpacing ?? 8,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:
            elements.map((element) {
              if (element is FieldsPopupElement) {
                return _FieldsPopupElementView(
                  fieldsElement: element,
                  isExpanded: true,
                  style: widget.elementStyle,
                  divider: widget.divider,
                );
              } else if (element is AttachmentsPopupElement) {
                return _AttachmentsPopupElementView(
                  attachmentsElement: element,
                  isExpanded: true,
                  style: widget.elementStyle,
                );
              } else if (element is MediaPopupElement) {
                return _MediaPopupElementView(
                  mediaElement: element,
                  isExpanded: true,
                  style: widget.elementStyle,
                );
              } else if (element is TextPopupElement) {
                return _TextPopupElementView(
                  textElement: element,
                  style: widget.elementStyle,
                );
              } else {
                return const Text('Element not supported');
              }
            }).toList(),
      ),
    );
  }
}
