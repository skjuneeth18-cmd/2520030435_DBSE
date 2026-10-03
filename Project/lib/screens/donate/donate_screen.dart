import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/donation_record.dart';
import '../../models/donor.dart';
import '../../services/auth_service.dart';
import '../../services/donor_service.dart';
import '../../widgets/donor_cards.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_header.dart';
import '../auth/login_screen.dart';
import '../camps/camps_screen.dart';
import 'book_slot_screen.dart';
import 'certificates_screen.dart';
import 'donation_history_screen.dart';
import 'my_bookings_screen.dart';

/// Donate tab: the donor dashboard. Shows eligibility, next appointment,
/// recent history, upcoming camps and latest certificates.
class DonateScreen extends StatefulWidget {
  const DonateScreen({super.key});

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  @override
  void initState() {
    super.initState();
    AuthService.instance.addListener(_refresh);
    DonorService.instance.addListener(_refresh);
    // Mock lifecycle: complete bookings whose date has passed.
    // Deferred to after the first frame — notifyListeners() during
    // build would crash listeners that call setState().
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) DonorService.instance.refresh();
    });
  }

  @override
  void dispose() {
    AuthService.instance.removeListener(_refresh);
    DonorService.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Donate Blood')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.volunteer_activism_outlined,
                  size: 64, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('Log in to become a donor'),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Book donation slots, register for camps and earn certificates.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    final donor = DonorService.instance.donorProfile()!;
    final bookings = DonorService.instance.activeBookings();
    final history = DonorService.instance.donationHistory();
    final camps = DonorService.instance.camps();
    final certs = DonorService.instance.myCertificates();

    return Scaffold(
      appBar: AppBar(title: const Text('Donate Blood')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // ---- Donor summary card ----
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.red, AppTheme.redDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: Text(
                        user.initials,
                        style: const TextStyle(
                          color: AppTheme.red,
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
                            '${user.fullName.split(' ').first}, ready to save lives?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${user.bloodGroup} · ${user.area}'
                            '${user.age != null ? ' · ${user.age} yrs' : ''}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            donor.eligibility.emoji == '✅'
                                ? Icons.check_circle
                                : donor.eligibility.emoji == '⏳'
                                    ? Icons.schedule
                                    : donor.eligibility.emoji == '🚫'
                                        ? Icons.block
                                        : Icons.help_outline,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            donor.eligibility.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '❤️ ${donor.donationCount} donation${donor.donationCount == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                if (donor.nextEligibleOn != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'You can donate again after '
                    '${DonorService.instance.nextEligibleLabel}.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ---- Primary action ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () => _push(const BookSlotScreen()),
              icon: const Icon(Icons.event_available),
              label: const Text('Book a donation slot'),
            ),
          ),
          const SizedBox(height: 4),

          // ---- Next appointment ----
          SectionHeader(
            title: '🕘 My donation slots',
            onSeeAll: () => _push(const MyBookingsScreen()),
          ),
          if (bookings.isEmpty)
            const EmptyState(
              icon: Icons.event_busy_outlined,
              title: 'No upcoming slots',
              message:
                  'Book a slot at a hospital or blood bank near you and walk in at your time.',
            )
          else
            for (final b in bookings.take(2))
              BookingCard(
                booking: b,
                onTap: () => _push(const MyBookingsScreen()),
              ),

          // ---- Recent history ----
          SectionHeader(
            title: '📋 Donation history',
            onSeeAll: () => _push(const DonationHistoryScreen()),
          ),
          if (history.isEmpty)
            const EmptyState(
              icon: Icons.history,
              title: 'No donations yet',
              message: 'Your completed donations will appear here.',
            )
          else
            for (final r in history.take(2))
              _HistoryTile(record: r),

          // ---- Upcoming camps ----
          SectionHeader(
            title: '📢 Upcoming camps',
            onSeeAll: () => _push(const CampsScreen()),
          ),
          if (camps.isEmpty)
            const EmptyState(
              icon: Icons.campaign_outlined,
              title: 'No camps scheduled',
              message: 'New camp announcements will show up here.',
            )
          else
            for (final c in camps.take(1)) CampCard(camp: c),

          // ---- Certificates ----
          SectionHeader(
            title: '🏅 My certificates',
            onSeeAll: () => _push(const CertificatesScreen()),
          ),
          if (certs.isEmpty)
            const EmptyState(
              icon: Icons.workspace_premium_outlined,
              title: 'No certificates yet',
              message:
                  'After each completed donation you receive a digital certificate here.',
            )
          else
            for (final c in certs.take(2))
              CertificateCard(
                certificate: c,
                compact: true,
                onTap: () => _push(const CertificatesScreen()),
              ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Compact history row used on the dashboard.
class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.record});

  final DonationRecord record;

  @override
  Widget build(BuildContext context) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final isCompleted = record.status.label == 'Completed';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          isCompleted ? Icons.check_circle : Icons.info_outline,
          color: isCompleted ? AppTheme.available : AppTheme.limited,
          size: 24,
        ),
        title: Text(
          record.facilityName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontSize: 13.5, fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${record.date.day} ${months[record.date.month - 1]} '
          '${record.date.year} · ${record.bloodGroup} · '
          '${record.facilityType}',
          style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
        ),
        trailing: Text(
          record.status.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isCompleted ? AppTheme.available : AppTheme.limited,
          ),
        ),
      ),
    );
  }
}
