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

/// Defines how the floor filter updates its site and facility selection as the
/// user navigates the associated [FloorFilterController].
enum AutomaticSelectionMode {
  /// Never update selection based on the GeoView's current viewpoint.
  never,

  /// Update selection based on the current viewpoint, clearing the site or
  /// facility when the viewpoint no longer identifies one.
  always,

  /// Update selection when the current viewpoint identifies a site or
  /// facility. Keep the current selection when it does not identify one.
  alwaysNonClearing,
}
