part of '../../arcgis_maps_toolkit.dart';

// Widget to list and select building floor.
class _BuildingFloorLevelSelector extends StatelessWidget {
  const _BuildingFloorLevelSelector({
    required this.floorList,
    required this.selectedFloor,
    required this.onChanged,
  });

  final List<String> floorList;
  final String selectedFloor;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = ['All', ...floorList];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Text('Floor:'),
        DropdownButton<String>(
          value: selectedFloor,
          items: options
              .map(
                (value) => DropdownMenuItem(value: value, child: Text(value)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ],
    );
  }
}
