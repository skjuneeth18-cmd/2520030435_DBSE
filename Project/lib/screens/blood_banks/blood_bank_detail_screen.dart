import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/blood_bank.dart';
import '../../widgets/info_tile.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/stock_grid.dart';

/// Blood bank detail: affiliation, timings, contact and live mock stock.
class BloodBankDetailScreen extends StatelessWidget {
  const BloodBankDetailScreen({super.key, required this.bloodBank});

  final BloodBank bloodBank;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blood Bank Details')),
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
                child: const Icon(Icons.water_drop,
                    color: AppTheme.red, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bloodBank.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${bloodBank.address}, ${bloodBank.area}, ${bloodBank.city}',
                      style: const TextStyle(
                          fontSize: 12.5, color: AppTheme.textGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          VerifiedBadge(isVerified: bloodBank.isVerified),

          const SizedBox(height: 16),

          // ---- Info ----
          if (bloodBank.affiliatedHospital.isNotEmpty)
            InfoTile(
              icon: Icons.local_hospital_outlined,
              label: 'AFFILIATED HOSPITAL',
              value: bloodBank.affiliatedHospital,
            ),
          InfoTile(
            icon: Icons.schedule_outlined,
            label: 'OPEN HOURS',
            value: bloodBank.openHours,
          ),
          InfoTile(
            icon: Icons.call_outlined,
            label: 'CONTACT',
            value: bloodBank.phone,
          ),
          InfoTile(
            icon: Icons.location_on_outlined,
            label: 'AREA',
            value: '${bloodBank.area}, ${bloodBank.city}',
          ),

          const SizedBox(height: 12),
          CallStrip(phone: bloodBank.phone),

          const SizedBox(height: 16),

          // ---- Stock ----
          const Text(
            'Blood Availability',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          StockGrid(stock: bloodBank.stock),
        ],
      ),
    );
  }
}
