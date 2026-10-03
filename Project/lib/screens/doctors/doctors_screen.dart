import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/doctor.dart';
import '../../services/doctor_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/empty_state.dart';
import 'doctor_profile_screen.dart';
import 'my_appointments_sheet.dart';

/// Doctors tab (Phase 3): browse doctors, filter by specialization,
/// open a profile to view consultation details and book.
class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _specialization;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = DoctorService.instance;
    var doctors = service.doctors(query: _query);
    if (_specialization != null) {
      doctors =
          doctors.where((d) => d.specialization == _specialization).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctors'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: CustomTextField(
              controller: _searchController,
              label: 'Search doctors, specialties…',
              hint: 'e.g. Cardiology, Dr. Sharma',
              icon: Icons.search,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _specialization == null,
                  onSelected: (_) => setState(() => _specialization = null),
                ),
                const SizedBox(width: 8),
                for (final s in service.specializations) ...[
                  ChoiceChip(
                    label: Text(s),
                    selected: _specialization == s,
                    onSelected: (_) => setState(() => _specialization = s),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          Expanded(
            child: doctors.isEmpty
                ? const EmptyState(
                    icon: Icons.medical_services_outlined,
                    title: 'No doctors found',
                    message: 'Try a different search or specialty filter.',
                  )
                : RefreshIndicator(
                    onRefresh: () async => setState(() {}),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: doctors.length,
                      itemBuilder: (context, i) => DoctorCard(
                        doctor: doctors[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DoctorProfileScreen(doctor: doctors[i]),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMyAppointments(context),
        icon: const Icon(Icons.event_available),
        label: const Text('My appointments'),
      ),
    );
  }

  void _showMyAppointments(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const MyAppointmentsSheet(),
    );
  }
}

/// Compact doctor card used in the Doctors tab and hospital detail.
class DoctorCard extends StatelessWidget {
  const DoctorCard({super.key, required this.doctor, this.onTap});

  final Doctor doctor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.red.withValues(alpha: 0.12),
                child: const Icon(
                  Icons.person,
                  color: AppTheme.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            doctor.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                        _StatusDot(status: doctor.status),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${doctor.specialization} · ${doctor.experienceYears} yrs',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textGrey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctor.hospitalName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textGrey.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${doctor.fee} consultation',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Colored dot reflecting consultation status.
class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final ConsultationStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      ConsultationStatus.available => (Colors.green, 'Available'),
      ConsultationStatus.busy => (Colors.orange, 'Busy'),
      ConsultationStatus.onLeave => (Colors.red, 'On leave'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
