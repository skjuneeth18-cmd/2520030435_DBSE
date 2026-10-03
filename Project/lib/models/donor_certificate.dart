import 'booking.dart';

/// Digital certificate issued automatically after a completed donation.
class DonorCertificate {
  const DonorCertificate({
    required this.id,
    required this.certificateId,
    required this.donorName,
    required this.bloodGroup,
    required this.donationDate,
    required this.facilityName,
    required this.facilityType,
    required this.issuedAt,
    this.userEmail,
  });

  final String id; // internal record id
  final String certificateId; // display id, e.g. RS-CERT-2026-0042
  final String donorName;
  final String bloodGroup;
  final DateTime donationDate;
  final String facilityName;
  final String facilityType;
  final DateTime issuedAt;
  final String? userEmail; // owner (mock: demo seed tagged to demo user)

  /// "12 Oct 2026"
  String get donationDateLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${donationDate.day} ${months[donationDate.month - 1]} '
        '${donationDate.year}';
  }

  String get issuedDateLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${issuedAt.day} ${months[issuedAt.month - 1]} ${issuedAt.year}';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'certificateId': certificateId,
        'donorName': donorName,
        'bloodGroup': bloodGroup,
        'donationDate': donationDate.toIso8601String(),
        'facilityName': facilityName,
        'facilityType': facilityType,
        'issuedAt': issuedAt.toIso8601String(),
        if (userEmail != null) 'userEmail': userEmail,
      };

  factory DonorCertificate.fromMap(Map<String, dynamic> map) =>
      DonorCertificate(
        id: map['id'] as String,
        certificateId: map['certificateId'] as String,
        donorName: map['donorName'] as String,
        bloodGroup: map['bloodGroup'] as String,
        donationDate: DateTime.parse(map['donationDate'] as String),
        facilityName: map['facilityName'] as String,
        facilityType: map['facilityType'] as String,
        issuedAt: DateTime.parse(map['issuedAt'] as String),
        userEmail: map['userEmail'] as String?,
      );

  /// Formats a donor's next eligible donation date: 90 days after the
  /// last whole-blood donation (standard whole-blood interval).
  static DateTime nextEligibleDate(DateTime lastDonation) =>
      DateTime(lastDonation.year, lastDonation.month, lastDonation.day + 90);

  /// Venue helper reused from the booking model.
  static String facilityAddressOf(String facilityId) =>
      findVenueById(facilityId)?.addressLine ?? facilityId;
}
