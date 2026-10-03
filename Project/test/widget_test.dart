import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raktasetu/app.dart';
import 'package:raktasetu/data/hospitals_data.dart';
import 'package:raktasetu/data/notifications_data.dart';
import 'package:raktasetu/data/blood_banks_data.dart';
import 'package:raktasetu/models/blood_availability.dart';
import 'package:raktasetu/widgets/blood_group_chip.dart';
import 'package:raktasetu/widgets/status_badge.dart';

void main() {
  group('Phase 1 mock datasets', () {
    test('provides at least 10 hospitals', () {
      expect(kHospitals.length, greaterThanOrEqualTo(10));
    });

    test('provides at least 10 blood banks', () {
      expect(kBloodBanks.length, greaterThanOrEqualTo(10));
    });

    test('provides notifications for all 5 categories', () {
      final categories = kNotifications.map((n) => n.category).toSet();
      expect(categories.length, 5);
    });

    test('every hospital has non-empty name, area and phone', () {
      for (final h in kHospitals) {
        expect(h.name.isNotEmpty, isTrue);
        expect(kAreas.contains(h.area), isTrue, reason: h.name);
        expect(h.phone.isNotEmpty, isTrue);
      }
    });

    test('every blood bank has an area and hours', () {
      for (final b in kBloodBanks) {
        expect(kAreas.contains(b.area), isTrue, reason: b.name);
        expect(b.openHours.isNotEmpty, isTrue);
      }
    });
  });

  group('Widgets', () {
    testWidgets('BloodGroupChip renders its group label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BloodGroupChip(group: 'O-', selected: false),
            ),
          ),
        ),
      );
      expect(find.text('O-'), findsOneWidget);
    });

    testWidgets('StatusBadge shows the status label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: StatusBadge(status: StockStatus.available)),
      );
      expect(find.text('Available'), findsOneWidget);
    });

    testWidgets('RaktaSetuApp starts on the splash screen', (tester) async {
      await tester.pumpWidget(const RaktaSetuApp());
      expect(find.text('RaktaSetu'), findsOneWidget);
      expect(find.text('Find Blood Fast. Save Lives.'), findsOneWidget);

      // Flush the 3-second splash timer; app should route to Login.
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('Welcome back'), findsOneWidget);
    });
  });
}
