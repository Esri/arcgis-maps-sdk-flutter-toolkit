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

/// A Container with an independent navigation flow for selecting a floor site
/// and facility. This widget is intended to be used in a modal view.
class _SiteAndFacilitySelectorNavigator extends StatefulWidget {
  /// Creates a selector flow.
  /// - floorFilterController: the [FloorFilterController] for this widget
  /// - onClose: optional [VoidCallback] called when X button in top right is
  /// tapped. If no callback is provided, the button will not appear.
  const _SiteAndFacilitySelectorNavigator({
    required FloorFilterController floorFilterController,
    this.onClose,
  }) : _widgetController = floorFilterController;

  final FloorFilterController _widgetController;
  final VoidCallback? onClose;

  // Static properties and functions for navigation.
  static const _siteSelectorRoute = '/';
  static const _facilitySelectorRoute = '/facilities';
  static void showFacilitySelector(BuildContext context) {
    Navigator.of(context).pushNamed(_facilitySelectorRoute).ignore();
  }

  @override
  State<_SiteAndFacilitySelectorNavigator> createState() =>
      _SiteAndFacilitySelectorNavigatorState();
}

class _SiteAndFacilitySelectorNavigatorState
    extends State<_SiteAndFacilitySelectorNavigator> {
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
        initialRoute: widget._widgetController._selectedFacility != null
            ? _SiteAndFacilitySelectorNavigator._facilitySelectorRoute
            : _SiteAndFacilitySelectorNavigator._siteSelectorRoute,
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Route<void> _onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) {
        return switch (settings.name) {
          _SiteAndFacilitySelectorNavigator._facilitySelectorRoute =>
            _FacilitySelector(
              floorFilterController: widget._widgetController,
              onClose: widget.onClose,
            ),
          _ => _SiteSelector(
            floorFilterController: widget._widgetController,
            onClose: widget.onClose,
          ),
        };
      },
    );
  }
}
