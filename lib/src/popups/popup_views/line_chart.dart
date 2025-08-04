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

/// A widget that displays a line chart for the given [PopupMedia].
/// The chart data is generated based on the data provided in the [PopupMedia].
class _PopupLineChart extends StatelessWidget {
  _PopupLineChart({required this.popupMedia})
    : chartData = popupMedia._getChartData();

  /// The pop-up media associated with this line chart.
  final PopupMedia popupMedia;

  /// The chart data associated with this media element.
  final List<_ChartData> chartData;

  /// The maximum y value for this line chart.
  double get _maximumYValue => _calculateMaximumYValue(chartData);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => _LineChartDetailView(
              popupMedia: popupMedia,
              // Line Chart should be interactive in detail view.
              lineData: lineData(interactive: true),
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
            // Line Chart should not be interactive in preview.
            child: LineChart(lineData(interactive: false)),
          ),
          // Display the footer containing a caption.
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _LineChartFooter(popupMedia: popupMedia),
          ),
          // Border around the preview of the element.
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

  /// Configures the line chart data object which defines how the line chart is displayed.
  LineChartData lineData({required bool interactive}) {
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
      lineTouchData: interactive
          ? LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (group) => Colors.grey.withAlpha(230),
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final data = chartData[spot.x.toInt()];
                    return LineTooltipItem(
                      '${data.label}: ${data.value}',
                      const TextStyle(color: Colors.white),
                    );
                  }).toList();
                },
              ),
            )
          : const LineTouchData(enabled: false),
    );
  }
}

/// Defines the caption which sits at the bottom of the chart in the list view.
/// It displays the pop-up media title, if available.
class _LineChartFooter extends StatelessWidget {
  const _LineChartFooter({required this.popupMedia});

  /// The pop-up media for this line chart.
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

/// Defines the detail view of the chart which is displayed when a chart is selected from the list view of media elements.
class _LineChartDetailView extends StatelessWidget {
  const _LineChartDetailView({
    required this.popupMedia,
    required this.onClose,
    required this.lineData,
  });

  /// The pop-up media for this line chart.
  final PopupMedia popupMedia;

  /// The data for this chart as defined in the pop-up definition.
  final LineChartData lineData;

  /// A callback that dismisses the dialog.
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
              height: MediaQuery.sizeOf(context).height / 2,
              child: LineChart(lineData),
            ),
          ),
        ),
      ),
    );
  }
}
