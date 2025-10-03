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

class PopupViewNavigator extends StatefulWidget {
  const PopupViewNavigator({required this.popup, super.key});

  final Popup popup;
  @override
  State<PopupViewNavigator> createState() => PopupViewNavigatorState();
}

class PopupViewNavigatorState extends State<PopupViewNavigator> {
  final _pages = <Page<Widget>>[];

  @override
  void initState() {
    super.initState();
    final fid = widget.popup.geoElement.attributes['objectId']?.toString();
    _pages.add(
      MaterialPage(
        child: PopupView(popup: widget.popup),
        key: ValueKey('PopupView_$fid'),
      ),
    );
  }

  @override
  void dispose() {
    _pages.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: List.of(_pages),
      onDidRemovePage: (page) {
        print('onDidRemovePage: $page');
      },
    );
  }

  void popupWithKey(String key) {
    setState(() {
      _pages.removeWhere((page) => page.key != ValueKey(key));
    });
  }

  void _push(Page<Widget> page) {
    setState(() {
      _pages.add(page);
    });
  }

  bool _pop() {
    if (_pages.isNotEmpty) {
      setState(_pages.removeLast);
      return true;
    }
    return false;
  }

  /// Tests if the GeoElement PopupView have been shown.
  bool _isRootPopup(String fid) {
    return widget.popup.geoElement.attributes['objectId']?.toString() == fid;
  }
}
