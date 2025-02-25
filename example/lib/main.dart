import 'package:flutter/material.dart';
import 'package:arcgis_maps/arcgis_maps.dart';

import 'example_template_widget.dart';

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

  runApp(MaterialApp(home: const ExampleApp()));
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Toolkit Examples')),
      body: Column(
        children: [
          ElevatedButton(
            child: Text('TemplateWidget'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExampleTemplateWidget(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
