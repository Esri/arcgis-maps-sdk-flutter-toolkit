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
  const _ImageMediaView({
    required this.popupMedia,
    required this.mediaSize,
    this.chartColor,
  });

  final PopupMedia popupMedia;
  final Size mediaSize;
  final Color? chartColor;

  @override
  _ImageMediaViewState createState() => _ImageMediaViewState();
}

class _ImageMediaViewState extends State<_ImageMediaView> {
  // A flag to indicate if the detail view is cached and ready to be shown.
  bool isShowingDetailReady = false;

  @override
  Widget build(BuildContext context) {
    final sourceURL = widget.popupMedia.value?.sourceUri;
    if (sourceURL != null) {
      return GestureDetector(
        onTap: () {
          if (isShowingDetailReady) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => _MediaDetailView(
                      popupMedia: widget.popupMedia,
                      onClose: () {
                        Navigator.of(context).pop();
                      },
                    ),
              ),
            );
          }
        },
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                sourceURL.toString(),
                width: widget.mediaSize.width,
                height: widget.mediaSize.height,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    isShowingDetailReady = true;
                    return child;
                  }
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
                  // This is to prevent showing a detail view with an error image.
                  isShowingDetailReady = false;
                  return const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 30,
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

            // Add a clock icon to indicate the image refresh interval
            if (widget.popupMedia.imageRefreshInterval > 0)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.access_time, color: Colors.white, size: 16),
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
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: Border.all(color: Colors.grey),
        gradient: LinearGradient(
          colors: [Colors.black.withAlpha(150), Colors.transparent],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      width: mediaSize.width,
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

class _MediaDetailView extends StatelessWidget {
  const _MediaDetailView({required this.popupMedia, required this.onClose});

  final PopupMedia popupMedia;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final imageRefreshInterval = popupMedia.imageRefreshInterval;
    final sourceUri = popupMedia.value?.sourceUri;

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(popupMedia.title),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
          ),
        ),
        body: Center(
          // Use the TimerBuilder package to periodically update the image
          // source URL with a timestamp to prevent caching.
          child:
              imageRefreshInterval > 0
                  ? TimerBuilder.periodic(
                    Duration(milliseconds: imageRefreshInterval),
                    alignment: Duration.zero,
                    builder: (context) {
                      final url =
                          sourceUri == null
                              ? ''
                              : sourceUri
                                  .replace(
                                    queryParameters: {
                                      ...sourceUri.queryParameters,
                                      't':
                                          DateTime.now().millisecondsSinceEpoch
                                              .toString(),
                                    },
                                  )
                                  .toString();
                      return Stack(
                        children: [
                          Image.network(
                            url,
                            fit: BoxFit.fill,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  'Fails to get the image details: $error',
                                ),
                              );
                            },
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: _IndicatorDot(
                              size: 16,
                              duration: Duration(
                                milliseconds:
                                    (imageRefreshInterval / 2).toInt(),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                  : Image.network(
                    popupMedia.value?.sourceUri?.toString() ?? '',
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text('Fails to get the image details: $error'),
                      );
                    },
                  ),
        ),
      ),
    );
  }
}

class _IndicatorDot extends StatefulWidget {
  const _IndicatorDot({
    required this.size,
    this.duration = const Duration(milliseconds: 600),
  });

  final double size;
  final Duration duration;

  @override
  State<_IndicatorDot> createState() => _IndicatorDotState();
}

class _IndicatorDotState extends State<_IndicatorDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
