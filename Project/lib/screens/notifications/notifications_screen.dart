import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../data/notifications_data.dart';
import '../../models/app_notification.dart';
import '../../services/auth_service.dart';
import '../../services/donor_service.dart';
import '../../widgets/empty_state.dart';

/// Notifications screen with filter chips per category.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationCategory? _filter;

  /// Donor notifications (Phase 2) on top of the city-wide feed.
  List<AppNotification> get _all {
    if (!AuthService.instance.isLoggedIn) return kNotifications;
    return [
      ...DonorService.instance.donorNotifications(),
      ...kNotifications,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final all = _all;
    final list = _filter == null
        ? all
        : all.where((n) => n.category == _filter).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                ),
                for (final c in NotificationCategory.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text('${c.emoji} ${c.label}'),
                      selected: _filter == c,
                      onSelected: (_) => setState(() => _filter = c),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const EmptyState(
                    icon: Icons.notifications_off_outlined,
                    title: 'Nothing here',
                    message: 'No notifications in this category yet.',
                  )
                : ListView(
                    padding: const EdgeInsets.only(top: 4, bottom: 24),
                    children: [
                      for (final n in list) _NotificationCard(n: n),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.n});

  final AppNotification n;

  Color _accent(AppNotification n) => switch (n.category) {
        NotificationCategory.emergency => AppTheme.red,
        NotificationCategory.availability => AppTheme.available,
        NotificationCategory.areaAlert => AppTheme.limited,
        NotificationCategory.donationCamp => const Color(0xFF7B1FA2),
        NotificationCategory.news => const Color(0xFF1565C0),
        NotificationCategory.slotConfirmation => AppTheme.available,
        NotificationCategory.slotReminder => AppTheme.limited,
        NotificationCategory.donationUpdate => AppTheme.red,
      };

  @override
  Widget build(BuildContext context) {
    final accent = _accent(n);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
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
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                n.category.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      Text(
                        n.timeAgo,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.body,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppTheme.textGrey,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      n.area.isEmpty ? n.category.label : '${n.category.label} · ${n.area}',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
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
