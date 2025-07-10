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

/// A widget that displays a fields pop-up element in a [Card] with an [ExpansionTile].
/// It uses a [ListView] to render the fields content.
class _FieldsPopupElementView extends StatefulWidget {
  const _FieldsPopupElementView({
    required this.fieldsElement,
    this.isExpanded = false,
  });

  /// The fields pop-up element to be displayed.
  final FieldsPopupElement fieldsElement;

  /// A boolean indicating whether the expansion tile should be initially expanded.
  final bool isExpanded;

  @override
  _FieldsPopupElementViewState createState() => _FieldsPopupElementViewState();
}

class _FieldsPopupElementViewState extends State<_FieldsPopupElementView> {
  late bool isExpanded;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fieldsElement.labels.isEmpty &&
        widget.fieldsElement.formattedValues.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color:
          Theme.of(context).cardTheme.color ??
          Theme.of(context).colorScheme.surface,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          backgroundColor:
              Theme.of(context).expansionTileTheme.backgroundColor ??
              Colors.transparent,
          collapsedBackgroundColor:
              Theme.of(context).expansionTileTheme.collapsedBackgroundColor ??
              Colors.transparent,
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: _PopupElementHeader(
            title:
                widget.fieldsElement.title.isEmpty
                    ? 'Fields'
                    : widget.fieldsElement.title,
            description: widget.fieldsElement.description,
          ),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() => isExpanded = expanded);
          },
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          tilePadding: const EdgeInsets.symmetric(horizontal: 10),
          childrenPadding: const EdgeInsets.all(10),
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.fieldsElement.labels.length,
              separatorBuilder:
                  (context, index) => Divider(
                    color: Theme.of(context).dividerTheme.color ?? Colors.grey,
                    height: 5,
                    thickness: Theme.of(context).dividerTheme.thickness ?? 1,
                  ),
              itemBuilder: (context, index) {
                return _FieldRow(
                  field: _DisplayField(
                    label: widget.fieldsElement.labels[index],
                    formattedValue: widget.fieldsElement.formattedValues[index],
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

/// Defines and formats the data for an individual field.
class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.field});

  /// The field to display.
  final _DisplayField field;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        // The label for the field.
        Text(field.label, style: Theme.of(context).textTheme.labelLarge),
        // Formats and displays the value of the field.
        _FormattedValueText(formattedValue: field.formattedValue),
      ],
    );
  }
}

/// Formats the field value depending on whether it includes a link or plain text.
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

  /// Links are made interactive and given a display label.
  /// If a link is invalid, it is displayed as plain text.
  Widget _buildLinkText(BuildContext context, String value) {
    try {
      final uri = Uri.parse(value);
      return GestureDetector(
        onTap: () async => _launchUri(context, uri),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            'View',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    } on FormatException {
      // Handle invalid URL.
      return _buildPlainText(context, value);
    }
  }

  /// Displays values as plain text.
  Widget _buildPlainText(BuildContext context, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(value, style: Theme.of(context).textTheme.labelMedium),
    );
  }

  /// A helper method to launch a Uri.
  Future<void> _launchUri(BuildContext context, Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        // Show an error dialog if the URL cannot be launched.
        await _showErrorDialog(context, uri.toString());
      }
    }
  }
}

/// A class that represents the display of a field.
class _DisplayField {
  _DisplayField({required this.label, required this.formattedValue});
  final String label;
  final String formattedValue;
}
