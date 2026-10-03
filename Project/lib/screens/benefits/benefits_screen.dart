import 'package:flutter/material.dart';

import '../../data/benefits_data.dart';
import '../../models/benefit.dart';
import '../../services/blood_service.dart';
import '../../services/kyc_service.dart';
import '../../widgets/section_header.dart';

/// Donor-facing benefits screen (Phase 4).
///
/// Shows available benefits, hospital-wise offers, a brochure view with
/// participating hospitals, and the terms & conditions.
class BenefitsScreen extends StatefulWidget {
  const BenefitsScreen({super.key});

  @override
  State<BenefitsScreen> createState() => _BenefitsScreenState();
}

class _BenefitsScreenState extends State<BenefitsScreen>
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Benefits'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Benefits'),
            Tab(text: 'Hospital Offers'),
            Tab(text: 'Brochure'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AllBenefitsTab(),
          _HospitalOffersTab(),
          _BrochureTab(),
        ],
      ),
    );
  }
}

class _AllBenefitsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final benefits =
        KYCService.instance.getActiveBenefits();
    if (benefits.isEmpty) {
      return const Center(
        child: Text('No active benefits available right now.'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(title: 'Active Benefits'),
        const SizedBox(height: 8),
        ...benefits.map((b) => _BenefitCard(benefit: b)),
      ],
    );
  }
}

class _HospitalOffersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hospitals = KYCService.instance.getParticipatingHospitals();
    if (hospitals.isEmpty) {
      return const Center(child: Text('No participating hospitals.'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(title: 'Hospital-wise Offers'),
        const SizedBox(height: 8),
        ...hospitals.map((h) => _HospitalOfferCard(hospital: h)),
      ],
    );
  }
}

class _BrochureTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hospitals = KYCService.instance.getParticipatingHospitals();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(title: 'Benefits Brochure'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Donor Benefits',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Verified donors of RaktaSetu can enjoy the following benefits '
                  'at participating hospitals and blood banks.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                ..._brochureBenefitSummary(context),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Participating Hospitals',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...hospitals.map((h) => _ParticipatingHospitalChip(hospital: h)),
        const SizedBox(height: 16),
        Text(
          'Coupon Details',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Coupons are issued to verified donors for specific benefits at '
              'specific participating hospitals. Each coupon has a unique code, '
              'a validity period, and a usage status. Coupons are single-use and '
              'non-transferable.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Terms & Conditions',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              kBenefitsTerms.trim(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _brochureBenefitSummary(BuildContext context) {
    final benefits = KYCService.instance.getActiveBenefits();
    if (benefits.isEmpty) {
      return [
        Text(
          'No active benefits right now. Check back later.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ];
    }
    return benefits.map((b) {
      final discountText = b.discountPercent != null && b.discountPercent! > 0
          ? '${b.discountPercent}% off'
          : b.benefitType == BenefitType.freeCheckup
              ? 'Free'
              : 'Benefit';
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.emoji_events, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.title,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '$discountText · ${b.description.split('.').first}.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

class _BenefitCard extends StatelessWidget {
  final Benefit benefit;
  const _BenefitCard({required this.benefit});

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
                Icon(
                  _iconFor(benefit.benefitType),
                  size: 22,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    benefit.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Chip(
                  label: Text(discountText),
                  labelStyle: const TextStyle(fontSize: 12),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              benefit.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _InfoChip(
                  Icons.medical_services,
                  benefit.benefitType.short,
                ),
                const SizedBox(width: 8),
                if (benefit.maxDiscount != null)
                  _InfoChip(
                    Icons.account_balance_wallet,
                    'Max ₹${benefit.maxDiscount} off',
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showHospitalsSheet(context),
                  child: const Text('Where it applies'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(BenefitType type) => switch (type) {
        BenefitType.freeCheckup => Icons.medical_services,
        BenefitType.consultationDiscount => Icons.medical_information,
        BenefitType.diagnosticDiscount => Icons.analytics,
        BenefitType.partnerHospitalBenefit => Icons.local_hospital,
      };

  void _showHospitalsSheet(BuildContext context) {
    final participating = KYCService.instance.getParticipatingHospitals();
    final applicable = <({String name, String area})>[];
    for (final id in benefit.participatingHospitalIds) {
      final hospital = BloodService.instance.hospitalById(id);
      final bank = BloodService.instance.bloodBankById(id);
      final seeded = participating.where((h) => h.id == id).firstOrNull;
      final name = hospital?.name ?? bank?.name ?? seeded?.name;
      final area = hospital?.area ?? bank?.area ?? seeded?.area;
      if (name != null && area != null) {
        applicable.add((name: name, area: area));
      }
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Available at',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: applicable
                    .map((e) => ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(e.name),
                          subtitle: Text(e.area),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HospitalOfferCard extends StatelessWidget {
  final ParticipatingHospital hospital;
  const _HospitalOfferCard({required this.hospital});

  @override
  Widget build(BuildContext context) {
    final offers = KYCService.instance
        .getBenefitsForHospital(hospital.id)
        .where((b) => b.isActive)
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: const Icon(Icons.location_on),
        title: Text(hospital.name),
        subtitle: Text(hospital.area),
        trailing: Icon(
          hospital.type == 'hospital' ? Icons.local_hospital : Icons.water_drop,
          color: Theme.of(context).colorScheme.primary,
        ),
        children: [
          if (offers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No active offers at this location right now.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          else
            ...offers.map((o) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${o.title} — ${(o.discountPercent ?? 0) > 0 ? '${o.discountPercent}% off' : 'Available'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}

class _ParticipatingHospitalChip extends StatelessWidget {
  final ParticipatingHospital hospital;
  const _ParticipatingHospitalChip({required this.hospital});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Chip(
        avatar: Icon(
          hospital.type == 'hospital' ? Icons.local_hospital : Icons.water_drop,
          size: 18,
        ),
        label: Text(
          '${hospital.name} (${hospital.area})',
          style: const TextStyle(fontSize: 13),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
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
