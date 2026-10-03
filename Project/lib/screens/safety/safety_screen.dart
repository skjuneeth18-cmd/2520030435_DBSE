import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/safety_info.dart';

/// Basic Safety section: eligibility, pre/post-donation precautions
/// and medical screening info, as expandable panels.
class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donation Safety')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '🩸 A single blood donation can save up to three lives. '
              'Read the guidelines below before and after you donate.',
              style: TextStyle(
                fontSize: 13.5,
                color: AppTheme.textDark,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final info in SafetyInfo.all)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: info == SafetyInfo.all.first,
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  childrenPadding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  leading: Text(
                    info.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    info.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  iconColor: AppTheme.red,
                  collapsedIconColor: AppTheme.red,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final point in info.points)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.check_circle,
                                    size: 15,
                                    color: AppTheme.available,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    point,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textDark,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'Disclaimer: This information is for general guidance only and '
            'does not replace advice from a qualified medical professional. '
            'Final eligibility is always decided by the blood bank\'s medical officer.',
            style: TextStyle(fontSize: 11.5, color: AppTheme.textGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
