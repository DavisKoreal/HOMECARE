import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homecare0x1/main.dart';
import 'package:homecare0x1/screens/login_screen.dart';

void main() {
  testWidgets('HomecareApp renders LoginScreen', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const HomecareApp());

    // Verify that the LoginScreen is displayed.
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome to Homecare Management'), findsOneWidget);

    // Verify the email and password fields exist.
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
