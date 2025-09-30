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

/// ArcGIS Maps SDK for Flutter Toolkit
///
/// Toolkit components:
/// * [Authenticator]: A widget that handles authentication challenges. It will display a user interface when network and ArcGIS authentication challenges occur.
/// * [Compass]: A widget that visualizes the current rotation of the map or scene and allows the user to reset the rotation to north by tapping on it.
/// * [OverviewMap]: A small inset map displaying a representation of the current viewpoint of the target map or scene.
/// * [PopupView]: A widget that will display a pop-up for an individual feature. This includes showing the feature's title, attributes, custom description, media, and attachments.
library;

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Authenticator Widget
part 'src/authenticator/authenticator.dart';
part 'src/authenticator/authenticator_certificate_required.dart';
part 'src/authenticator/authenticator_certificate_password.dart';
part 'src/authenticator/authenticator_login.dart';
part 'src/authenticator/authenticator_trust.dart';
// Compass Widget
part 'src/compass/compass.dart';
part 'src/compass/compass_needle_painter.dart';
// Overview Map Widget
part 'src/overview_map/overview_map.dart';
// Popup Widget
part 'src/popups/popup_view.dart';
part 'src/popups/attachments_popup_element_view.dart';
part 'src/popups/fields_popup_element_view.dart';
part 'src/popups/media_popup_element_view.dart';
part 'src/popups/text_popup_element_view.dart';
part 'src/popups/utility_associations_popup_element_view.dart';
part 'src/popups/popup_views/utility_associations_filter_result.dart';
part 'src/popups/popup_views/utility_association_group_result.dart';
part 'src/popups/popup_views/utility_association_result.dart';
part 'src/popups/popup_views/utility_association_result_selector.dart';
part 'src/popups/popup_views/bar_chart.dart';
part 'src/popups/popup_views/line_chart.dart';
part 'src/popups/popup_views/pie_chart.dart';
part 'src/popups/popup_views/image_media_view.dart';
part 'src/popups/popup_views/popup_element_header.dart';
part 'src/popups/popup_views/common_utils.dart';
part 'src/popups/theme/theme_data.dart';

part 'src/template_widget.dart';
