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

/// Toolkit for the ArcGIS Maps SDK for Flutter.
library;

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

part 'src/authenticator/authenticator.dart';
part 'src/authenticator/authenticator_login.dart';
part 'src/compass/compass.dart';
part 'src/compass/compass_needle_painter.dart';
part 'src/overview_map/overview_map.dart';
// Popup Widget
part 'src/popups/popup_view.dart';
part 'src/popups/attachments_popup_element_view.dart';
part 'src/popups/fields_popup_element_view.dart';
part 'src/popups/media_popup_element_view.dart';
part 'src/popups/text_popup_element_view.dart';
part 'src/popups/popup_views/bar_chart.dart';
part 'src/popups/popup_views/line_chart.dart';
part 'src/popups/popup_views/pie_chart.dart';
part 'src/popups/popup_views/image_media_view.dart';
part 'src/popups/popup_views/popup_element_header.dart';
part 'src/popups/popup_views/common_utils.dart';
part 'src/popups/theme/theme_data.dart';

part 'src/template_widget.dart';
