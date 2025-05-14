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

class _AttachmentsPopupElementView extends StatefulWidget {
  const _AttachmentsPopupElementView({required this.attachmentsElement});

  final AttachmentsPopupElement attachmentsElement;

  @override
  State<_AttachmentsPopupElementView> createState() =>
      _AttachmentsPopupElementViewState();
}

class _AttachmentsPopupElementViewState
    extends State<_AttachmentsPopupElementView> {
  bool isExpanded = true;
  late PopupAttachmentsDisplayType displayType;
  @override
  void initState() {
    super.initState();
    displayType = widget.attachmentsElement.displayType;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: FutureBuilder<void>(
        future: widget.attachmentsElement.fetchAttachments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load attachments: ${snapshot.error}'),
            );
          }
          return ExpansionTile(
            title: _PopupElementHeader(
              title:
                  widget.attachmentsElement.title.isEmpty
                      ? 'Attachments'
                      : widget.attachmentsElement.title,
              description: widget.attachmentsElement.description,
            ),
            initiallyExpanded: isExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                isExpanded = expanded;
              });
            },
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 200,
                child:
                    displayType == PopupAttachmentsDisplayType.preview
                        ? _buildGridView()
                        : _buildListView(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListView() {
    if (widget.attachmentsElement.attachments.isEmpty) {
      return const Center(child: Text('No attachments available'));
    }
    return ListView.builder(
      itemCount: widget.attachmentsElement.attachments.length,
      itemBuilder: (context, index) {
        final attachment = widget.attachmentsElement.attachments[index];
        return _PopupAttachmentViewInList(popupAttachment: attachment);
      },
    );
  }

  Widget _buildGridView() {
    final attachments = widget.attachmentsElement.attachments;
    return GridView.builder(
      shrinkWrap: true,
      itemCount: attachments.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final attachment = attachments[index];
        return _PopupAttachmentViewInGallery(popupAttachment: attachment);
      },
    );
  }
}

/// Presets a single attachment popup element in a gallery view.
class _PopupAttachmentViewInGallery extends StatefulWidget {
  const _PopupAttachmentViewInGallery({required this.popupAttachment});
  final PopupAttachment popupAttachment;

  @override
  State<_PopupAttachmentViewInGallery> createState() =>
      _PopupAttachmentViewInGalleryState();
}

class _PopupAttachmentViewInGalleryState
    extends State<_PopupAttachmentViewInGallery> {
  @override
  Widget build(BuildContext context) {
    final attachment = widget.popupAttachment;
    return InkWell(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        var filePath = prefs.getString(attachment.name);
        filePath ??= await _downloadingAttachment(attachment);
        if (filePath != null) {
          if (attachment.contentType.startsWith('image') && mounted) {
            await showDialog(
              context: context,
              builder:
                  (context) => _DetailsScreenImageDialog(filePath: filePath!),
            );
          } else {
            await OpenFile.open(filePath, type: attachment.contentType);
          }
        }
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _thumbnailFutureBuilder(attachment, 50),
            Text(
              attachment.name,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
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
  final double sizePreview = 35;
  late final String contentType;
  String? filePath;

  @override
  void initState() {
    super.initState();
    contentType = widget.popupAttachment.attachment!.contentType;
    loadFilePath();
  }

  Future<void> loadFilePath() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      filePath = prefs.getString(widget.popupAttachment.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _thumbnailFutureBuilder(widget.popupAttachment, sizePreview),
      title: Text(widget.popupAttachment.name),
      subtitle: Text(
        widget.popupAttachment.size.toSizeString,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(color: Colors.grey),
      ),
      trailing:
          filePath == null
              ? _buildDownloadButton()
              : const Icon(Icons.check, color: Colors.green),
      onTap:
          () => {
            if (filePath != null)
              {
                if (contentType.startsWith('image'))
                  {
                    showDialog(
                      context: context,
                      builder:
                          (context) =>
                              _DetailsScreenImageDialog(filePath: filePath!),
                    ),
                  }
                else
                  {OpenFile.open(filePath, type: contentType)},
              },
          },
    );
  }

  Widget _buildDownloadButton() {
    return FutureBuilder<void>(
      future: downloadAttachment(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        } else if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasError) {
          return const Icon(Icons.error, color: Colors.red);
        } else if (snapshot.connectionState == ConnectionState.done) {
          // Download finished, show check icon
          return IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () {
              if (filePath != null) {
                showDialog(
                  context: context,
                  builder:
                      (context) =>
                          _DetailsScreenImageDialog(filePath: filePath!),
                );
              }
            },
          );
        }
        // Not downloading, show download icon
        return IconButton(
          icon: const Icon(Icons.download, color: Colors.indigoAccent),
          onPressed: downloadAttachment,
        );
      },
    );
  }

  Future<void> downloadAttachment() async {
    final filePath = await _downloadingAttachment(widget.popupAttachment);
    setState(() {
      this.filePath = filePath;
    });
  }
}

FutureBuilder<ArcGISImage> _thumbnailFutureBuilder(
  PopupAttachment attachment,
  double size,
) {
  return FutureBuilder<ArcGISImage>(
    future: attachment.createThumbnail(
      width: size.toInt(),
      height: size.toInt(),
    ),
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(popupAttachment.name, filePath);
    return filePath;
  } else {
    return null;
  }
}

Icon _getContentTypeIcon(String contentType, {double size = 35}) {
  switch (contentType) {
    case 'application/pdf':
      return Icon(Icons.picture_as_pdf, size: size);
    case 'video/quicktime':
      return Icon(Icons.videocam, size: size);
    case 'application/octet-stream':
      return Icon(Icons.edit_document, size: size);
    case 'image/jpeg':
    case 'image/png':
    case 'image/gif':
      return Icon(Icons.image, size: size);
    default:
      return Icon(Icons.device_unknown, size: size);
  }
}

extension on int {
  String get toSizeString {
    return this / 1024 / 1024 > 1
        ? '${(this / 1024 / 1024).toStringAsFixed(2)} MB'
        : '${(this / 1024).toStringAsFixed(2)} KB';
  }
}
