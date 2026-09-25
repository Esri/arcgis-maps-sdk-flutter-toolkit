//
// Copyright 2026 Esri
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

/// A navigation flow for selecting a floor site and facility.
class _SelectorFlow extends StatefulWidget {
  /// Creates a selector flow.
  const _SelectorFlow({required FloorFilterController floorFilterController})
    : _widgetController = floorFilterController;

  static const _facilitySelectorRoute = '/facilities';

  final FloorFilterController _widgetController;

  static void showFacilitySelector(BuildContext context) {
    Navigator.of(context).pushNamed(_facilitySelectorRoute).ignore();
  }

  @override
  State<_SelectorFlow> createState() => _SelectorFlowState();
}

class _SelectorFlowState extends State<_SelectorFlow> {
  static const _siteSelectorRoute = '/';

  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: .antiAlias,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Navigator(
        key: _navigatorKey,
        initialRoute: _siteSelectorRoute,
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Route<void> _onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) {
        return switch (settings.name) {
          _SelectorFlow._facilitySelectorRoute => _FacilitySelector(
            floorFilterController: widget._widgetController,
          ),
          _ => _SiteSelector(floorFilterController: widget._widgetController),
        };
      },
    );
  }
}
