/// Emergency level of a blood requirement.
enum EmergencyLevel { critical, urgent, normal }

/// Status of a requirement.
enum RequirementStatus { open, fulfilled }

extension EmergencyLevelX on EmergencyLevel {
  String get label => switch (this) {
        EmergencyLevel.critical => 'Critical',
        EmergencyLevel.urgent => 'Urgent',
        EmergencyLevel.normal => 'Normal',
      };
}

extension RequirementStatusX on RequirementStatus {
  String get label => switch (this) {
        RequirementStatus.open => 'Open',
        RequirementStatus.fulfilled => 'Fulfilled',
      };
}

/// One area-wise blood requirement entry.
class BloodRequirement {
  const BloodRequirement({
    required this.id,
    required this.area,
    required this.bloodGroup,
    required this.unitsNeeded,
    required this.facilityName,
    required this.facilityType,
    required this.emergencyLevel,
    required this.status,
    required this.postedAgo,
    required this.phone,
  });

  final String id;
  final String area;
  final String bloodGroup;
  final int unitsNeeded;
  final String facilityName;
  final String facilityType; // 'Hospital' | 'Blood Bank'
  final EmergencyLevel emergencyLevel;
  final RequirementStatus status;
  final String postedAgo;
  final String phone;
}
