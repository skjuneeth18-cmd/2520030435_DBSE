import 'package:flutter/material.dart';

import '../../models/coupon.dart';
import '../../services/auth_service.dart';
import '../../services/kyc_service.dart';

/// Donor-facing coupons screen (Phase 4).
///
/// Shows active, used and expired coupons, and lets the donor mark a coupon
/// as used at the listed participating hospital.
class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Coupon> _couponsForUser() {
    final user = AuthService.instance.currentUser;
    if (user == null) return [];
    return KYCService.instance.getCouponsForUser(user.id);
  }

  List<Coupon> _active() =>
      _couponsForUser().where((c) => c.isActive).toList();

  List<Coupon> _used() =>
      _couponsForUser().where((c) => c.isUsed).toList();

  List<Coupon> _expired() =>
      _couponsForUser().where((c) => c.isExpired).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Coupons'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Used'),
            Tab(text: 'Expired'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CouponsTab(couponFilter: _active, emptyText: 'No active coupons.'),
          _CouponsTab(couponFilter: _used, emptyText: 'No used coupons yet.'),
          _CouponsTab(couponFilter: _expired, emptyText: 'No expired coupons.'),
        ],
      ),
    );
  }
}

class _CouponsTab extends StatelessWidget {
  final List<Coupon> Function() couponFilter;
  final String emptyText;
  const _CouponsTab({
    required this.couponFilter,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    final coupons = couponFilter();
    if (coupons.isEmpty) {
      return Center(child: Text(emptyText));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        ...coupons.map((c) => _CouponCard(coupon: c)),
      ],
    );
  }
}

class _CouponCard extends StatelessWidget {
  final Coupon coupon;
  const _CouponCard({required this.coupon});

  @override
  Widget build(BuildContext context) {
    final discountText =
        coupon.discountPercent > 0 ? '${coupon.discountPercent}% off' : 'Available';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusBackground(coupon.status),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    coupon.status.label.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _statusTextColor(coupon.status),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.qr_code,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              coupon.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              coupon.code,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              coupon.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _InfoChip(
                  Icons.euro,
                  discountText,
                ),
                if (coupon.maxDiscount != null) ...[
                  const SizedBox(width: 8),
                  _InfoChip(Icons.account_balance_wallet,
                      'Max ₹${coupon.maxDiscount} off'),
                ],
                const Spacer(),
                TextButton(
                  onPressed:
                      coupon.isActive ? () => _showRedeemDialog(context) : null,
                  child: const Text('Redeem'),
                ),
              ],
            ),
            const Divider(),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _DetailChip(Icons.calendar_today, _validUntilText(coupon)),
                if (coupon.status == CouponStatus.used) ...[
                  _DetailChip(
                      Icons.check_circle, 'Used at ${_hospitalName(coupon)}'),
                  _DetailChip(Icons.access_time,
                      'Used ${coupon.usedAt!.day}/${coupon.usedAt!.month}/${coupon.usedAt!.year}'),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusBackground(CouponStatus status) {
    return switch (status) {
      CouponStatus.active => Colors.green.withValues(alpha: 0.15),
      CouponStatus.used => Colors.blue.withValues(alpha: 0.15),
      CouponStatus.expired => Colors.red.withValues(alpha: 0.15),
      CouponStatus.revoked => Colors.orange.withValues(alpha: 0.15),
    };
  }

  Color _statusTextColor(CouponStatus status) {
    return switch (status) {
      CouponStatus.active => Colors.green,
      CouponStatus.used => Colors.blue,
      CouponStatus.expired => Colors.red,
      CouponStatus.revoked => Colors.orange,
    };
  }

  String _validUntilText(Coupon coupon) {
    return 'Valid until ${coupon.validUntil.day}/${coupon.validUntil.month}/${coupon.validUntil.year}';
  }

  String _hospitalName(Coupon coupon) {
    final hosp = KYCService.instance.getParticipatingHospitals()
        .firstWhere(
          (h) => h.id == coupon.participatingHospitalId,
          orElse: () => KYCService.instance.getParticipatingHospitals().first,
        );
    return hosp.name;
  }

  void _showRedeemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Redeem Coupon'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Coupon code: ${coupon.code}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'This coupon is valid only at: ${_hospitalName(coupon)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Text(
              'When you redeem it, show this coupon code and your donor certificate '
              'at the hospital billing counter.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _redeem(context);
            },
            child: const Text('Mark as Redeemed'),
          ),
        ],
      ),
    );
  }

  void _redeem(BuildContext context) {
    final error = KYCService.instance.useCoupon(coupon.id, coupon.participatingHospitalId);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coupon marked as used.')),
      );
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DetailChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
          ),
        ),
      ],
    );
  }
}
