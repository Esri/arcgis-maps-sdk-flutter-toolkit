//
// Copyright 2026 Esri
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

/// A widget for selecting a floor level in the selected facility.
class _LevelSelector extends StatefulWidget {
  const _LevelSelector({required FloorFilterController floorFilterController})
    : widgetController = floorFilterController;

  final FloorFilterController widgetController;

  @override
  State<_LevelSelector> createState() => _LevelSelectorState();
}

class _LevelSelectorState extends State<_LevelSelector> {
  StreamSubscription<FloorLevel?>? onLevelChangedSubscription;
  FloorLevel? selectedLevel;

  @override
  void initState() {
    super.initState();
    // Set the initial selectedLevel.
    selectedLevel = widget.widgetController._selectedLevel;

    // Listen for any changes to the selected level.
    onLevelChangedSubscription = widget.widgetController._onLevelChanged.listen(
      (level) {
        if (mounted) {
          setState(() => selectedLevel = level);
        }
      },
    );
  }

  @override
  void dispose() {
    onLevelChangedSubscription?.cancel().ignore();
    onLevelChangedSubscription = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final levels =
        widget.widgetController._selectedFacility?.levels ?? const [];

    if (levels.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: SizedBox(
            height: 24,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                side: const BorderSide(color: Colors.black12),
                backgroundColor: Colors.white,
              ),
              child: const Icon(Icons.expand_less_outlined, size: 18),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            reverse: true,
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            itemCount: levels.length,
            itemBuilder: (context, index) {
              final level = levels[index];
              return Align(
                child: IntrinsicWidth(
                  child: Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: Text(level.levelNumber.toString()),
                      selected: selectedLevel == level,
                      onTap: () {
                        widget.widgetController._selectLevel(level);
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );

    // return ConstrainedBox(
    //   constraints: BoxConstraints(maxHeight: maxHeight),
    //   child: Column(
    //     children: [
    //       Padding(
    //         padding: const EdgeInsets.only(bottom: 4),
    //         child: SizedBox(
    //           height: 24,
    //           width: 50,
    //           child: OutlinedButton(
    //             onPressed: () {},
    //             style: OutlinedButton.styleFrom(
    //               padding: EdgeInsets.zero,
    //               shape: RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.circular(6),
    //               ),
    //               side: const BorderSide(color: Colors.black12),
    //               backgroundColor: Colors.white,
    //             ),
    //             child: const Icon(Icons.expand_less_outlined, size: 18),
    //           ),
    //         ),
    //       ),
    //       Expanded(
    //         child: ScrollConfiguration(
    //           behavior: const ScrollBehavior().copyWith(overscroll: false),
    //           child: ListView.builder(
    //             physics: const BouncingScrollPhysics(),
    //             itemCount: levels.length,
    //             itemBuilder: (context, index) {
    //               final level = levels[index];
    //               return Align(
    //                 child: IntrinsicWidth(
    //                   child: Material(
    //                     type: MaterialType.transparency,
    //                     child: ListTile(
    //                       dense: true,
    //                       contentPadding: const EdgeInsets.symmetric(
    //                         horizontal: 8,
    //                       ),
    //                       title: Text(level.levelNumber.toString()),
    //                       selected: selectedLevel == level,
    //                       onTap: () {
    //                         widget.widgetController._selectLevel(level);
    //                       },
    //                     ),
    //                   ),
    //                 ),
    //               );
    //             },
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
