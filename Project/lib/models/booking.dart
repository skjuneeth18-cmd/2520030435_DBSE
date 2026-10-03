import '../data/hospitals_data.dart';
import '../data/blood_banks_data.dart';

/// Venue where a donation slot can be booked (hospital or blood bank).
class BookingVenue {
  const BookingVenue({
    required this.id,
    required this.name,
    required this.type, // 'Hospital' | 'Blood Bank'
    required this.area,
    required this.address,
    required this.phone,
  });

  final String id;
  final String name;
  final String type;
  final String area;
  final String address;
  final String phone;

  String get addressLine => '$address, $area, Hyderabad';
}

/// Status of a donation slot booking.
enum BookingStatus { confirmed, completed, cancelled, rescheduled }

extension BookingStatusX on BookingStatus {
  String get label => switch (this) {
        BookingStatus.confirmed => 'Confirmed',
        BookingStatus.completed => 'Completed',
        BookingStatus.cancelled => 'Cancelled',
        BookingStatus.rescheduled => 'Rescheduled',
      };

  String get emoji => switch (this) {
        BookingStatus.confirmed => '🕘',
        BookingStatus.completed => '✅',
        BookingStatus.cancelled => '❌',
        BookingStatus.rescheduled => '🔁',
      };
}

/// Everything the app knows about a donation appointment.
class DonationBooking {
  const DonationBooking({
    required this.id,
    required this.userEmail,
    required this.venueId,
    required this.venueName,
    required this.venueType,
    required this.venueArea,
    required this.date,
    required this.time,
    required this.status,
    this.bloodGroup,
    this.createdAt,
  });

  final String id;
  final String userEmail; // owner of the booking
  final String venueId;
  final String venueName;
  final String venueType; // 'Hospital' | 'Blood Bank'
  final String venueArea;
  final DateTime date;
  final String time; // slot label, e.g. '10:00 AM'
  final BookingStatus status;
  final String? bloodGroup; // donor group at booking time
  final DateTime? createdAt;

  bool get isActive =>
      status == BookingStatus.confirmed ||
      status == BookingStatus.rescheduled;

  bool get isUpcoming =>
      isActive &&
      !date.isBefore(DateTime(date.year, date.month, date.day));

  /// Every slot offered for donation (9 AM – 4 PM, hourly, incl. lunch gap).
  static const List<String> kTimeSlots = [
    '09:00 AM', '10:00 AM', '11:00 AM', '12:00 PM',
    '02:00 PM', '03:00 PM', '04:00 PM',
  ];

  /// Deterministic mock capacity per (venue, date, slot): 0–3 seats taken.
  static int mockTakenSeats({
    required String venueId,
    required DateTime date,
    required String slot,
  }) {
    final dayNum = date.year * 10000 + date.month * 100 + date.day;
    final slotNum = kTimeSlots.indexOf(slot);
    final v = (_stableHash(venueId) * 7 + dayNum * 13 + slotNum * 29).abs();
    return v % 4; // 0..3 taken out of 4 seats per slot
  }

  /// Stable string hash (String.hashCode is randomized per isolate).
  static int _stableHash(String s) {
    var h = 0;
    for (final c in s.codeUnits) {
      h = (h * 31 + c) & 0x3FFFFFFF;
    }
    return h;
  }

  /// True when at least one of the 4 seats per slot is free.
  static bool isSlotAvailable({
    required String venueId,
    required DateTime date,
    required String slot,
  }) =>
      mockTakenSeats(venueId: venueId, date: date, slot: slot) < 3;

  DonationBooking copyWith({
    DateTime? date,
    String? time,
    BookingStatus? status,
  }) {
    return DonationBooking(
      id: id,
      userEmail: userEmail,
      venueId: venueId,
      venueName: venueName,
      venueType: venueType,
      venueArea: venueArea,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      bloodGroup: bloodGroup,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userEmail': userEmail,
        'venueId': venueId,
        'venueName': venueName,
        'venueType': venueType,
        'venueArea': venueArea,
        'date': date.toIso8601String(),
        'time': time,
        'status': status.name,
        'bloodGroup': bloodGroup,
      };

  factory DonationBooking.fromMap(Map<String, dynamic> map) => DonationBooking(
        id: map['id'] as String,
        userEmail: map['userEmail'] as String,
        venueId: map['venueId'] as String,
        venueName: map['venueName'] as String,
        venueType: map['venueType'] as String,
        venueArea: map['venueArea'] as String,
        date: DateTime.parse(map['date'] as String),
        time: map['time'] as String,
        status: BookingStatus.values.byName(map['status'] as String),
        bloodGroup: map['bloodGroup'] as String?,
      );
}

/// Lookup helper: find a venue record by id from Phase 1 mock facilities.
BookingVenue? findVenueById(String venueId) {
  for (final h in kHospitals) {
    if (h.id == venueId) {
      return BookingVenue(
        id: h.id,
        name: h.name,
        type: 'Hospital',
        area: h.area,
        address: h.address,
        phone: h.phone,
      );
    }
  }
  for (final b in kBloodBanks) {
    if (b.id == venueId) {
      return BookingVenue(
        id: b.id,
        name: b.name,
        type: 'Blood Bank',
        area: b.area,
        address: b.address,
        phone: b.phone,
      );
    }
  }
  return null;
}
