import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/appointment.dart';
import '../../services/doctor_service.dart';
import '../../widgets/empty_state.dart';

/// Bottom sheet listing the user's appointments with cancel action.
class MyAppointmentsSheet extends StatefulWidget {
  const MyAppointmentsSheet({super.key});

  @override
  State<MyAppointmentsSheet> createState() => _MyAppointmentsSheetState();
}

class _MyAppointmentsSheetState extends State<MyAppointmentsSheet> {
  @override
  Widget build(BuildContext context) {
    final appts = DoctorService.instance.myAppointments();

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, controller) => Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppTheme.textGrey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'My appointments',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Consultation bookings are shown newest first.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textGrey.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: appts.isEmpty
                    ? const EmptyState(
                        icon: Icons.event_busy,
                        title: 'No appointments yet',
                        message:
                            'Book a consultation from any doctor profile.',
                      )
                    : ListView.builder(
                        controller: controller,
                        itemCount: appts.length,
                        itemBuilder: (context, i) {
                          final a = appts[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          a.doctorName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                      ),
                                      _StatusPill(status: a.status),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${a.specialization} · ${a.hospitalName}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${_dateLabel(a.date)} at ${a.time}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.red,
                                    ),
                                  ),
                                  if (a.status ==
                                      AppointmentStatus.confirmed) ...[
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            _cancel(a.id),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppTheme.red,
                                          side: const BorderSide(
                                              color: AppTheme.red),
                                        ),
                                        child: const Text('Cancel'),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cancel(String id) async {
    final err = DoctorService.instance.cancelAppointment(id);
    if (!mounted) return;
    setState(() {}); // rebuild sheet with new status
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(err ?? 'Appointment cancelled.'),
        backgroundColor: err == null ? Colors.green : Colors.red,
      ),
    );
  }

  static String _dateLabel(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

/// Colored status pill for appointments.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      AppointmentStatus.confirmed => (Colors.green, 'Confirmed'),
      AppointmentStatus.completed => (Colors.blue, 'Completed'),
      AppointmentStatus.cancelled => (Colors.red, 'Cancelled'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
