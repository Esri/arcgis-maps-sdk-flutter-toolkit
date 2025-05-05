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
class _MediaPopupElementView extends StatefulWidget {
  const _MediaPopupElementView({required this.mediaElement,});

  final MediaPopupElement mediaElement;

  @override
  _MediaPopupElementViewState createState() => _MediaPopupElementViewState();
}

class _MediaPopupElementViewState extends State<_MediaPopupElementView> {
  bool _isExpanded = true;
  int get displayableMediaCount => widget.mediaElement.media.length;

  @override
  Widget build(BuildContext context) {
    if (displayableMediaCount > 0) {
      return Card(
        margin: const EdgeInsets.all(8),
        child: ExpansionTile(
          title: _PopupElementHeader(
            title: widget.mediaElement.title.isEmpty
                ? 'Media'
                : widget.mediaElement.title,
            description: widget.mediaElement.description,
          ),
          initiallyExpanded: _isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          children: [
            _PopupMediaView(
              popupMedia: widget.mediaElement.media,
              displayableMediaCount: displayableMediaCount,
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

    return SizedBox(
      height: mediaSize.height,
      child: ListView.builder(
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
                color: Colors.grey.shade200,
              ),
              child: _buildMediaContent(media, mediaSize),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMediaContent(PopupMedia popupMedia, Size mediaSize) {
    switch (popupMedia.type) {
      case PopupMediaType.image:
        return _ImageMediaView(popupMedia: popupMedia, mediaSize: mediaSize);
      case PopupMediaType.barChart:
      case PopupMediaType.columnChart:
      case PopupMediaType.lineChart:
      case PopupMediaType.pieChart:
        return const Text('Chart not implemented');
      default:
        return const SizedBox.shrink(); // Empty view for unsupported media types
    }
  }
}
