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
  _PopupPieChart({required this.popupMedia, required this.mediaSize})
    : chartData = popupMedia._getChartData();

  final PopupMedia popupMedia;
  final Size mediaSize;
  final List<_ChartData> chartData;

  @override
  Widget build(BuildContext context) {
    final radius = MediaQuery.of(context).orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width / 3
        : MediaQuery.of(context).size.height / 3;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => _PieChartDetailView(
              popupMedia: popupMedia,
              chartData: chartData,
              // Pie Charts have default size of 40. Define radius that fits within screen depending on orientation.
              pieData: pieData(radius: radius),
              onClose: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
      child: Stack(
        children: [
          // Pie Charts have default size of 40. Define radius that fits within width of media container.
          PieChart(pieData(radius: mediaSize.width / 4)),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _PieChartFooter(popupMedia: popupMedia),
          ),
        ],
      ),
    );
  }

  PieChartData pieData({required double radius}) {
    return PieChartData(
      sectionsSpace: 0,
      centerSpaceRadius: 0,
      startDegreeOffset: 45,
      sections: List.generate(chartData.length, (index) {
        final data = chartData[index];
        return PieChartSectionData(
          color: data.color,
          value: data.value,
          showTitle: false,
          radius: radius,
        );
      }),
      borderData: _flBorderData,
    );
  }
}

class _PieChartFooter extends StatelessWidget {
  const _PieChartFooter({required this.popupMedia});

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

class _PieChartDetailView extends StatelessWidget {
  const _PieChartDetailView({
    required this.popupMedia,
    required this.onClose,
    required this.pieData,
    required this.chartData,
  });

  final PopupMedia popupMedia;
  final List<_ChartData> chartData;
  final VoidCallback onClose;
  final PieChartData pieData;

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
          child: SizedBox(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 50,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      height: pieData.sections.first.radius * 2,
                      width: pieData.sections.first.radius * 2,
                      child: PieChart(pieData),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
