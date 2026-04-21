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

/// Header widget with title, optional subtitle, and navigation controls.
class _UtilityAssociationHeader extends StatelessWidget {
  const _UtilityAssociationHeader({required this.title, this.subtitle});

  final String title;

  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_PopupViewState>()!;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Visibility(
            visible: !state.isHome,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
              child: Row(
                children: [
                  // (<) back one step.
                  IconButton(
                    visualDensity: const VisualDensity(horizontal: -2),
                    onPressed: state._pop,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  // (^) exit associations.
                  IconButton(
                    visualDensity: const VisualDensity(horizontal: -2),
                    onPressed: state._popToRoot,
                    icon: const Icon(Icons.keyboard_return),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title.
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                // Subtitle (optional).
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          Visibility(
            visible: state.hasClose,
            // (x) close the popup.
            child: IconButton(
              visualDensity: const VisualDensity(horizontal: -2),
              icon: const Icon(Icons.close),
              onPressed: state._close,
            ),
          ),
        ],
      ),
    );
  }
}
