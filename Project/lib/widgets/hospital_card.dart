import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/hospital.dart';

/// Card for hospital lists (home + hospitals tab).
class HospitalCard extends StatelessWidget {
  const HospitalCard({super.key, required this.hospital, this.onTap});

  final Hospital hospital;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      hospital.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    hospital.isVerified
                        ? Icons.verified
                        : Icons.info_outline,
                    size: 18,
                    color: hospital.isVerified
                        ? AppTheme.available
                        : AppTheme.textGrey,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: AppTheme.textGrey),
                  const SizedBox(width: 4),
                  Text(
                    '${hospital.area}, ${hospital.city}',
                    style: const TextStyle(
                        fontSize: 12.5, color: AppTheme.textGrey),
                  ),
                  const Spacer(),
                  const Icon(Icons.star, size: 14, color: AppTheme.limited),
                  const SizedBox(width: 3),
                  Text(
                    hospital.rating.toString(),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _pill(
                    icon: Icons.bloodtype,
                    text: hospital.hasBloodBank ? 'Blood Bank' : 'No Blood Bank',
                    color: hospital.hasBloodBank
                        ? AppTheme.red
                        : AppTheme.textGrey,
                  ),
                  _pill(
                    icon: Icons.emergency,
                    text: hospital.hasEmergency ? '24x7 Emergency' : 'No ER',
                    color: hospital.hasEmergency
                        ? AppTheme.available
                        : AppTheme.textGrey,
                  ),
                  _pill(
                    icon: Icons.medical_services_outlined,
                    text: '${hospital.doctorCount} doctors',
                    color: AppTheme.textGrey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
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
