import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:raktasetu/app.dart';
import 'package:raktasetu/services/auth_service.dart';

/// End-to-end flow test: splash -> login -> dashboard -> tabs -> logout.
///
/// Run against a real browser with:
///   flutter drive \
///     --driver=test_driver/integration_test.dart \
///     --target=integration_test/app_flow_test.dart \
///     -d chrome
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('login -> dashboard -> tabs -> logout', (tester) async {
    // Start from a clean, logged-out session.
    AuthService.instance.logout();

    // ---- Splash ----
    await tester.pumpWidget(const RaktaSetuApp());
    expect(find.text('Find Blood Fast. Save Lives.'), findsOneWidget);

    // Flush the 3-second splash timer (spinner animates, so no settle here).
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // ---- Login screen ----
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Demo login →  demo@raktasetu.in  /  demo123'),
        findsOneWidget);

    // Login screen has exactly two fields: email, then password.
    await tester.enterText(
        find.byType(TextFormField).at(0), 'demo@raktasetu.in');
    await tester.enterText(find.byType(TextFormField).at(1), 'demo123');
    await tester.pump();

    // Submit; the mock auth call takes ~600 ms (loading spinner runs).
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // ---- Home dashboard ----
    expect(find.text('Hello, Demo 👋'), findsOneWidget);
    expect(find.text('O+ · Kukatpally'), findsOneWidget);
    expect(find.text('🚨 Emergency Requirements'), findsOneWidget);
    expect(find.text('🏥 Nearby Hospitals'), findsOneWidget);
    expect(find.text('🩸 Nearby Blood Banks'), findsOneWidget);
    expect(find.text('🔔 Latest Notifications'), findsOneWidget);

    // ---- Bottom navigation: Find Blood tab + filtering ----
    await tester.tap(find.text('Find Blood'));
    await tester.pumpAndSettle();
    expect(find.text('Select blood group'), findsOneWidget);

    await tester.tap(find.text('A-'));
    await tester.pumpAndSettle();
    expect(find.textContaining('result(s) for A-'), findsOneWidget);

    // ---- Profile tab ----
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Demo Donor'), findsWidgets);
    expect(find.text('demo@raktasetu.in'), findsWidgets);

    // ---- Logout -> back to login ----
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
