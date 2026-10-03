import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/blood_availability.dart';
import '../../models/donation_record.dart';
import '../../models/blood_request.dart';
import '../../services/admin_service.dart';
import '../../services/donor_service.dart';
import '../../services/kyc_service.dart';
import 'kyc_admin_screen.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_header.dart';

/// Role-based Blood Bank Admin dashboard (Phase 3).
/// Sections: facility info, inventory updates, donation slots,
/// donor registry, blood requests.
class BloodBankAdminScreen extends StatefulWidget {
  const BloodBankAdminScreen({super.key});

  @override
  State<BloodBankAdminScreen> createState() => _BloodBankAdminScreenState();
}

class _BloodBankAdminScreenState extends State<BloodBankAdminScreen> {
  @override
  void initState() {
    super.initState();
    AdminService.instance.addListener(_refresh);
    DonorService.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    AdminService.instance.removeListener(_refresh);
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
        body: Center(child: Text('No blood bank linked to this account.')),
      );
    }
    final admin = AdminService.instance;
    final donorSvc = DonorService.instance;
    final inventory = admin.inventory(facility.id);
    final requests = admin.requestsFor(facility.id);
    final bookings = donorSvc.bookingsForFacility(facility.id);
    final records = donorSvc.donationRecordsForFacility(facility.id);
    final donors = donorSvc.donorsForFacility(facility.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Blood Bank Admin')),
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
                  'Blood Bank · ${facility.area} · ${facility.phone}',
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
                    _pill('${admin.totalUnits(facility.id)} units in stock'),
                    _pill('${bookings.length} upcoming slots'),
                    _pill('${donors.length} donors'),
                    _pill(
                        '${requests.where((r) => r.status == RequestStatus.pending).length} pending requests'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ---- Inventory updates ----
          const SectionHeader(title: '🧪 Update inventory'),
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
          const SizedBox(height: 8),
          Text(
            'Tip: fulfilled requests deduct units automatically.',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textGrey.withValues(alpha: 0.9),
            ),
          ),

          const SizedBox(height: 20),

          // ---- Blood requests ----
          const SectionHeader(title: '🩸 Blood requests'),
          if (requests.isEmpty)
            const EmptyState(
              icon: Icons.inbox_outlined,
              title: 'No requests',
              message: 'Requests raised to your blood bank appear here.',
            )
          else
            for (final r in requests)
              _RequestCard(request: r),

          const SizedBox(height: 20),

          // ---- Donation slots ----
          const SectionHeader(title: '💉 Donation slots'),
          if (bookings.isEmpty)
            const EmptyState(
              icon: Icons.event_busy,
              title: 'No upcoming donation slots',
              message: 'Donor bookings appear here — manage them from here.',
            )
          else
            for (final b in bookings)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.water_drop, color: AppTheme.red),
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
                  trailing: const Icon(Icons.chevron_right,
                      size: 18, color: AppTheme.textGrey),
                ),
              ),

          const SizedBox(height: 20),

          // ---- Donors ----
          const SectionHeader(title: '🧑‍🤝‍🧑 Donors'),
          if (donors.isEmpty)
            const EmptyState(
              icon: Icons.person_off_outlined,
              title: 'No donors yet',
              message: 'Donors who donated or booked here appear here.',
            )
          else
            for (final d in donors)
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.red.withValues(alpha: 0.12),
                    child: Text(
                      d.bloodGroup,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.red,
                      ),
                    ),
                  ),
                  title: Text(d.name,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w800)),
                  subtitle: Text(
                    d.lastDonation == null
                        ? (d.hasUpcomingSlot
                            ? 'Upcoming slot booked'
                            : 'No donations yet')
                        : 'Last: ${_dateLabel(d.lastDonation!)} · ${d.donations} donation(s)',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),

          const SizedBox(height: 20),

          // ---- Donation records ----
          const SectionHeader(title: '📜 Donation records'),
          if (records.isEmpty)
            const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No records',
              message: 'Completed donations at your bank appear here.',
            )
          else
            for (final r in records.take(6))
              Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt_long_outlined,
                      color: AppTheme.red),
                  title: Text(
                    '${r.bloodGroup} · ${r.units} unit(s)',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text('${_dateLabel(r.date)} · ${r.status.label}',
                      style: const TextStyle(fontSize: 12)),
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

  Widget _pill(String text) {
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

/// Blood request row with fulfil / reject (shared look with hospital admin).
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
                            content: Text(
                                err ?? 'Request fulfilled — inventory updated.'),
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
