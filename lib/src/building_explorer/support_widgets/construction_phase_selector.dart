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

/// Widget to list and select building's construction phases. Selecting a phase
/// will apply a filter to the building layer hiding all features that were not
/// present during that construction phase.
class _ConstructionPhaseSelector extends StatefulWidget {
  const _ConstructionPhaseSelector({required this.buildingSceneLayerState});

  final _BuildingSceneLayerState buildingSceneLayerState;

  @override
  State<StatefulWidget> createState() => _ConstructionPhaseSelectorState();
}

class _ConstructionPhaseSelectorState
    extends State<_ConstructionPhaseSelector> {
  // A listing of all construction phases in the building scene layer.
  var _constructionPhaseList = <String>[];

  @override
  void initState() {
    super.initState();

    // Get the state for the new BuidlingSceneLayer
    _initPhaseList();

    // Check if the selected construction phase is still valid for the current state of the
    // building layer.
    _checkSelectedPhase();
  }

  @override
  void didUpdateWidget(_ConstructionPhaseSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset the state variables
    _constructionPhaseList = <String>[];

    // Get the state for the new BuidlingSceneLayer
    _initPhaseList();

    // Check if the selected phase is still valid for the current state of the
    // building layer.
    _checkSelectedPhase();
  }

  @override
  Widget build(BuildContext context) {
    final options = ['All', ..._constructionPhaseList];

    if (options.length < 3) {
      // Don't show the widget if there is less than two phases (excluding 'All').
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 20, 0),
      child: Row(
        children: [
          const Text('Construction phase:'),
          const Spacer(),
          DropdownButton(
            value: widget.buildingSceneLayerState.selectedConstructionPhase,
            items: options
                .map(
                  (value) => DropdownMenuItem(value: value, child: Text(value)),
                )
                .toList(),
            onChanged: onConstructionPhaseChanged,
          ),
        ],
      ),
    );
  }

  Future<void> _initPhaseList() async {
    // Get the construction phase listing from the statistics.
    final statistics = await widget.buildingSceneLayerState.buildingSceneLayer
        .fetchStatistics();
    if (statistics[_CONSTRUCTION_PHASE_ATTRIBUTES] != null) {
      final phaseList = <String>[];
      phaseList.addAll(
        statistics[_CONSTRUCTION_PHASE_ATTRIBUTES]!.mostFrequentValues,
      );
      phaseList.sort((a, b) {
        final intA = int.tryParse(a) ?? 0;
        final intB = int.tryParse(b) ?? 0;
        return intB.compareTo(intA);
      });

      // Setting state after await. Check if the widget is mounted.
      if (context.mounted) {
        setState(() {
          _constructionPhaseList = phaseList;
        });
      }
    }
  }

  void _checkSelectedPhase() {
    if (!identical(
      widget.buildingSceneLayerState.buildingSceneLayer.activeFilter,
      widget.buildingSceneLayerState.currentBuildingFilter,
    )) {
      // The active filter for the layer was not set by this widget. The
      // selected layer is invalid.
      widget.buildingSceneLayerState.selectedConstructionPhase = 'All';
    }

    // Update the building filter to the currently selected construction phase.
    widget.buildingSceneLayerState.updateBuildingFilter();
  }

  void onConstructionPhaseChanged(String? phase) {
    if (phase == null) return;

    setState(
      () => widget.buildingSceneLayerState.selectedConstructionPhase = phase,
    );
    widget.buildingSceneLayerState.updateBuildingFilter();
  }
}
