import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:arcgis_maps_toolkit_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('launch', ($) async {
    const apiKey = String.fromEnvironment('API_KEY');
    ArcGISEnvironment.apiKey = apiKey;

    const username = String.fromEnvironment('USERNAME');
    const password = String.fromEnvironment('PASSWORD');

    await $.pumpWidgetAndSettle(const MaterialApp(home: ExampleApp()));

    await $('Authenticator').tap();
    await $('Load').tap();

    await $.platform.ios.tap(
      IOSSelector(text: 'Continue'),
      appId: 'com.apple.springboard',
    );

    // await Future.delayed(const Duration(seconds: 10));

    // await $.platform.ios.enterText(IOSSelector(hasFocus: true), text: username);
    // await $.platform.ios.enterText(IOSSelector(hasFocus: true), text: password);

    await $.platform.mobile.enterText(
      Selector(resourceId: 'user_username'),
      text: username,
    );
    await $.platform.mobile.enterText(
      Selector(resourceId: 'user_password'),
      text: password,
    );
    await $.platform.mobile.tap(Selector(resourceId: 'signIn'));
    await $.pumpAndSettle();

    expect($(ArcGISMapView), findsOneWidget);

    await $.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 10));
    await $.pumpAndSettle();
  });
}
