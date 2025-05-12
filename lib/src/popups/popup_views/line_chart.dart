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

/// A widget that displays a line chart for the given [popupMedia].
class _PopupLineChart extends StatelessWidget {
  _PopupLineChart({required this.popupMedia})
    : chartData = popupMedia._getChartData();

  final PopupMedia popupMedia;
  final List<_ChartData> chartData;

  double get _maximumYValue => _calculateMaximumYValue(chartData);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: LineChart(lineData),
    );
  }

  LineChartData get lineData {
    return LineChartData(
      maxY: _maximumYValue,
      lineBarsData: [
        LineChartBarData(
          color: Colors.blue,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          spots: List.generate(chartData.length, (index) {
            return FlSpot(index.toDouble(), chartData[index].value);
          }),
        ),
      ],
      titlesData: _getFlTitlesData(chartData),
      gridData: _gridData,
      borderData: _flBorderData,
    );
  }
}
