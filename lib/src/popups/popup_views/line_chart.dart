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
      titlesData: _titlesData,
      gridData: _gridData,
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: const Color.fromARGB(100, 100, 100, 100),
          width: 0.5,
        ),
      ),
    );
  }

  /// Returns the titles data for the chart.
  FlTitlesData get _titlesData {
    return FlTitlesData(
      topTitles: const AxisTitles(),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.all(2),
              child: Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            );
          },
          maxIncluded: false,
          minIncluded: false,
        ),
      ),
      leftTitles: const AxisTitles(),
      bottomTitles: AxisTitles(
        axisNameSize: 20,
        axisNameWidget: Text(
          chartData.map((data) => data.label).join(' '),
          style: const TextStyle(fontSize: 14, color: Colors.grey),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  /// Returns the grid data for the chart.
  /// The grid lines are drawn with a light gray color and a stroke width of 0.5.
  FlGridData get _gridData {
    return FlGridData(
      getDrawingVerticalLine: (value) {
        return const FlLine(
          color: Color.fromARGB(100, 100, 100, 100),
          strokeWidth: 0.5,
          dashArray: [1, 1],
        );
      },
      drawVerticalLine: false,
      getDrawingHorizontalLine: (value) {
        return const FlLine(
          color: Color.fromARGB(100, 100, 100, 100),
          strokeWidth: 0.5,
          dashArray: [5, 5],
        );
      },
    );
  }
}
