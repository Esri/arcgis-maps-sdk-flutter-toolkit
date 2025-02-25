import 'package:flutter/material.dart';

import 'example_template_widget.dart';

void main() {
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
