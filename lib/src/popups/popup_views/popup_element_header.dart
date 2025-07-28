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

/// A widget that displays the title and description for a pop-up element.
/// The title and description are defined in the pop-up definition in the Map Viewer.
/// If a title is not set in the pop-up definition, default values are passed to this widget from the respective pop-up element views.
/// If the description is empty then no text is displayed.
class _PopupElementHeader extends StatelessWidget {
  const _PopupElementHeader({required this.title, required this.description});

  /// The title of the pop-up element.
  final String title;

  /// The description for the pop-up element.
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        if (description.isNotEmpty)
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
