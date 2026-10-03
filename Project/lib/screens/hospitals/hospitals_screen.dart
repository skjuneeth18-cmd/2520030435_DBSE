import 'package:flutter/material.dart';

import '../../data/hospitals_data.dart';
import '../../models/hospital.dart';
import '../../services/blood_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/hospital_card.dart';
import 'hospital_detail_screen.dart';

/// Top-10 Hospitals screen with search + area + verified-only filters.
class HospitalsScreen extends StatefulWidget {
  const HospitalsScreen({super.key});

  @override
  State<HospitalsScreen> createState() => _HospitalsScreenState();
}

class _HospitalsScreenState extends State<HospitalsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  String _area = '';
  bool _verifiedOnly = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Hospital> _filtered() {
    var list = BloodService.instance.topHospitals(limit: 10);
    if (_area.isNotEmpty) {
      list = list.where((h) => h.area == _area).toList();
    }
    if (_verifiedOnly) {
      list = list.where((h) => h.isVerified).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where((h) =>
              h.name.toLowerCase().contains(q) ||
              h.area.toLowerCase().contains(q) ||
              h.specialties.any((s) => s.toLowerCase().contains(q)))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered();

    return Scaffold(
      appBar: AppBar(title: const Text('Top Hospitals')),
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
                    hintText: 'Search hospitals, areas, specialties…',
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
                    icon: Icons.local_hospital_outlined,
                    title: 'No hospitals match',
                    message: 'Clear the search or filters and try again.',
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      for (final h in list)
                        HospitalCard(
                          hospital: h,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HospitalDetailScreen(hospital: h),
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
