import 'donor_certificate.dart';
import 'user.dart';

/// Donor eligibility states shown on dashboard, profile and booking.
enum EligibilityStatus { eligible, temporarilyDeferred, notEligible, unknown }

extension EligibilityStatusX on EligibilityStatus {
  String get label => switch (this) {
        EligibilityStatus.eligible => 'Eligible to donate',
        EligibilityStatus.temporarilyDeferred => 'Temporarily deferred',
        EligibilityStatus.notEligible => 'Not eligible',
        EligibilityStatus.unknown => 'Check eligibility',
      };

  String get emoji => switch (this) {
        EligibilityStatus.eligible => '✅',
        EligibilityStatus.temporarilyDeferred => '⏳',
        EligibilityStatus.notEligible => '🚫',
        EligibilityStatus.unknown => '❓',
      };
}

/// Donor-specific profile layered on top of the Phase 1 [AppUser].
class DonorProfile {
  const DonorProfile({
    required this.user,
    this.age,
    this.eligibility = EligibilityStatus.unknown,
    this.eligibilityNote,
    this.donationCount = 0,
    this.lastDonationDate,
    this.lastDonationFacility,
  });

  final AppUser user;
  final int? age;
  final EligibilityStatus eligibility;
  final String? eligibilityNote; // e.g. "Next donation after 12 Jan 2027"
  final int donationCount;
  final DateTime? lastDonationDate;
  final String? lastDonationFacility;

  /// Standard whole-blood interval between donations (3 months).
  static const int intervalDays = 90;

  /// Mock rule: 18–65 years, body-weight/KYC checks come in Phase 6.
  bool get isEligibleByAge {
    if (age == null) return false;
    return age! >= 18 && age! <= 65;
  }

  /// Eligibility considering both age band and 90-day interval rule.
  EligibilityStatus get computedStatus {
    if (!isEligibleByAge) return EligibilityStatus.notEligible;
    if (lastDonationDate == null) return EligibilityStatus.eligible;
    final next = DonorCertificate.nextEligibleDate(lastDonationDate!);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (today.isBefore(next)) return EligibilityStatus.temporarilyDeferred;
    return EligibilityStatus.eligible;
  }

  /// Date the donor becomes eligible again (null if already eligible).
  DateTime? get nextEligibleOn {
    if (computedStatus != EligibilityStatus.temporarilyDeferred) return null;
    return DonorCertificate.nextEligibleDate(lastDonationDate!);
  }

  Map<String, dynamic> toMap() => {
        'user': user.toMap(),
        'age': age,
        'eligibility': eligibility.name,
        'eligibilityNote': eligibilityNote,
        'donationCount': donationCount,
        'lastDonationDate': lastDonationDate?.toIso8601String(),
        'lastDonationFacility': lastDonationFacility,
      };
}
