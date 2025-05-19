// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:magic_box_app/pages/login_page.dart';
import 'package:magic_box_app/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MagicBoxApp());

    // Verify that the app title is displayed
    expect(find.text('魔盒'), findsOneWidget);

    // Verify that we are on the login page
    expect(find.byType(LoginPage), findsOneWidget);
  });
}
