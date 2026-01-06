// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:arcgis_maps_toolkit_example/example_authenticator.dart'
    as _arcgis_maps_toolkit_example_example_authenticator;
import 'package:arcgis_maps_toolkit_example/example_compass_custom.dart'
    as _arcgis_maps_toolkit_example_example_compass_custom;
import 'package:arcgis_maps_toolkit_example/example_compass_local_scene.dart'
    as _arcgis_maps_toolkit_example_example_compass_local_scene;
import 'package:arcgis_maps_toolkit_example/example_compass_map.dart'
    as _arcgis_maps_toolkit_example_example_compass_map;
import 'package:arcgis_maps_toolkit_example/example_compass_scene.dart'
    as _arcgis_maps_toolkit_example_example_compass_scene;
import 'package:arcgis_maps_toolkit_example/example_overview_map_with_local_scene.dart'
    as _arcgis_maps_toolkit_example_example_overview_map_with_local_scene;
import 'package:arcgis_maps_toolkit_example/example_overview_map_with_map.dart'
    as _arcgis_maps_toolkit_example_example_overview_map_with_map;
import 'package:arcgis_maps_toolkit_example/example_overview_map_with_scene.dart'
    as _arcgis_maps_toolkit_example_example_overview_map_with_scene;
import 'package:arcgis_maps_toolkit_example/example_popup.dart'
    as _arcgis_maps_toolkit_example_example_popup;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookCategory(
    name: 'Authenticator',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'ExampleAuthenticator',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Authenticator(oauth)',
            builder: _arcgis_maps_toolkit_example_example_authenticator
                .authenticatorOAuthUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Authenticator(token)',
            builder: _arcgis_maps_toolkit_example_example_authenticator
                .authenticatorTokenUseCase,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Compass',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'ExampleCompassCustom',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Compass (custom)',
            builder: _arcgis_maps_toolkit_example_example_compass_custom
                .defaultCompassCustomUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'ExampleCompassLocalScene',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Compass (local scene)',
            builder: _arcgis_maps_toolkit_example_example_compass_local_scene
                .defaultCompassLocalSceneUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'ExampleCompassMap',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Compass (map)',
            builder: _arcgis_maps_toolkit_example_example_compass_map
                .defaultCompassMapUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'ExampleCompassScene',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Compass (scene)',
            builder: _arcgis_maps_toolkit_example_example_compass_scene
                .defaultCompassSceneUseCase,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'OverviewMap',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'ExampleOverviewMapWithLocalScene',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'OverviewMap (local scene)',
            builder:
                _arcgis_maps_toolkit_example_example_overview_map_with_local_scene
                    .defaultOverviewMapWithLocalSceneUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'ExampleOverviewMapWithMap',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'OverviewMap (map custom)',
            builder: _arcgis_maps_toolkit_example_example_overview_map_with_map
                .defaultOverviewMapWithMapUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'ExampleOverviewMapWithScene',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'OverviewMap (scene)',
            builder:
                _arcgis_maps_toolkit_example_example_overview_map_with_scene
                    .defaultOverviewMapWithSceneUseCase,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'PopupView',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'PopupExample',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'PopupView',
            builder:
                _arcgis_maps_toolkit_example_example_popup.defaultPopupUseCase,
          ),
        ],
      ),
    ],
  ),
];
