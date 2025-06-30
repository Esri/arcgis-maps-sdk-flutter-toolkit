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

/// Displays a list of attachments in a popup.
/// It fetches the attachments from the server and displays them in a grid
/// or list view, depending on the display type.
/// parameters:
/// - [attachmentsElement]: The attachments popup element to be displayed.
/// - [isExpanded]: A boolean indicating whether the expansion tile should be initially expanded or not.
class _AttachmentsPopupElementView extends StatefulWidget {
  const _AttachmentsPopupElementView({
    required this.attachmentsElement,
    this.isExpanded = false,
  });

  final AttachmentsPopupElement attachmentsElement;
  final bool isExpanded;
  @override
  State<_AttachmentsPopupElementView> createState() =>
      _AttachmentsPopupElementViewState();
}

class _AttachmentsPopupElementViewState
    extends State<_AttachmentsPopupElementView> {
  late bool isExpanded;
  late Future<void> fetchAttachmentsFuture;
  @override
  void initState() {
    super.initState();
    isExpanded = widget.isExpanded;
    fetchAttachmentsFuture = widget.attachmentsElement.fetchAttachments();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.attachmentsElement.attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color:
          Theme.of(context).cardTheme.color ??
          Theme.of(context).colorScheme.surface,
      child: FutureBuilder<void>(
        future: fetchAttachmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Unable to load attachments.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.red),
                ),
              ),
            );
          }
          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              backgroundColor:
                  Theme.of(context).expansionTileTheme.backgroundColor ??
                  Colors.transparent,
              collapsedBackgroundColor:
                  Theme.of(
                    context,
                  ).expansionTileTheme.collapsedBackgroundColor ??
                  Colors.transparent,
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              tilePadding: const EdgeInsets.symmetric(horizontal: 10),
              childrenPadding: const EdgeInsets.all(10),
              title: _PopupElementHeader(
                title: widget.attachmentsElement.title.isEmpty
                    ? 'Attachments'
                    : widget.attachmentsElement.title,
                description: widget.attachmentsElement.description,
              ),
              initiallyExpanded: isExpanded,
              onExpansionChanged: (expanded) {
                setState(() => isExpanded = expanded);
              },
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 200,
                  child: widget.attachmentsElement.attachments.isEmpty
                      ? const Center(child: Text('No attachments available'))
                      : widget.attachmentsElement.displayType ==
                            PopupAttachmentsDisplayType.preview
                      ? _buildGridView()
                      : _buildListView(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildListView() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color.fromARGB(255, 255, 252, 252),
      ),
      child: ListView.builder(
        itemCount: widget.attachmentsElement.attachments.length,
        itemBuilder: (context, index) {
          final attachment = widget.attachmentsElement.attachments[index];
          return _PopupAttachmentViewInList(popupAttachment: attachment);
        },
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: widget.attachmentsElement.attachments.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final attachment = widget.attachmentsElement.attachments[index];
        return _PopupAttachmentViewInGallery(popupAttachment: attachment);
      },
    );
  }
}

/// A widget that represents a popup attachment element in a preview mode.
class _PopupAttachmentViewInGallery extends StatefulWidget {
  const _PopupAttachmentViewInGallery({required this.popupAttachment});
  final PopupAttachment popupAttachment;

  @override
  State<_PopupAttachmentViewInGallery> createState() =>
      _PopupAttachmentViewInGalleryState();
}

class _PopupAttachmentViewInGalleryState
    extends State<_PopupAttachmentViewInGallery> {
  final double thumbnailSize = 30;
  late Future<ArcGISImage> thumbnailFuture;
  String? filePath;

  @override
  void initState() {
    super.initState();
    // Create a thumbnail for the attachment and prevent it from being
    // recreated every time the widget is rebuilt.
    thumbnailFuture = getThumbnailFuture(thumbnailSize.toInt());
    // Load the file path from cache
    initFilePath();
  }

  Future<void> initFilePath() async {
    final cachePath = await _getCachedFilePath(widget.popupAttachment.name);
    if (cachePath != null && File(cachePath).existsSync()) {
      setState(() => filePath = cachePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final attachment = widget.popupAttachment;
    return InkWell(
      onTap: () async {
        if (filePath == null) {
          final downloadedFilePath = await _downloadingAttachment(attachment);
          if (downloadedFilePath != null) {
            setState(() => filePath = downloadedFilePath);
          }
        } else {
          if (attachment.contentType.startsWith('image') && mounted) {
            await showDialog(
              context: context,
              builder: (context) =>
                  _DetailsScreenImageDialog(filePath: filePath!),
            );
          } else {
            await OpenFile.open(filePath, type: attachment.contentType);
          }
        }
      },
      child: Card(
        color: const Color.fromARGB(255, 255, 252, 252),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _thumbnailFutureBuilder(thumbnailFuture, attachment, thumbnailSize),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                attachment.name,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: Colors.black),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              attachment.size.toSizeString,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (filePath == null)
              Icon(Icons.download, color: Theme.of(context).colorScheme.primary)
            else
              const Icon(Icons.check, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Future<ArcGISImage> getThumbnailFuture(int size) {
    return widget.popupAttachment.createThumbnail(width: size, height: size);
  }
}

/// A widget that displays a popup attachment element in a ListTile.
/// Presents a single attachment popup element in a ListTile.
/// The ListTile shows the attachment name, size, and a thumbnail.
/// If the attachment is an image, it shows a thumbnail.
/// Clicking on the ListTile opens the image in a dialog, or opens the file
/// using the default application for the file type.
class _PopupAttachmentViewInList extends StatefulWidget {
  const _PopupAttachmentViewInList({required this.popupAttachment});
  final PopupAttachment popupAttachment;

  @override
  State<_PopupAttachmentViewInList> createState() =>
      _PopupAttachmentViewInListState();
}

class _PopupAttachmentViewInListState
    extends State<_PopupAttachmentViewInList> {
  final double thumbnailSize = 35;
  late Future<ArcGISImage> thumbnailFuture;
  Future<void>? downloadFuture;
  String? filePath;

  @override
  void initState() {
    super.initState();
    thumbnailFuture = getThumbnailFuture(thumbnailSize.toInt());
    initFilePath();
  }

  Future<void> initFilePath() async {
    final cachePath = await _getCachedFilePath(widget.popupAttachment.name);
    if (cachePath != null && File(cachePath).existsSync()) {
      setState(() => filePath = cachePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _thumbnailFutureBuilder(
        thumbnailFuture,
        widget.popupAttachment,
        thumbnailSize,
      ),
      title: Text(
        widget.popupAttachment.name,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(color: Colors.black),
      ),
      subtitle: Text(
        widget.popupAttachment.size.toSizeString,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: Colors.grey),
      ),
      trailing: filePath == null
          ? (downloadFuture == null
                ? IconButton(
                    icon: Icon(
                      Icons.download,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      setState(() {
                        downloadFuture = downloadAttachment();
                      });
                    },
                  )
                : FutureBuilder<void>(
                    future: downloadFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      } else if (snapshot.hasError) {
                        return IconButton(
                          icon: const Icon(Icons.error, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              downloadFuture = downloadAttachment();
                            });
                          },
                        );
                      } else {
                        return const Icon(Icons.check, color: Colors.green);
                      }
                    },
                  ))
          : const Icon(Icons.check, color: Colors.green),
      onTap: () {
        if (filePath == null) {
          if (downloadFuture == null) {
            setState(() {
              downloadFuture = downloadAttachment();
            });
          }
        } else {
          if (widget.popupAttachment.contentType.startsWith('image')) {
            showDialog(
              context: context,
              builder: (context) =>
                  _DetailsScreenImageDialog(filePath: filePath!),
            );
          } else {
            OpenFile.open(filePath, type: widget.popupAttachment.contentType);
          }
        }
      },
    );
  }

  Future<void> downloadAttachment() async {
    final downloadPath = await _downloadingAttachment(widget.popupAttachment);
    setState(() {
      filePath = downloadPath;
      downloadFuture = null;
    });
  }

  Future<ArcGISImage> getThumbnailFuture(int size) {
    return widget.popupAttachment.createThumbnail(width: size, height: size);
  }
}

FutureBuilder<ArcGISImage> _thumbnailFutureBuilder(
  Future<ArcGISImage> createThumbnail,
  PopupAttachment attachment,
  double size,
) {
  return FutureBuilder(
    future: createThumbnail,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return _getContentTypeIcon(attachment.contentType, size: size);
      }
      return Image.memory(
        snapshot.data!.getEncodedBuffer(),
        width: size,
        height: size,
      );
    },
  );
}

Future<String?> _downloadingAttachment(PopupAttachment popupAttachment) async {
  final data = await popupAttachment.attachment?.fetchData();
  if (data != null) {
    final directory = await getApplicationCacheDirectory();
    final filePath = '${directory.path}/${popupAttachment.name}';
    final file = File(filePath);
    await file.writeAsBytes(data);
    // Save the file path in SharedPreferences
    // to persist it across app restarts
    await _setCachedFilePath(popupAttachment.name, filePath);
    return filePath;
  } else {
    return null;
  }
}

Icon _getContentTypeIcon(
  String contentType, {
  double size = 30,
  Color color = Colors.grey,
}) {
  switch (contentType) {
    case 'application/pdf':
      return Icon(Icons.picture_as_pdf, size: size, color: color);
    case 'video/quicktime':
      return Icon(Icons.videocam, size: size, color: color);
    case 'application/octet-stream':
      return Icon(Icons.edit_document, size: size, color: color);
    case 'image/jpeg':
    case 'image/png':
    case 'image/gif':
      return Icon(Icons.image, size: size, color: color);
    default:
      return Icon(Icons.device_unknown, size: size, color: color);
  }
}

extension on int {
  String get toSizeString {
    return this / 1024 / 1024 > 1
        ? '${(this / 1024 / 1024).toStringAsFixed(2)} MB'
        : '${(this / 1024).toStringAsFixed(2)} KB';
  }
}
