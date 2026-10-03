import 'package:flutter/foundation.dart';

import '../data/camps_data.dart';
import '../data/donor_seed_data.dart';
import '../models/app_notification.dart';
import '../models/booking.dart';
import '../models/camp.dart';
import '../models/donation_record.dart';
import '../models/donor.dart';
import '../models/donor_certificate.dart';
import '../models/donor_registry.dart';
import '../services/auth_service.dart';

/// Phase 2 donor service: slot booking, camp registration, history,
/// certificates and donor notifications. All state lives in memory and
/// is seeded with demo data; swap internals for a backend in Phase 6.
class DonorService extends ChangeNotifier {
  DonorService._();
  static final DonorService instance = DonorService._();

  // ---- Backing stores (mock) ----
  final List<DonationBooking> _bookings = [...kDemoBookings];
  final List<DonationRecord> _history = [...kDemoDonationHistory];
  final List<DonorCertificate> _certificates = [...kDemoCertificates];
  final List<CampRegistration> _campRegs = [];
  final List<AppNotification> _donorNotifications = [
    ...kDemoDonorNotifications,
  ];

  // Camp slot counts: campId -> extra bookings made in this session
  // (on top of the static slotsBooked in the camp dataset).
  final Map<String, int> _campExtraBooked = {};
  int _certCounter = 42; // last issued RS-CERT serial

  /// Next unique certificate ID, e.g. RS-CERT-2026-0043.
  String _nextCertificateId() =>
      'RS-CERT-2026-${(++_certCounter).toString().padLeft(4, '0')}';
  int _bkCounter = 2;
  int _drCounter = 4;
  int _regCounter = 1;
  int _dnCounter = 5;

  AuthService get _auth => AuthService.instance;

  String? get _userEmail => _auth.currentUser?.email;

  // ==========================================================
  //  Donor profile / eligibility
  // ==========================================================

  /// Donor view of the logged-in user (null when logged out).
  DonorProfile? donorProfile() {
    final user = _auth.currentUser;
    if (user == null) return null;
    final history = donationHistory();
    final completed = history
        .where((r) => r.status == DonationRecordStatus.completed)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final last = completed.isEmpty ? null : completed.first;
    return DonorProfile(
      user: user,
      age: user.age,
      donationCount: completed.length,
      lastDonationDate: last?.date,
      lastDonationFacility: last?.facilityName,
      eligibility: user.age == null
          ? EligibilityStatus.unknown
          : _computeEligibility(user.age!, last?.date),
    );
  }

  EligibilityStatus _computeEligibility(int age, DateTime? lastDonation) {
    if (age < 18 || age > 65) return EligibilityStatus.notEligible;
    if (lastDonation == null) return EligibilityStatus.eligible;
    final next = DonorCertificate.nextEligibleDate(lastDonation);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.isBefore(next)
        ? EligibilityStatus.temporarilyDeferred
        : EligibilityStatus.eligible;
  }

  /// Date donor becomes eligible again, formatted (null if eligible now).
  String? get nextEligibleLabel {
    final p = donorProfile();
    if (p == null) return null;
    if (p.computedStatus != EligibilityStatus.temporarilyDeferred) {
      return null;
    }
    final d = DonorCertificate.nextEligibleDate(p.lastDonationDate!);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  // ==========================================================
  //  Slot booking
  // ==========================================================

  /// All bookings of the current user, newest first.
  List<DonationBooking> myBookings() {
    final email = _userEmail;
    if (email == null) return [];
    final mine =
        _bookings.where((b) => b.userEmail == email).toList();
    mine.sort((a, b) => b.date.compareTo(a.date));
    return mine;
  }

  /// Active (confirmed/rescheduled) bookings, upcoming first.
  List<DonationBooking> activeBookings() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final active = myBookings().where((b) => b.isActive).toList();
    active.sort((a, b) => a.date.compareTo(b.date));
    return active.where((b) => !b.date.isBefore(today)).toList();
  }

  /// Whether [email] already has an active booking on [date].
  bool hasActiveBookingOn(String email, DateTime date) {
    return _bookings.any((b) =>
        b.userEmail == email &&
        b.isActive &&
        _sameDay(b.date, date));
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Mock per-slot capacity (4 seats/slot) considering this user's own
  /// active bookings, so their own seat shows as taken after booking.
  bool isSlotAvailable({
    required String venueId,
    required DateTime date,
    required String slot,
  }) {
    final email = _userEmail;
    if (email != null) {
      final own = _bookings.any((b) =>
          b.userEmail == email &&
          b.isActive &&
          b.venueId == venueId &&
          _sameDay(b.date, date) &&
          b.time == slot);
      if (own) return false;
    }
    return DonationBooking.isSlotAvailable(
      venueId: venueId,
      date: date,
      slot: slot,
    );
  }

  /// Books a donation slot. Returns an error message or null on success.
  String? bookSlot({
    required String venueId,
    required String venueName,
    required String venueType,
    required String venueArea,
    required DateTime date,
    required String slot,
  }) {
    final user = _auth.currentUser;
    if (user == null) return 'Please log in to book a slot.';
    if (date.isBefore(
        DateTime.now().subtract(const Duration(days: 1)))) {
      return 'Please pick a future date.';
    }
    if (hasActiveBookingOn(user.email, date)) {
      return 'You already have a booking on this date. Cancel or reschedule it first.';
    }
    if (!isSlotAvailable(
        venueId: venueId, date: date, slot: slot)) {
      return 'That slot is full. Please pick another time.';
    }
    final booking = DonationBooking(
      id: 'bk${_bkCounter++}',
      userEmail: user.email,
      venueId: venueId,
      venueName: venueName,
      venueType: venueType,
      venueArea: venueArea,
      date: date,
      time: slot,
      status: BookingStatus.confirmed,
      bloodGroup: user.bloodGroup,
      createdAt: DateTime.now(),
    );
    _bookings.add(booking);
    _addDonorNotification(
      title: 'Slot confirmed at $venueName',
      body:
          'Your donation slot on ${_dateLabel(date)} at $slot is confirmed. Please carry a photo ID and stay hydrated.',
      category: NotificationCategory.slotConfirmation,
      area: venueArea,
    );
    notifyListeners();
    return null;
  }

  /// Cancels a confirmed booking and notifies the donor.
  void cancelBooking(String bookingId) {
    final b = _findBooking(bookingId);
    if (b == null || !b.isActive) return;
    _replaceBooking(b.copyWith(status: BookingStatus.cancelled));
    _addDonorNotification(
      title: 'Booking cancelled',
      body:
          'Your ${b.time} slot at ${b.venueName} on ${_dateLabel(b.date)} was cancelled. You can book a new slot anytime.',
      category: NotificationCategory.donationUpdate,
      area: b.venueArea,
    );
    notifyListeners();
  }

  /// Reschedules a booking to a new date/slot. Returns error or null.
  String? rescheduleBooking({
    required String bookingId,
    required DateTime newDate,
    required String newSlot,
  }) {
    final b = _findBooking(bookingId);
    if (b == null || !b.isActive) return 'Booking not found.';
    if (newDate.isBefore(
        DateTime.now().subtract(const Duration(days: 1)))) {
      return 'Please pick a future date.';
    }
    if (hasActiveBookingOn(b.userEmail, newDate) &&
        !_sameDay(b.date, newDate)) {
      return 'You already have a booking on that date.';
    }
    final moved = b.copyWith(
      date: newDate,
      time: newSlot,
      status: BookingStatus.rescheduled,
    );
    _replaceBooking(moved);
    _addDonorNotification(
      title: 'Booking rescheduled — ${b.venueName}',
      body:
          'Your donation is now on ${_dateLabel(newDate)} at $newSlot (${b.venueName}).',
      category: NotificationCategory.slotConfirmation,
      area: b.venueArea,
    );
    notifyListeners();
    return null;
  }

  DonationBooking? _findBooking(String id) {
    for (var i = 0; i < _bookings.length; i++) {
      if (_bookings[i].id == id) return _bookings[i];
    }
    return null;
  }

  void _replaceBooking(DonationBooking updated) {
    for (var i = 0; i < _bookings.length; i++) {
      if (_bookings[i].id == updated.id) {
        _bookings[i] = updated;
        return;
      }
    }
  }

  // ==========================================================
  //  Donation history + certificates
  // ==========================================================

  /// History of the current user, newest first.
  List<DonationRecord> donationHistory() {
    final email = _userEmail;
    if (email == null) return [];
    final mine =
        _history.where((r) => r.userEmail == email).toList();
    mine.sort((a, b) => b.date.compareTo(a.date));
    return mine;
  }

  List<DonorCertificate> myCertificates() {
    final email = _userEmail;
    if (email == null) return [];
    // Seed certificates carry userEmail; older mock records without one
    // stay visible to their issuer (session-scoped).
    return _certificates
        .where((c) => c.userEmail == null || c.userEmail == email)
    .toList();
  }

  /// Issues a certificate for a completed donation (mock: the demo
  /// account's certificates are pre-seeded; new ones get fresh IDs).
  DonorCertificate generateCertificate(DonationRecord record) {
    final user = _auth.currentUser;
    final cert = DonorCertificate(
      id: 'cert-${_certCounter}_${record.id}',
      certificateId: record.certificateId ?? _nextCertificateId(),
      donorName: user?.fullName ?? 'RaktaSetu Donor',
      bloodGroup: record.bloodGroup,
      donationDate: record.date,
      facilityName: record.facilityName,
      facilityType: record.facilityType,
      issuedAt: DateTime.now(),
      userEmail: user?.email,
    );
    _certificates.add(cert);
    return cert;
  }

  /// Mock: marks a confirmed booking as completed once its date has
  /// passed — creates a history entry + certificate + notification.
  void _completeDueBookings() {
    final user = _auth.currentUser;
    if (user == null) return;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final b in _bookings.where((b) =>
        b.userEmail == user.email &&
        b.isActive &&
        b.date.isBefore(today))) {
      _replaceBooking(b.copyWith(status: BookingStatus.completed));
      final record = DonationRecord(
        id: 'dr${_drCounter++}',
        userEmail: user.email,
        date: b.date,
        facilityId: b.venueId,
        facilityName: b.venueName,
        facilityType: b.venueType,
        bloodGroup: b.bloodGroup ?? user.bloodGroup,
        status: DonationRecordStatus.completed,
        certificateId: _nextCertificateId(),
      );
      _history.add(record);
      generateCertificate(record);
      _addDonorNotification(
        title: 'Thank you for donating ❤️',
        body:
            'Your donation at ${b.venueName} on ${_dateLabel(b.date)} is complete. Your digital certificate is ready.',
        category: NotificationCategory.donationUpdate,
        area: b.venueArea,
      );
    }
  }

  // ==========================================================
  //  Facility admin views (Phase 3)
  // ==========================================================

  /// All active bookings at a facility (any donor) — admin view.
  List<DonationBooking> bookingsForFacility(String facilityId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final list = _bookings
        .where((b) =>
            b.venueId == facilityId &&
            b.isActive &&
            !b.date.isBefore(today))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  /// Completed donation records at a facility — admin "donation records".
  List<DonationRecord> donationRecordsForFacility(String facilityId) {
    final list = _history
        .where((r) => r.facilityId == facilityId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// Mock donor registry for a facility: donors derived from the demo
  /// seed + registered accounts (Phase 3 admin view).
  List<DonorRegistryEntry> donorsForFacility(String facilityId) {
    final entries = <DonorRegistryEntry>[];
    for (final r in _history.where((r) => r.facilityId == facilityId)) {
      entries.add(DonorRegistryEntry(
        name: r.userEmail == kDemoDonorEmail ? 'Demo Donor' : r.userEmail,
        bloodGroup: r.bloodGroup,
        lastDonation: r.date,
        donations: 1,
      ));
    }
    for (final b in _bookings
        .where((b) => b.venueId == facilityId && b.isActive)) {
      if (!entries.any((e) => e.name == b.userEmail)) {
        entries.add(DonorRegistryEntry(
          name: b.userEmail == kDemoDonorEmail ? 'Demo Donor' : b.userEmail,
          bloodGroup: b.bloodGroup ?? '?',
          lastDonation: null,
          donations: 0,
          hasUpcomingSlot: true,
        ));
      }
    }
    return entries;
  }

  // ==========================================================
  //  Camps
  // ==========================================================

  /// Upcoming camps (or all when [includePast]) sorted by date.
  List<DonationCamp> camps({bool includePast = false}) {
    final list = includePast
        ? [...kCamps]
        : kCamps.where((c) => c.isUpcoming).toList();
    list.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return list
        .map((c) => c.copyWith(
            slotsBooked:
                c.slotsBooked + (_campExtraBooked[c.id] ?? 0)))
        .toList();
  }

  /// Camps the current user registered for (upcoming first).
  List<DonationCamp> myRegisteredCamps() {
    final email = _userEmail;
    if (email == null) return [];
    final myCampIds =
        _campRegs.where((r) => r.userEmail == email).map((r) => r.campId);
    final camps =
        kCamps.where((c) => myCampIds.contains(c.id)).toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return camps
        .map((c) => c.copyWith(
            slotsBooked:
                c.slotsBooked + (_campExtraBooked[c.id] ?? 0)))
        .toList();
  }

  bool isRegisteredForCamp(String campId) {
    final email = _userEmail;
    if (email == null) return false;
    return _campRegs
        .any((r) => r.userEmail == email && r.campId == campId);
  }

  /// Registers the current user for [campId]. Returns error or null.
  String? registerForCamp(String campId) {
    final user = _auth.currentUser;
    if (user == null) return 'Please log in to register.';
    final matches = kCamps.where((c) => c.id == campId).toList();
    if (matches.isEmpty) return 'Camp not found.';
    final camp = matches.first;
    if (!camp.isUpcoming) return 'This camp has already taken place.';
    if (isRegisteredForCamp(campId)) {
      return 'You are already registered for this camp.';
    }
    if (camps().firstWhere((c) => c.id == campId).isFull) {
      return 'All slots for this camp are taken.';
    }
    _campRegs.add(CampRegistration(
      id: 'reg${_regCounter++}',
      userEmail: user.email,
      campId: campId,
      registeredAt: DateTime.now(),
    ));
    _campExtraBooked[campId] = (_campExtraBooked[campId] ?? 0) + 1;
    _addDonorNotification(
      title: 'Camp registration confirmed',
      body:
          'You are registered for "${camp.name}" on ${_dateLabel(camp.startsAt)}, ${camp.timeLabel}, at ${camp.location}.',
      category: NotificationCategory.donationCamp,
      area: camp.area,
    );
    notifyListeners();
    return null;
  }

  // ==========================================================
  //  Donor notifications
  // ==========================================================

  /// Donor notifications for the current user (global demo seed +
  /// anything generated this session), newest first.
  List<AppNotification> donorNotifications() {
    final email = _userEmail;
    if (email == null) return [];
    // Mock: seed data belongs to the demo account; session-generated
    // items are already user-tagged by construction.
    return [..._donorNotifications];
  }

  void _addDonorNotification({
    required String title,
    required String body,
    required NotificationCategory category,
    required String area,
  }) {
    _donorNotifications.insert(
      0,
      AppNotification(
        id: 'dn${_dnCounter++}',
        title: title,
        body: body,
        category: category,
        timeAgo: 'just now',
        area: area,
      ),
    );
  }

  /// Called after login/logout so dashboards reflect the right user.
  void refresh() {
    _completeDueBookings();
    notifyListeners();
  }

  static String _dateLabel(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
