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

/// A [ThemeData] instance specifically designed for the [PopupView] widget.
///
/// This theme provides text styles and other visual properties
/// tailored for popups. You can apply a custom theme by passing
/// a custom [ThemeData] to the [PopupView]'s [PopupView.theme] parameter.
///
/// Example:
/// ```dart
/// PopupView(
///   theme: popupViewThemeData,
///   ...
/// )
/// ```
///
ThemeData popupViewThemeData = ThemeData(
  colorScheme: const ColorScheme.light(
    // surface:
    // - used as background color of PopupView container.
    // - if cardTheme not set, used as background color of cards that wrap each popup element.
    // primary:
    // - used as color of download icon of attachments.
    // - used as color of text links in fields popup element.
  ),
  textTheme: const TextTheme(
    // Used as text style for the main title of the popup.
    titleMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    // Used as text style for the title of a section.
    titleSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
    // Used as text style for field name in fields section.
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.grey,
    ),
    // Used as text style for values in fields section.
    labelMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    ),
    // Used by attachments section:
    // - attachment name (color is set to black).
    // - attachment size (color is set to grey).
    labelSmall: TextStyle(),
    // Used by error messages (color is set to red).
    bodyLarge: TextStyle(),
    // Used as text style for the description of a section.
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.grey,
    ),
  ),
  // Used as theme for cards that wrap each popup element.
  cardTheme: const CardThemeData(color: Colors.white),
  // Used as theme for expansion tiles that wrap media and fields elements.
  // Note: if backgroundColor or collapsedBackgroundColor are not set in expansionTileTheme, the PopupView defaults to transparent.
  expansionTileTheme: const ExpansionTileThemeData(
    iconColor: Colors.grey,
    collapsedIconColor: Colors.grey,
    backgroundColor: Colors.white,
    collapsedBackgroundColor: Colors.white,
  ),
  // Used by divider widgets:
  // - below main popup title.
  // - between fields in fields section.
  dividerTheme: const DividerThemeData(
    color: Colors.grey,
    thickness: 1,
    indent: 5,
    endIndent: 5,
    space: 10,
  ),
  // Used by close icon next to main popup title.
  // Used by icons in attachments (note: color is set).
  iconButtonTheme: const IconButtonThemeData(style: ButtonStyle()),
  iconTheme: const IconThemeData(color: Colors.grey),
  // Used by fullscreen dialog e.g. when an image or chart is tapped.
  appBarTheme: const AppBarTheme(),
);
