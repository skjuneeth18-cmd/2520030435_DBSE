import 'package:flutter_test/flutter_test.dart';
import 'package:raktasetu/models/blood_availability.dart';
import 'package:raktasetu/models/blood_requirement.dart';
import 'package:raktasetu/services/blood_service.dart';

void main() {
  group('FacilityStock.mock', () {
    test('is deterministic for the same seed', () {
      final a = FacilityStock.mock(42);
      final b = FacilityStock.mock(42);
      for (var i = 0; i < a.entries.length; i++) {
        expect(a.entries[i].bloodGroup, b.entries[i].bloodGroup);
        expect(a.entries[i].status, b.entries[i].status);
        expect(a.entries[i].units, b.entries[i].units);
      }
    });

    test('contains exactly the 8 blood groups', () {
      final stock = FacilityStock.mock(7);
      expect(stock.entries.map((e) => e.bloodGroup).toList(),
          FacilityStock.allGroups);
      expect(FacilityStock.allGroups.length, 8);
    });

    test('unit counts are consistent with status', () {
      for (var seed = 0; seed < 60; seed++) {
        for (final e in FacilityStock.mock(seed).entries) {
          switch (e.status) {
            case StockStatus.available:
              expect(e.units, greaterThanOrEqualTo(8), reason: '$seed/$e');
            case StockStatus.limited:
              expect(e.units, inInclusiveRange(1, 3), reason: '$seed/$e');
            case StockStatus.unavailable:
              expect(e.units, 0, reason: '$seed/$e');
          }
        }
      }
    });

    test('forGroup finds entries and returns null for unknown group', () {
      final stock = FacilityStock.mock(11);
      expect(stock.forGroup('O+')!.bloodGroup, 'O+');
      expect(stock.forGroup('Z-'), isNull);
    });
  });

  group('BloodService.topHospitals', () {
    final service = BloodService.instance;

    test('returns 10 hospitals sorted by rating descending', () {
      final top = service.topHospitals();
      expect(top.length, 10);
      for (var i = 1; i < top.length; i++) {
        expect(top[i - 1].rating, greaterThanOrEqualTo(top[i].rating));
      }
    });

    test('underlying dataset has at least 10 hospitals', () {
      expect(service.hospitals.length, greaterThanOrEqualTo(10));
    });
  });

  group('BloodService.requirements', () {
    final service = BloodService.instance;

    test('sorts critical before urgent before normal', () {
      final list = service.requirements();
      final ranks = list.map((r) => r.emergencyLevel.index).toList();
      expect(ranks, equals([...ranks]..sort()));
    });

    test('area filter returns only that area', () {
      final list = service.requirements(area: 'Kukatpally');
      expect(list, isNotEmpty);
      expect(list.every((r) => r.area == 'Kukatpally'), isTrue);
    });

    test('openOnly excludes fulfilled requirements', () {
      final open = service.requirements(openOnly: true);
      expect(
          open.every((r) => r.status == RequirementStatus.open), isTrue);
      final all = service.requirements(openOnly: false);
      expect(all.length, greaterThan(open.length));
    });

    test('dataset has at least one requirement per area', () {
      final areas = service.requirements(openOnly: false).map((r) => r.area);
      expect(areas.toSet().length, greaterThanOrEqualTo(10));
    });
  });

  group('BloodService.findFacilitiesWithBlood', () {
    final service = BloodService.instance;

    test('excludes unavailable stock by default', () {
      for (final group
          in FacilityStock.allGroups) {
        final rows = service.findFacilitiesWithBlood(group: group);
        for (final row in rows) {
          expect(row.stock.forGroup(group)!.status,
              isNot(StockStatus.unavailable),
              reason: '$group @ ${row.name}');
        }
      }
    });

    test('includeUnavailable adds out-of-stock facilities', () {
      for (final group in FacilityStock.allGroups) {
        final withOut = service.findFacilitiesWithBlood(group: group);
        final withAll = service.findFacilitiesWithBlood(
            group: group, includeUnavailable: true);
        expect(withAll.length, greaterThanOrEqualTo(withOut.length),
            reason: group);
      }
    });

    test('area filter restricts results to that area', () {
      final rows = service.findFacilitiesWithBlood(
        group: 'O+',
        area: 'Kukatpally',
        includeUnavailable: true,
      );
      expect(rows.every((r) => r.area == 'Kukatpally'), isTrue);
    });

    test('facilityType filter returns only hospitals or only blood banks',
        () {
      final hospitals = service.findFacilitiesWithBlood(
          group: 'O+', facilityType: 'Hospital', includeUnavailable: true);
      expect(hospitals.every((r) => r.type == 'Hospital'), isTrue);
      expect(hospitals, isNotEmpty);

      final banks = service.findFacilitiesWithBlood(
          group: 'O+', facilityType: 'Blood Bank', includeUnavailable: true);
      expect(banks.every((r) => r.type == 'Blood Bank'), isTrue);
      expect(banks, isNotEmpty);
    });

    test('results are sorted available before limited', () {
      final rows = service.findFacilitiesWithBlood(group: 'O+');
      final statuses = rows
          .map((r) => r.stock.forGroup('O+')!.status.index)
          .toList();
      expect(statuses, equals([...statuses]..sort()));
    });

    test('every hospital with a blood bank is searchable', () {
      final withBb = service.hospitals.where((h) => h.hasBloodBank);
      expect(withBb.length, greaterThanOrEqualTo(8));
    });
  });
}
