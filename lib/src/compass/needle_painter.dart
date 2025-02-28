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

part of '../../arcgis_maps_toolkit.dart';

/// A [CustomPainter] that paints a classic compass needle.
class NeedlePainter extends CustomPainter {
  /// Constructs a [NeedlePainter].
  NeedlePainter();

  static final _bronzePaint =
      Paint()..color = const Color.fromARGB(255, 241, 169, 59);

  static final _darkGreyPaint =
      Paint()..color = const Color.fromARGB(255, 128, 128, 128);

  static final _darkRedPaint =
      Paint()..color = const Color.fromARGB(255, 124, 22, 13);

  static final _lightGreyPaint =
      Paint()..color = const Color.fromARGB(255, 169, 168, 168);

  static final _lightRedPaint =
      Paint()..color = const Color.fromARGB(255, 233, 51, 35);

  @override
  void paint(Canvas canvas, Size size) {
    // Center and normalize the canvas as [-0.5, -0.5] to [0.5, 0.5].
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(size.width, size.height);

    // Scale down the needle to 60% of the available space.
    canvas.scale(0.6);

    _paintQuadrants(canvas);
    _paintCenterPin(canvas);
  }

  void _paintQuadrants(Canvas canvas) {
    canvas.save();

    // One quadrant of the needle.
    final path =
        Path()..addPolygon([
          Offset.zero,
          const Offset(-0.5, 0),
          const Offset(0, -0.5),
        ], true);

    // Squeeze the quadrants to 1/3 of the width.
    canvas.scale(1 / 3, 1);

    // Draw the 4 quadrants with a 90 degree rotation between each.
    canvas.drawPath(path, _lightRedPaint);
    canvas.rotate(math.pi / 2);
    canvas.drawPath(path, _darkRedPaint);
    canvas.rotate(math.pi / 2);
    canvas.drawPath(path, _darkGreyPaint);
    canvas.rotate(math.pi / 2);
    canvas.drawPath(path, _lightGreyPaint);

    canvas.restore();
  }

  void _paintCenterPin(Canvas canvas) {
    canvas.drawCircle(Offset.zero, 0.0625, _bronzePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
