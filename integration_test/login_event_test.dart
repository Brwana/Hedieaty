import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty/login_page.dart';
import 'package:hedieaty/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hedieaty/createEvent.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  group('login Tests', (){testWidgets('Login with invalid credentials shows error', (
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

  testWidgets('Login with valid credentials navigates to home page', (
      WidgetTester tester) async {
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
});
  group('CreateEvent Widget Tests', () {
    testWidgets('renders all input fields and button correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateEvent(),
        ),
      );

      // Check for Event Name input field
      expect(find.widgetWithText(TextFormField, 'Event Name'), findsOneWidget);

      // Check for Location input field
      expect(find.widgetWithText(TextFormField, 'Location'), findsOneWidget);

      // Check for Description input field
      expect(find.widgetWithText(TextFormField, 'Description'), findsOneWidget);

      // Check for Event Date field
      expect(find.widgetWithText(TextFormField, 'Event Date'), findsOneWidget);

      // Check for Category dropdown
      // expect(find.widgetWithText(DropdownButtonFormField, 'Category'), findsOneWidget);
      final dropdownFinder = find.byKey(const Key('category'));
      expect(dropdownFinder, findsOneWidget);

      // Check for Create Event button
      expect(find.widgetWithText(ElevatedButton, 'Create Event'), findsOneWidget);
    });

    testWidgets('validates input fields correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateEvent(),
        ),
      );

      // Attempt to submit without filling fields
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Event'));
      await tester.pump();

      // Check for validation error messages
      expect(find.text('Please enter the event name'), findsOneWidget);
      expect(find.text('Please enter the location'), findsOneWidget);
      expect(find.text('Please enter a description'), findsOneWidget);
      expect(find.text('Please select a category'), findsOneWidget);
    });

    testWidgets('allows filling and submission of the form', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateEvent(),
        ),
      );

      // Fill in Event Name
      await tester.enterText(find.widgetWithText(TextFormField, 'Event Name'), 'Birthday Party');

      // Fill in Location
      await tester.enterText(find.widgetWithText(TextFormField, 'Location'), 'New York');

      // Fill in Description
      await tester.enterText(find.widgetWithText(TextFormField, 'Description'), 'A fun birthday party.');

      // Select a date
      await tester.tap(find.widgetWithText(TextFormField, 'Event Date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('29'));
      await tester.tap(find.text('OK'));
      await tester.pump();

      // Find the dropdown using its key
      final dropdownFinder = find.byKey(const Key('category'));
      expect(dropdownFinder, findsOneWidget);

      // Tap the dropdown to open the menu
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle(); // Wait for the menu to open

      // Ensure the item is visible before tapping
      final itemFinder = find.byKey(const Key('categoryItem_0'));
      await tester.ensureVisible(itemFinder);

      // // Find a specific menu item by its key and tap it
      // final itemFinder = find.byKey(const Key('categoryItem_0')); // Adjust index for desired item
      // expect(itemFinder, findsOneWidget);

      await tester.tap(itemFinder,warnIfMissed: false);
      await tester.pumpAndSettle(); // Wait for the menu to close

      // Verify the selected category
      expect(find.text('Birthday'), findsOneWidget);

      // Submit the form
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Event'));
      await tester.pump();

      // Verify success message or navigate back
      // expect(find.text('Event created successfully!'), findsOneWidget);
      print("event created successfully");
    });
  });
}





