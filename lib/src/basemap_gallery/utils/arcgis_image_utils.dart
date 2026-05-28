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

/// Helpers for converting ArcGIS `ArcGISImage` into Flutter `ImageProvider`s.
final class _ArcGISImageUtils {
  const _ArcGISImageUtils._();

  /// Returns an [ImageProvider] for [thumbnail] when encoded bytes are
  /// available.
  static ImageProvider? imageProviderIfAvailable(ArcGISImage? thumbnail) {
    if (thumbnail == null) return null;

    try {
      final bytes = thumbnail.getEncodedBuffer();
      if (bytes.isEmpty) return null;
      return MemoryImage(bytes);
    } on Object {
      // If we cannot get encoded bytes, avoid throwing inside build.
      return null;
    }
  }

  /// Widget that renders a thumbnail image or a placeholder.
  static Widget thumbnailOrPlaceholder({
    required ArcGISImage? thumbnail,
    required BoxFit fit,
    Widget? placeholder,
  }) {
    final provider = imageProviderIfAvailable(thumbnail);
    if (provider == null) {
      return placeholder ??
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFE8E8E8),
            ),
            child: const Center(child: Icon(Icons.map_outlined)),
          );
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: provider,
          fit: fit,
          filterQuality: FilterQuality.low,
          isAntiAlias: true,
        ),
      ),
    );
  }
}
