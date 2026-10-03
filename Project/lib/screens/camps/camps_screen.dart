import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_theme.dart';
import '../../models/camp.dart';
import '../../services/donor_service.dart';
import '../../widgets/donor_cards.dart';
import '../../widgets/empty_state.dart';
import '../auth/login_screen.dart';

/// Camps tab: upcoming monthly blood donation camps.
class CampsScreen extends StatefulWidget {
  const CampsScreen({super.key});

  @override
  State<CampsScreen> createState() => _CampsScreenState();
}

class _CampsScreenState extends State<CampsScreen> {
  bool _showAll = false;
  String? _areaFilter;

  @override
  Widget build(BuildContext context) {
    final areas = DonorService.instance
        .camps(includePast: true)
        .map((c) => c.area)
        .toSet()
        .toList()
      ..sort();

    var camps = DonorService.instance.camps(includePast: _showAll);
    if (_areaFilter != null) {
      camps = camps.where((c) => c.area == _areaFilter).toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Donation camps')),
      body: Column(
        children: [
          // ---- Filters ----
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: const Text('Include past camps'),
                    selected: _showAll,
                    onSelected: (v) => setState(() => _showAll = v),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: const Text('All areas'),
                    selected: _areaFilter == null,
                    onSelected: (_) =>
                        setState(() => _areaFilter = null),
                  ),
                ),
                for (final a in areas)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(a),
                      selected: _areaFilter == a,
                      onSelected: (_) =>
                          setState(() => _areaFilter = a),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: camps.isEmpty
                ? const EmptyState(
                    icon: Icons.campaign_outlined,
                    title: 'No camps found',
                    message:
                        'Try another area or include past camps to see more.',
                  )
                : RefreshIndicator(
                    onRefresh: () async =>
                        setState(() {}), // mock re-fetch
                    child: ListView(
                      padding: const EdgeInsets.only(top: 4, bottom: 24),
                      children: [
                        for (final c in camps)
                          CampCard(
                            camp: c,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CampDetailScreen(camp: c),
                              ),
                            ),
                            onRegister: () =>
                                _register(context, c.id),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

Future<void> _register(BuildContext context, String campId) async {
  final error = DonorService.instance.registerForCamp(campId);
  if (error == 'Please log in to register.' && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please log in to register.')),
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    return;
  }
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
          error ?? '🎉 Registered! Check notifications for details.'),
      backgroundColor: error == null ? Colors.green : AppTheme.red,
    ),
  );
}

/// Full camp detail with organizer info and registration.
class CampDetailScreen extends StatelessWidget {
  const CampDetailScreen({super.key, required this.camp});

  final DonationCamp camp;

  Future<void> _call() async {
    final uri = Uri(
        scheme: 'tel', path: camp.contactPhone.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DonorService.instance,
      builder: (context, _) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final registered =
        DonorService.instance.isRegisteredForCamp(camp.id);
    final camps = DonorService.instance
        .camps(includePast: true)
        .where((c) => c.id == camp.id)
        .toList();
    final live = camps.isEmpty ? camp : camps.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Camp details')),
      floatingActionButton: live.isUpcoming && !live.isFull
          ? FloatingActionButton.extended(
              onPressed: () => _register(context, live.id),
              backgroundColor: registered ? Colors.green : AppTheme.red,
              foregroundColor: Colors.white,
              icon: Icon(registered
                  ? Icons.check_circle_outline
                  : Icons.how_to_reg),
              label: Text(registered ? 'Registered ✓' : 'Register'),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- Header ----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7B1FA2), Color(0xFF4A148C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  live.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${live.dateLabel} · ${live.timeLabel}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${live.location}, ${live.area}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _pill(
                      live.isFull
                          ? 'Camp full'
                          : '${live.slotsLeft} / ${live.totalSlots} slots left',
                    ),
                    _pill('By ${live.organizer}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ---- Blood groups required ----
          const Text(
            'Blood groups needed',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final g in live.bloodGroupsRequired)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.red.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    g,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.red,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // ---- Details ----
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('📅', 'Date', live.dateLabel),
                  _row('🕘', 'Time', live.timeLabel),
                  _row('📍', 'Location', '${live.location}, ${live.area}, '
                      '${live.city}'),
                  _row('🤝', 'Organizer', live.organizer),
                  _row('🪑', 'Slots',
                      '${live.slotsBooked} booked of ${live.totalSlots}'),
                  if (!live.isUpcoming)
                    _row('⌛', 'Status', 'This camp has ended'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _call,
            icon: const Icon(Icons.call, size: 18),
            label: Text('Contact organizer  ${live.contactPhone}'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF7B1FA2),
              side: const BorderSide(color: Color(0xFF7B1FA2)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (registered) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.available.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.available),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You are registered for this camp. '
                      'Walk in anytime during camp hours with a photo ID.',
                      style: TextStyle(
                          fontSize: 12.5, color: AppTheme.textDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  Widget _row(String emoji, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 10),
            SizedBox(
              width: 84,
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
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ),
          ],
        ),
      );
}
