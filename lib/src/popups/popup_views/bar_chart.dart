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

class _PopupBarChart extends StatelessWidget {
  const _PopupBarChart({required this.chartData, required this.isColumnChart});
  final List<_ChartData> chartData;
  final bool isColumnChart;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        Text(
          isColumnChart ? 'Column Chart' : 'Bar Chart',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey),
        ),

        Flexible(child: BarChart(barData)),

        //Text('Detailed View', style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }

  BarChartData get barData {
    return BarChartData(
      rotationQuarterTurns: isColumnChart ? 0 : 1,
      maxY: _maxY,
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
      borderData: FlBorderData(show: false),
    );
  }

  double get _barWidth {
    if (chartData.length > 10) {
      return 5;
    } else if (chartData.length > 5) {
      return 20;
    } else {
      return 40;
    }
  }

  double get _maxY {
    if (chartData.isEmpty) {
      return 0; // Return 0 if the list is empty
    }
    return chartData
        .map((data) => data.value)
        .reduce((a, b) => a > b ? a : b)
        .ceilToDouble();
  }

  FlTitlesData get _titlesData {
    return FlTitlesData(
      topTitles: const AxisTitles(),
      rightTitles: const AxisTitles(),
      leftTitles: AxisTitles(
        axisNameWidget: const Text(
          'Elevation (feet)',
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
        axisNameSize: 40,
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 60,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: const TextStyle(fontSize: 14, color: Colors.black),
            );
          },
          maxIncluded: false,
          minIncluded: false,
          interval: 4000,
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            return Text(
              chartData[value.toInt()].label,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            );
          },
        ),
        axisNameWidget: Text(
          chartData.map((data) => data.label).join(' vs '),
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
      ),
    );
  }

  FlGridData get _gridData {
    return FlGridData(
      drawVerticalLine: true,
      getDrawingVerticalLine: (value) {
        return const FlLine(
          color: Color.fromARGB(100, 106, 105, 105),
          strokeWidth: 0.5,
        );
      },
      getDrawingHorizontalLine: (value) {
        return const FlLine(
          color: Color.fromARGB(100, 106, 105, 105),
          strokeWidth: 0.5,
        );
      },
    );
  }
}
