import '../data/blood_banks_data.dart';
import '../data/hospitals_data.dart';
import '../data/requirements_data.dart';
import '../models/blood_availability.dart';
import '../models/blood_bank.dart';
import '../models/booking.dart';
import '../models/blood_requirement.dart';
import '../models/hospital.dart';

/// A generic facility row shown by the Find Blood screen.
class FacilityRow {
  const FacilityRow({
    required this.id,
    required this.name,
    required this.type,
    required this.area,
    required this.phone,
    required this.stock,
    required this.isVerified,
  });

  final String id;
  final String name;
  final String type; // 'Hospital' | 'Blood Bank'
  final String area;
  final String phone;
  final FacilityStock stock;
  final bool isVerified;
}

/// Central read API over Phase 1 mock data. Replace internals with
/// repository/network calls in later phases without touching the UI.
class BloodService {
  BloodService._();
  static final BloodService instance = BloodService._();

  List<Hospital> get hospitals => List.unmodifiable(kHospitals);

  Hospital? hospitalById(String id) {
    for (final h in kHospitals) {
      if (h.id == id) return h;
    }
    return null;
  }

  /// Blood bank by id (null if not found).
  BloodBank? bloodBankById(String id) {
    for (final b in kBloodBanks) {
      if (b.id == id) return b;
    }
    return null;
  }

  List<BloodBank> get bloodBanks => List.unmodifiable(kBloodBanks);

  /// Hospitals sorted by rating (Top-10 style list).
  List<Hospital> topHospitals({int limit = 10}) {
    final sorted = [...kHospitals]..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(limit).toList();
  }

  /// Area-wise requirements, critical first, then by units needed.
  List<BloodRequirement> requirements({
    String? area,
    EmergencyLevel? level,
    bool openOnly = true,
  }) {
    var list = kRequirements.where((r) {
      if (openOnly && r.status != RequirementStatus.open) return false;
      if (area != null && area.isNotEmpty && r.area != area) return false;
      if (level != null && r.emergencyLevel != level) return false;
      return true;
    }).toList();
    const rank = {
      EmergencyLevel.critical: 0,
      EmergencyLevel.urgent: 1,
      EmergencyLevel.normal: 2,
    };
    list.sort((a, b) {
      final c = rank[a.emergencyLevel]!.compareTo(rank[b.emergencyLevel]!);
      return c != 0 ? c : b.unitsNeeded.compareTo(a.unitsNeeded);
    });
    return list;
  }

  /// Facilities that have [group] in stock (Available or Limited),
  /// optionally filtered by area / facility type / specific facility name.
  /// Pass [includeUnavailable] to also receive out-of-stock facilities.
  List<FacilityRow> findFacilitiesWithBlood({
    required String group,
    String? area,
    String? facilityType, // null/'' = both
    String? facilityName,
    bool includeUnavailable = false,
  }) {
    final rows = <FacilityRow>[];
    final wantType = (facilityType == null || facilityType.isEmpty)
        ? null
        : facilityType;

    if (wantType == null || wantType == 'Hospital') {
      for (final h in kHospitals) {
        if (!h.hasBloodBank) continue;
        if (area != null && area.isNotEmpty && h.area != area) continue;
        if (facilityName != null &&
            facilityName.isNotEmpty &&
            h.name != facilityName) {
          continue;
        }
        final e = h.stock.forGroup(group);
        if (e == null) continue;
        if (!includeUnavailable && e.status == StockStatus.unavailable) {
          continue;
        }
        rows.add(FacilityRow(
          id: h.id,
          name: h.name,
          type: 'Hospital',
          area: h.area,
          phone: h.phone,
          stock: h.stock,
          isVerified: h.isVerified,
        ));
      }
    }
    if (wantType == null || wantType == 'Blood Bank') {
      for (final b in kBloodBanks) {
        if (area != null && area.isNotEmpty && b.area != area) continue;
        if (facilityName != null &&
            facilityName.isNotEmpty &&
            b.name != facilityName) {
          continue;
        }
        final e = b.stock.forGroup(group);
        if (e == null) continue;
        if (!includeUnavailable && e.status == StockStatus.unavailable) {
          continue;
        }
        rows.add(FacilityRow(
          id: b.id,
          name: b.name,
          type: 'Blood Bank',
          area: b.area,
          phone: b.phone,
          stock: b.stock,
          isVerified: b.isVerified,
        ));
      }
    }
    // Available first, then Limited; within same status more units first.
    rows.sort((a, b) {
      final ea = a.stock.forGroup(group)!;
      final eb = b.stock.forGroup(group)!;
      final s = ea.status.index.compareTo(eb.status.index);
      return s != 0 ? s : eb.units.compareTo(ea.units);
    });
    return rows;
  }

  /// All facilities that accept donation slot bookings (Phase 2),
  /// sorted by area name; optionally filtered to one area.
  List<BookingVenue> bookableFacilities({String? area}) {
    final venues = <BookingVenue>[
      for (final h in kHospitals)
        BookingVenue(
          id: h.id,
          name: h.name,
          type: 'Hospital',
          area: h.area,
          address: h.address,
          phone: h.phone,
        ),
      for (final b in kBloodBanks)
        BookingVenue(
          id: b.id,
          name: b.name,
          type: 'Blood Bank',
          area: b.area,
          address: b.address,
          phone: b.phone,
        ),
    ];
    final filtered = (area == null || area.isEmpty)
        ? venues
        : venues.where((v) => v.area == area).toList();
    filtered.sort((a, b) => a.area.compareTo(b.area));
    return filtered;
  }
}
