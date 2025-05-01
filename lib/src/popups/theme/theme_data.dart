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

import 'package:flutter/material.dart';

extension CustomTextTheme on TextTheme {
  TextStyle get popupTile => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.grey,
  );

  TextStyle get subtitle => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  TextStyle get headline => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black, 
  );

  TextStyle get bodyText => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );

   TextStyle get fieldValueText => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );

  TextStyle get customLabelStyle => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  TextStyle get categoryCardLabelStyle => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  TextStyle get customErrorStyle => const TextStyle(color: Colors.red);

  TextStyle get customWhiteStyle => const TextStyle(color: Colors.white);
}
