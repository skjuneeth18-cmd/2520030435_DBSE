import 'package:flutter/foundation.dart';

import '../data/blood_banks_data.dart';
import '../data/hospitals_data.dart';
import '../models/blood_availability.dart';
import '../models/blood_request.dart';
import '../models/user.dart';
import 'auth_service.dart';

/// Which kind of facility an admin manages (Phase 3).
enum AdminFacilityKind { hospital, bloodBank }

/// The facility a logged-in admin manages.
class AdminFacility {
  const AdminFacility({
    required this.kind,
    required this.id,
    required this.name,
    required this.area,
    required this.address,
    required this.phone,
  });

  final AdminFacilityKind kind;
  final String id;
  final String name;
  final String area;
  final String address;
  final String phone;

  String get kindLabel =>
      kind == AdminFacilityKind.hospital ? 'Hospital' : 'Blood Bank';
}

/// Phase 3 service powering the Hospital and Blood Bank admin
/// dashboards: editable inventory and blood requests. In-memory mock;
/// swap internals for a backend in Phase 6.
class AdminService extends ChangeNotifier {
  AdminService._();
  static final AdminService instance = AdminService._();

  /// Mutable inventory overrides: facilityId -> {group: units}.
  /// Starts empty; values fall through to the Phase 1 deterministic
  /// mock stock so dashboards open with the numbers users already see.
  final Map<String, Map<String, int>> _inventory = {};

  final List<BloodRequest> _requests = [];
  final Set<String> _seededFacilities = {};
  int _reqCounter = 1;

  AuthService get _auth => AuthService.instance;

  // ==========================================================
  //  Facility resolution
  // ==========================================================

  /// The facility the logged-in admin manages (null for donors /
  /// logged-out users / admins without a facility).
  AdminFacility? managedFacility() {
    final user = _auth.currentUser;
    if (user == null || !user.isAdmin) return null;
    final id = user.managedFacilityId;
    if (id == null) return null;
    if (user.role == UserRole.hospitalAdmin) {
      for (final h in kHospitals) {
        if (h.id == id) {
          return AdminFacility(
            kind: AdminFacilityKind.hospital,
            id: h.id,
            name: h.name,
            area: h.area,
            address: h.address,
            phone: h.phone,
          );
        }
      }
    } else if (user.role == UserRole.bloodBankAdmin) {
      for (final b in kBloodBanks) {
        if (b.id == id) {
          return AdminFacility(
            kind: AdminFacilityKind.bloodBank,
            id: b.id,
            name: b.name,
            area: b.area,
            address: b.address,
            phone: b.phone,
          );
        }
      }
    }
    return null;
  }

  // ==========================================================
  //  Inventory
  // ==========================================================

  /// Live inventory for a facility: admin overrides win over the mock
  /// seed derived from the facility's Phase 1 stock snapshot.
  List<BloodAvailability> inventory(String facilityId) {
    final seed = _seedStock(facilityId);
    final overrides = _inventory[facilityId];
    if (overrides == null) return seed.entries;
    return [
      for (final e in seed.entries)
        overrides.containsKey(e.bloodGroup)
            ? BloodAvailability(
                bloodGroup: e.bloodGroup,
                units: overrides[e.bloodGroup]!,
                status: statusForUnits(overrides[e.bloodGroup]!),
              )
            : e,
    ];
  }

  /// Total units currently in stock at a facility.
  int totalUnits(String facilityId) => inventory(facilityId)
      .fold(0, (sum, e) => sum + e.units);

  static StockStatus statusForUnits(int units) {
    if (units == 0) return StockStatus.unavailable;
    if (units <= 3) return StockStatus.limited;
    return StockStatus.available;
  }

  FacilityStock _seedStock(String facilityId) {
    for (final h in kHospitals) {
      if (h.id == facilityId) return h.stock;
    }
    for (final b in kBloodBanks) {
      if (b.id == facilityId) return b.stock;
    }
    return FacilityStock.mock(facilityId.hashCode.abs());
  }

  /// Admin sets the unit count of one blood group.
  void updateUnits({
    required String facilityId,
    required String bloodGroup,
    required int units,
  }) {
    final map = _inventory.putIfAbsent(facilityId, () => {});
    map[bloodGroup] = units.clamp(0, 999);
    notifyListeners();
  }

  // ==========================================================
  //  Blood requests
  // ==========================================================

  /// Requests raised to a facility, critical first. Seeds deterministic
  /// mock requests on first access so dashboards have content.
  List<BloodRequest> requestsFor(String facilityId) {
    if (!_seededFacilities.contains(facilityId)) {
      _seedRequests(facilityId);
      _seededFacilities.add(facilityId);
    }
    final list =
        _requests.where((r) => r.facilityId == facilityId).toList();
    const order = {
      RequestPriority.critical: 0,
      RequestPriority.urgent: 1,
      RequestPriority.routine: 2,
    };
    list.sort((a, b) {
      final p = order[a.priority]!.compareTo(order[b.priority]!);
      if (p != 0) return p;
      return b.requestedOn.compareTo(a.requestedOn);
    });
    return list;
  }

  void _seedRequests(String facilityId) {
    final facilityName = _facilityName(facilityId);
    const requesters = [
      'Ward 4 (IPD)', 'ICU', 'Casualty', 'OT — Dr. Rao', 'Dialysis Unit',
    ];
    final h = _stableHash(facilityId);
    final now = DateTime.now();
    final count = 3 + h % 2; // 3–4 requests per facility
    for (var i = 0; i < count; i++) {
      final v = h + i * 97;
      _requests.add(BloodRequest(
        id: 'br-$facilityId-$i',
        facilityId: facilityId,
        facilityName: facilityName,
        requesterName: requesters[v % requesters.length],
        bloodGroup: FacilityStock.allGroups[(v ~/ 7) % 8],
        units: 1 + (v ~/ 13) % 3,
        priority: RequestPriority
            .values[(v ~/ 3) % 3], // routine / urgent / critical
        status: RequestStatus.pending,
        requestedOn:
            now.subtract(Duration(days: (v ~/ 11) % 4, hours: i * 3)),
      ));
    }
    _reqCounter += count;
  }

  String _facilityName(String facilityId) {
    for (final h in kHospitals) {
      if (h.id == facilityId) return h.name;
    }
    for (final b in kBloodBanks) {
      if (b.id == facilityId) return b.name;
    }
    return 'Facility';
  }

  /// Fulfils a request: decrements that blood group in inventory.
  /// Returns an error message or null on success.
  String? fulfilRequest(String requestId) {
    final idx = _requests.indexWhere((r) => r.id == requestId);
    if (idx == -1) return 'Request not found.';
    final r = _requests[idx];
    if (r.status != RequestStatus.pending) {
      return 'This request has already been processed.';
    }
    final current = inventory(r.facilityId);
    final entry = current
        .where((e) => e.bloodGroup == r.bloodGroup)
        .firstOrNull;
    final available = entry?.units ?? 0;
    if (available < r.units) {
      return 'Only $available unit(s) of ${r.bloodGroup} in stock. '
          'Update inventory first.';
    }
    updateUnits(
      facilityId: r.facilityId,
      bloodGroup: r.bloodGroup,
      units: available - r.units,
    );
    _requests[idx] = r.copyWith(status: RequestStatus.fulfilled);
    notifyListeners();
    return null;
  }

  /// Rejects a pending request.
  String? rejectRequest(String requestId) {
    final idx = _requests.indexWhere((r) => r.id == requestId);
    if (idx == -1) return 'Request not found.';
    if (_requests[idx].status != RequestStatus.pending) {
      return 'This request has already been processed.';
    }
    _requests[idx] = _requests[idx].copyWith(status: RequestStatus.rejected);
    notifyListeners();
    return null;
  }

  /// A user raises a new request to a facility (Phase 3 user feature).
  String? raiseRequest({
    required String facilityId,
    required String facilityName,
    required String bloodGroup,
    required int units,
    RequestPriority priority = RequestPriority.urgent,
  }) {
    final user = _auth.currentUser;
    if (user == null) return 'Please log in to raise a request.';
    if (!FacilityStock.allGroups.contains(bloodGroup)) {
      return 'Pick a valid blood group.';
    }
    if (units < 1 || units > 10) {
      return 'Units must be between 1 and 10.';
    }
    if (!_seededFacilities.contains(facilityId)) {
      _seedRequests(facilityId);
      _seededFacilities.add(facilityId);
    }
    _requests.insert(
      0,
      BloodRequest(
        id: 'br${_reqCounter++}',
        facilityId: facilityId,
        facilityName: facilityName,
        requesterName: user.fullName,
        bloodGroup: bloodGroup,
        units: units,
        priority: priority,
        status: RequestStatus.pending,
        requestedOn: DateTime.now(),
      ),
    );
    notifyListeners();
    return null;
  }

  static int _stableHash(String s) {
    var h = 0;
    for (final c in s.codeUnits) {
      h = (h * 31 + c) & 0x3FFFFFFF;
    }
    return h;
  }
}
