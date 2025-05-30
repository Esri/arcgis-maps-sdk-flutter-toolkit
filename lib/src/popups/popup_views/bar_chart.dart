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
    return Padding(padding: const EdgeInsets.all(8), child: BarChart(barData));
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
              color: data.color.withAlpha(160),
              width: _barWidth,
              borderRadius: BorderRadius.circular(0),
            ),
          ],
        );
      }),
      titlesData: _getFlTitlesData(chartData),
      gridData: _gridData,
      borderData: _flBorderData,
      barTouchData: BarTouchData(
        enabled: true,
        allowTouchBarBackDraw: true,
        touchTooltipData: BarTouchTooltipData(
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final value = rod.toY;
            final label = chartData[group.x].label;
            return BarTooltipItem(
              '$label\n$value',
              const TextStyle(color: Colors.white),
            );
          },
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
}
