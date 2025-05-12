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

/// A widget that displays a pie chart for the given [popupMedia].
/// The chart data is generated based on the data provided in the [popupMedia].
class _PopupPieChart extends StatelessWidget {
  _PopupPieChart({required this.popupMedia})
    : chartData = popupMedia._getChartData();

  final PopupMedia popupMedia;
  final List<_ChartData> chartData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Expanded(child: PieChart(pieData)),
    );
  }

  PieChartData get pieData {
    return PieChartData(
      startDegreeOffset: 45,
      sections: List.generate(chartData.length, (index) {
        final data = chartData[index];
        return PieChartSectionData(
          color: data.color,
          value: data.value,
          title: data.label,
          radius: 50,
          titleStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          badgeWidget: Text(
            '(${data.value})',
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
          badgePositionPercentageOffset: 1,
        );
      }),
      borderData: _flBorderData,
    );
  }
}
