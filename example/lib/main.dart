import 'package:flutter/material.dart';
import 'package:arcgis_maps_toolkit/arcgis_maps_toolkit.dart';

void main() {
  runApp(MaterialApp(home: const MyHomePage()));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _added = Calculator().addOne(8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('$_added')));
  }
}
