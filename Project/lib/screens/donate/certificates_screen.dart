import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/donor_certificate.dart';
import '../../services/donor_service.dart';
import '../../widgets/donor_cards.dart';
import '../../widgets/empty_state.dart';

/// Donor certificates list; tap a certificate for the full view.
class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final certs = DonorService.instance.myCertificates();

    return Scaffold(
      appBar: AppBar(title: const Text('My certificates')),
      body: certs.isEmpty
          ? const EmptyState(
              icon: Icons.workspace_premium_outlined,
              title: 'No certificates yet',
              message:
                  'A digital certificate is issued automatically after each completed donation.',
            )
          : ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              children: [
                for (final c in certs)
                  CertificateCard(
                    certificate: c,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CertificateDetailScreen(certificate: c),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

/// Printable-style certificate view.
class CertificateDetailScreen extends StatelessWidget {
  const CertificateDetailScreen({super.key, required this.certificate});

  final DonorCertificate certificate;

  @override
  Widget build(BuildContext context) {
    final c = certificate;
    return Scaffold(
      appBar: AppBar(title: const Text('Certificate')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1565C0), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(Icons.volunteer_activism,
                  size: 44, color: AppTheme.red),
              const SizedBox(height: 8),
              const Text(
                'Certificate of Appreciation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'RaktaSetu · Blood Donation',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textGrey,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Proudly presented to',
                style: TextStyle(fontSize: 12.5, color: AppTheme.textGrey),
              ),
              const SizedBox(height: 6),
              Text(
                c.donorName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.red,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'for the noble act of voluntary blood donation',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              _row('Blood group', c.bloodGroup),
              _row('Donation date', c.donationDateLabel),
              _row('Facility',
                  '${c.facilityName} (${c.facilityType})'),
              _row('Certificate ID', c.certificateId),
              _row('Issued on', c.issuedDateLabel),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                '“Donate blood, save lives.”',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textGrey,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
            ),
          ],
        ),
      );
}
