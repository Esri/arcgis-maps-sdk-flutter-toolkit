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

/// A widget that displays an image media view in a popup.
/// It uses a stack to overlay the image with a footer and a border.
/// parameters:
/// - [popupMedia]: The popup media to be displayed.
/// - [mediaSize]: The size of the media view.
class _ImageMediaView extends StatefulWidget {
  const _ImageMediaView({required this.popupMedia, required this.mediaSize});

  final PopupMedia popupMedia;
  final Size mediaSize;

  @override
  _ImageMediaViewState createState() => _ImageMediaViewState();
}

class _ImageMediaViewState extends State<_ImageMediaView> {
  // TODO(3337): show detail view when clicked.
  bool isShowingDetailView = false;

  @override
  Widget build(BuildContext context) {
    final sourceURL = widget.popupMedia.value?.sourceUri;

    if (sourceURL != null) {
      return GestureDetector(
        onTap: () {
          setState(() {
            isShowingDetailView = true;
          });
        },
        child: Stack(
          children: [
            // Async Image View
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                sourceURL.toString(),
                width: widget.mediaSize.width,
                height: widget.mediaSize.height,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      'Image not available',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.red),
                    ),
                  );
                },
              ),
            ),

            // Footer Overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _PopupMediaFooter(
                popupMedia: widget.popupMedia,
                mediaSize: widget.mediaSize,
              ),
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
    } else {
      return const SizedBox.shrink(); // Return an empty widget if no source URL is available
    }
  }
}

class _PopupMediaFooter extends StatelessWidget {
  const _PopupMediaFooter({required this.popupMedia, required this.mediaSize});

  final PopupMedia popupMedia;
  final Size mediaSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: mediaSize.width,
      padding: const EdgeInsets.all(8),
      color: Colors.black.withValues(alpha: 0.5),
      child: Text(
        popupMedia.title.isNotEmpty ? popupMedia.title : 'untitled',
        maxLines: 2,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _MediaDetailView extends StatelessWidget {
  const _MediaDetailView({required this.popupMedia, required this.onClose});

  final PopupMedia popupMedia;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(popupMedia.title),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: onClose),
      ),
      body: Center(
        child: Image.network(
          popupMedia.value?.linkUri.toString() ?? '',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Text('Image details not implemented yet'),
            );
          },
        ),
      ),
    );
  }
}
