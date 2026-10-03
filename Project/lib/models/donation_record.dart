/// Outcome of a past donation visit.
enum DonationRecordStatus { completed, deferred }

extension DonationRecordStatusX on DonationRecordStatus {
  String get label => switch (this) {
        DonationRecordStatus.completed => 'Completed',
        DonationRecordStatus.deferred => 'Deferred',
      };
}

/// One past donation visit shown in the donor's history.
class DonationRecord {
  const DonationRecord({
    required this.id,
    required this.userEmail,
    required this.date,
    required this.facilityId,
    required this.facilityName,
    required this.facilityType,
    required this.bloodGroup,
    required this.status,
    this.units = 1,
    this.notes,
    this.certificateId,
  });

  final String id;
  final String userEmail;
  final DateTime date;
  final String facilityId;
  final String facilityName;
  final String facilityType; // 'Hospital' | 'Blood Bank'
  final String bloodGroup;
  final DonationRecordStatus status;
  final int units;
  final String? notes; // e.g. reason for deferral
  final String? certificateId; // issued when completed

  Map<String, dynamic> toMap() => {
        'id': id,
        'userEmail': userEmail,
        'date': date.toIso8601String(),
        'facilityId': facilityId,
        'facilityName': facilityName,
        'facilityType': facilityType,
        'bloodGroup': bloodGroup,
        'status': status.name,
        'units': units,
        'notes': notes,
        'certificateId': certificateId,
      };

  factory DonationRecord.fromMap(Map<String, dynamic> map) => DonationRecord(
        id: map['id'] as String,
        userEmail: map['userEmail'] as String,
        date: DateTime.parse(map['date'] as String),
        facilityId: map['facilityId'] as String,
        facilityName: map['facilityName'] as String,
        facilityType: map['facilityType'] as String,
        bloodGroup: map['bloodGroup'] as String,
        status: DonationRecordStatus.values.byName(map['status'] as String),
        units: (map['units'] as num?)?.toInt() ?? 1,
        notes: map['notes'] as String?,
        certificateId: map['certificateId'] as String?,
      );
}
