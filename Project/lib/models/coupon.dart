import '../models/benefit.dart';

/// A coupon generated for a verified donor (Phase 4).
class Coupon {
  const Coupon({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.benefitType,
    required this.discountPercent,
    this.maxDiscount,
    required this.participatingHospitalId,
    required this.issuedToUserId,
    required this.issuedAt,
    this.validFrom,
    required this.validUntil,
    this.usedAt,
    this.usedAtHospitalId,
    this.status = CouponStatus.active,
  });

  final String id;
  final String code; // human-readable coupon code, e.g. 'RAKTA-XY2Z'
  final String title;
  final String description;
  final BenefitType benefitType;
  final int discountPercent; // 0..100
  final int? maxDiscount; // in INR
  final String participatingHospitalId;
  final String issuedToUserId;
  final DateTime issuedAt;
  final DateTime? validFrom;
  final DateTime validUntil;
  final DateTime? usedAt;
  final String? usedAtHospitalId;
  final CouponStatus status;

  bool get isActive =>
      status == CouponStatus.active &&
      (validFrom == null || DateTime.now().isAfter(validFrom!)) &&
      DateTime.now().isBefore(validUntil);

  bool get isExpired =>
      status == CouponStatus.active &&
      DateTime.now().isAfter(validUntil);

  bool get isUsed => status == CouponStatus.used;

  Coupon copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    BenefitType? benefitType,
    int? discountPercent,
    int? maxDiscount,
    String? participatingHospitalId,
    String? issuedToUserId,
    DateTime? issuedAt,
    DateTime? validFrom,
    DateTime? validUntil,
    DateTime? usedAt,
    String? usedAtHospitalId,
    CouponStatus? status,
  }) {
    return Coupon(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      benefitType: benefitType ?? this.benefitType,
      discountPercent: discountPercent ?? this.discountPercent,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      participatingHospitalId:
          participatingHospitalId ?? this.participatingHospitalId,
      issuedToUserId: issuedToUserId ?? this.issuedToUserId,
      issuedAt: issuedAt ?? this.issuedAt,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      usedAt: usedAt ?? this.usedAt,
      usedAtHospitalId: usedAtHospitalId ?? this.usedAtHospitalId,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'code': code,
        'title': title,
        'description': description,
        'benefitType': benefitType.name,
        'discountPercent': discountPercent,
        'maxDiscount': maxDiscount,
        'participatingHospitalId': participatingHospitalId,
        'issuedToUserId': issuedToUserId,
        'issuedAt': issuedAt.toIso8601String(),
        'validFrom': validFrom?.toIso8601String(),
        'validUntil': validUntil.toIso8601String(),
        'usedAt': usedAt?.toIso8601String(),
        'usedAtHospitalId': usedAtHospitalId,
        'status': status.name,
      };

  factory Coupon.fromMap(Map<String, dynamic> map) {
    return Coupon(
      id: map['id'] as String,
      code: map['code'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      benefitType:
          BenefitType.values.firstWhere((b) => b.name == map['benefitType']),
      discountPercent: (map['discountPercent'] as num).toInt(),
      maxDiscount: (map['maxDiscount'] as num?)?.toInt(),
      participatingHospitalId: map['participatingHospitalId'] as String,
      issuedToUserId: map['issuedToUserId'] as String,
      issuedAt: DateTime.parse(map['issuedAt'] as String),
      validFrom: map['validFrom'] != null
          ? DateTime.parse(map['validFrom'] as String)
          : null,
      validUntil: DateTime.parse(map['validUntil'] as String),
      usedAt: map['usedAt'] != null
          ? DateTime.parse(map['usedAt'] as String)
          : null,
      usedAtHospitalId: map['usedAtHospitalId'] as String?,
      status: CouponStatus.values.firstWhere(
        (s) => s.name == (map['status'] as String?),
        orElse: () => CouponStatus.active,
      ),
    );
  }
}

enum CouponStatus { active, used, expired, revoked }

extension CouponStatusX on CouponStatus {
  String get label => switch (this) {
        CouponStatus.active => 'Active',
        CouponStatus.used => 'Used',
        CouponStatus.expired => 'Expired',
        CouponStatus.revoked => 'Revoked',
      };
}
