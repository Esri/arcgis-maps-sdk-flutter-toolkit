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
part of '../../arcgis_maps_toolkit.dart';

/// A widget that displays a media popup element in a card with an expansion tile.
/// It uses a horizontal list view to render the media content.
/// parameters:
/// - [mediaElement]: The media popup element to be displayed.
/// - [isExpanded]: A boolean indicating whether the expansion tile should be initially expanded or not.
class _MediaPopupElementView extends StatefulWidget {
  const _MediaPopupElementView({
    required this.mediaElement,
    this.isExpanded = false,
  });
  final MediaPopupElement mediaElement;
  final bool isExpanded;

  @override
  _MediaPopupElementViewState createState() => _MediaPopupElementViewState();
}

class _MediaPopupElementViewState extends State<_MediaPopupElementView> {
  late bool isExpanded;
  int get displayableMediaCount => widget.mediaElement.media.length;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    if (displayableMediaCount > 0) {
      return Card(
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: _PopupElementHeader(
              title: widget.mediaElement.title.isEmpty
                  ? 'Media'
                  : widget.mediaElement.title,
              description: widget.mediaElement.description,
            ),
            initiallyExpanded: isExpanded,
            onExpansionChanged: (expanded) {
              setState(() => isExpanded = expanded);
            },
            tilePadding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              _PopupMediaView(
                popupMedia: widget.mediaElement.media,
                displayableMediaCount: displayableMediaCount,
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox.shrink(); // Return an empty widget if no media is available
    }
  }
}

class _PopupMediaView extends StatelessWidget {
  const _PopupMediaView({
    required this.popupMedia,
    required this.displayableMediaCount,
  });

  final List<PopupMedia> popupMedia;
  final int displayableMediaCount;
  double get widthScaleFactor => displayableMediaCount > 1 ? 0.75 : 1.0;

  @override
  Widget build(BuildContext context) {
    final mediaSize = Size(
      MediaQuery.of(context).size.width * widthScaleFactor,
      200,
    );

    if (popupMedia.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: mediaSize.height,
      child: (popupMedia.length > 1)
          ? _buildMediaListWidgets(mediaSize)
          : _buildMediaWidget(popupMedia.first, mediaSize),
    );
  }

  Widget _buildMediaListWidgets(Size mediaSize) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: popupMedia.length,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      itemBuilder: (context, index) {
        final media = popupMedia[index];
        return Container(
          width: mediaSize.width,
          height: mediaSize.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade200,
          ),
          child: _buildMediaWidget(media, mediaSize),
        );
      },
      separatorBuilder: (context, index) {
        return const SizedBox(width: 8);
      },
    );
  }

  Widget _buildMediaWidget(PopupMedia popupMedia, Size mediaSize) {
    switch (popupMedia.type) {
      case PopupMediaType.image:
        return _ImageMediaView(popupMedia: popupMedia, mediaSize: mediaSize);
      case PopupMediaType.barChart:
        return _PopupBarChart(popupMedia: popupMedia, isColumnChart: false);
      case PopupMediaType.columnChart:
        return _PopupBarChart(popupMedia: popupMedia, isColumnChart: true);
      case PopupMediaType.lineChart:
        return _PopupLineChart(popupMedia: popupMedia);
      case PopupMediaType.pieChart:
        return _PopupPieChart(popupMedia: popupMedia);
      default:
        return const SizedBox.shrink(); // Empty view for unsupported media types
    }
  }
}

/// Converts the PopupMediaValue data into a list of _ChartData.
extension on PopupMedia {
  List<_ChartData> _getChartData() {
    final popupMediaValue = value;
    final list = <_ChartData>[];
    if (popupMediaValue != null) {
      for (var i = 0; i < popupMediaValue.data.length; i++) {
        final value = popupMediaValue.data[i]._toDouble!;

        var label = 'untitled';
        if (popupMediaValue.labels.isNotEmpty &&
            popupMediaValue.labels.length > i) {
          label = popupMediaValue.labels[i];
        }

        var color = Colors.blue as Color;
        if (popupMediaValue.chartColors.isNotEmpty &&
            popupMediaValue.chartColors.length > i) {
          color = popupMediaValue.chartColors[i];
        }
        list.add(_ChartData(value: value, label: label, color: color));
      }
    }
    return list;
  }
}

/// Representing the data for a chart.
class _ChartData {
  const _ChartData({
    required this.value,
    required this.label,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}
