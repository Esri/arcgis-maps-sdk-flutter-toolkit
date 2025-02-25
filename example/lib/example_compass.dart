import 'package:flutter/material.dart';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:arcgis_maps_toolkit/arcgis_maps_toolkit.dart';

void main() {
  // Supply your apiKey using the --dart-define-from-file command line argument.
  const apiKey = String.fromEnvironment('API_KEY');
  // Alternatively, replace the above line with the following and hard-code your apiKey here:
  // const apiKey = ''; // Your API Key here.
  if (apiKey.isEmpty) {
    throw Exception('apiKey undefined');
  } else {
    ArcGISEnvironment.apiKey = apiKey;
  }

  runApp(MaterialApp(home: const ExampleCompass()));
}

class ExampleCompass extends StatefulWidget {
  const ExampleCompass({super.key});

  @override
  State<ExampleCompass> createState() => _ExampleCompassState();
}

class _ExampleCompassState extends State<ExampleCompass> {
  final _mapViewController = ArcGISMapView.createController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Compass')),
      body: Stack(
        children: [
          ArcGISMapView(
            controllerProvider: () => _mapViewController,
            onMapViewReady: onMapViewReady,
          ),
          // Default Compass.
          Compass(controllerProvider: () => _mapViewController),
          // Compass with custom settings.
          Compass(
            controllerProvider: () => _mapViewController,
            automaticallyHides: false,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(40),
            icon: Icon(Icons.arrow_circle_up, size: 80, color: Colors.purple),
          ),
        ],
      ),
    );
  }

  void onMapViewReady() {
    _mapViewController.arcGISMap = ArcGISMap.withBasemapStyle(
      BasemapStyle.arcGISTopographic,
    );
  }
}
