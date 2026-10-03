import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raktasetu/app.dart';
import 'package:raktasetu/services/auth_service.dart';

/// Phase 3 widget flows: Doctors tab, doctor profile, hospital detail
/// doctors section and the role-based admin dashboards.
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

  testWidgets('Doctors tab: browse, filter, open profile', (tester) async {
    await loginAs(tester, 'demo@raktasetu.in');

    await tester.tap(find.text('Doctors'));
    await tester.pumpAndSettle();

    expect(find.text('Dr. A. Sharma'), findsOneWidget);

    // Filter by specialization chip.
    await tester.tap(find.text('Cardiology'));
    await tester.pumpAndSettle();
    expect(find.text('Dr. A. Sharma'), findsOneWidget);
    expect(find.text('Dr. P. Rao'), findsNothing);

    // Open profile via first card.
    await tester.tap(find.text('Dr. A. Sharma'));
    await tester.pumpAndSettle();
    expect(find.text('Doctor profile'), findsOneWidget);
    expect(find.textContaining('₹600'), findsWidgets);
    expect(find.text('Book consultation'), findsOneWidget);

    // Back out.
    await tester.pageBack();
    await tester.pumpAndSettle();
  });

  testWidgets('search filters doctors by name', (tester) async {
    await loginAs(tester, 'demo@raktasetu.in');

    await tester.tap(find.text('Doctors'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Fatima');
    await tester.pumpAndSettle();

    expect(find.text('Dr. N. Fatima'), findsOneWidget);
    expect(find.text('Dr. A. Sharma'), findsNothing);
  });

  testWidgets('hospital detail shows doctors section', (tester) async {
    await loginAs(tester, 'demo@raktasetu.in');

    // Hospitals tab → first hospital card.
    await tester.tap(find.text('Hospitals'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('City Care Multispeciality Hospital'));
    await tester.pumpAndSettle();

    expect(find.text('Doctors & Consultation'), findsOneWidget);
    expect(find.text('Dr. A. Sharma'), findsOneWidget);
  });

  testWidgets('hospital admin dashboard renders with requests', (tester) async {
    await loginAs(tester, 'hospital@raktasetu.in');

    // Home shows the admin entry card (donor quick actions hidden).
    expect(find.text('Open Hospital Admin Dashboard'), findsOneWidget);
    expect(find.text('Book a slot'), findsNothing);

    await tester.tap(find.text('Open Hospital Admin Dashboard'));
    await tester.pumpAndSettle();

    expect(find.text('Hospital Admin'), findsOneWidget);
    expect(find.text('City Care Multispeciality Hospital'), findsOneWidget);
    expect(find.text('🩸 Blood requests'), findsOneWidget);

    // Lower sections live below the fold — scroll to them.
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('🧪 Blood inventory'),
      250,
      scrollable: scrollable,
    );
    expect(find.text('🧪 Blood inventory'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('📅 Appointments'),
      250,
      scrollable: scrollable,
    );
    expect(find.text('📅 Appointments'), findsOneWidget);
  });

  testWidgets('blood bank admin dashboard renders with donors', (tester) async {
    await loginAs(tester, 'bloodbank@raktasetu.in');

    expect(find.text('Open Blood Bank Admin Dashboard'), findsOneWidget);

    await tester.tap(find.text('Open Blood Bank Admin Dashboard'));
    await tester.pumpAndSettle();

    expect(find.text('Blood Bank Admin'), findsOneWidget);
    expect(find.text('City Care Blood Centre'), findsOneWidget);
    expect(find.text('🧪 Update inventory'), findsOneWidget);

    // Scroll through the sections (inventory's 8 rows push them down).
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('🩸 Blood requests'),
      300,
      scrollable: scrollable,
    );
    expect(find.text('🩸 Blood requests'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('💉 Donation slots'),
      300,
      scrollable: scrollable,
    );
    expect(find.text('💉 Donation slots'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('🧑‍🤝‍🧑 Donors'),
      300,
      scrollable: scrollable,
    );
    expect(find.text('🧑‍🤝‍🧑 Donors'), findsOneWidget);
  });
}
