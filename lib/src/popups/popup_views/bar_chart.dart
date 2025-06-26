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
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => _BarChartDetailView(
              popupMedia: popupMedia,
              // Bar Chart should be interactive in detail view.
              barData: barData(interactive: true),
              onClose: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsetsGeometry.all(5),
            // Bar Chart should not be interactive in preview.
            child: BarChart(barData(interactive: false)),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BarChartFooter(popupMedia: popupMedia),
          ),
          // Border
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the bar chart data.
  BarChartData barData({required bool interactive}) {
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
      barTouchData: interactive
          ? BarTouchData(
              enabled: true,
              allowTouchBarBackDraw: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => Colors.grey.withAlpha(230),
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
            )
          : const BarTouchData(enabled: false),
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

class _BarChartFooter extends StatelessWidget {
  const _BarChartFooter({required this.popupMedia});

  final PopupMedia popupMedia;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: Border.all(color: Colors.black.withAlpha(100)),
        gradient: LinearGradient(
          colors: [Colors.black.withAlpha(200), Colors.black.withAlpha(100)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Text(
        popupMedia.title.isNotEmpty ? popupMedia.title : 'untitled',
        maxLines: 2,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _BarChartDetailView extends StatelessWidget {
  const _BarChartDetailView({
    required this.popupMedia,
    required this.onClose,
    required this.barData,
  });

  final PopupMedia popupMedia;
  final BarChartData barData;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 252, 252),
        appBar: AppBar(
          title: Text(popupMedia.title),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
          ),
        ),
        body: SafeArea(
          minimum: const EdgeInsets.all(20),
          child: Center(
            child: SizedBox(
              // Bar Chart should be interactive in detail view.
              height: MediaQuery.of(context).size.height / 2,
              child: BarChart(barData),
            ),
          ),
        ),
      ),
    );
  }
}
