import 'package:flutter/foundation.dart';

import '../data/doctors_data.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';
import 'auth_service.dart';

/// Phase 3 service: doctor listing, consultation slots and appointment
/// booking. In-memory mock; swap internals for a backend in Phase 6.
class DoctorService extends ChangeNotifier {
  DoctorService._();
  static final DoctorService instance = DoctorService._();

  final List<DoctorAppointment> _appointments = [];

  /// Admin overrides: doctorId -> consultation status (Phase 3).
  final Map<String, ConsultationStatus> _statusOverrides = {};

  int _apptCounter = 1;

  /// Seed a couple of walk-in appointments so the hospital admin
  /// dashboard has content on first run (other users' bookings).
  void _seedWalkIns() {
    if (_appointments.isNotEmpty) return;
    final now = DateTime.now();
    final d1 = DateTime(now.year, now.month, now.day + 2);
    final d2 = DateTime(now.year, now.month, now.day + 3);
    _appointments.addAll([
      DoctorAppointment(
        id: 'apW1',
        userEmail: 'walkin1@mock.in',
        doctorId: 'd01',
        doctorName: 'Dr. A. Sharma',
        specialization: 'Cardiology',
        hospitalId: 'h01',
        hospitalName: 'City Care Multispeciality Hospital',
        date: d1,
        time: '10:30 AM',
        status: AppointmentStatus.confirmed,
        patientName: 'Walk-in Patient A',
      ),
      DoctorAppointment(
        id: 'apW2',
        userEmail: 'walkin2@mock.in',
        doctorId: 'd03',
        doctorName: 'Dr. S. Prakash',
        specialization: 'General Medicine',
        hospitalId: 'h01',
        hospitalName: 'City Care Multispeciality Hospital',
        date: d2,
        time: '09:30 AM',
        status: AppointmentStatus.confirmed,
        patientName: 'Walk-in Patient B',
      ),
    ]);
  }

  AuthService get _auth => AuthService.instance;

  String? get _userEmail => _auth.currentUser?.email;

  // ==========================================================
  //  Doctor queries
  // ==========================================================

  /// All doctors, optionally filtered by hospital / search text.
  /// Applies admin status overrides.
  List<Doctor> doctors({String? hospitalId, String? query}) {
    var list = [
      for (final d in kDoctors)
        _statusOverrides.containsKey(d.id)
            ? d.copyWith(status: _statusOverrides[d.id])
            : d,
    ];
    if (hospitalId != null && hospitalId.isNotEmpty) {
      list = list.where((d) => d.hospitalId == hospitalId).toList();
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((d) {
        return d.name.toLowerCase().contains(q) ||
            d.specialization.toLowerCase().contains(q) ||
            d.department.toLowerCase().contains(q) ||
            d.hospitalName.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  Doctor? doctorById(String id) {
    for (final d in kDoctors) {
      if (d.id == id) return d;
    }
    return null;
  }

  List<Doctor> doctorsByHospital(String hospitalId) =>
      doctors(hospitalId: hospitalId);

  /// Specialization chips for the filter row.
  List<String> get specializations {
    final set = <String>{};
    for (final d in kDoctors) {
      set.add(d.specialization);
    }
    return set.toList()..sort();
  }

  /// Admin: sets a doctor's consultation status.
  void setDoctorStatus(String doctorId, ConsultationStatus status) {
    _statusOverrides[doctorId] = status;
    notifyListeners();
  }

  /// All appointments at a hospital (any patient) — admin view.
  List<DoctorAppointment> appointmentsForHospital(String hospitalId) {
    _seedWalkIns();
    _completeDueAppointments();
    final list = _appointments
        .where((a) => a.hospitalId == hospitalId)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  /// Admin: marks an appointment completed (front-desk action).
  void completeAppointment(String appointmentId) {
    final idx =
        _appointments.indexWhere((a) => a.id == appointmentId);
    if (idx == -1) return;
    _appointments[idx] =
        _appointments[idx].copyWith(status: AppointmentStatus.completed);
    notifyListeners();
  }

  // ==========================================================
  //  Consultation slots (deterministic mock capacity)
  // ==========================================================

  /// Whether [doctorId] has a free seat in [slot] on [date].
  bool isSlotAvailable({
    required String doctorId,
    required DateTime date,
    required String slot,
  }) {
    return mockTakenSeats(doctorId: doctorId, date: date, slot: slot) < 3;
  }

  /// 0..3 of 4 seats taken, stable across runs (unlike String.hashCode).
  static int mockTakenSeats({
    required String doctorId,
    required DateTime date,
    required String slot,
  }) {
    final dayNum = date.year * 10000 + date.month * 100 + date.day;
    final slotNum = kConsultationSlots.indexOf(slot);
    final h = _stableHash(doctorId);
    return (h * 7 + dayNum * 13 + slotNum * 29).abs() % 4;
  }

  static int _stableHash(String s) {
    var h = 0;
    for (final c in s.codeUnits) {
      h = (h * 31 + c) & 0x3FFFFFFF;
    }
    return h;
  }

  // ==========================================================
  //  Appointments
  // ==========================================================

  /// All appointments of the current user, newest first. Also applies
  /// the mock lifecycle (past confirmed → completed).
  List<DoctorAppointment> myAppointments() {
    _completeDueAppointments();
    final email = _userEmail;
    if (email == null) return [];
    final mine = _appointments.where((a) => a.userEmail == email).toList();
    mine.sort((a, b) => b.date.compareTo(a.date));
    return mine;
  }

  /// Upcoming (confirmed, today or later) appointments, soonest first.
  List<DoctorAppointment> activeAppointments() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return myAppointments()
        .where((a) => a.isActive && !a.date.isBefore(today))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Whether the user already has an active appointment with the same
  /// doctor on the same date (one per doctor per day).
  bool hasActiveAppointmentOn(String doctorId, DateTime date) {
    final email = _userEmail;
    if (email == null) return false;
    return _appointments.any((a) =>
        a.userEmail == email &&
        a.isActive &&
        a.doctorId == doctorId &&
        _sameDay(a.date, date));
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Books a consultation. Returns an error message or null on success.
  String? bookAppointment({
    required Doctor doctor,
    required DateTime date,
    required String slot,
  }) {
    final user = _auth.currentUser;
    if (user == null) return 'Please log in to book a consultation.';
    if (doctor.status == ConsultationStatus.onLeave) {
      return 'This doctor is on leave. Please pick another doctor.';
    }
    if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return 'Please pick a future date.';
    }
    if (!doctorConsultsOn(doctor, date)) {
      return 'This doctor does not consult on '
          '${_weekdayName(date.weekday)}s. Pick a consulting day.';
    }
    if (hasActiveAppointmentOn(doctor.id, date)) {
      return 'You already have an appointment with this doctor that day.';
    }
    if (!isSlotAvailable(
        doctorId: doctor.id, date: date, slot: slot)) {
      return 'That slot is full. Please pick another time.';
    }
    _appointments.add(DoctorAppointment(
      id: 'ap${_apptCounter++}',
      userEmail: user.email,
      doctorId: doctor.id,
      doctorName: doctor.name,
      specialization: doctor.specialization,
      hospitalId: doctor.hospitalId,
      hospitalName: doctor.hospitalName,
      date: date,
      time: slot,
      status: AppointmentStatus.confirmed,
      patientName: user.fullName,
    ));
    notifyListeners();
    return null;
  }

  /// Marks a confirmed appointment as cancelled.
  String? cancelAppointment(String appointmentId) {
    final email = _userEmail;
    if (email == null) return 'Please log in first.';
    final idx = _appointments
        .indexWhere((a) => a.id == appointmentId && a.userEmail == email);
    if (idx == -1) return 'Appointment not found.';
    if (_appointments[idx].status != AppointmentStatus.confirmed) {
      return 'Only confirmed appointments can be cancelled.';
    }
    _appointments[idx] =
        _appointments[idx].copyWith(status: AppointmentStatus.cancelled);
    notifyListeners();
    return null;
  }

  /// Mock lifecycle: confirmed appointments dated before today become
  /// "completed" (read-only mutation, no notification needed).
  void _completeDueAppointments() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (var i = 0; i < _appointments.length; i++) {
      final a = _appointments[i];
      if (a.isActive && a.date.isBefore(today)) {
        _appointments[i] = a.copyWith(status: AppointmentStatus.completed);
      }
    }
  }

  static String _weekdayName(int weekday) {
    const names = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    return names[weekday - 1];
  }
}
