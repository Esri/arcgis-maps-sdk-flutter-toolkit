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

/// A bar chart widget that displays data in a bar chart format.
/// The chart can be displayed as a column chart or a bar chart based on the
/// `isColumnChart` parameter.
class _PopupBarChart extends StatelessWidget {
  _PopupBarChart({required this.popupMedia, required this.isColumnChart})
    : chartData = popupMedia._getChartData();

  final PopupMedia popupMedia;
  final List<_ChartData> chartData;
  final bool isColumnChart;

  double get _maximumYValue => _calculateMaximumYValue(chartData);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Expanded(child: BarChart(barData)),
    );
  }

  /// Returns the bar chart data.
  BarChartData get barData {
    return BarChartData(
      rotationQuarterTurns: isColumnChart ? 0 : 1,
      alignment: BarChartAlignment.spaceEvenly,
      maxY: _maximumYValue,
      barGroups: List.generate(chartData.length, (index) {
        final data = chartData[index];
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: data.value,
              color: data.color,
              width: _barWidth,
              borderRadius: BorderRadius.circular(0),
            ),
          ],
        );
      }),
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

  /// Returns the width of the bars in the chart.
  double get _barWidth {
    if (chartData.length > 10) {
      return 5;
    } else if (chartData.length > 5) {
      return 20;
    } else {
      return 40;
    }
  }

  /// Returns the titles data for the chart.
  /// The top and right titles are not shown.
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
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.all(2),
              child: Text(
                chartData[value.toInt()].label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
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
