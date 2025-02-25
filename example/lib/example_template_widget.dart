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

  runApp(MaterialApp(home: const ExampleTemplateWidget()));
}

class ExampleTemplateWidget extends StatefulWidget {
  const ExampleTemplateWidget({super.key});

  @override
  State<ExampleTemplateWidget> createState() => _ExampleTemplateWidgetState();
}

class _ExampleTemplateWidgetState extends State<ExampleTemplateWidget> {
  final _mapViewController = ArcGISMapView.createController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TemplateWidget')),
      body: Stack(
        children: [
          ArcGISMapView(
            controllerProvider: () => _mapViewController,
            onMapViewReady: onMapViewReady,
          ),
          Center(child: TemplateWidget()),
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
