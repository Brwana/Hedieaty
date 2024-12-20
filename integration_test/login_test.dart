import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty/login_page.dart';
import 'package:hedieaty/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  testWidgets('Login with invalid credentials shows error', (
      WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    // Enter invalid credentials
    await tester.enterText(find.byKey(Key('emailField')), 'invalidexample.com');
    await tester.enterText(find.byKey(Key('passwordField')), '');
    await tester.tap(find.byKey(Key('loginButton')));

    // Wait for the UI to update
    await tester.pumpAndSettle(const Duration(seconds: 5));
    print("invalide credentials");

  });

  testWidgets('Login with valid credentials navigates to home page', (WidgetTester tester) async {
    // Build the app and let the LoginPage load
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    // Simulate typing a valid email and password in the login form
    await tester.enterText(find.byKey(Key('emailField')), 'ah@gmail.com');
    await tester.enterText(find.byKey(Key('passwordField')), '123456');
    await tester.tap(find.byKey(Key('loginButton')));

    // Wait for the navigation to complete
    await tester.pumpAndSettle();
print("goes to home page");

  });


}
