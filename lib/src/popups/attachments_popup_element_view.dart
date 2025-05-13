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
  bool _isExpanded = true;
  late PopupAttachmentsDisplayType _displayType;
  @override
  void initState() {
    super.initState();
    _displayType = widget.attachmentsElement.displayType;
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
            return const Center(child: Text('Failed to load attachments'));
          }
          return ExpansionTile(
            title: _PopupElementHeader(
              title:
                  widget.attachmentsElement.title.isEmpty
                      ? 'Attachments'
                      : widget.attachmentsElement.title,
              description: widget.attachmentsElement.description,
            ),
            initiallyExpanded: _isExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _isExpanded = expanded;
              });
            },
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 200,
                child:
                    _displayType == PopupAttachmentsDisplayType.list
                        ? _buildListView()
                        : Text('Unsupported display type: $_displayType'),
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
        return _PopupAttachmentView(popupAttachment: attachment);
      },
    );
  }

  // Widget _buildPreview() {
  //   return GridView.builder(
  //     shrinkWrap: true,
  //     //physics: const NeverScrollableScrollPhysics(),
  //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 2,
  //       childAspectRatio: 1.5,
  //     ),
  //     itemCount: widget.attachmentsElement.attachments.length,
  //     itemBuilder: (context, index) {
  //       final attachment = widget.attachmentsElement.attachments[index];
  //       return Card(
  //         child: InkWell(
  //           onTap: () => {}, //_openAttachment(attachment),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [Text(attachment.name)],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}

class _PopupAttachmentView extends StatefulWidget {
  const _PopupAttachmentView({required this.popupAttachment});
  final PopupAttachment popupAttachment;

  @override
  State<_PopupAttachmentView> createState() => _PopupAttachmentViewState();
}

class _PopupAttachmentViewState extends State<_PopupAttachmentView> {
  final sizePreview = 35;
  late final String _contentType;
  String? filePath;
  Future<void>? _downloadFuture;

  @override
  void initState() {
    super.initState();
    _contentType = widget.popupAttachment.attachment!.contentType;
    _loadFilePath();
  }

  Future<void> _loadFilePath() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      filePath = prefs.getString(widget.popupAttachment.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: FutureBuilder(
        future: widget.popupAttachment.createThumbnail(
          width: sizePreview,
          height: sizePreview,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            if (_contentType == 'application/pdf') {
              return Icon(Icons.picture_as_pdf, size: sizePreview.toDouble());
            } else if (_contentType == 'video/quicktime') {
              return Icon(Icons.videocam, size: sizePreview.toDouble());
            } else if (_contentType == 'application/octet-stream') {
              return Icon(Icons.edit_document, size: sizePreview.toDouble());
            }
            return Icon(Icons.device_unknown, size: sizePreview.toDouble());
          }
          return snapshot.data != null
              ? Image.memory(
                snapshot.data!.getEncodedBuffer(),
                width: sizePreview.toDouble(),
                height: sizePreview.toDouble(),
              )
              : const Icon(Icons.image);
        },
      ),
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
                if (_contentType.startsWith('image'))
                  {
                    showDialog(
                      context: context,
                      builder:
                          (context) =>
                              _DetailsScreenImageDialog(filePath: filePath!),
                    ),
                  }
                else
                  {OpenFile.open(filePath, type: _contentType)},
              },
          },
      //_openAttachment(attachment),
    );
  }

  Widget _buildDownloadButton() {
    return FutureBuilder<void>(
      future: _downloadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        } else if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasError) {
          return IconButton(
            icon: const Icon(Icons.error, color: Colors.red),
            onPressed: _startDownload,
          );
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
          onPressed: _startDownload,
        );
      },
    );
  }

  void _startDownload() {
    setState(() {
      _downloadFuture = downloadAttachment();
    });
  }

  Future<void> downloadAttachment() async {
    final data = await widget.popupAttachment.attachment!.fetchData();

    final directory = await getApplicationCacheDirectory();
    final filePath = '${directory.path}/${widget.popupAttachment.name}';
    final file = File(filePath);
    await file.writeAsBytes(data);

    // Save the file path in SharedPreferences
    // to persist it across app restarts
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(widget.popupAttachment.name, filePath);
    setState(() {
      this.filePath = filePath;
    });
  }
}

extension on int {
  String get toSizeString {
    return this / 1024 / 1024 > 1
        ? '${(this / 1024 / 1024).toStringAsFixed(2)} MB'
        : '${(this / 1024).toStringAsFixed(2)} KB';
  }
}
