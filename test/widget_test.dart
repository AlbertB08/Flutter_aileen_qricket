// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qricket/main.dart';

void main() {
  group('Qricket App Widget Tests', () {
    setUpAll(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('App should start with login screen when not authenticated', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Wait for the app to initialize
      await tester.pumpAndSettle();

      // Verify that we're on the login screen
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('Login screen should have proper UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Check for main UI elements
      expect(find.byType(TextField), findsAtLeast(2)); // Email and password fields
      expect(find.byType(ElevatedButton), findsAtLeast(1)); // Login button
      expect(find.text('Don\'t have an account?'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('App should have proper theme support', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Check that the app has a MaterialApp with proper theme
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
      expect(materialApp.debugShowCheckedModeBanner, false);
    });

    testWidgets('App should handle theme provider correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Check that the app initializes properly
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
