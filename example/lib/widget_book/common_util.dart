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
 
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

// Common utility functions for creating knobs used in multiple widgetbook delegates.
Alignment alignmentKnob(BuildContext context) =>
 context.knobs.object.dropdown<Alignment>(
      label: 'Alignment',
      options: const [
        Alignment.topLeft,
        Alignment.topRight,
        Alignment.bottomLeft,
        Alignment.bottomRight,      
        Alignment.centerLeft,
        Alignment.centerRight,
      ],
      initialOption: Alignment.topRight,
      labelBuilder: (value) {
        if (value == Alignment.topLeft) {
          return 'Top Left';
        } else if (value == Alignment.topRight) {
          return 'Top Right';
        } else if (value == Alignment.bottomLeft) {
          return 'Bottom Left';
        } else if (value == Alignment.bottomRight) {
          return 'Bottom Right';
        } else if (value == Alignment.centerLeft) {
          return 'Center Left';
        } else if (value == Alignment.centerRight) {
          return 'Center Right';
        } else {
          return 'Unknown';
        }
      }
  );
