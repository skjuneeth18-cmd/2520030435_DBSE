import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/blood_requirement.dart';
import 'status_badge.dart';

/// Card for area-wise blood requirements.
class RequirementCard extends StatelessWidget {
  const RequirementCard({super.key, required this.requirement});

  final BloodRequirement requirement;

  @override
  Widget build(BuildContext context) {
    final open = requirement.status == RequirementStatus.open;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    requirement.bloodGroup,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${requirement.unitsNeeded} unit(s) of ${requirement.bloodGroup}',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        requirement.facilityName,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppTheme.textGrey),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${requirement.area} · ${requirement.facilityType} · ${requirement.postedAgo}',
                        style: const TextStyle(
                            fontSize: 11.5, color: AppTheme.textGrey),
                      ),
                    ],
                  ),
                ),
                EmergencyBadge(level: requirement.emergencyLevel),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                RequirementStatusBadge(status: requirement.status),
                const Spacer(),
                if (open)
                  TextButton.icon(
                    onPressed: () {}, // Phase 2: direct dialer + donor match
                    icon: const Icon(Icons.call, size: 16),
                    label: const Text('Contact'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.red,
                      textStyle: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
