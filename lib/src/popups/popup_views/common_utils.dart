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
