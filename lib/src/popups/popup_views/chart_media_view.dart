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

class _ChartMediaView extends StatefulWidget {
  const _ChartMediaView({
    required this.popupMedia,
    required this.mediaSize, 
    required this.child,
  });

  final PopupMedia popupMedia;
  final Size mediaSize;
  final Widget child;

  @override
  _ChartMediaViewState createState() => _ChartMediaViewState();
}

class _ChartMediaViewState extends State<_ChartMediaView> {
  bool isShowingDetailView = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isShowingDetailView = true;
        });
      },
      child: SizedBox(
        width: widget.mediaSize.width,
        //height: widget.mediaSize.height,
        child: Stack(
          children: [
            // Chart View
            widget.child,
            //_ChartView(popupMedia: widget.popupMedia, data: chartData),
            // Footer Overlay
            // Positioned(
            //   bottom: 0,
            //   left: 0,
            //   right: 0,
            //   child: _PopupMediaFooter(
            //     popupMedia: widget.popupMedia,
            //     mediaSize: widget.mediaSize,
            //   ),
            // ),
            // Border
            // Positioned.fill(
            //   child: Container(
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(8),
            //       border: Border.all(color: Colors.grey),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
