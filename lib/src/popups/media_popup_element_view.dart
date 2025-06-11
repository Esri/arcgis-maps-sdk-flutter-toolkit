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
    this.style,
  });
  final MediaPopupElement mediaElement;
  final bool isExpanded;
  final PopupElementStyle? style;

  @override
  _MediaPopupElementViewState createState() => _MediaPopupElementViewState();
}

class _MediaPopupElementViewState extends State<_MediaPopupElementView> {
  late bool isExpanded;
  late PopupElementStyle? style;
  int get displayableMediaCount => widget.mediaElement.media.length;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.isExpanded;
    style = widget.style;
  }

  @override
  Widget build(BuildContext context) {
    if (displayableMediaCount > 0) {
      return Card(
        elevation: style?.elevation,
        shape: style?.shape,
        margin: style?.margin ?? const EdgeInsets.all(8),
        clipBehavior: style?.clipBehavior ?? Clip.none,
        child: ExpansionTile(
          title: _PopupElementHeader(
            title:
                widget.mediaElement.title.isEmpty
                    ? 'Media'
                    : widget.mediaElement.title,
            description: widget.mediaElement.description,
          ),
          initiallyExpanded: style?.tile?.initiallyExpanded ?? isExpanded,
          onExpansionChanged: (expanded) {
            setState(() => isExpanded = expanded);
          },
          // General tile styling
          leading: style?.tile?.leading,
          trailing: style?.tile?.trailing,
          showTrailingIcon: style?.tile?.showTrailingIcon ?? true,
          tilePadding: style?.tile?.tilePadding,
          childrenPadding: style?.tile?.childrenPadding,
          backgroundColor: style?.tile?.backgroundColor,
          collapsedBackgroundColor: style?.tile?.collapsedBackgroundColor,
          // Typography & icon styling
          textColor: style?.tile?.textColor,
          collapsedTextColor: style?.tile?.collapsedTextColor,
          iconColor: style?.tile?.iconColor,
          collapsedIconColor: style?.tile?.collapsedIconColor,
          // Layout
          expandedCrossAxisAlignment:
              style?.tile?.expandedCrossAxisAlignment ??
              CrossAxisAlignment.start,
          expandedAlignment: style?.tile?.expandedAlignment,
          // Shape & animation
          shape: style?.tile?.shape,
          collapsedShape: style?.tile?.collapsedShape,
          clipBehavior: style?.tile?.clipBehavior ?? Clip.none,
          dense: style?.tile?.dense,
          minTileHeight: style?.tile?.minTileHeight,
          enabled: style?.tile?.enabled ?? true,
          expansionAnimationStyle: style?.tile?.expansionAnimationStyle,
          // Content
          children: [
            _PopupMediaView(
              popupMedia: widget.mediaElement.media,
              displayableMediaCount: displayableMediaCount,
              chartColor: style?.chartColor,
              chartForegroundColor: style?.chartForegroundColor,
            ),
          ],
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
    this.chartForegroundColor,
    this.chartColor,
  });

  final List<PopupMedia> popupMedia;
  final int displayableMediaCount;
  double get widthScaleFactor => displayableMediaCount > 1 ? 0.75 : 1.0;
  final Color? chartForegroundColor;
  final Color? chartColor;

  @override
  Widget build(BuildContext context) {
    final mediaSize = Size(
      MediaQuery.of(context).size.width * widthScaleFactor,
      200,
    );

    return SizedBox(
      height: mediaSize.height,
      child:
          (popupMedia.length > 1)
              ? _buildMediaListWidgets(mediaSize)
              : _buildMediaWidget(popupMedia.first, mediaSize, chartColor),
    );
  }

  Widget _buildMediaListWidgets(Size mediaSize) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: popupMedia.length,
      itemBuilder: (context, index) {
        final media = popupMedia[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            width: mediaSize.width,
            height: mediaSize.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: chartForegroundColor ?? Colors.grey.shade200,
            ),
            child: _buildMediaWidget(media, mediaSize, chartColor),
          ),
        );
      },
    );
  }

  Widget _buildMediaWidget(
    PopupMedia popupMedia,
    Size mediaSize,
    Color? chartColor,
  ) {
    switch (popupMedia.type) {
      case PopupMediaType.image:
        return _ImageMediaView(
          popupMedia: popupMedia,
          mediaSize: mediaSize,
          chartColor: chartColor,
        );
      case PopupMediaType.barChart:
        return _PopupBarChart(
          popupMedia: popupMedia,
          chartColor: chartColor,
          isColumnChart: false,
        );
      case PopupMediaType.columnChart:
        return _PopupBarChart(
          popupMedia: popupMedia,
          chartColor: chartColor,
          isColumnChart: true,
        );
      case PopupMediaType.lineChart:
        return _PopupLineChart(popupMedia: popupMedia, chartColor: chartColor);
      case PopupMediaType.pieChart:
        return _PopupPieChart(popupMedia: popupMedia, chartColor: chartColor);
      default:
        return const SizedBox.shrink(); // Empty view for unsupported media types
    }
  }
}

/// Converts the PopupMediaValue data into a list of _ChartData.
extension on PopupMedia {
  List<_ChartData> _getChartData(Color? chartColor) {
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

        var color = chartColor ?? (Colors.blue as Color);
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
