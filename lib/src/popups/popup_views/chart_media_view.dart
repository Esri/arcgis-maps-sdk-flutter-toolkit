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

class _ChartMediaView extends StatefulWidget {
  const _ChartMediaView({
    required this.popupMedia,
    required this.mediaSize,
  });

  final PopupMedia popupMedia;
  final Size mediaSize;

  @override
  _ChartMediaViewState createState() => _ChartMediaViewState();
}

class _ChartMediaViewState extends State<_ChartMediaView> {
  bool isShowingDetailView = false;
  late final List<_ChartData> chartData;

  @override
  void initState() {
    super.initState();
    chartData = _ChartData.getChartDataFromPopupMedia(widget.popupMedia);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isShowingDetailView = true;
        });
      },
      child: SizedBox(
        width: widget.mediaSize.width,
        //height: widget.mediaSize.height,
        child: Stack(
          children: [
            // Chart View
            _ChartView(popupMedia: widget.popupMedia, data: chartData),
            // Footer Overlay
            // Positioned(
            //   bottom: 0,
            //   left: 0,
            //   right: 0,
            //   child: _PopupMediaFooter(
            //     popupMedia: widget.popupMedia,
            //     mediaSize: widget.mediaSize,
            //   ),
            // ),
            // Border
            // Positioned.fill(
            //   child: Container(
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(8),
            //       border: Border.all(color: Colors.grey),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class _ChartView extends StatelessWidget {
  const _ChartView({
    required this.popupMedia,
    required this.data,
  });

  final PopupMedia popupMedia;
  final List<_ChartData> data;

  @override
  Widget build(BuildContext context) {
    switch (popupMedia.type) {
      case PopupMediaType.barChart:
        return _BarChartView(
          chartData: data,
          isColumnChart: false,
        );
      case PopupMediaType.columnChart:
        return _BarChartView(
          chartData: data,
          isColumnChart: true,
        );
      case PopupMediaType.pieChart:
        return const Text('not implemented yet');
      // return PieChartView(
      //   chartData: data,
      //   isShowingDetailView: isShowingDetailView,
      // );
      case PopupMediaType.lineChart:
        return const Text('not implemented yet');
      // return LineChartView(
      //   chartData: data,
      //   isShowingDetailView: isShowingDetailView,
      // );
      default:
        return const SizedBox.shrink(); // Empty view for unsupported chart types
    }
  }
}



class _ChartData {
  _ChartData({required this.value, this.label = 'untitled', this.color = Colors.blue});

  final String label;
  final double value;
  final Color color;

  static List<_ChartData> getChartDataFromPopupMedia(PopupMedia popupMedia) {
    final popupMediaValue = popupMedia.value;
    final list = <_ChartData>[];
    if (popupMediaValue != null) {
      for (var i = 0; i < popupMediaValue.data.length; i++) {
        final value = popupMediaValue.data[i]._toDouble!;

        var label = 'untitled';
        if (popupMediaValue.labels.isNotEmpty) {
          label = popupMediaValue.labels[i];
        } else if (popupMediaValue.fieldNames.isNotEmpty) {
          label = popupMediaValue.fieldNames[i];
        } 

        Color color = Colors.blue;
        if (popupMediaValue.chartColors.isNotEmpty) {
          color = popupMediaValue.chartColors[i];
        }
        list.add(
          _ChartData(
            value: value,
            label: label,
            color: color
          ),
        );
      }
    }
    return list;
  }
}
