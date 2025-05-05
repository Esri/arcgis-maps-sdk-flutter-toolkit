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

class _BarChartView extends StatelessWidget {
  const _BarChartView({
    required this.chartData,
    required this.isColumnChart,
    this.isShowingDetailView = false,
  });

  final List<_ChartData> chartData;
  final bool isColumnChart;
  final bool isShowingDetailView;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        spacing: 8,
        children: [
          Text(
            isColumnChart ? 'Column Chart' : 'Bar Chart',
            style: Theme.of(context).textTheme.labelMedium,
          ),

         
          SizedBox(width: 400, height: 500, child: BarChart(barData)),
          

          Text('Detailed View', style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }

  BarChartData get barData {
    var index = 0;
    return BarChartData(
      alignment: BarChartAlignment.spaceEvenly,
      maxY: 15000,
      barGroups:
          chartData
              .map(
                (data) => BarChartGroupData(
                  x: index++,
                  barRods: [
                    BarChartRodData(
                      toY: data.value,
                      color: isColumnChart ? Colors.blue : Colors.red,
                      width: 100,
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ],
                ),
              )
              .toList(),
      titlesData: FlTitlesData(
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            getTitlesWidget: (value, meta) {
              return Text('A$value');
            },
          ),
        ),
        topTitles: const AxisTitles(),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 38,
            getTitlesWidget: (value, meta) {
              switch (value.toInt()) {
                case 0:
                  return const Text('Elevation (feet)');
                case 1:
                  return const Text('Prominence (feet)');

                default:
                  return const Text('');
              }
            },
          ),
        ),
      ),
      gridData: FlGridData(
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
      ),
      borderData: FlBorderData(show: false),
    );
  }
}
