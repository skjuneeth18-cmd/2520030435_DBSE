/// A monthly (or special) blood donation camp.
class DonationCamp {
  const DonationCamp({
    required this.id,
    required this.name,
    required this.startsAt,
    required this.timeLabel,
    required this.location,
    required this.organizer,
    required this.area,
    required this.city,
    required this.totalSlots,
    required this.slotsBooked,
    required this.bloodGroupsRequired,
    required this.contactPhone,
  });

  /// Organizer contact number shown on the camp detail screen.

  final String id;
  final String name;
  final DateTime startsAt;
  final String timeLabel; // e.g. '9:00 AM – 4:00 PM'
  final String location; // venue / address line
  final String organizer; // NGO / blood bank / association
  final String area;
  final String city;
  final int totalSlots;
  final int slotsBooked;
  final List<String> bloodGroupsRequired;

  /// Organizer contact number shown on the camp detail screen.
  final String contactPhone;

  int get slotsLeft => (totalSlots - slotsBooked).clamp(0, totalSlots);
  bool get isFull => slotsLeft == 0;
  bool get isUpcoming =>
      startsAt.isAfter(DateTime.now()) || _isToday(startsAt);

  static bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  /// "12 Oct 2026 · Mon"
  String get dateLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${startsAt.day} ${months[startsAt.month - 1]} '
        '${startsAt.year} · ${days[startsAt.weekday - 1]}';
  }

  DonationCamp copyWith({int? slotsBooked}) => DonationCamp(
        id: id,
        name: name,
        startsAt: startsAt,
        timeLabel: timeLabel,
        location: location,
        organizer: organizer,
        area: area,
        city: city,
        totalSlots: totalSlots,
        slotsBooked: slotsBooked ?? this.slotsBooked,
        bloodGroupsRequired: bloodGroupsRequired,
        contactPhone: contactPhone,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'startsAt': startsAt.toIso8601String(),
        'timeLabel': timeLabel,
        'location': location,
        'organizer': organizer,
        'area': area,
        'city': city,
        'totalSlots': totalSlots,
        'slotsBooked': slotsBooked,
        'bloodGroupsRequired': bloodGroupsRequired,
        'contactPhone': contactPhone,
      };

  factory DonationCamp.fromMap(Map<String, dynamic> map) => DonationCamp(
        id: map['id'] as String,
        name: map['name'] as String,
        startsAt: DateTime.parse(map['startsAt'] as String),
        timeLabel: map['timeLabel'] as String,
        location: map['location'] as String,
        organizer: map['organizer'] as String,
        area: map['area'] as String,
        city: map['city'] as String? ?? 'Hyderabad',
        totalSlots: map['totalSlots'] as int,
        slotsBooked: map['slotsBooked'] as int,
        bloodGroupsRequired:
            (map['bloodGroupsRequired'] as List<dynamic>).cast<String>(),
        contactPhone: map['contactPhone'] as String,
      );
}

/// One donor's registration for a camp.
class CampRegistration {
  const CampRegistration({
    required this.id,
    required this.userEmail,
    required this.campId,
    required this.registeredAt,
  });

  final String id;
  final String userEmail;
  final String campId;
  final DateTime registeredAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'userEmail': userEmail,
        'campId': campId,
        'registeredAt': registeredAt.toIso8601String(),
      };

  factory CampRegistration.fromMap(Map<String, dynamic> map) =>
      CampRegistration(
        id: map['id'] as String,
        userEmail: map['userEmail'] as String,
        campId: map['campId'] as String,
        registeredAt: DateTime.parse(map['registeredAt'] as String),
      );
}
