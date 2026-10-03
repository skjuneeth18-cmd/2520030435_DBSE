import 'package:flutter/material.dart';

import '../../models/donor_verification.dart';
import '../../models/kyc.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/kyc_service.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_badge.dart';

/// Admin screen for KYC review and donor verification (Phase 4).
///
/// Lists all users with KYC records, lets the admin verify/reject KYC and
/// donor verification status.
class KYCAdminScreen extends StatefulWidget {
  const KYCAdminScreen({super.key});

  @override
  State<KYCAdminScreen> createState() => _KYCAdminScreenState();
}

class _KYCAdminScreenState extends State<KYCAdminScreen> {
  String? _reviewError;
  final _reviewNoteCtrl = TextEditingController();

  @override
  void dispose() {
    _reviewNoteCtrl.dispose();
    super.dispose();
  }

  List<KYCRecord> get _kycRecords =>
      KYCService.instance.getKYCRecords();

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC & Donor Verification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            onPressed: () => _showDonorList(context),
            tooltip: 'All donors',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_reviewError != null) ...[
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _reviewError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SectionHeader(title: 'KYC Review Queue'),
          const SizedBox(height: 8),
          if (_kycRecords.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No KYC records to review.'),
              ),
            )
          else
            ..._kycRecords.map((record) => _KYCReviewCard(
                  record: record,
                  reviewNoteCtrl: _reviewNoteCtrl,
                  onReview: (status) => _reviewKYC(record.userId, status),
                )),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Quick Actions'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.playlist_remove),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Approve all pending KYC',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Bulk approve pending KYC records',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: _approveAllPending,
                    child: const Text('Approve All'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistics',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _StatsRow(
                    label: 'Total KYC records',
                    value: '$_kycRecords.length',
                  ),
                  const Divider(height: 24),
                  _StatsRow(
                    label: 'Verified',
                    value: '${_kycRecords.where((r) => r.status == KYCStatus.verified).length}',
                  ),
                  const Divider(height: 24),
                  _StatsRow(
                    label: 'Pending',
                    value: '${_kycRecords.where((r) => r.status == KYCStatus.pending).length}',
                  ),
                  const Divider(height: 24),
                  _StatsRow(
                    label: 'Rejected',
                    value: '${_kycRecords.where((r) => r.status == KYCStatus.rejected).length}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _reviewKYC(String userId, KYCStatus status) async {
    final note = _reviewNoteCtrl.text.trim();
    setState(() {
      _reviewError = null;
    });
    final result =
        KYCService.instance.reviewKYC(userId, status, note.isEmpty ? null : note);
    setState(() {
      _reviewNoteCtrl.clear();
      _reviewError = result;
    });
  }

  void _approveAllPending() {
    for (final record in _kycRecords.where((r) => r.status == KYCStatus.pending)) {
      KYCService.instance.reviewKYC(record.userId, KYCStatus.verified, 'Bulk approved by admin');
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All pending KYC records approved.')),
      );
    }
  }

  void _showDonorList(BuildContext context) {
    final users = AuthService.instance.allUsers;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'All Users',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: users.map((u) {
                  final dv =
                      KYCService.instance.getDonorVerification(u.id);
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(u.initials),
                    ),
                    title: Text(u.fullName),
                    subtitle: Text('${u.email} · ${u.bloodGroup}'),
                    trailing: PillBadge(
                      label: ' ',
                      color: switch (dv) {
                        DonorVerificationStatus.pending => Colors.orange,
                        DonorVerificationStatus.verified => Colors.green,
                        DonorVerificationStatus.rejected => Colors.red,
                      },
                    ),
                    onTap: () => Navigator.pop(ctx),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KYCReviewCard extends StatelessWidget {
  final KYCRecord record;
  final TextEditingController reviewNoteCtrl;
  final void Function(KYCStatus) onReview;

  const _KYCReviewCard({
    required this.record,
    required this.reviewNoteCtrl,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final user = _findUser(record.userId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(user?.initials ?? '?')),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'Unknown',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        '${user?.email ?? ''} · ${user?.bloodGroup ?? ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PillBadge(
                  label: ' ',
                  color: _statusColor(record.status),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            _DetailRow('Submitted', _fmt(record.submissionDate)),
            _DetailRow('Aadhaar (masked)', record.aadhaarLast4Masked),
            if (record.notes != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Notes: ${record.notes}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Secure ref: ${record.secureRef}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmAction(context, 'Reject', () {
                      onReview(KYCStatus.rejected);
                    }),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Reject'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _confirmAction(context, 'Verify', () {
                      onReview(KYCStatus.verified);
                    }),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Verify'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _confirmAction(
      BuildContext context, String label, VoidCallback action) {
    return PrimaryButton(
      label: label,
      onPressed: () {
        action();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label KYC status updated.')),
        );
      },
    );
  }

  Color _statusColor(KYCStatus status) => switch (status) {
        KYCStatus.pending => Colors.orange,
        KYCStatus.verified => Colors.green,
        KYCStatus.rejected => Colors.red,
      };

  String _fmt(DateTime d) =>
      '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';

  AppUser? _findUser(String userId) =>
      AuthService.instance.userById(userId);
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatsRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
