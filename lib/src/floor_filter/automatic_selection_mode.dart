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

part of '../../arcgis_maps_toolkit.dart';

/// Enum that defines how the floor filter updates its selection as the user
/// navigates the connected GeoView.
enum AutomaticSelectionMode {
  /// Never update selection based on the GeoView's current viewpoint.
  never,

  /// Always update selection based on the current viewpoint; clear the
  /// selection when the user navigates away.
  always,

  /// Only update the selection when there is a new site or facility in the
  /// current viewpoint. Do not clear selection when the user navigates away.
  alwaysNonClearing,
}
