import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raktasetu/app.dart';
import 'package:raktasetu/services/auth_service.dart';

/// Phase 4 widget flows: KYC & verification, donor benefits and coupons,
/// plus the admin KYC review queue.
void main() {
  setUp(() {
    AuthService.instance.logout();
  });

  Future<void> loginAs(WidgetTester tester, String email) async {
    await tester.pumpWidget(const RaktaSetuApp());
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), email);
    await tester.enterText(find.byType(TextFormField).at(1), 'demo123');
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();
  }

  testWidgets('home exposes the Phase 4 quick actions for a donor',
      (tester) async {
    await loginAs(tester, 'demo@raktasetu.in');

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('KYC & Verification'),
      250,
      scrollable: scrollable,
    );
    expect(find.text('My Coupons'), findsOneWidget);
    expect(find.text('Donor Benefits'), findsOneWidget);
  });

  testWidgets('KYC screen shows the verified donor badge for the demo user',
      (tester) async {
    await loginAs(tester, 'demo@raktasetu.in');

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('KYC & Verification'),
      250,
      scrollable: scrollable,
    );
    await tester.tap(find.text('KYC & Verification'));
    await tester.pumpAndSettle();

    expect(find.text('KYC & Verification'), findsWidgets);
    expect(find.text('Your Verification Status'), findsOneWidget);
    expect(find.textContaining('Verified'), findsWidgets);
    expect(find.textContaining('Secure reference: ID-'), findsOneWidget);
  });

  testWidgets('coupons screen lists active, used and expired tabs',
      (tester) async {
    await loginAs(tester, 'demo@raktasetu.in');

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('KYC & Verification'),
      250,
      scrollable: scrollable,
    );
    await tester.tap(find.text('My Coupons'));
    await tester.pumpAndSettle();

    expect(find.text('My Coupons'), findsWidgets);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Used'), findsOneWidget);
    expect(find.text('Expired'), findsOneWidget);
    expect(find.text('RAKTA-AB12'), findsOneWidget);
    expect(find.text('Redeem'), findsWidgets);

    // Used tab shows the previously redeemed coupon.
    await tester.tap(find.text('Used'));
    await tester.pumpAndSettle();
    expect(find.text('RAKTA-CD34'), findsOneWidget);
    expect(find.textContaining('Used at'), findsOneWidget);
  });

  testWidgets('benefits screen shows benefits, hospital offers and brochure',
      (tester) async {
    await loginAs(tester, 'demo@raktasetu.in');

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('KYC & Verification'),
      250,
      scrollable: scrollable,
    );
    await tester.tap(find.text('Donor Benefits'));
    await tester.pumpAndSettle();

    expect(find.text('All Benefits'), findsOneWidget);
    expect(find.text('Hospital Offers'), findsOneWidget);
    expect(find.text('Brochure'), findsOneWidget);
    expect(find.text('Active Benefits'), findsOneWidget);

    await tester.tap(find.text('Brochure'));
    await tester.pumpAndSettle();
    expect(find.text('Available Donor Benefits'), findsOneWidget);

    final brochureScroll = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(
      find.text('Coupon Details'),
      250,
      scrollable: brochureScroll,
    );
    expect(find.text('Coupon Details'), findsOneWidget);
    expect(find.text('Terms & Conditions'), findsOneWidget);
  });

  testWidgets('hospital admin can open the KYC review queue', (tester) async {
    await loginAs(tester, 'hospital@raktasetu.in');

    await tester.tap(find.text('Open Hospital Admin Dashboard'));
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('🪪 KYC & donor verification'),
      250,
      scrollable: scrollable,
    );
    expect(find.text('KYC review queue'), findsOneWidget);

    await tester.ensureVisible(find.text('KYC review queue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('KYC review queue'));
    await tester.pumpAndSettle();

    expect(find.text('KYC & Donor Verification'), findsOneWidget);
    expect(find.text('KYC Review Queue'), findsOneWidget);
  });

  testWidgets('donors do not get the admin KYC entry', (tester) async {
    await loginAs(tester, 'demo@raktasetu.in');

    expect(find.text('Open Hospital Admin Dashboard'), findsNothing);
    expect(find.text('Open Blood Bank Admin Dashboard'), findsNothing);
  });
}