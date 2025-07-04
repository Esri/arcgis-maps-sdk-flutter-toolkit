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

/// Displays an error dialog with the given [message].
Future<void> _showErrorDialog(BuildContext context, String message) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

/// Displays an image from an [AttachmentsPopupElement] in a [Dialog].
class _DetailsScreenImageDialog extends StatelessWidget {
  const _DetailsScreenImageDialog({required this.filePath});
  final String filePath;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 255, 252, 252),
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Center(child: Image.file(File(filePath), fit: BoxFit.contain)),
          Positioned(
            top: 24,
            right: 24,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

/// The maximum Y value for the chart is calculated based on the data.
double _calculateMaximumYValue(List<_ChartData> chartData) {
  if (chartData.isEmpty) {
    return 0;
  }
  final maxY = chartData
      .map((data) => data.value)
      .fold<double>(0, (a, b) => a > b ? a : b)
      .ceilToDouble();
  return maxY + (maxY / 5).ceilToDouble();
}

/// Calculates the width of the text based on the maximum value.
double _measureTextWidth(List<_ChartData> chartData, TextStyle style) {
  final maxValue = _calculateMaximumYValue(chartData).toString();
  final textPainter = TextPainter(
    text: TextSpan(text: maxValue, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout();
  return textPainter.width.ceilToDouble();
}

/// Returns the grid data for the chart.
/// The grid lines are drawn with a light gray color and a stroke width of 0.5.
FlGridData get _gridData {
  return FlGridData(
    getDrawingVerticalLine: (value) {
      return const FlLine(
        color: Color.fromARGB(100, 100, 100, 100),
        strokeWidth: 0.5,
        dashArray: [1, 1],
      );
    },
    drawVerticalLine: false,
    getDrawingHorizontalLine: (value) {
      return const FlLine(
        color: Color.fromARGB(100, 100, 100, 100),
        strokeWidth: 0.5,
        dashArray: [5, 5],
      );
    },
  );
}

/// Returns the titles data for the chart.
/// The top and right titles are not shown.
FlTitlesData _getFlTitlesData(List<_ChartData> chartData) {
  final interval = chartData.length > 4 ? 2 : 1;
  return FlTitlesData(
    topTitles: const AxisTitles(),
    rightTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: _measureTextWidth(
          chartData,
          const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        getTitlesWidget: (value, meta) {
          return Padding(
            padding: const EdgeInsets.all(2),
            child: Text(
              value.toInt().toString(),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          );
        },
        maxIncluded: false,
        minIncluded: false,
      ),
    ),
    leftTitles: const AxisTitles(),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 20,
        interval: interval.toDouble(),
        maxIncluded: false,
        minIncluded: false,
        getTitlesWidget: (value, meta) {
          // If the chart is rotated 90 degrees, do not show the labels.
          if (meta.rotationQuarterTurns == 1) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.all(2),
            child: Text(
              chartData[value.toInt()].label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
    ),
  );
}

/// Returns the border data for the chart.
FlBorderData get _flBorderData {
  return FlBorderData(
    show: true,
    border: Border.all(
      color: const Color.fromARGB(100, 100, 100, 100),
      width: 0.5,
    ),
  );
}

/// Retrieves the cached file path for the given [name].
Future<String?> _getCachedFilePath(String name) async {
  return SharedPreferencesHelper.instance.getString(name);
}

/// Sets the cached file path for the given [name] and [filePath].
Future<void> _setCachedFilePath(String name, String filePath) async {
  return SharedPreferencesHelper.instance.setString(name, filePath);
}

/// A singleton class that provides access to shared preferences.
class SharedPreferencesHelper {
  static SharedPreferencesAsync? _instance;

  static SharedPreferencesAsync get instance {
    _instance ??= SharedPreferencesAsync();
    return _instance!;
  }
}
