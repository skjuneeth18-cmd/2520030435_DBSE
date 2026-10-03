import 'package:flutter/material.dart';

import '../../models/kyc.dart';
import '../../models/donor_verification.dart';
import '../../services/auth_service.dart';
import '../../services/kyc_service.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_badge.dart';

/// Donor-facing KYC + verification screen (Phase 4).
///
/// Shows the current KYC status, donor verification status, and gives the
/// donor a way to apply for KYC (mock: enter masked Aadhaar suffix and
/// submit for admin review).
class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final _formKey = GlobalKey<FormState>();
  final _last4Ctrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _submitError;
  bool _submitting = false;

  @override
  void dispose() {
    _last4Ctrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _applyKYC() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitError = null;
      _submitting = true;
    });
    final result = await _submitKYC();
    setState(() => _submitting = false);
    if (result != null) {
      setState(() => _submitError = result);
    }
  }

  Future<String?> _submitKYC() async {
    // Small delay so the button loading state is visible.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return KYCService.instance.submitKYC(
      aadhaarLast4Masked: _last4Ctrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
  }

  void _cancelKYC() {
    final ok = KYCService.instance.cancelKYC();
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('KYC application withdrawn.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_user_outlined, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Please log in to view your KYC status.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final kyc = KYCService.instance.getKYCRecord(user.id);
    final donorStatus =
        KYCService.instance.getDonorVerification(user.id);
    final fullyVerified =
        KYCService.instance.isDonorFullyVerified(user.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC & Verification'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(title: 'Your Verification Status'),
          if (fullyVerified) ...const [
            _VerifiedBadgeCard(),
            SizedBox(height: 16),
          ],
          _KYCStatusCard(kyc: kyc),
          const SizedBox(height: 24),
          if (kyc == null || kyc.status == KYCStatus.pending) ...[
            _ApplyKYCForm(
              formKey: _formKey,
              last4Ctrl: _last4Ctrl,
              notesCtrl: _notesCtrl,
              submitError: _submitError,
              submitting: _submitting,
              onSubmit: _applyKYC,
              onCancel: kyc != null ? _cancelKYC : null,
            ),
          ] else ...[
            _KYCActionCard(
              status: kyc.status,
              onCancel: kyc.status == KYCStatus.pending ? _cancelKYC : null,
            ),
          ],
          const SizedBox(height: 12),
          _DonorVerificationCard(
            status: donorStatus,
            fullyVerified: fullyVerified,
          ),
        ],
      ),
    );
  }
}

class _KYCStatusCard extends StatelessWidget {
  final KYCRecord? kyc;
  const _KYCStatusCard({required this.kyc});

  @override
  Widget build(BuildContext context) {
    final record = kyc;
    final title = record == null ? 'No KYC Applied' : 'KYC Status';
    final subtitle =
        record == null ? 'You have not applied for KYC yet.' : record.status.label;
    final badge = record == null
        ? PillBadge(
            label: 'Not Applied',
            color: Theme.of(context).colorScheme.outline,
          )
        : PillBadge(
            label: ' ',
            color: switch (record.status) {
              KYCStatus.pending => Colors.orange,
              KYCStatus.verified => Colors.green,
              KYCStatus.rejected => Colors.red,
            },
          );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text(subtitle)),
                const SizedBox(width: 12),
                badge,
              ],
            ),
            if (kyc != null) ...[
              const SizedBox(height: 12),
              _DetailRow('Submitted',
                  '• ${kyc!.submissionDate.day}/${kyc!.submissionDate.month}/${kyc!.submissionDate.year}'),
              _DetailRow('Aadhaar (masked)', kyc!.aadhaarLast4Masked),
              if (kyc!.notes != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Notes: ${kyc!.notes}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const Divider(height: 24),
              Text(
                'Secure reference: ${kyc!.secureRef}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your full Aadhaar number is never stored or shown in this app. '
                'Only a masked suffix and a secure reference are retained.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ApplyKYCForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController last4Ctrl;
  final TextEditingController notesCtrl;
  final String? submitError;
  final bool submitting;
  final VoidCallback onSubmit;
  final VoidCallback? onCancel;

  const _ApplyKYCForm({
    required this.formKey,
    required this.last4Ctrl,
    required this.notesCtrl,
    required this.submitError,
    required this.submitting,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<_ApplyKYCForm> createState() => _ApplyKYCFormState();
}

class _ApplyKYCFormState extends State<_ApplyKYCForm> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apply for KYC',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Enter the last 4 digits of your Aadhaar number as XXXX-1234. '
              'Your full Aadhaar is never stored in this app.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Form(
              key: widget.formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: widget.last4Ctrl,
                    decoration: const InputDecoration(
                      labelText: 'Aadhaar (last 4 digits)',
                      hintText: 'XXXX-1234',
                      helperText: 'Format: XXXX-1234',
                    ),
                    keyboardType: TextInputType.text,
                    maxLength: 9,
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return 'Required';
                      if (!RegExp(r'^XXXX-\d{4}$').hasMatch(v)) {
                        return 'Use format XXXX-1234';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: widget.notesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'Any additional info for the reviewer',
                    ),
                    maxLines: 2,
                  ),
                  if (widget.submitError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      widget.submitError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: widget.submitting ? 'Submitting...' : 'Submit KYC',
                    onPressed: widget.submitting ? null : widget.onSubmit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KYCActionCard extends StatelessWidget {
  final KYCStatus status;
  final VoidCallback? onCancel;
  const _KYCActionCard({required this.status, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      KYCStatus.pending => Colors.orange,
      KYCStatus.verified => Colors.green,
      KYCStatus.rejected => Colors.red,
    };

    final children = <Widget>[
      Icon(
        switch (status) {
          KYCStatus.pending => Icons.hourglass_empty,
          KYCStatus.verified => Icons.verified_user,
          KYCStatus.rejected => Icons.cancel,
        },
        size: 48,
        color: color,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              status.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              switch (status) {
                KYCStatus.pending =>
                    'Your KYC is under review. You will be notified once verified.',
                KYCStatus.verified =>
                    'Your identity has been verified. You can now access donor benefits and coupons.',
                KYCStatus.rejected =>
                    'Your KYC was not approved. Contact support for more information.',
              },
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ];

    if (onCancel != null) {
      children.add(
        PrimaryButton(
          label: 'Withdraw Application',
          onPressed: onCancel,
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: children),
      ),
    );
  }
}

class _DonorVerificationCard extends StatelessWidget {
  final DonorVerificationStatus status;
  final bool fullyVerified;
  const _DonorVerificationCard({
    required this.status,
    required this.fullyVerified,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      DonorVerificationStatus.pending => Colors.orange,
      DonorVerificationStatus.verified => Colors.green,
      DonorVerificationStatus.rejected => Colors.red,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              switch (status) {
                DonorVerificationStatus.pending => Icons.pending_actions,
                DonorVerificationStatus.verified => Icons.check_circle,
                DonorVerificationStatus.rejected => Icons.cancel,
              },
              size: 40,
              color: color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Donor Verification',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status.label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (fullyVerified) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Profile complete and donation-eligible.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerifiedBadgeCard extends StatelessWidget {
  const _VerifiedBadgeCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.verified_user, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Verified Donor',
                    style:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your identity and donor profile have been verified. '
                    'You are eligible for all donor benefits and coupons.',
                    style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer
                            .withValues(alpha: 0.8),
                      ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
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
