import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/hospital.dart';
import '../../services/doctor_service.dart';
import '../../widgets/info_tile.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/stock_grid.dart';
import '../doctors/doctor_profile_screen.dart';
import '../doctors/doctors_screen.dart';

/// Hospital detail: contact, facilities, verification and live mock stock.
class HospitalDetailScreen extends StatelessWidget {
  const HospitalDetailScreen({super.key, required this.hospital});

  final Hospital hospital;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hospital Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- Header ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.local_hospital,
                    color: AppTheme.red, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${hospital.address}, ${hospital.area}, ${hospital.city}',
                      style: const TextStyle(
                          fontSize: 12.5, color: AppTheme.textGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              VerifiedBadge(isVerified: hospital.isVerified),
              _pill(
                icon: Icons.emergency,
                text: hospital.hasEmergency ? '24x7 Emergency' : 'No ER',
                color: hospital.hasEmergency
                    ? AppTheme.available
                    : AppTheme.textGrey,
              ),
              _pill(
                icon: Icons.bloodtype,
                text: hospital.hasBloodBank ? 'On-site Blood Bank' : 'No Blood Bank',
                color: hospital.hasBloodBank ? AppTheme.red : AppTheme.textGrey,
              ),
              _pill(
                icon: Icons.star,
                text: hospital.rating.toString(),
                color: AppTheme.limited,
              ),
              _pill(
                icon: Icons.medical_services_outlined,
                text: '${hospital.doctorCount} doctors',
                color: AppTheme.textGrey,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ---- Specialties ----
          const Text(
            'Specialties',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: hospital.specialties
                .map(
                  (s) => Chip(
                    label: Text(s, style: const TextStyle(fontSize: 12)),
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 16),

          // ---- Contact info ----
          InfoTile(
            icon: Icons.call_outlined,
            label: 'CONTACT',
            value: hospital.phone,
          ),
          InfoTile(
            icon: Icons.location_on_outlined,
            label: 'AREA',
            value: '${hospital.area}, ${hospital.city}',
          ),

          const SizedBox(height: 12),
          CallStrip(phone: hospital.phone),

          const SizedBox(height: 16),

          const SizedBox(height: 16),

          // ---- Hospital-wise doctors (Phase 3) ----
          _DoctorsSection(hospitalId: hospital.id),

          const SizedBox(height: 16),

          // ---- Blood stock ----
          if (hospital.hasBloodBank) ...[
            const Text(
              'Blood Availability',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            StockGrid(stock: hospital.stock),
          ] else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'This hospital does not have an on-site blood bank. '
                'Check nearby independent blood bank centers.',
                style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _pill({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Hospital-wise doctor listing (Phase 3) with a See-all link.
class _DoctorsSection extends StatelessWidget {
  const _DoctorsSection({required this.hospitalId});

  final String hospitalId;

  @override
  Widget build(BuildContext context) {
    final doctors = DoctorService.instance.doctorsByHospital(hospitalId);
    if (doctors.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Doctors & Consultation',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DoctorsScreen(),
                ),
              ),
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        for (final d in doctors.take(3))
          DoctorCard(
            doctor: d,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DoctorProfileScreen(doctor: d),
              ),
            ),
          ),
        if (doctors.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+${doctors.length - 3} more doctors — tap See all',
              style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
            ),
          ),
      ],
    );
  }
}
