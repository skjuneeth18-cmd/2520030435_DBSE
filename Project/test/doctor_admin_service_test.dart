import 'package:flutter_test/flutter_test.dart';
import 'package:raktasetu/data/doctors_data.dart';
import 'package:raktasetu/models/appointment.dart';
import 'package:raktasetu/models/blood_availability.dart';
import 'package:raktasetu/models/blood_request.dart';
import 'package:raktasetu/services/admin_service.dart';
import 'package:raktasetu/services/auth_service.dart';
import 'package:raktasetu/services/blood_service.dart';
import 'package:raktasetu/services/doctor_service.dart';

/// Phase 3 service tests: doctors, consultation booking, admin
/// inventory updates and blood-request handling.
void main() {
  setUp(() {
    AuthService.instance.logout();
  });

  String registerAndLogin(String tag) {
    final email = '$tag@raktasetu.test';
    final err = AuthService.instance.register(
      fullName: 'Test User $tag',
      email: email,
      phone: '+91 90000 10000',
      bloodGroup: 'B+',
      area: 'Kukatpally',
      password: 'secret1',
      age: 30,
    );
    expect(err, isNull);
    return email;
  }

  group('DoctorService', () {
    test('lists doctors, filters by hospital and search', () {
      final all = DoctorService.instance.doctors();
      expect(all.length, 18);

      final h01 = DoctorService.instance.doctorsByHospital('h01');
      expect(h01.length, 3);
      expect(h01.every((d) => d.hospitalId == 'h01'), isTrue);

      final cardio = DoctorService.instance.doctors(query: 'cardio');
      expect(cardio, isNotEmpty);
      expect(
        cardio.every((d) =>
            d.specialization.toLowerCase().contains('cardio') ||
            d.department.toLowerCase().contains('cardio')),
        isTrue,
      );

      expect(DoctorService.instance.doctorById('d01')!.name,
          'Dr. A. Sharma');
      expect(DoctorService.instance.specializations.length, greaterThan(4));
    });

    test('slot availability is deterministic', () {
      final date = DateTime.now().add(const Duration(days: 3));
      final a = DoctorService.mockTakenSeats(
          doctorId: 'd01', date: date, slot: '10:00 AM');
      final b = DoctorService.mockTakenSeats(
          doctorId: 'd01', date: date, slot: '10:00 AM');
      expect(a, b); // same input → same seats taken
      expect(a, inInclusiveRange(0, 3));
    });

    test('booking lifecycle: book, duplicate blocked, cancel, history', () {
      registerAndLogin('appt1');
      final svc = DoctorService.instance;
      final doctor = svc.doctorById('d03')!; // Mon–Sat, AM slots

      // Find the next consulting day.
      var date = DateTime.now().add(const Duration(days: 1));
      while (!doctorConsultsOn(doctor, date)) {
        date = date.add(const Duration(days: 1));
      }
      final slot = kConsultationSlots
          .firstWhere((s) => svc.isSlotAvailable(
              doctorId: doctor.id, date: date, slot: s));

      final err = svc.bookAppointment(
          doctor: doctor, date: date, slot: slot);
      expect(err, isNull);

      final active = svc.activeAppointments();
      expect(active.length, 1);
      expect(active.first.doctorId, doctor.id);
      expect(active.first.status, AppointmentStatus.confirmed);
      expect(active.first.time, slot);

      // Same doctor/day duplicate blocked.
      expect(
        svc.bookAppointment(doctor: doctor, date: date, slot: slot),
        contains('already have'),
      );

      // Cancel → history shows cancelled.
      final id = active.first.id;
      expect(svc.cancelAppointment(id), isNull);
      final mine = svc.myAppointments();
      expect(mine.first.status, AppointmentStatus.cancelled);
      expect(svc.activeAppointments(), isEmpty);
    });

    test('rejects booking on non-consulting days and past dates', () {
      registerAndLogin('appt2');
      final svc = DoctorService.instance;
      final doctor = svc.doctorById('d01')!; // Mon/Wed/Fri

      // Find the next NON-consulting day.
      var bad = DateTime.now().add(const Duration(days: 1));
      while (doctorConsultsOn(doctor, bad)) {
        bad = bad.add(const Duration(days: 1));
      }
      final err = svc.bookAppointment(
          doctor: doctor, date: bad, slot: '10:00 AM');
      expect(err, contains('does not consult'));

      final past = DateTime.now().subtract(const Duration(days: 2));
      expect(
        svc.bookAppointment(doctor: doctor, date: past, slot: '10:00 AM'),
        contains('future'),
      );
    });

    test('admin hospital view lists appointments', () {
      registerAndLogin('appt3');
      final svc = DoctorService.instance;
      final doctor = svc.doctorById('d01')!;
      var date = DateTime.now().add(const Duration(days: 1));
      while (!doctorConsultsOn(doctor, date)) {
        date = date.add(const Duration(days: 1));
      }
      final slot = kConsultationSlots.firstWhere((s) =>
          svc.isSlotAvailable(doctorId: doctor.id, date: date, slot: s));
      svc.bookAppointment(doctor: doctor, date: date, slot: slot);

      final hospitalAppts = svc.appointmentsForHospital('h01');
      expect(hospitalAppts, isNotEmpty);
      expect(
        hospitalAppts.any((a) => a.doctorId == 'd01'),
        isTrue,
      );
    });
  });

  group('AdminService', () {
    test('hospital admin resolves managed facility', () {
      AuthService.instance.logout();
      final err = AuthService.instance.login(
        email: 'hospital@raktasetu.in',
        password: 'demo123',
      );
      expect(err, isNull);
      final facility = AdminService.instance.managedFacility();
      expect(facility, isNotNull);
      expect(facility!.id, 'h01');
      expect(facility.kind, AdminFacilityKind.hospital);
    });

    test('blood bank admin resolves managed facility', () {
      AuthService.instance.logout();
      final err = AuthService.instance.login(
        email: 'bloodbank@raktasetu.in',
        password: 'demo123',
      );
      expect(err, isNull);
      final facility = AdminService.instance.managedFacility();
      expect(facility, isNotNull);
      expect(facility!.id, 'bb01');
      expect(facility.kind, AdminFacilityKind.bloodBank);
    });

    test('donor has no managed facility', () {
      registerAndLogin('admin1');
      expect(AdminService.instance.managedFacility(), isNull);
    });

    test('inventory update overrides seed and recomputes status', () {
      AuthService.instance.logout();
      AuthService.instance.login(
          email: 'hospital@raktasetu.in', password: 'demo123');
      final admin = AdminService.instance;

      final before = admin.inventory('h01');
      expect(before.length, 8);

      admin.updateUnits(
          facilityId: 'h01', bloodGroup: 'O+', units: 2);
      final oPos =
          admin.inventory('h01').where((e) => e.bloodGroup == 'O+').first;
      expect(oPos.units, 2);
      expect(oPos.status, StockStatus.limited);

      admin.updateUnits(facilityId: 'h01', bloodGroup: 'O+', units: 0);
      expect(
        admin.inventory('h01').where((e) => e.bloodGroup == 'O+').first.status,
        StockStatus.unavailable,
      );
    });

    test('requests seed, fulfil decrements inventory, reject works', () {
      AuthService.instance.logout();
      AuthService.instance.login(
          email: 'bloodbank@raktasetu.in', password: 'demo123');
      final admin = AdminService.instance;

      final requests = admin.requestsFor('bb01');
      expect(requests, isNotEmpty);
      expect(
        requests.any((r) => r.status == RequestStatus.pending),
        isTrue,
      );

      // Find a fulfillable request (enough stock).
      final fulfillable = requests.firstWhere(
        (r) =>
            r.status == RequestStatus.pending &&
            (admin.inventory('bb01')
                    .where((e) => e.bloodGroup == r.bloodGroup)
                    .first
                    .units) >=
                r.units,
      );
      final beforeUnits = admin
          .inventory('bb01')
          .where((e) => e.bloodGroup == fulfillable.bloodGroup)
          .first
          .units;

      expect(admin.fulfilRequest(fulfillable.id), isNull);
      final afterUnits = admin
          .inventory('bb01')
          .where((e) => e.bloodGroup == fulfillable.bloodGroup)
          .first
          .units;
      expect(afterUnits, beforeUnits - fulfillable.units);
      expect(
        admin.requestsFor('bb01').firstWhere((r) => r.id == fulfillable.id).status,
        RequestStatus.fulfilled,
      );

      // Double-fulfil blocked.
      expect(admin.fulfilRequest(fulfillable.id),
          contains('already'));

      // Reject a pending one.
      final pending = admin
          .requestsFor('bb01')
          .firstWhere((r) => r.status == RequestStatus.pending);
      expect(admin.rejectRequest(pending.id), isNull);
      expect(
        admin.requestsFor('bb01').firstWhere((r) => r.id == pending.id).status,
        RequestStatus.rejected,
      );
    });

    test('users can raise requests to a facility', () {
      registerAndLogin('requester1');
      final admin = AdminService.instance;
      final err = admin.raiseRequest(
        facilityId: 'bb02',
        facilityName: 'Sunshine Voluntary Blood Bank',
        bloodGroup: 'A-',
        units: 2,
        priority: RequestPriority.urgent,
      );
      expect(err, isNull);
      final raised = admin
          .requestsFor('bb02')
          .firstWhere((r) => r.requesterName == 'Test User requester1');
      expect(raised.bloodGroup, 'A-');
      expect(raised.requesterName, 'Test User requester1');
      expect(raised.status, RequestStatus.pending);

      // Validation guards.
      expect(
        admin.raiseRequest(
          facilityId: 'bb02',
          facilityName: 'x',
          bloodGroup: 'ZZ',
          units: 1,
        ),
        isNotNull,
      );
      expect(
        admin.raiseRequest(
          facilityId: 'bb02',
          facilityName: 'x',
          bloodGroup: 'O+',
          units: 0,
        ),
        isNotNull,
      );
    });

    test('facility lookup helpers find hospitals and blood banks', () {
      expect(BloodService.instance.hospitalById('h01')!.name,
          contains('City Care'));
      expect(BloodService.instance.bloodBankById('bb01')!.name,
          contains('City Care'));
      expect(BloodService.instance.hospitalById('nope'), isNull);
    });
  });
}
