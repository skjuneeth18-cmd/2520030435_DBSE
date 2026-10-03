/// Priority of a blood request (Phase 3).
enum RequestPriority { routine, urgent, critical }

extension RequestPriorityX on RequestPriority {
  String get label => switch (this) {
        RequestPriority.routine => 'Routine',
        RequestPriority.urgent => 'Urgent',
        RequestPriority.critical => 'Critical',
      };
}

/// Status of a blood request raised to a facility.
enum RequestStatus { pending, fulfilled, rejected }

extension RequestStatusX on RequestStatus {
  String get label => switch (this) {
        RequestStatus.pending => 'Pending',
        RequestStatus.fulfilled => 'Fulfilled',
        RequestStatus.rejected => 'Rejected',
      };
}

/// A blood request raised by a ward / hospital / user to a facility
/// (Phase 3 admin dashboards manage these).
class BloodRequest {
  const BloodRequest({
    required this.id,
    required this.facilityId, // 'h01' or 'bb01'
    required this.facilityName,
    required this.requesterName,
    required this.bloodGroup,
    required this.units,
    required this.priority,
    required this.status,
    required this.requestedOn,
    this.note,
  });

  final String id;
  final String facilityId;
  final String facilityName;
  final String requesterName; // ward / person raising the request
  final String bloodGroup;
  final int units;
  final RequestPriority priority;
  final RequestStatus status;
  final DateTime requestedOn;
  final String? note;

  BloodRequest copyWith({RequestStatus? status}) {
    return BloodRequest(
      id: id,
      facilityId: facilityId,
      facilityName: facilityName,
      requesterName: requesterName,
      bloodGroup: bloodGroup,
      units: units,
      priority: priority,
      status: status ?? this.status,
      requestedOn: requestedOn,
      note: note,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'facilityId': facilityId,
        'facilityName': facilityName,
        'requesterName': requesterName,
        'bloodGroup': bloodGroup,
        'units': units,
        'priority': priority.name,
        'status': status.name,
        'requestedOn': requestedOn.toIso8601String(),
        'note': note,
      };

  factory BloodRequest.fromMap(Map<String, dynamic> map) => BloodRequest(
        id: map['id'] as String,
        facilityId: map['facilityId'] as String,
        facilityName: map['facilityName'] as String,
        requesterName: map['requesterName'] as String,
        bloodGroup: map['bloodGroup'] as String,
        units: (map['units'] as num).toInt(),
        priority: RequestPriority.values.firstWhere(
          (p) => p.name == (map['priority'] as String?),
          orElse: () => RequestPriority.routine,
        ),
        status: RequestStatus.values.firstWhere(
          (s) => s.name == (map['status'] as String?),
          orElse: () => RequestStatus.pending,
        ),
        requestedOn: DateTime.parse(map['requestedOn'] as String),
        note: map['note'] as String?,
      );
}
