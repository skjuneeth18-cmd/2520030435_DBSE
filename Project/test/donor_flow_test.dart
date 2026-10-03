import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raktasetu/app.dart';
import 'package:raktasetu/models/booking.dart';
import 'package:raktasetu/services/auth_service.dart';

/// Phase 2 end-to-end widget flows: Donate tab, booking, camps,
/// certificates — driven through the real widget tree.
void main() {
  setUp(() {
    AuthService.instance.logout();
  });

  Future<void> loginAsDemo(WidgetTester tester) async {
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
  }

  testWidgets('demo login lands on dashboard with Phase 2 tabs',
      (tester) async {
    await loginAsDemo(tester);

    // New bottom navigation exists with the 6 Phase 3 tabs.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Find Blood'), findsOneWidget);
    expect(find.text('Hospitals'), findsOneWidget);
    expect(find.text('Doctors'), findsOneWidget);
    expect(find.text('Blood Banks'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Home still surfaces hospitals & blood banks sections.
    expect(find.text('🚨 Emergency Requirements'), findsOneWidget);
  });

  testWidgets('donor dashboard opens from Home and shows sections',
      (tester) async {
    await loginAsDemo(tester);

    await tester.tap(find.text('Donate dashboard'));
    await tester.pumpAndSettle();

    expect(find.text('Donate Blood'), findsOneWidget);
    expect(find.text('Book a donation slot'), findsOneWidget);
    expect(find.text('🕘 My donation slots'), findsOneWidget);
    expect(find.text('📋 Donation history'), findsOneWidget);

    // Lower sections live below the fold — scroll to them.
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('📢 Upcoming camps'),
      250,
      scrollable: scrollable,
    );
    expect(find.text('📢 Upcoming camps'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('🏅 My certificates'),
      250,
      scrollable: scrollable,
    );
    expect(find.text('🏅 My certificates'), findsOneWidget);

    // Demo donor has a seeded upcoming booking (bk01, 10 Oct 2026).
    await tester.scrollUntilVisible(
      find.textContaining('City Care Blood Centre'),
      -250,
      scrollable: scrollable,
    );
    expect(find.textContaining('City Care Blood Centre'), findsWidgets);
  });

  testWidgets('booking flow: pick facility, date, slot, confirm',
      (tester) async {
    await loginAsDemo(tester);

    await tester.tap(find.text('Donate dashboard'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Book a donation slot'));
    await tester.pumpAndSettle();

    // Step 1: search & pick a facility.
    expect(find.text('Step 1 · Choose facility'), findsOneWidget);
    await tester.enterText(
        find.byType(TextFormField).first, 'Cyber Blood Hub');
    await tester.pumpAndSettle();
    // Tap the venue tile (the search field itself also shows the text).
    await tester.tap(find.widgetWithText(ListTile, 'Cyber Blood Hub'));
    await tester.pumpAndSettle();

    // Step 2: default date is tomorrow; open picker and keep it.
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();
    // Dialog: confirm with OK / SAVE label (locale-dependent).
    final okFinder = find.text('OK');
    if (tester.any(okFinder)) {
      await tester.tap(okFinder.last);
    } else {
      await tester.tap(find.text('SAVE').last);
    }
    await tester.pumpAndSettle();

    // Step 3: pick the first available slot chip for (bb11, tomorrow).
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final slot = DonationBooking.kTimeSlots.firstWhere((s) =>
        DonationBooking.isSlotAvailable(
            venueId: 'bb11', date: tomorrow, slot: s));
    await tester.tap(find.text(slot));
    await tester.pumpAndSettle();

    // Confirm the booking (button sits below the fold; label is dynamic).
    final confirmFinder = find.textContaining('Confirm');
    await tester.scrollUntilVisible(
      confirmFinder,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(confirmFinder);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    // Confirmation snackbar appears.
    expect(find.textContaining('Slot confirmed'), findsOneWidget);
  });

  testWidgets('camps screen lists camps and registers for one',
      (tester) async {
    await loginAsDemo(tester);

    await tester.tap(find.text('All camps'));
    await tester.pumpAndSettle();

    expect(find.text('Donation camps'), findsOneWidget);
    expect(find.text('October City Mega Donation Camp'), findsOneWidget);

    // Open detail via the first camp card.
    await tester
        .tap(find.text('October City Mega Donation Camp'));
    await tester.pumpAndSettle();
    expect(find.text('Camp details'), findsOneWidget);
    expect(find.text('Blood groups needed'), findsOneWidget);

    // Register via the FAB.
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Registered'), findsWidgets);
  });

  testWidgets('certificates open in a detail view', (tester) async {
    await loginAsDemo(tester);

    await tester.tap(find.text('Donate dashboard'));
    await tester.pumpAndSettle();
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('🏅 My certificates'),
      250,
      scrollable: scrollable,
    );
    await tester.tap(find.text('See all').last);
    await tester.pumpAndSettle();

    expect(find.text('My certificates'), findsOneWidget);
    expect(find.text('RS-CERT-2026-0042'), findsOneWidget);

    await tester.tap(find.text('RS-CERT-2026-0042'));
    await tester.pumpAndSettle();
    expect(find.text('Certificate of Appreciation'), findsOneWidget);
    expect(find.text('Demo Donor'), findsOneWidget);
  });
}
