
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
import 'package:arcgis_maps_toolkit/src/popups/theme/theme_data.dart';
import 'package:flutter/material.dart';

/// A widget that displays a header for a popup element.
/// It includes a title and an optional description.
class PopupElementHeader extends StatelessWidget {
  const PopupElementHeader({
    required this.title,
    required this.description,
    super.key,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headline),
        if (description.isNotEmpty)
          Text(description, style: Theme.of(context).textTheme.bodyText),
      ],
    );
  }
}
