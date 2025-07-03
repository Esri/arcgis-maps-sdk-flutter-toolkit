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

/// A widget that displays [PopupMedia] in a [Card] with an [ExpansionTile].
/// The media popup elements represent images and charts, per the [PopupMediaType]s.
class _MediaPopupElementView extends StatefulWidget {
  const _MediaPopupElementView({
    required this.mediaElement,
    this.isExpanded = false,
  });

  /// The media popup element to be displayed.
  final MediaPopupElement mediaElement;

  /// A boolean indicating whether the expansion tile should be initially expanded.
  final bool isExpanded;

  @override
  _MediaPopupElementViewState createState() => _MediaPopupElementViewState();
}

class _MediaPopupElementViewState extends State<_MediaPopupElementView> {
  /// Whether the expansion tile is expanded.
  late bool isExpanded;

  /// The count of media elements to display.
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color:
            Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            backgroundColor:
                Theme.of(context).expansionTileTheme.backgroundColor ??
                Colors.transparent,
            collapsedBackgroundColor:
                Theme.of(context).expansionTileTheme.collapsedBackgroundColor ??
                Colors.transparent,
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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
            childrenPadding: const EdgeInsets.all(10),
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
      return const SizedBox.shrink(); // Return an empty widget if no media is available.
    }
  }
}

/// A widget that displays a horizontal [ListView] to render the media content.
class _PopupMediaView extends StatelessWidget {
  const _PopupMediaView({
    required this.popupMedia,
    required this.displayableMediaCount,
  });

  /// A list of popup media.
  final List<PopupMedia> popupMedia;

  /// The count of media to display.
  final int displayableMediaCount;

  // The width scale factor to display optimally in the list view.
  double get widthScaleFactor => displayableMediaCount > 1 ? 0.75 : 1.0;

  @override
  Widget build(BuildContext context) {
    final mediaSize = Size(
      MediaQuery.of(context).size.width * widthScaleFactor,
      200,
    );

    // Don't display if there is no media.
    if (popupMedia.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: mediaSize.height,
      // Display either a list of media elements or a single media element.
      child: (popupMedia.length > 1)
          ? _buildMediaListWidgets(mediaSize)
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color.fromARGB(255, 255, 252, 252),
              ),
              child: _buildMediaWidget(popupMedia.first, mediaSize),
            ),
    );
  }

  /// A list view of media elements with horizontal scroll.
  Widget _buildMediaListWidgets(Size mediaSize) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: popupMedia.length,
      itemBuilder: (context, index) {
        final media = popupMedia[index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color.fromARGB(255, 255, 252, 252),
          ),
          width: mediaSize.width,
          height: mediaSize.height,
          child: _buildMediaWidget(media, mediaSize),
        );
      },
      separatorBuilder: (context, index) {
        return const SizedBox(width: 8);
      },
    );
  }

  /// Build a widget to display the media depending on type.
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
        return _PopupPieChart(popupMedia: popupMedia, mediaSize: mediaSize);
      default:
        return const SizedBox.shrink(); // Empty view for unsupported media types.
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

        // The default label if no label is provided from the popup definition in the Map Viewer.
        var label = 'untitled';
        if (popupMediaValue.labels.isNotEmpty &&
            popupMediaValue.labels.length > i) {
          label = popupMediaValue.labels[i];
        }

        // The default color for charts if no color is provided from the popup definition in the Map Viewer.
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

/// A class that represents the data for a chart.
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
