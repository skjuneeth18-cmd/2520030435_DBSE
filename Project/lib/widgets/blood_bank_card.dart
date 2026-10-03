import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/blood_bank.dart';

/// Card for blood bank lists (home + blood banks tab).
class BloodBankCard extends StatelessWidget {
  const BloodBankCard({super.key, required this.bloodBank, this.onTap});

  final BloodBank bloodBank;
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
                      bloodBank.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    bloodBank.isVerified ? Icons.verified : Icons.info_outline,
                    size: 18,
                    color: bloodBank.isVerified
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
                  Expanded(
                    child: Text(
                      '${bloodBank.area}, ${bloodBank.city}',
                      style: const TextStyle(
                          fontSize: 12.5, color: AppTheme.textGrey),
                    ),
                  ),
                  const Icon(Icons.schedule, size: 14, color: AppTheme.textGrey),
                  const SizedBox(width: 3),
                  Text(
                    bloodBank.openHours,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textGrey),
                  ),
                ],
              ),
              if (bloodBank.affiliatedHospital.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.local_hospital_outlined,
                        size: 14, color: AppTheme.red),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        bloodBank.affiliatedHospital,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textGrey,
                          fontStyle: FontStyle.italic,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
