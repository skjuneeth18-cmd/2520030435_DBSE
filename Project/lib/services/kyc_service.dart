import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/benefits_data.dart';
import '../models/benefit.dart';
import '../models/coupon.dart';
import '../models/donor_verification.dart';
import '../models/kyc.dart';
import '../models/user.dart';
import 'auth_service.dart';

/// Manages KYC, donor verification, benefits and coupons (Phase 4).
///
/// Sensitive identity data is kept intentionally minimal in this mock:
/// only a masked Aadhaar suffix and a secure reference are retained,
/// never the raw Aadhaar number. In a real deployment these fields would
/// live in a compliant, encrypted store behind an authorized KYC provider.
class KYCService extends ChangeNotifier {
  KYCService._() {
    _seedDemoDonor();
  }

  static final KYCService instance = KYCService._();

  final Map<String, KYCRecord> _kycRecords = {};
  final Map<String, DonorVerification> _verifications = {};
  final List<Coupon> _coupons = [];

  static const String _codeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  // ---- KYC (per-user) ----

  KYCRecord? getKYCRecord(String userId) => _kycRecords[userId];

  /// All KYC records, newest submission first (admin queue).
  List<KYCRecord> getKYCRecords() {
    final records = _kycRecords.values.toList()
      ..sort((a, b) => b.submissionDate.compareTo(a.submissionDate));
    return List.unmodifiable(records);
  }

  /// Records still awaiting review.
  int get pendingKYCCount =>
      _kycRecords.values.where((r) => r.status == KYCStatus.pending).length;

  /// Starts KYC for the current user with a masked Aadhaar reference.
  ///
  /// In a real app this would upload documents to the KYC provider;
  /// here the donor enters a masked Aadhaar suffix and the record is
  /// created as [KYCStatus.pending] for admin review.
  String? submitKYC({
    required String aadhaarLast4Masked,
    String? notes,
  }) {
    final user = AuthService.instance.currentUser;
    if (user == null) return 'Please log in to apply for KYC.';

    final normalized = aadhaarLast4Masked.replaceAll(RegExp(r'\s+'), '');
    if (!RegExp(r'^XXXX-\d{4}$').hasMatch(normalized)) {
      return 'Enter Aadhaar as XXXX-1234 (last 4 digits only).';
    }

    _kycRecords[user.id] = KYCRecord(
      userId: user.id,
      aadhaarLast4Masked: normalized,
      submissionDate: DateTime.now(),
      status: KYCStatus.pending,
      notes: notes,
    );
    notifyListeners();
    return null;
  }

  /// Reverts a pending KYC submission (donor-only self-service).
  bool cancelKYC() {
    final user = AuthService.instance.currentUser;
    if (user == null) return false;
    final record = _kycRecords[user.id];
    if (record == null || record.status != KYCStatus.pending) return false;
    _kycRecords.remove(user.id);
    notifyListeners();
    return true;
  }

  /// Admin: review a KYC record.
  String? reviewKYC(String userId, KYCStatus newStatus, String? reviewerNote) {
    final record = _kycRecords[userId];
    if (record == null) return 'No KYC record found for this user.';
    if (record.status == KYCStatus.verified && newStatus != KYCStatus.verified) {
      return 'Already verified KYC cannot be moved to another state.';
    }
    if (newStatus == KYCStatus.pending) {
      return 'Cannot set KYC status back to pending from review.';
    }
    final updated = record.copyWith(
      status: newStatus,
      notes: record.notes != null
          ? '${record.notes}\n[Reviewed: ${DateTime.now()}] reviewerNote'
          : '[Reviewed: ${DateTime.now()}] reviewerNote',
    );
    _kycRecords[userId] = updated;
    notifyListeners();
    return null;
  }

  // ---- Donor verification (separate from KYC) ----

  DonorVerificationStatus getDonorVerification(String userId) {
    return _verifications[userId]?.status ?? DonorVerificationStatus.pending;
  }

  /// Admin: verify or reject a donor record.
  String? verifyDonor(String userId, DonorVerificationStatus newStatus) {
    final user = _findUserById(userId);
    if (user == null) return 'User not found.';
    if (newStatus == DonorVerificationStatus.pending) {
      return 'Cannot set donor status back to pending.';
    }
    _verifications[userId] = DonorVerification(
      userId: userId,
      status: newStatus,
      verifiedAt: newStatus == DonorVerificationStatus.verified
          ? DateTime.now()
          : null,
      note: newStatus == DonorVerificationStatus.verified
          ? 'Verified by admin'
          : 'Reviewed by admin',
    );
    notifyListeners();
    return null;
  }

  /// Recompute donor verification eligibility from profile + history.
  /// Called by admins and also surfaced on the donor dashboard.
  bool isDonorFullyVerified(String userId) {
    final user = _findUserById(userId);
    if (user == null) return false;
    final kyc = _kycRecords[userId];
    if (kyc == null || kyc.status != KYCStatus.verified) return false;
    final dv = _verifications[userId];
    if (dv == null || dv.status != DonorVerificationStatus.verified) return false;
    return true;
  }

  // ---- Coupons ----

  List<Coupon> getCouponsForUser(String userId) {
    return _coupons.where((c) => c.issuedToUserId == userId).toList()
      ..sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
  }

  Coupon? getCoupon(String couponId) {
    try {
      return _coupons.firstWhere((c) => c.id == couponId);
    } catch (_) {
      return null;
    }
  }

  /// Generate a coupon for a verified donor.
  ///
  /// Returns the created coupon or an error message string.
  Object generateCoupon({
    required String userId,
    required String participatingHospitalId,
    required BenefitType benefitType,
    required int discountPercent,
    int? maxDiscount,
    int validityDays = 90,
  }) {
    final user = _findUserById(userId);
    if (user == null) {
      return 'User not found.';
    }
    if (isDonorFullyVerified(userId) == false) {
      return 'Only verified donors can receive coupons.';
    }
    if (discountPercent < 0 || discountPercent > 100) {
      return 'Discount percent must be 0..100.';
    }
    final validUntil = DateTime.now().add(Duration(days: validityDays));
    final code = _generateCouponCode();
    final coupon = Coupon(
      id: 'cp${_coupons.length + 1}',
      code: code,
      title: _couponTitle(benefitType),
      description: _couponDescription(benefitType, discountPercent, maxDiscount),
      benefitType: benefitType,
      discountPercent: discountPercent,
      maxDiscount: maxDiscount,
      participatingHospitalId: participatingHospitalId,
      issuedToUserId: userId,
      issuedAt: DateTime.now(),
      validUntil: validUntil,
    );
    _coupons.add(coupon);
    notifyListeners();
    return coupon;
  }

  /// Mark a coupon as used at a hospital.
  String? useCoupon(String couponId, String hospitalId) {
    final coupon = getCoupon(couponId);
    if (coupon == null) return 'Coupon not found.';
    if (coupon.isUsed) return 'Coupon already used.';
    if (coupon.isExpired) return 'Coupon has expired.';
    if (coupon.participatingHospitalId != hospitalId) {
      return 'This coupon is valid only at the listed participating hospital.';
    }
    final updated = coupon.copyWith(
      status: CouponStatus.used,
      usedAt: DateTime.now(),
      usedAtHospitalId: hospitalId,
    );
    _coupons[_coupons.indexOf(coupon)] = updated;
    notifyListeners();
    return null;
  }

  /// Admin: revoke a coupon.
  String? revokeCoupon(String couponId) {
    final idx =
        _coupons.indexWhere((c) => c.id == couponId);
    if (idx < 0) return 'Coupon not found.';
    if (_coupons[idx].status == CouponStatus.used) {
      return 'Cannot revoke an already used coupon.';
    }
    _coupons[idx] = _coupons[idx].copyWith(status: CouponStatus.revoked);
    notifyListeners();
    return null;
  }

  // ---- Benefits (admin CRUD) ----

  /// All benefits: the seeded ones plus any admin-created/edited ones.
  List<Benefit> getBenefits() {
    final merged = <String, Benefit>{
      for (final b in kBenefits) b.id: b,
    };
    merged.addAll(_adminBenefits);
    return List.unmodifiable(merged.values);
  }

  List<Benefit> getActiveBenefits() =>
      getBenefits().where((b) => b.isActive).toList();

  List<Benefit> getBenefitsForHospital(String hospitalId) =>
      getBenefits().where((b) => b.isAvailableForHospital(hospitalId)).toList();

  String? addBenefit(Benefit benefit) {
    // Simple duplicate-id guard for the mock.
    if (getBenefits().any((b) => b.id == benefit.id)) {
      return 'A benefit with this ID already exists.';
    }
    // Admin edits live in a mutable mirror that [getBenefits] merges over
    // the read-only seed list.
    _adminBenefits[benefit.id] = benefit;
    notifyListeners();
    return null;
  }

  String? updateBenefit(String id, Benefit updated) {
    if (!getBenefits().any((b) => b.id == id)) {
      return 'Benefit not found.';
    }
    _adminBenefits[id] = updated;
    notifyListeners();
    return null;
  }

  String? deleteBenefit(String id) {
    final seeded = kBenefits.where((b) => b.id == id).firstOrNull;
    final custom = _adminBenefits[id];
    if (seeded == null && custom == null) {
      return 'Benefit not found.';
    }
    // Seeded benefits are retired rather than removed: pushing isValidUntil
    // into the past drops them out of the active list.
    if (seeded != null) {
      _adminBenefits[id] = seeded.copyWith(
        isValidUntil: DateTime.now().subtract(const Duration(days: 1)),
      );
    } else {
      _adminBenefits.remove(id);
    }
    notifyListeners();
    return null;
  }

  // ---- Participating hospitals (read from seed) ----

  List<ParticipatingHospital> getParticipatingHospitals() =>
      List.unmodifiable(kParticipatingHospitals);

  void _seedDemoDonor() {
    const demoId = 'u0';
    _kycRecords[demoId] = KYCRecord(
      userId: demoId,
      aadhaarLast4Masked: 'XXXX-0000',
      submissionDate: DateTime(2026, 9, 1),
      status: KYCStatus.verified,
      notes: 'Verified during onboarding.',
    );
    _verifications[demoId] = DonorVerification(
      userId: demoId,
      status: DonorVerificationStatus.verified,
      verifiedAt: DateTime(2026, 9, 1),
      note: 'Verified by admin',
    );
    _coupons.add(Coupon(
      id: 'cp_demo_active',
      code: 'RAKTA-AB12',
      title: 'Doctor Consultation Discount Coupon',
      description: 'Get 20% off on doctor consultation fees at City Care Hospital.',
      benefitType: BenefitType.consultationDiscount,
      discountPercent: 20,
      participatingHospitalId: 'h01',
      issuedToUserId: demoId,
      issuedAt: DateTime(2026, 9, 10),
      validUntil: DateTime(2027, 1, 10),
    ));
    _coupons.add(Coupon(
      id: 'cp_demo_used',
      code: 'RAKTA-CD34',
      title: 'Free Checkup Coupon',
      description: 'Redeem for a free health checkup at City Care Hospital.',
      benefitType: BenefitType.freeCheckup,
      discountPercent: 100,
      participatingHospitalId: 'h01',
      issuedToUserId: demoId,
      issuedAt: DateTime(2026, 8, 1),
      validUntil: DateTime(2027, 1, 1),
      usedAt: DateTime(2026, 9, 5),
      usedAtHospitalId: 'h01',
      status: CouponStatus.used,
    ));
  }

  // ---- internal helpers ----

  AppUser? _findUserById(String id) => AuthService.instance.userById(id);

  String _generateCouponCode() {
    final rand = Random(DateTime.now().millisecondsSinceEpoch);
    final first = String.fromCharCode(
      _codeAlphabet.codeUnitAt(rand.nextInt(_codeAlphabet.length)),
    );
    final second = String.fromCharCode(
      _codeAlphabet.codeUnitAt(rand.nextInt(_codeAlphabet.length)),
    );
    final digits =
        String.fromCharCodes(
          List.generate(4, (_) => rand.nextInt(10) + 48),
        );
    return 'RAKTA-$first$second$digits';
  }

  String _couponTitle(BenefitType type) => switch (type) {
        BenefitType.freeCheckup => 'Free Checkup Coupon',
        BenefitType.consultationDiscount => 'Consultation Discount Coupon',
        BenefitType.diagnosticDiscount => 'Diagnostic Discount Coupon',
        BenefitType.partnerHospitalBenefit => 'Partner Hospital Benefit Coupon',
      };

  String _couponDescription(BenefitType type, int discount, int? maxDiscount) {
    final base = switch (type) {
      BenefitType.freeCheckup => 'Redeem for a free health checkup at the participating hospital.',
      BenefitType.consultationDiscount => 'Get $discount% off on doctor consultation fees.',
      BenefitType.diagnosticDiscount => 'Get $discount% off on diagnostic tests.',
      BenefitType.partnerHospitalBenefit => 'Priority access benefit at the participating facility.',
    };
    if (maxDiscount != null && discount > 0) {
      return '$base (max ₹$maxDiscount off).';
    }
    return base;
  }

  /// Admin-side mutable mirror for benefits created/edited in the UI.
  final Map<String, Benefit> _adminBenefits = {};

  /// All coupons, newest first (admin view).
  List<Coupon> getAllCoupons() {
    final list = [..._coupons]
      ..sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
    return List.unmodifiable(list);
  }

  /// Coupons are stored inside KYCService so the admin screen can manage
  /// them directly. Donor screen reads via [getCouponsForUser].

  /// Admin eligibility: can this admin manage KYC (hospital admin only)?
  bool get canManageKYC =>
      AuthService.instance.currentUser?.role == UserRole.hospitalAdmin;
}

/// A donor's KYC record.
class KYCRecord {
  const KYCRecord({
    required this.userId,
    required this.aadhaarLast4Masked,
    required this.submissionDate,
    this.status = KYCStatus.pending,
    this.notes,
  });

  final String userId;
  final String aadhaarLast4Masked;
  final DateTime submissionDate;
  final KYCStatus status;
  final String? notes;

  /// Opaque reference shown instead of any raw identity number.
  String get secureRef =>
      'ID-${submissionDate.millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond}';

  KYCRecord copyWith({
    String? userId,
    String? aadhaarLast4Masked,
    DateTime? submissionDate,
    KYCStatus? status,
    String? notes,
  }) {
    return KYCRecord(
      userId: userId ?? this.userId,
      aadhaarLast4Masked: aadhaarLast4Masked ?? this.aadhaarLast4Masked,
      submissionDate: submissionDate ?? this.submissionDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'aadhaarLast4Masked': aadhaarLast4Masked,
        'submissionDate': submissionDate.toIso8601String(),
        'status': status.name,
        'notes': notes,
      };

  factory KYCRecord.fromMap(Map<String, dynamic> map) {
    return KYCRecord(
      userId: map['userId'] as String,
      aadhaarLast4Masked: map['aadhaarLast4Masked'] as String,
      submissionDate: DateTime.parse(map['submissionDate'] as String),
      status: KYCStatus.values.firstWhere(
        (s) => s.name == (map['status'] as String?),
        orElse: () => KYCStatus.pending,
      ),
      notes: map['notes'] as String?,
    );
  }
}

/// Donor verification record (separate from KYC record).
class DonorVerification {
  const DonorVerification({
    required this.userId,
    required this.status,
    this.verifiedAt,
    this.note,
  });

  final String userId;
  final DonorVerificationStatus status;
  final DateTime? verifiedAt;
  final String? note;

  DonorVerification copyWith({
    String? userId,
    DonorVerificationStatus? status,
    DateTime? verifiedAt,
    String? note,
  }) {
    return DonorVerification(
      userId: userId ?? this.userId,
      status: status ?? this.status,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'status': status.name,
        'verifiedAt': verifiedAt?.toIso8601String(),
        'note': note,
      };

  factory DonorVerification.fromMap(Map<String, dynamic> map) {
    return DonorVerification(
      userId: map['userId'] as String,
      status: DonorVerificationStatus.values.firstWhere(
        (s) => s.name == (map['status'] as String?),
        orElse: () => DonorVerificationStatus.pending,
      ),
      verifiedAt: map['verifiedAt'] != null
          ? DateTime.parse(map['verifiedAt'] as String)
          : null,
      note: map['note'] as String?,
    );
  }
}
