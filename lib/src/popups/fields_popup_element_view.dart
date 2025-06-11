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

/// A widget that displays a fields popup element in a card with an expansion tile.
/// It uses a list view to render the fields content.
/// parameters:
/// - [fieldsElement]: The fields popup element to be displayed.
/// - [isExpanded]: A boolean indicating whether the expansion tile should be initially expanded or not.
class _FieldsPopupElementView extends StatefulWidget {
  const _FieldsPopupElementView({
    required this.fieldsElement,
    this.isExpanded = false,
    this.style,
    this.divider,
  });

  final FieldsPopupElement fieldsElement;
  final bool isExpanded;
  final PopupElementStyle? style;
  final WidgetBuilder? divider;

  @override
  _FieldsPopupElementViewState createState() => _FieldsPopupElementViewState();
}

class _FieldsPopupElementViewState extends State<_FieldsPopupElementView> {
  late bool isExpanded;
  late PopupElementStyle? style;
  late final List<_DisplayField> displayFields;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.isExpanded;
    style = widget.style;
    displayFields = List.generate(
      widget.fieldsElement.labels.length,
      (index) => _DisplayField(
        label: widget.fieldsElement.labels[index],
        formattedValue: widget.fieldsElement.formattedValues[index],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tileStyle = widget.style?.tile;
    return Card(
      elevation: widget.style?.elevation,
      shape: widget.style?.shape,
      margin: widget.style?.margin ?? const EdgeInsets.all(8),
      clipBehavior: widget.style?.clipBehavior ?? Clip.none,
      child: ExpansionTile(
        title: _PopupElementHeader(
          title:
              widget.fieldsElement.title.isEmpty
                  ? 'Fields'
                  : widget.fieldsElement.title,
          description: widget.fieldsElement.description,
        ),
        initiallyExpanded: tileStyle?.initiallyExpanded ?? isExpanded,
        onExpansionChanged: (expanded) {
          setState(() => isExpanded = expanded);
        },
        // Visual & layout customizations
        leading: tileStyle?.leading,
        trailing: tileStyle?.trailing,
        showTrailingIcon: tileStyle?.showTrailingIcon ?? true,
        tilePadding: tileStyle?.tilePadding,
        expandedCrossAxisAlignment:
            tileStyle?.expandedCrossAxisAlignment ?? CrossAxisAlignment.start,
        expandedAlignment: tileStyle?.expandedAlignment,
        childrenPadding: tileStyle?.childrenPadding,
        backgroundColor: tileStyle?.backgroundColor,
        collapsedBackgroundColor: tileStyle?.collapsedBackgroundColor,
        textColor: tileStyle?.textColor,
        collapsedTextColor: tileStyle?.collapsedTextColor,
        iconColor: tileStyle?.iconColor,
        collapsedIconColor: tileStyle?.collapsedIconColor,
        shape: tileStyle?.shape,
        collapsedShape: tileStyle?.collapsedShape,
        clipBehavior: tileStyle?.clipBehavior ?? Clip.none,
        dense: tileStyle?.dense,
        minTileHeight: tileStyle?.minTileHeight,
        enabled: tileStyle?.enabled ?? true,
        expansionAnimationStyle: tileStyle?.expansionAnimationStyle,
        children:
            displayFields
                .map(
                  (field) => _FieldRow(field: field, divider: widget.divider),
                )
                .toList(),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.field, this.divider});
  final _DisplayField field;
  final WidgetBuilder? divider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: Colors.grey),
        ),
        _FormattedValueText(formattedValue: field.formattedValue),
        divider?.call(context) ??
            const Divider(color: Colors.grey, height: 2, thickness: 1),
      ],
    );
  }
}

class _FormattedValueText extends StatelessWidget {
  const _FormattedValueText({required this.formattedValue});
  final String formattedValue;

  @override
  Widget build(BuildContext context) {
    if (formattedValue.toLowerCase().startsWith('http')) {
      return _buildLinkText(context, formattedValue);
    } else {
      return _buildPlainText(context, formattedValue);
    }
  }

  Widget _buildLinkText(BuildContext context, String value) {
    try {
      final uri = Uri.parse(value);
      return GestureDetector(
        onTap: () async => _launchUri(context, uri),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            'View',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      );
    } on FormatException {
      // Handle invalid URL
      return _buildPlainText(context, value);
    }
  }

  Widget _buildPlainText(BuildContext context, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(value, style: Theme.of(context).textTheme.labelMedium),
    );
  }

  Future<void> _launchUri(BuildContext context, Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        // Show an error dialog if the URL cannot be launched
        await _showErrorDialog(context, uri.toString());
      }
    }
  }
}

class _DisplayField {
  _DisplayField({required this.label, required this.formattedValue});
  final String label;
  final String formattedValue;
}
