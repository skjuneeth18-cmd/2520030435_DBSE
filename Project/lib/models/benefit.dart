/// A donor benefit offered by a participating hospital (Phase 4).
class Benefit {
  const Benefit({
    required this.id,
    required this.title,
    required this.description,
    required this.benefitType,
    this.discountPercent,
    this.maxDiscount,
    this.isValidFrom,
    this.isValidUntil,
    required this.participatingHospitalIds,
  });

  final String id;
  final String title;
  final String description;
  final BenefitType benefitType;
  final int? discountPercent; // 0..100
  final int? maxDiscount; // in INR, if applicable
  final DateTime? isValidFrom;
  final DateTime? isValidUntil;
  final List<String> participatingHospitalIds; // 'h01'..'h12'

  bool get isActive {
    if (isValidFrom != null && DateTime.now().isBefore(isValidFrom!)) {
      return false;
    }
    if (isValidUntil != null && DateTime.now().isAfter(isValidUntil!)) {
      return false;
    }
    return true;
  }

  bool isAvailableForHospital(String hospitalId) =>
      participatingHospitalIds.contains(hospitalId);

  Benefit copyWith({
    String? id,
    String? title,
    String? description,
    BenefitType? benefitType,
    int? discountPercent,
    int? maxDiscount,
    DateTime? isValidFrom,
    DateTime? isValidUntil,
    List<String>? participatingHospitalIds,
  }) {
    return Benefit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      benefitType: benefitType ?? this.benefitType,
      discountPercent: discountPercent ?? this.discountPercent,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      isValidFrom: isValidFrom ?? this.isValidFrom,
      isValidUntil: isValidUntil ?? this.isValidUntil,
      participatingHospitalIds:
          participatingHospitalIds ?? this.participatingHospitalIds,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'benefitType': benefitType.name,
        'discountPercent': discountPercent,
        'maxDiscount': maxDiscount,
        'isValidFrom': isValidFrom?.toIso8601String(),
        'isValidUntil': isValidUntil?.toIso8601String(),
        'participatingHospitalIds': participatingHospitalIds,
      };

  factory Benefit.fromMap(Map<String, dynamic> map) => Benefit(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        benefitType: BenefitType.values.firstWhere(
          (b) => b.name == map['benefitType'],
          orElse: () => BenefitType.freeCheckup,
        ),
        discountPercent: (map['discountPercent'] as num?)?.toInt(),
        maxDiscount: (map['maxDiscount'] as num?)?.toInt(),
        isValidFrom: map['isValidFrom'] != null
            ? DateTime.parse(map['isValidFrom'] as String)
            : null,
        isValidUntil: map['isValidUntil'] != null
            ? DateTime.parse(map['isValidUntil'] as String)
            : null,
        participatingHospitalIds: (map['participatingHospitalIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
      );
}

enum BenefitType {
  freeCheckup,
  consultationDiscount,
  diagnosticDiscount,
  partnerHospitalBenefit,
}

extension BenefitTypeX on BenefitType {
  String get label => switch (this) {
        BenefitType.freeCheckup => 'Free / Discounted Checkup',
        BenefitType.consultationDiscount => 'Consultation Discount',
        BenefitType.diagnosticDiscount => 'Diagnostic Test Discount',
        BenefitType.partnerHospitalBenefit => 'Partner Hospital Benefit',
      };

  String get short => switch (this) {
        BenefitType.freeCheckup => 'Checkup',
        BenefitType.consultationDiscount => 'Consultation',
        BenefitType.diagnosticDiscount => 'Diagnostics',
        BenefitType.partnerHospitalBenefit => 'Partner Hospital',
      };
}