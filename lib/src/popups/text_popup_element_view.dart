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

/// A widget that displays a text popup element in a card with a WebView.
/// It uses a WebView to render the HTML content of the text element.
/// The height of the WebView is dynamically calculated based on the content.
/// The widget also provides a callback to notify when the height changes.
/// The text element is passed as a parameter to the widget.
/// parameters:
/// - [textElement]: The text popup element to be displayed.
class _TextPopupElementView extends StatefulWidget {
  const _TextPopupElementView({required this.textElement});
  final TextPopupElement textElement;

  @override
  _TextPopupElementViewState createState() => _TextPopupElementViewState();
}

class _TextPopupElementViewState extends State<_TextPopupElementView> {
  late final WebViewController _controller;
  double height = 100;

  @override
  void initState() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;
            if (url.startsWith('http') || url.startsWith('https')) {
              _launchUri(context, url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate; // Allow WebView to load the URL
          },

          onPageFinished: (url) async {
            final calculatedHeight = await _calculateHeight();
            if (calculatedHeight != null) {
              setState(() => height = calculatedHeight);
            }
          },
        ),
      )
      ..setBackgroundColor(Colors.transparent)
      ..loadHtmlString(_buildHTML(widget.textElement.text));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.textElement.text.isEmpty) return const SizedBox.shrink();

    return Card(
      child: SizedBox(
        height: height, // Default height until calculated
        child: WebViewWidget(controller: _controller),
      ),
    );
  }

  String _buildHTML(String userHTML) {
    return """
    <html>
      <head>
        <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'>
        <style>
          html { word-wrap: break-word; font-family: -apple-system, sans-serif; font-size: 14px; }
          body { margin: 10px; padding: 0px; background: var(--body-bg); color: var(--body-color); }
          img { max-width: 100%; }
          a { color: var(--link-color); }
        </style>
        <style type="text/css" media="screen">
          :root {
            --body-bg: #FFFFFF00;
            --body-color: #000000;
            --link-color: #0164C8;
          }
          @media (prefers-color-scheme: dark) {
            :root {
              --body-bg: #00000000;
              --body-color: #D3D3D3;
              --link-color: #1796FA;
            }
          }
        </style>
      </head>
      <body>
        ${userHTML.trim()}
      </body>
    </html>
    """;
  }

  Future<double?> _calculateHeight() async {
    try {
      final result = await _controller.runJavaScriptReturningResult(
        'document.documentElement.scrollHeight;',
      );
      return result._toDouble;
    } on Exception {
      return null;
    }
  }

  Future<void> _launchUri(BuildContext context, String uri) async {
    if (!await launchUrl(
      Uri.parse(uri),
      mode: LaunchMode.externalApplication,
    )) {
      if (context.mounted) {
        await _showErrorDialog(context, uri);
      }
    }
  }
}

extension on Object {
  double? get _toDouble {
    if (this is String) {
      return double.parse(this as String);
    } else if (this is num) {
      return (this as num).toDouble();
    } else {
      throw Exception('$this: Cannot convert to double');
    }
  }
}
