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
class _FieldsPopupElementView extends StatefulWidget {
  const _FieldsPopupElementView({required this.fieldsElement});

  final FieldsPopupElement fieldsElement;

  @override
  _FieldsPopupElementViewState createState() => _FieldsPopupElementViewState();
}

class _FieldsPopupElementViewState extends State<_FieldsPopupElementView> {
  bool _isExpanded = true;
  late final List<_DisplayField> displayFields;

  @override
  void initState() {
    super.initState();
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
    return Card(
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        title: _PopupElementHeader(
          title:
              widget.fieldsElement.title.isEmpty
                  ? 'Fields'
                  : widget.fieldsElement.title,
          description: widget.fieldsElement.description,
        ),
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children:
            displayFields.map((field) => _FieldRow(field: field)).toList(),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.field});
  final _DisplayField field;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 1, 10, 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: Colors.grey),
          ),
          _FormattedValueText(formattedValue: field.formattedValue),
          const Divider(color: Colors.grey, height: 1, thickness: 1),
        ],
      ),
    );
  }
}

class _FormattedValueText extends StatelessWidget {
  const _FormattedValueText({required this.formattedValue});
  final String formattedValue;

  @override
  Widget build(BuildContext context) {
    if (formattedValue.toLowerCase().startsWith('http')) {
      return GestureDetector(
        onTap: () async {
          final uri = Uri.parse(formattedValue);
          await _launchUri(context, uri);
        },
        child: Text(
          'View',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            decoration: TextDecoration.underline,
          ),
        ),
      );
    } else {
      return Text(
        formattedValue,
        style: Theme.of(context).textTheme.labelMedium,
      );
    }
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
