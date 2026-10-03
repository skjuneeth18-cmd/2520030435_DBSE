/// Status of a doctor consultation appointment (Phase 3).
enum AppointmentStatus { confirmed, completed, cancelled }

extension AppointmentStatusX on AppointmentStatus {
  String get label => switch (this) {
        AppointmentStatus.confirmed => 'Confirmed',
        AppointmentStatus.completed => 'Completed',
        AppointmentStatus.cancelled => 'Cancelled',
      };
}

/// A booked doctor consultation (Phase 3).
class DoctorAppointment {
  const DoctorAppointment({
    required this.id,
    required this.userEmail,
    required this.doctorId,
    required this.doctorName,
    required this.specialization,
    required this.hospitalId,
    required this.hospitalName,
    required this.date,
    required this.time,
    required this.status,
    this.patientName,
  });

  final String id;
  final String userEmail; // owner of the appointment
  final String doctorId;
  final String doctorName;
  final String specialization;
  final String hospitalId;
  final String hospitalName;
  final DateTime date;
  final String time; // e.g. '10:30 AM'
  final AppointmentStatus status;
  final String? patientName; // defaults to account holder

  bool get isActive => status == AppointmentStatus.confirmed;

  DoctorAppointment copyWith({AppointmentStatus? status}) {
    return DoctorAppointment(
      id: id,
      userEmail: userEmail,
      doctorId: doctorId,
      doctorName: doctorName,
      specialization: specialization,
      hospitalId: hospitalId,
      hospitalName: hospitalName,
      date: date,
      time: time,
      status: status ?? this.status,
      patientName: patientName,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userEmail': userEmail,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'specialization': specialization,
        'hospitalId': hospitalId,
        'hospitalName': hospitalName,
        'date': date.toIso8601String(),
        'time': time,
        'status': status.name,
        'patientName': patientName,
      };

  factory DoctorAppointment.fromMap(Map<String, dynamic> map) =>
      DoctorAppointment(
        id: map['id'] as String,
        userEmail: map['userEmail'] as String,
        doctorId: map['doctorId'] as String,
        doctorName: map['doctorName'] as String,
        specialization: map['specialization'] as String,
        hospitalId: map['hospitalId'] as String,
        hospitalName: map['hospitalName'] as String,
        date: DateTime.parse(map['date'] as String),
        time: map['time'] as String,
        status: AppointmentStatus.values.firstWhere(
          (s) => s.name == (map['status'] as String?),
          orElse: () => AppointmentStatus.confirmed,
        ),
        patientName: map['patientName'] as String?,
      );
}
