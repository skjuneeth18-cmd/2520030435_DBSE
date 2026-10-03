import 'package:flutter/material.dart';

import '../../data/hospitals_data.dart';
import '../../services/blood_service.dart';
import '../../widgets/blood_bank_card.dart';
import '../../widgets/empty_state.dart';
import 'blood_bank_detail_screen.dart';

/// Blood Bank Centers screen with search + area + verified-only filters.
class BloodBanksScreen extends StatefulWidget {
  const BloodBanksScreen({super.key});

  @override
  State<BloodBanksScreen> createState() => _BloodBanksScreenState();
}

class _BloodBanksScreenState extends State<BloodBanksScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  String _area = '';
  bool _verifiedOnly = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var list = BloodService.instance.bloodBanks;
    if (_area.isNotEmpty) {
      list = list.where((b) => b.area == _area).toList();
    }
    if (_verifiedOnly) {
      list = list.where((b) => b.isVerified).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where((b) =>
              b.name.toLowerCase().contains(q) ||
              b.area.toLowerCase().contains(q) ||
              b.affiliatedHospital.toLowerCase().contains(q))
        .toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Blood Bank Centers')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search blood banks, areas…',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _area.isEmpty ? null : _area,
                        decoration: const InputDecoration(
                          labelText: 'Area (All)',
                          isDense: true,
                          prefixIcon:
                              Icon(Icons.location_on_outlined, size: 18),
                        ),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('All areas')),
                          ...kAreas.map(
                            (a) => DropdownMenuItem(value: a, child: Text(a)),
                          ),
                        ],
                        onChanged: (v) => setState(() => _area = v ?? ''),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Verified only'),
                      selected: _verifiedOnly,
                      onSelected: (v) => setState(() => _verifiedOnly = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const EmptyState(
                    icon: Icons.water_drop_outlined,
                    title: 'No blood banks match',
                    message: 'Clear the search or filters and try again.',
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      for (final b in list)
                        BloodBankCard(
                          bloodBank: b,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BloodBankDetailScreen(bloodBank: b),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
