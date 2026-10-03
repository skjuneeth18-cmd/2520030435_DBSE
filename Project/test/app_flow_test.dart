import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raktasetu/app.dart';
import 'package:raktasetu/services/auth_service.dart';

/// End-to-end login -> dashboard flow tests.
///
/// These drive the real widget tree (splash timer, form validation,
/// AuthService, Navigator routes, NavigationBar tabs) exactly as a user
/// would, minus the browser shell.
void main() {
  setUp(() {
    AuthService.instance.logout();
  });

  testWidgets('wrong password shows an error and stays on login',
      (tester) async {
    // Register a real account first so the wrong-password path is hit.
    AuthService.instance.register(
      fullName: 'Wrong Pass User',
      email: 'wrongpass@example.com',
      phone: '9000000007',
      bloodGroup: 'A+',
      area: 'Koti',
      password: 'rightpass',
    );
    AuthService.instance.logout();

    await tester.pumpWidget(const RaktaSetuApp());
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byType(TextFormField).at(0), 'wrongpass@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrongpass');
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.text('Incorrect password. Please try again.'),
        findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget); // still on login
  });

  testWidgets('empty form validation blocks submission', (tester) async {
    await tester.pumpWidget(const RaktaSetuApp());
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget); // still on login
  });

  testWidgets('demo login lands on dashboard with user data, tabs work, '
      'and logout returns to login', (tester) async {
    await tester.pumpWidget(const RaktaSetuApp());
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // --- Login with the demo account ---
    await tester.enterText(
        find.byType(TextFormField).at(0), 'demo@raktasetu.in');
    await tester.enterText(find.byType(TextFormField).at(1), 'demo123');
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    // --- Dashboard shows personalised data ---
    expect(find.text('Hello, Demo 👋'), findsOneWidget);
    expect(find.text('O+ · Kukatpally'), findsOneWidget);
    expect(find.text('🚨 Emergency Requirements'), findsOneWidget);

    // Sections below the viewport are built lazily; scroll to each.
    final homeScrollable = find.byType(Scrollable).first;

    await tester.scrollUntilVisible(
      find.text('🏥 Nearby Hospitals'),
      250,
      scrollable: homeScrollable,
    );
    expect(find.text('🏥 Nearby Hospitals'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('🩸 Nearby Blood Banks'),
      250,
      scrollable: homeScrollable,
    );
    expect(find.text('🩸 Nearby Blood Banks'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('🔔 Latest Notifications'),
      250,
      scrollable: homeScrollable,
    );
    expect(find.text('🔔 Latest Notifications'), findsOneWidget);

    // --- Bottom navigation: Find Blood tab with group filtering ---
    await tester.tap(find.text('Find Blood'));
    await tester.pumpAndSettle();
    expect(find.text('Select blood group'), findsOneWidget);

    await tester.tap(find.text('A-'));
    await tester.pumpAndSettle();
    expect(find.textContaining('result(s) for A-'), findsOneWidget);

    // Area filter narrows results without crashing.
    await tester.tap(find.text('All facilities'));
    await tester.pumpAndSettle();

    // --- Profile tab shows the account ---
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Demo Donor'), findsWidgets);
    expect(find.text('demo@raktasetu.in'), findsWidgets);

    // --- Logout returns to the login screen ---
    await tester.scrollUntilVisible(
      find.text('Logout'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('notifications open from the home app bar', (tester) async {
    await tester.pumpWidget(const RaktaSetuApp());
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byType(TextFormField).at(0), 'demo@raktasetu.in');
    await tester.enterText(find.byType(TextFormField).at(1), 'demo123');
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    // Bell icon in the app bar opens the notifications screen.
    await tester.tap(find.byIcon(Icons.notifications_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    // Emergency category chip filters the list.
    await tester.tap(find.text('🚨 Emergency'));
    await tester.pumpAndSettle();
    expect(find.textContaining('needed'), findsWidgets);
  });
}
