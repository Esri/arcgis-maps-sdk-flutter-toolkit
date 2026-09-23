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
  const _LevelSelector({
    required FloorFilterController floorFilterController,
    required this.maxHeight,
  }) : widgetController = floorFilterController;

  final FloorFilterController widgetController;

  // The maximum height that the LevelSelector can occupy.
  final double maxHeight;

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

    // The maximum height of the level listing. It is the maximum height of the
    // widget minus the height of the button.
    final listViewMaxHeight = widget.maxHeight - 24;

    return Column(
      children: [
        Padding(
          // padding: const EdgeInsets.only(bottom: 4),
          padding: EdgeInsets.zero,
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
              // child: const Icon(Icons.expand_less_outlined, size: 18),
              child: const Icon(Icons.expand_more_outlined, size: 18),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: listViewMaxHeight),
          child: ListView.builder(
            shrinkWrap: true,
            reverse: true,
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            itemCount: levels.length,
            itemBuilder: (context, index) {
              final level = levels[index];
              return OutlinedButton(
                onPressed: () => widget.widgetController._selectLevel(level),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  side: const BorderSide(color: Colors.white),
                  backgroundColor: Colors.white,
                ),
                child: level == widget.widgetController._selectedLevel
                    ? Text(
                        level.levelNumber.toString(),
                        style: DefaultTextStyle.of(
                          context,
                        ).style.apply(fontWeightDelta: 2, fontSizeFactor: 1.3),
                      )
                    : Text(
                        level.levelNumber.toString(),
                        style: DefaultTextStyle.of(context).style,
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}
