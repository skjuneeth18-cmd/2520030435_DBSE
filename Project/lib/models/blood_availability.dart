/// Availability status of a blood group at a facility.
enum StockStatus { available, limited, unavailable }

extension StockStatusX on StockStatus {
  String get label => switch (this) {
        StockStatus.available => 'Available',
        StockStatus.limited => 'Limited',
        StockStatus.unavailable => 'Unavailable',
      };
}

/// A single blood group's stock entry at one facility.
class BloodAvailability {
  const BloodAvailability({
    required this.bloodGroup,
    required this.status,
    required this.units,
  });

  final String bloodGroup; // 'A+', 'A-', ... 'O-'
  final StockStatus status;
  final int units;
}

/// A record of one facility's full stock snapshot.
class FacilityStock {
  const FacilityStock({required this.entries});

  final List<BloodAvailability> entries;

  static const List<String> allGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

  BloodAvailability? forGroup(String group) {
    for (final e in entries) {
      if (e.bloodGroup == group) return e;
    }
    return null;
  }

  /// Creates a deterministic pseudo-random snapshot for mock data.
  static FacilityStock mock(int seed) {
    final entries = <BloodAvailability>[];
    for (var i = 0; i < allGroups.length; i++) {
      final v = (seed * 31 + i * 17) % 10; // 0..9 deterministic
      final StockStatus status;
      final int units;
      if (v >= 6) {
        status = StockStatus.available;
        units = 8 + (seed + i) % 25;
      } else if (v >= 3) {
        status = StockStatus.limited;
        units = 1 + (seed + i) % 3;
      } else {
        status = StockStatus.unavailable;
        units = 0;
      }
      entries.add(
        BloodAvailability(bloodGroup: allGroups[i], status: status, units: units),
      );
    }
    return FacilityStock(entries: entries);
  }
}
