/// Consultation status of a doctor at their hospital (Phase 3).
enum ConsultationStatus { available, busy, onLeave }

extension ConsultationStatusX on ConsultationStatus {
  String get label => switch (this) {
        ConsultationStatus.available => 'Available',
        ConsultationStatus.busy => 'Busy',
        ConsultationStatus.onLeave => 'On leave',
      };
}

/// A doctor listing with consultation details (Phase 3).
class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.department,
    required this.hospitalId,
    required this.hospitalName,
    required this.consultationDays,
    required this.consultationTime,
    required this.fee,
    required this.status,
    this.experienceYears = 5,
    this.qualification = 'MBBS',
  });

  final String id; // 'd01'…
  final String name; // 'Dr. A. Sharma'
  final String specialization; // 'Cardiology'
  final String department; // 'Cardiac Sciences'
  final String hospitalId; // 'h01'…
  final String hospitalName;
  final List<String> consultationDays; // ['Mon', 'Wed', 'Fri']
  final String consultationTime; // '10:00 AM – 1:00 PM'
  final int fee; // INR
  final ConsultationStatus status;
  final int experienceYears;
  final String qualification;

  Doctor copyWith({ConsultationStatus? status}) => Doctor(
        id: id,
        name: name,
        specialization: specialization,
        department: department,
        hospitalId: hospitalId,
        hospitalName: hospitalName,
        consultationDays: consultationDays,
        consultationTime: consultationTime,
        fee: fee,
        status: status ?? this.status,
        experienceYears: experienceYears,
        qualification: qualification,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'specialization': specialization,
        'department': department,
        'hospitalId': hospitalId,
        'hospitalName': hospitalName,
        'consultationDays': consultationDays,
        'consultationTime': consultationTime,
        'fee': fee,
        'status': status.name,
        'experienceYears': experienceYears,
        'qualification': qualification,
      };

  factory Doctor.fromMap(Map<String, dynamic> map) => Doctor(
        id: map['id'] as String,
        name: map['name'] as String,
        specialization: map['specialization'] as String,
        department: map['department'] as String,
        hospitalId: map['hospitalId'] as String,
        hospitalName: map['hospitalName'] as String,
        consultationDays:
            (map['consultationDays'] as List<dynamic>).cast<String>(),
        consultationTime: map['consultationTime'] as String,
        fee: (map['fee'] as num).toInt(),
        status: ConsultationStatus.values.firstWhere(
          (s) => s.name == (map['status'] as String?),
          orElse: () => ConsultationStatus.available,
        ),
        experienceYears: (map['experienceYears'] as num?)?.toInt() ?? 5,
        qualification: map['qualification'] as String? ?? 'MBBS',
      );
}
