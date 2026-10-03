import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/donation_record.dart';
import '../../services/donor_service.dart';
import '../../widgets/empty_state.dart';

/// Donation history: past visits with facility, group and status.
class DonationHistoryScreen extends StatelessWidget {
  const DonationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = DonorService.instance.donationHistory();
    final completed = history
        .where((r) => r.status == DonationRecordStatus.completed)
        .length;
    final totalUnits = history.fold<int>(
      0,
      (sum, r) =>
          sum + (r.status == DonationRecordStatus.completed ? r.units : 0),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Donation history')),
      body: history.isEmpty
          ? const EmptyState(
              icon: Icons.history,
              title: 'No donations yet',
              message:
                  'After your first donation it will be recorded here with date, facility and status.',
            )
          : ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              children: [
                // ---- Stats strip ----
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.red.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _stat('$completed', 'completed'),
                      _stat('$totalUnits', 'units donated'),
                      _stat('❤️', 'lives touched'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                for (final r in history)
                  Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 5),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: (r.status ==
                                          DonationRecordStatus.completed
                                      ? AppTheme.available
                                      : AppTheme.limited)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              r.status == DonationRecordStatus.completed
                                  ? Icons.favorite
                                  : Icons.info_outline,
                              size: 20,
                              color: r.status ==
                                      DonationRecordStatus.completed
                                  ? AppTheme.available
                                  : AppTheme.limited,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.facilityName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_dateLabel(r.date)} · ${r.facilityType}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textGrey),
                                ),
                                if (r.notes != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    r.notes!,
                                    style: const TextStyle(
                                        fontSize: 11.5,
                                        fontStyle: FontStyle.italic,
                                        color: AppTheme.textGrey),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                r.bloodGroup,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (r.status ==
                                              DonationRecordStatus
                                                  .completed
                                          ? AppTheme.available
                                          : AppTheme.limited)
                                      .withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(6),
                                ),
                                child: Text(
                                  r.status.label,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: r.status ==
                                            DonationRecordStatus.completed
                                        ? AppTheme.available
                                        : AppTheme.limited,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _stat(String value, String label) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppTheme.red,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
                fontSize: 11.5, color: AppTheme.textGrey),
          ),
        ],
      );

  static String _dateLabel(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
