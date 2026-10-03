import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../data/doctors_data.dart';
import '../../models/doctor.dart';
import '../../services/blood_service.dart';
import '../../services/doctor_service.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_header.dart';
import '../hospitals/hospital_detail_screen.dart';

/// Doctor profile (Phase 3): consultation details + slot booking flow.
class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key, required this.doctor});

  final Doctor doctor;

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  String? _slot;
  bool _booking = false;

  Doctor get _doctor => widget.doctor;

  @override
  Widget build(BuildContext context) {
    final d = _doctor;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- Header card ----
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0x1FD32F2F),
                    child: Icon(Icons.person, size: 32, color: AppTheme.red),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${d.specialization} · ${d.qualification}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.textGrey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${d.experienceYears} yrs experience',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ---- Consultation details ----
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Consultation'),
                  _detailRow('Hospital', d.hospitalName),
                  _detailRow('Department', d.department),
                  _detailRow('Days', d.consultationDays.join(', ')),
                  _detailRow('Hours', d.consultationTime),
                  _detailRow('Fee', '₹${d.fee}'),
                  _detailRow('Status', d.status.label),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ---- Hospital link ----
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_hospital_outlined,
                  color: AppTheme.red),
              title: const Text(
                'View hospital',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
              ),
              subtitle: Text(
                d.hospitalName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
              trailing:
                  const Icon(Icons.chevron_right, color: AppTheme.textGrey),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HospitalDetailScreen(
                    hospital: BloodService.instance.hospitalById(d.hospitalId)!,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ---- Booking card ----
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Book consultation'),
                  if (d.status == ConsultationStatus.onLeave) ...[
                    const Text(
                      'This doctor is currently on leave — booking is '
                      'unavailable. Please check back later.',
                      style: TextStyle(fontSize: 12.5, color: AppTheme.textGrey),
                    ),
                  ] else ...[
                    // Date picker button
                    OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month_outlined,
                          size: 18),
                      label: Text(_dateLabel(_date)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.red,
                        side: const BorderSide(color: AppTheme.red),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    if (!doctorConsultsOn(d, _date)) ...[
                      const SizedBox(height: 8),
                      Text(
                        '⚠️ Not a consulting day — days are '
                        '${d.consultationDays.join(', ')}.',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.orange),
                      ),
                    ],
                    const SizedBox(height: 12),
                    // Slot chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in kConsultationSlots)
                          _SlotChip(
                            label: s,
                            selected: _slot == s,
                            available: DoctorService.instance.isSlotAvailable(
                              doctorId: d.id,
                              date: _date,
                              slot: s,
                            ),
                            onSelected: (sel) {
                              if (sel) setState(() => _slot = s);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: _slot == null
                          ? 'Book appointment'
                          : 'Book $_slot · ${_dateLabel(_date)}',
                      isLoading: _booking,
                      onPressed: _slot == null ? null : _book,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _slot = null;
      });
    }
  }

  Future<void> _book() async {
    if (_slot == null) return;
    setState(() => _booking = true);
    final err = DoctorService.instance.bookAppointment(
      doctor: _doctor,
      date: _date,
      slot: _slot!,
    );
    setState(() => _booking = false);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.red),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '✅ Appointment confirmed with ${_doctor.name} at $_slot'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  static String _dateLabel(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppTheme.textGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Time-slot chip; disabled look when the slot is full.
class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.label,
    required this.selected,
    required this.available,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final bool available;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: available ? onSelected : null,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: !available
            ? AppTheme.textGrey.withValues(alpha: 0.4)
            : selected
                ? Colors.white
                : AppTheme.textDark,
      ),
      selectedColor: AppTheme.red,
      showCheckmark: false,
    );
  }
}
