import 'package:flutter/material.dart';

import '../../data/benefits_data.dart';
import '../../models/benefit.dart';
import '../../models/coupon.dart';
import '../../services/auth_service.dart';
import '../../services/blood_service.dart';
import '../../services/kyc_service.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_header.dart';

/// Admin screen for managing benefits and coupons (Phase 4).
///
/// Create / edit / delete benefits and coupons, and view participating
/// hospitals.
class BenefitsCouponsAdminScreen extends StatefulWidget {
  const BenefitsCouponsAdminScreen({super.key});

  @override
  State<BenefitsCouponsAdminScreen> createState() =>
      _BenefitsCouponsAdminScreenState();
}

class _BenefitsCouponsAdminScreenState
    extends State<BenefitsCouponsAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Benefits & Coupons'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Benefits'),
            Tab(text: 'Coupons'),
            Tab(text: 'Create Coupon'),
            Tab(text: 'Hospitals'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BenefitsTab(),
          _CouponsTab(),
          _CreateCouponTab(),
          _HospitalsTab(),
        ],
      ),
    );
  }
}

class _BenefitsTab extends StatefulWidget {
  @override
  State<_BenefitsTab> createState() => _BenefitsTabState();
}

class _BenefitsTabState extends State<_BenefitsTab> {
  String? _error;
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = KYCService.instance.getBenefits()
      ..sort((a, b) => a.title.compareTo(b.title));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_error != null) ...[
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SectionHeader(title: 'Benefits'),
        const SizedBox(height: 8),
        ...all.map((b) => _BenefitAdminCard(
              benefit: b,
              onDelete: () => _deleteBenefit(b.id),
            )),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Benefit',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Benefit ID',
                    hintText: 'e.g. b99',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Title',
                  ),
                ),
                const SizedBox(height: 8),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<BenefitType>(
                  initialValue: BenefitType.freeCheckup,
                  decoration:
                      const InputDecoration(labelText: 'Benefit type'),
                  items: BenefitType.values
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.label),
                          ))
                      .toList(),
                  onChanged: (_) {},
                ),
                const SizedBox(height: 8),
                PrimaryButton(
                  label: 'Add Benefit',
                  onPressed: () {
                    setState(() => _error = 'Mock: benefit add is not wired for manual entry. Use seed data.');
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _deleteBenefit(String id) {
    final error = KYCService.instance.deleteBenefit(id);
    setState(() => _error = error);
    _notesCtrl.clear();
  }
}

class _BenefitAdminCard extends StatelessWidget {
  final Benefit benefit;
  final VoidCallback onDelete;
  const _BenefitAdminCard({
    required this.benefit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final discountText = benefit.discountPercent != null &&
            benefit.discountPercent! > 0
        ? '${benefit.discountPercent}% off'
        : benefit.benefitType == BenefitType.freeCheckup
            ? 'Free'
            : 'Benefit';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        benefit.title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        benefit.id,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(benefit.benefitType.short),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(discountText),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Delete benefit',
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              benefit.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Hospitals: ${benefit.participatingHospitalIds.join(", ")}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const Divider(height: 24),
            Row(
              children: [
                _InfoChip(
                  Icons.calendar_today,
                  'From ${_fmt(benefit.isValidFrom)}',
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  Icons.calendar_today,
                  'Until ${_fmt(benefit.isValidUntil)}',
                ),
                const Spacer(),
                _InfoChip(Icons.hotel, 'Active: ${benefit.isActive}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime? d) =>
      d == null ? '—' : '${d.day}/${d.month}/${d.year}';
}

class _CouponsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final coupons = KYCService.instance.getAllCoupons();
    if (coupons.isEmpty) {
      return const Center(child: Text('No coupons yet.'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(title: 'Coupons'),
        const SizedBox(height: 8),
        ...coupons.map((c) => _CouponAdminCard(coupon: c)),
      ],
    );
  }
}

class _CouponAdminCard extends StatelessWidget {
  final Coupon coupon;
  const _CouponAdminCard({required this.coupon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coupon.title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        coupon.code,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(coupon.status.label),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.orange),
                  onPressed: coupon.status == CouponStatus.used
                      ? null
                      : () {
                          final err =
                              KYCService.instance.revokeCoupon(coupon.id);
                          final messenger = ScaffoldMessenger.of(context);
                          if (err != null) {
                            messenger.showSnackBar(SnackBar(content: Text(err)));
                          } else {
                            messenger.showSnackBar(const SnackBar(
                                content: Text('Coupon revoked.')));
                          }
                        },
                  tooltip: 'Revoke coupon',
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              coupon.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _InfoChip(
                  Icons.person,
                  'User: ${_userName(coupon.issuedToUserId)}',
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  Icons.hotel,
                  'Hospital: ${_hospitalName(coupon.participatingHospitalId)}',
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  Icons.calendar_today,
                  'Expires ${_fmt(coupon.validUntil)}',
                ),
                if (coupon.status == CouponStatus.used) ...[
                  const SizedBox(width: 8),
                  _InfoChip(
                    Icons.check_circle,
                    'Used ${_fmt(coupon.usedAt)}',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _userName(String userId) =>
      AuthService.instance.userById(userId)?.fullName ?? userId;

  String _hospitalName(String id) {
    try {
      return KYCService.instance
          .getParticipatingHospitals()
          .firstWhere((h) => h.id == id)
          .name;
    } catch (_) {
      return id;
    }
  }

  String _fmt(DateTime? d) =>
      d == null ? '—' : '${d.day}/${d.month}/${d.year}';
}

class _CreateCouponTab extends StatefulWidget {
  @override
  State<_CreateCouponTab> createState() => _CreateCouponTabState();
}

class _CreateCouponTabState extends State<_CreateCouponTab> {
  final _discountCtrl = TextEditingController(text: '20');
  final _maxDiscountCtrl = TextEditingController();
  final _validDaysCtrl = TextEditingController(text: '90');
  BenefitType _type = BenefitType.consultationDiscount;
  String? _selectedHospital;
  String? _createError;

  @override
  void dispose() {
    _discountCtrl.dispose();
    _maxDiscountCtrl.dispose();
    _validDaysCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hospitals =
        KYCService.instance.getParticipatingHospitals();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_createError != null) ...[
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _createError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SectionHeader(title: 'Create Coupon'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generate a coupon for verified donors.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _discountCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Discount %'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _maxDiscountCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Max discount (₹, optional)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<BenefitType>(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'Benefit type'),
                  items: BenefitType.values
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.label),
                          ))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _type = v!;
                      _createError = null;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedHospital,
                  decoration: const InputDecoration(labelText: 'Participating hospital'),
                  items: hospitals
                      .map((h) => DropdownMenuItem(
                            value: h.id,
                            child: Text('${h.name} (${h.area})'),
                          ))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedHospital = v;
                      _createError = null;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _validDaysCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Validity (days)',
                    hintText: 'e.g. 90',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Generate Coupon',
                  onPressed: _selectedHospital == null
                      ? null
                      : _generate,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _generate() {
    final discountText = _discountCtrl.text.trim();
    final discount = int.tryParse(discountText) ?? 0;
    final maxDiscountText = _maxDiscountCtrl.text.trim();
    final maxDiscount = maxDiscountText.isEmpty
        ? null
        : int.tryParse(maxDiscountText);
    final daysText = _validDaysCtrl.text.trim();
    final days = int.tryParse(daysText) ?? 90;

    setState(() => _createError = null);

    final result = KYCService.instance.generateCoupon(
      userId: AuthService.instance.currentUser!.id,
      participatingHospitalId: _selectedHospital!,
      benefitType: _type,
      discountPercent: discount,
      maxDiscount: maxDiscount,
      validityDays: days,
    );

    setState(() {
      if (result is String) {
        _createError = result;
      } else if (result is Coupon) {
        _createError = null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Coupon created: ${result.code} — ${result.title}'),
          ),
        );
        _selectedHospital = null;
        _discountCtrl.clear();
        _maxDiscountCtrl.clear();
        _validDaysCtrl.clear();
      }
    });
  }
}

class _HospitalsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hospitals =
        KYCService.instance.getParticipatingHospitals();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(title: 'Participating Hospitals'),
        const SizedBox(height: 8),
        ...hospitals.map((h) => _HospitalAdminChip(hospital: h)),
      ],
    );
  }
}

class _HospitalAdminChip extends StatelessWidget {
  final ParticipatingHospital hospital;
  const _HospitalAdminChip({required this.hospital});

  @override
  Widget build(BuildContext context) {
    final hospital_ = BloodService.instance.hospitalById(hospital.id);
    final bank = BloodService.instance.bloodBankById(hospital.id);
    final contact = hospital_?.phone ?? bank?.phone ?? '—';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          hospital.type == 'hospital' ? Icons.local_hospital : Icons.water_drop,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(hospital.name),
        subtitle: Text(
          '${hospital.area} · $contact',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showAboutDialog(
                  context: context,
                  applicationName: hospital.name,
                  applicationVersion: hospital.id,
                  applicationLegalese: 'Phase 4 participating hospital.',
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      hospital.type == 'hospital'
                          ? 'Hospital facility'
                          : 'Blood bank facility',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              },
              tooltip: 'Details',
            ),
          ],
        ),
      ),
    );
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
