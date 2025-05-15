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

class _DetailsScreenImageDialog extends StatelessWidget {
  const _DetailsScreenImageDialog({required this.filePath});
  final String filePath;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Center(child: Image.file(File(filePath), fit: BoxFit.contain)),
          Positioned(
            top: 24,
            right: 24,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 24),
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
  final maxY =
      chartData
          .map((data) => data.value)
          .fold<double>(0, (a, b) => a > b ? a : b)
          .ceilToDouble();
  return maxY + (maxY / 5).ceilToDouble();
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
        reservedSize: 40,
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
          // Rotate the labels if the chart is rotated
          // and the number of data points is greater than 4.
          if (meta.rotationQuarterTurns == 1 &&
              chartData.length > 4) {
            return ((meta.formattedValue._toDouble! % 2).toInt() == 0)
                ? Transform.rotate(
                  angle: -30 * (math.pi / 180),
                  child: Text(
                    chartData[value.toInt()].label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
                : const SizedBox.shrink();
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

// Returns the border data for the chart.
FlBorderData get _flBorderData {
  return FlBorderData(
    show: true,
    border: Border.all(
      color: const Color.fromARGB(100, 100, 100, 100),
      width: 0.5,
    ),
  );
}
