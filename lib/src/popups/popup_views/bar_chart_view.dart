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
  });

  final List<_ChartData> chartData;
  final bool isColumnChart;

  @override
  Widget build(BuildContext context) {
    return 
      Column(
        spacing: 8,
        children: [
          Text(
            isColumnChart ? 'Column Chart' : 'Bar Chart',
            style: Theme.of(context).textTheme.labelMedium,
          ),

          Flexible(
            child: BarChart(barData)),

          //Text('Detailed View', style: Theme.of(context).textTheme.labelMedium),
        ],
      );
    
  }

  BarChartData get barData {
    return BarChartData(
      rotationQuarterTurns: 0,
      //maxY: 15000,
      barGroups:List.generate(chartData.length, (index) {
        final data = chartData[index];
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: data.value,
              color: data.color,
              width: 50,
              borderRadius: BorderRadius.circular(0),
            )
          ],
        );
      }),
          
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
            showTitles: false,
            reservedSize: 38,
            getTitlesWidget: (value, meta) {
              return Text('B$value');
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
