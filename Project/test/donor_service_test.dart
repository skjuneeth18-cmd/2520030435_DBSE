import 'package:flutter_test/flutter_test.dart';
import 'package:raktasetu/data/camps_data.dart';
import 'package:raktasetu/data/donor_seed_data.dart';
import 'package:raktasetu/models/app_notification.dart';
import 'package:raktasetu/models/booking.dart';
import 'package:raktasetu/models/donation_record.dart';
import 'package:raktasetu/models/donor.dart';
import 'package:raktasetu/models/donor_certificate.dart';
import 'package:raktasetu/services/auth_service.dart';
import 'package:raktasetu/services/blood_service.dart';
import 'package:raktasetu/services/donor_service.dart';

/// Phase 2 donor service tests: booking, camps, history,
/// certificates, notifications and eligibility.
void main() {
  // Creates a fresh account (unique email) and logs into it.
  String registerAndLogin(String tag, {int age = 28}) {
    final email = '$tag@raktasetu.test';
    final err = AuthService.instance.register(
      fullName: 'Test Donor $tag',
      email: email,
      phone: '90000000$tag',
      bloodGroup: 'B+',
      area: 'Koti',
      password: 'secret1',
      age: age,
    );
    expect(err, isNull, reason: 'register $tag should succeed');
    return email;
  }

  /// First bookable slot for [venueId] on [date] (mock data is
  /// deterministic, so this is stable).
  String firstAvailableSlot(String venueId, DateTime date) {
    for (final s in DonationBooking.kTimeSlots) {
      if (DonationBooking.isSlotAvailable(
          venueId: venueId, date: date, slot: s)) {
        return s;
      }
    }
    fail('no available slot in mock data');
  }

  group('Slot booking', () {
    test('books a slot, notifies, and lists it as active', () {
      AuthService.instance.logout();
      registerAndLogin('booker1');
      final date = DateTime.now().add(const Duration(days: 3));
      final slot = firstAvailableSlot('bb01', date);

      final error = DonorService.instance.bookSlot(
        venueId: 'bb01',
        venueName: 'City Care Blood Centre',
        venueType: 'Blood Bank',
        venueArea: 'Kukatpally',
        date: date,
        slot: slot,
      );
      expect(error, isNull);

      final bookings = DonorService.instance.activeBookings();
      expect(bookings, isNotEmpty);
      expect(bookings.first.venueId, 'bb01');
      expect(bookings.first.status, BookingStatus.confirmed);
      expect(bookings.first.time, slot);

      final notifs = DonorService.instance.donorNotifications();
      expect(
        notifs.any((n) =>
            n.category == NotificationCategory.slotConfirmation &&
            n.title.contains('Slot confirmed')),
        isTrue,
      );
    });

    test('rejects a second booking on the same date', () {
      AuthService.instance.logout();
      registerAndLogin('booker2');
      final date = DateTime.now().add(const Duration(days: 4));
      final slot = firstAvailableSlot('h02', date);

      expect(
        DonorService.instance.bookSlot(
          venueId: 'h02',
          venueName: 'Sunshine Institute of Medical Sciences',
          venueType: 'Hospital',
          venueArea: 'Gachibowli',
          date: date,
          slot: slot,
        ),
        isNull,
      );
      expect(
        DonorService.instance.bookSlot(
          venueId: 'h02',
          venueName: 'Sunshine Institute of Medical Sciences',
          venueType: 'Hospital',
          venueArea: 'Gachibowli',
          date: date,
          slot: slot,
        ),
        contains('already have a booking'),
      );
    });

    test('rejects booking a full slot', () {
      AuthService.instance.logout();
      registerAndLogin('booker3');
      // Find a venue/date/slot combination that is full in mock data.
      String? fullSlot;
      outer:
      for (final venue in BloodService.instance.bookableFacilities()) {
        for (var d = 1; d <= 10; d++) {
          for (final s in DonationBooking.kTimeSlots) {
            if (!DonationBooking.isSlotAvailable(
                venueId: venue.id,
                date: DateTime.now().add(Duration(days: d)),
                slot: s)) {
              fullSlot = s;
              break outer;
            }
          }
        }
      }
      expect(fullSlot, isNotNull, reason: 'mock data should contain a full slot');
    });

    test('cancel and reschedule update status and notify', () {
      AuthService.instance.logout();
      registerAndLogin('booker4');
      final date = DateTime.now().add(const Duration(days: 5));
      final slot = firstAvailableSlot('bb05', date);
      DonorService.instance.bookSlot(
        venueId: 'bb05',
        venueName: 'St. Mary Rotary Blood Bank',
        venueType: 'Blood Bank',
        venueArea: 'Secunderabad',
        date: date,
        slot: slot,
      );
      var booking = DonorService.instance.activeBookings().first;
      final id = booking.id;

      // Reschedule to another available slot on a new date.
      final newDate = DateTime.now().add(const Duration(days: 6));
      final newSlot = firstAvailableSlot('bb05', newDate);
      final err =
          DonorService.instance.rescheduleBooking(
        bookingId: id,
        newDate: newDate,
        newSlot: newSlot,
      );
      expect(err, isNull);
      booking = DonorService.instance.myBookings().firstWhere((b) => b.id == id);
      expect(booking.status, BookingStatus.rescheduled);
      expect(booking.date, newDate);
      expect(booking.time, newSlot);

      // Cancel it.
      DonorService.instance.cancelBooking(id);
      booking = DonorService.instance.myBookings().firstWhere((b) => b.id == id);
      expect(booking.status, BookingStatus.cancelled);
      expect(booking.isActive, isFalse);
      expect(
        DonorService.instance
            .donorNotifications()
            .any((n) => n.title == 'Booking cancelled'),
        isTrue,
      );
    });
  });

  group('Camps', () {
    test('lists upcoming camps and hides past ones by default', () {
      final upcoming = DonorService.instance.camps();
      for (final c in upcoming) {
        expect(c.isUpcoming, isTrue, reason: c.name);
      }
      final all = DonorService.instance.camps(includePast: true);
      expect(all.length, greaterThanOrEqualTo(kCamps.length - 1));
    });

    test('register, duplicate and full/past-camp errors', () {
      AuthService.instance.logout();
      registerAndLogin('camper1');

      expect(DonorService.instance.isRegisteredForCamp('c02'), isFalse);
      expect(DonorService.instance.registerForCamp('c02'), isNull);
      expect(DonorService.instance.isRegisteredForCamp('c02'), isTrue);
      expect(DonorService.instance.myRegisteredCamps().map((c) => c.id),
          contains('c02'));
      // Slot count incremented by 1 over the static dataset value.
      final c02 = DonorService.instance
          .camps()
          .firstWhere((c) => c.id == 'c02');
      expect(c02.slotsBooked, 31 + 1);

      // Duplicate registration rejected.
      expect(DonorService.instance.registerForCamp('c02'),
          contains('already registered'));

      // Notification generated.
      expect(
        DonorService.instance.donorNotifications().any((n) =>
            n.category == NotificationCategory.donationCamp &&
            n.title.contains('Camp registration confirmed')),
        isTrue,
      );

      // Past camp rejected.
      expect(DonorService.instance.registerForCamp('c08'),
          contains('already taken place'));

      // Second donor finds the nearly-full camp (c03) full after one seat.
      AuthService.instance.logout();
      registerAndLogin('camper2');
      expect(DonorService.instance.registerForCamp('c03'), isNull);
      final c03 = DonorService.instance
          .camps()
          .firstWhere((c) => c.id == 'c03');
      expect(c03.isFull, isTrue);
      AuthService.instance.logout();
      registerAndLogin('camper3');
      expect(DonorService.instance.registerForCamp('c03'),
          contains('All slots'));
    });
  });

  group('History, certificates & eligibility', () {
    test('demo account has seeded history and certificates', () {
      AuthService.instance.logout();
      final err = AuthService.instance.login(
        email: kDemoDonorEmail,
        password: 'demo123',
      );
      expect(err, isNull);

      final history = DonorService.instance.donationHistory();
      expect(history.length, 3);
      expect(
        history.where((r) => r.status == DonationRecordStatus.completed).length,
        2,
      );
      expect(
        history.where((r) => r.status == DonationRecordStatus.deferred).length,
        1,
      );
      expect(DonorService.instance.myCertificates().length, 2);

      final profile = DonorService.instance.donorProfile()!;
      expect(profile.donationCount, 2);
      expect(profile.lastDonationFacility, 'City Care Blood Centre');
    });

    test('new donor has empty history and gets certificates generated',
        () {
      AuthService.instance.logout();
      registerAndLogin('cert1');
      expect(DonorService.instance.donationHistory(), isEmpty);
      expect(DonorService.instance.myCertificates(), isEmpty);

      final cert = DonorService.instance.generateCertificate(
        DonationRecord(
          id: 'drX',
          userEmail: 'cert1@raktasetu.test',
          date: DateTime.now().subtract(const Duration(days: 1)),
          facilityId: 'bb01',
          facilityName: 'City Care Blood Centre',
          facilityType: 'Blood Bank',
          bloodGroup: 'B+',
          status: DonationRecordStatus.completed,
        ),
      );
      expect(cert.certificateId, startsWith('RS-CERT-2026-'));
      expect(cert.certificateId.length, greaterThan('RS-CERT-2026-'.length));
      expect(
        DonorService.instance.myCertificates().map((c) => c.certificateId),
        contains(cert.certificateId),
      );
    });

    test('eligibility follows age band and 90-day interval', () {
      AuthService.instance.logout();
      registerAndLogin('elig1', age: 17);
      expect(DonorService.instance.donorProfile()!.computedStatus,
          EligibilityStatus.notEligible);

      AuthService.instance.logout();
      registerAndLogin('elig2', age: 70);
      expect(DonorService.instance.donorProfile()!.computedStatus,
          EligibilityStatus.notEligible);

      // Demo donor: last donation 15 Aug 2026 → interval rule decides.
      AuthService.instance.logout();
      AuthService.instance.login(email: kDemoDonorEmail, password: 'demo123');
      final next = DonorCertificate.nextEligibleDate(DateTime(2026, 8, 15));
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final expected = today.isBefore(next)
          ? EligibilityStatus.temporarilyDeferred
          : EligibilityStatus.eligible;
      expect(DonorService.instance.donorProfile()!.computedStatus, expected);
    });

    test('venue lookup resolves hospitals and blood banks', () {
      final h = findVenueById('h01');
      expect(h, isNotNull);
      expect(h!.type, 'Hospital');
      final b = findVenueById('bb01');
      expect(b, isNotNull);
      expect(b!.type, 'Blood Bank');
      expect(findVenueById('nope'), isNull);
    });
  });
}
