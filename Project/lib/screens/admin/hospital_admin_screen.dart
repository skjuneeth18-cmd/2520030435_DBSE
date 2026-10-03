import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/appointment.dart';
import '../../models/blood_availability.dart';
import '../../models/blood_request.dart';
import '../../models/doctor.dart';
import '../../services/admin_service.dart';
import '../../services/doctor_service.dart';
import '../../services/donor_service.dart';
import '../../services/kyc_service.dart';
import 'kyc_admin_screen.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_header.dart';

/// Role-based Hospital Admin dashboard (Phase 3).
/// Sections: facility info, doctors, inventory, appointments, camps,
/// blood requests.
class HospitalAdminScreen extends StatefulWidget {
  const HospitalAdminScreen({super.key});

  @override
  State<HospitalAdminScreen> createState() => _HospitalAdminScreenState();
}

class _HospitalAdminScreenState extends State<HospitalAdminScreen> {
  @override
  void initState() {
    super.initState();
    AdminService.instance.addListener(_refresh);
    DoctorService.instance.addListener(_refresh);
    DonorService.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    AdminService.instance.removeListener(_refresh);
    DoctorService.instance.removeListener(_refresh);
    DonorService.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final facility = AdminService.instance.managedFacility();
    if (facility == null) {
      return const Scaffold(
        body: Center(child: Text('No hospital linked to this account.')),
      );
    }
    final admin = AdminService.instance;
    final doctorSvc = DoctorService.instance;
    final donorSvc = DonorService.instance;
    final doctors = doctorSvc.doctorsByHospital(facility.id);
    final appts = doctorSvc.appointmentsForHospital(facility.id);
    final requests = admin.requestsFor(facility.id);
    final inventory = admin.inventory(facility.id);
    final camps = donorSvc.camps();
    final bookings = donorSvc.bookingsForFacility(facility.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Hospital Admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- Facility header ----
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.red, AppTheme.redDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  facility.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${facility.kindLabel} · ${facility.area}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _statPill('${doctors.length} doctors'),
                    _statPill('${appts.where((a) => a.isActive).length} active appts'),
                    _statPill('${requests.where((r) => r.status == RequestStatus.pending).length} pending requests'),
                    _statPill('${admin.totalUnits(facility.id)} units in stock'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ---- Blood requests ----
          const SectionHeader(title: '🩸 Blood requests'),
          if (requests.isEmpty)
            const EmptyState(
              icon: Icons.inbox_outlined,
              title: 'No requests',
              message: 'Blood requests raised to your facility appear here.',
            )
          else
            for (final r in requests)
              _RequestCard(request: r),

          const SizedBox(height: 20),

          // ---- Inventory ----
          const SectionHeader(title: '🧪 Blood inventory'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  for (final e in inventory)
                    _InventoryRow(
                      entry: e,
                      onEdit: () => _editUnits(e),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ---- Doctors ----
          const SectionHeader(title: '👩‍⚕️ Doctors'),
          for (final d in doctors)
            Card(
              child: ListTile(
                leading: const Icon(Icons.person, color: AppTheme.red),
                title: Text(d.name,
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w800)),
                subtitle: Text(
                  '${d.specialization} · ${d.status.label} · ₹${d.fee}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: PopupMenuButton<ConsultationStatus>(
                  icon: const Icon(Icons.edit, size: 20),
                  onSelected: (s) =>
                      doctorSvc.setDoctorStatus(d.id, s),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                        value: ConsultationStatus.available,
                        child: Text('Available')),
                    PopupMenuItem(
                        value: ConsultationStatus.busy,
                        child: Text('Busy')),
                    PopupMenuItem(
                        value: ConsultationStatus.onLeave,
                        child: Text('On leave')),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          // ---- Appointments ----
          const SectionHeader(title: '📅 Appointments'),
          if (appts.isEmpty)
            const EmptyState(
              icon: Icons.event_busy,
              title: 'No appointments',
              message: 'Consultation bookings at your hospital appear here.',
            )
          else
            for (final a in appts.take(6))
              Card(
                child: ListTile(
                  leading: const Icon(Icons.event_available,
                      color: AppTheme.red),
                  title: Text(
                    '${a.patientName ?? a.userEmail} → ${a.doctorName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text('${_dateLabel(a.date)} · ${a.time} · ${a.status.label}',
                      style: const TextStyle(fontSize: 12)),
                  trailing: a.status == AppointmentStatus.confirmed
                      ? TextButton(
                          onPressed: () =>
                              doctorSvc.completeAppointment(a.id),
                          child: const Text('Complete'),
                        )
                      : null,
                ),
              ),

          const SizedBox(height: 20),

          // ---- Donation slots (facility bookings) ----
          const SectionHeader(title: '💉 Donation slots'),
          if (bookings.isEmpty)
            const EmptyState(
              icon: Icons.water_drop_outlined,
              title: 'No upcoming donation slots',
              message: 'Donor bookings at your facility appear here.',
            )
          else
            for (final b in bookings.take(6))
              Card(
                child: ListTile(
                  leading:
                      const Icon(Icons.water_drop, color: AppTheme.red),
                  title: Text(
                    b.userEmail == 'demo@raktasetu.in'
                        ? 'Demo Donor'
                        : b.userEmail,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '${_dateLabel(b.date)} · ${b.time} · ${b.bloodGroup ?? "?"}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),

          const SizedBox(height: 20),

          // ---- Camps (manage = view + register counts) ----
          const SectionHeader(title: '📢 Donation camps'),
          for (final c in camps.take(4))
            Card(
              child: ListTile(
                leading: const Icon(Icons.campaign_outlined,
                    color: AppTheme.red),
                title: Text(c.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800)),
                subtitle: Text(
                  '${_dateLabel(c.startsAt)} · ${c.slotsBooked}/${c.totalSlots} registered',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          const SizedBox(height: 20),

          // ---- KYC & donor verification (admin) ----
          if (KYCService.instance.canManageKYC) ...[
            const SectionHeader(title: '🪪 KYC & donor verification'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    ListTile(
                      leading:
                          const Icon(Icons.verified_user_outlined,
                              color: AppTheme.red),
                      title: const Text('KYC review queue',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800)),
                      subtitle: Text(
                          '${_pendingKYCCount()} pending KYC records',
                          style: const TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward,
                          size: 18, color: AppTheme.textGrey),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const KYCAdminScreen()),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.people_outline,
                          color: AppTheme.red),
                      title: const Text('All donors',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800)),
                      subtitle: const Text(
                          'Review donor verification status',
                          style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward,
                          size: 18, color: AppTheme.textGrey),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const KYCAdminScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  int _pendingKYCCount() => KYCService.instance.pendingKYCCount;

  Future<void> _editUnits(BloodAvailability entry) async {
    final controller = TextEditingController(text: '${entry.units}');
    final units = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update ${entry.bloodGroup} units'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
              labelText: 'Units in stock', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(ctx, int.tryParse(controller.text)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (units != null) {
      AdminService.instance.updateUnits(
        facilityId: AdminService.instance.managedFacility()!.id,
        bloodGroup: entry.bloodGroup,
        units: units,
      );
    }
  }

  Widget _statPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
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

/// A blood request row with fulfil / reject actions.
class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final BloodRequest request;

  @override
  Widget build(BuildContext context) {
    final admin = AdminService.instance;
    final (priorityColor, priorityLabel) = switch (request.priority) {
      RequestPriority.critical => (Colors.red, 'CRITICAL'),
      RequestPriority.urgent => (Colors.orange, 'URGENT'),
      RequestPriority.routine => (Colors.blue, 'Routine'),
    };
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    priorityLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: priorityColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${request.bloodGroup} · ${request.units} unit(s)',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textDark,
                  ),
                ),
                const Spacer(),
                _statusChip(request.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'From: ${request.requesterName}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
            ),
            if (request.status == RequestStatus.pending) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        final err = admin.fulfilRequest(request.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(err ?? 'Request fulfilled — inventory updated.'),
                            backgroundColor:
                                err == null ? Colors.green : Colors.red,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                      ),
                      child: const Text('Fulfil'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => admin.rejectRequest(request.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusChip(RequestStatus status) {
    final (color, label) = switch (status) {
      RequestStatus.pending => (Colors.orange, 'Pending'),
      RequestStatus.fulfilled => (Colors.green, 'Fulfilled'),
      RequestStatus.rejected => (Colors.red, 'Rejected'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
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

/// Inventory row with tap-to-edit units.
class _InventoryRow extends StatelessWidget {
  const _InventoryRow({required this.entry, required this.onEdit});

  final BloodAvailability entry;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (entry.status) {
      StockStatus.available => (Colors.green, 'Available'),
      StockStatus.limited => (Colors.orange, 'Limited'),
      StockStatus.unavailable => (Colors.red, 'Out'),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              entry.bloodGroup,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${entry.units} units · $label',
              style: TextStyle(fontSize: 12.5, color: color),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 18, color: AppTheme.red),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}
