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
          // (<) back one step.
          Visibility(
            visible: !state.isHome,
            child: IconButton(
              onPressed: state._pop,
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          // (^) exit associations.
          Visibility(
            visible: !state.isHome,
            child: IconButton(
              onPressed: state._popToRoot,
              icon: const Icon(Icons.arrow_upward),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
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
          // (x) close the popup.
          IconButton(icon: const Icon(Icons.close), onPressed: state._close),
        ],
      ),
    );
  }
}
