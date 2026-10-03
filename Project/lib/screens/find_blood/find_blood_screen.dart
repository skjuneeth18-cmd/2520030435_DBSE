import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../data/hospitals_data.dart';
import '../../models/blood_availability.dart';
import '../../services/blood_service.dart';
import '../../widgets/blood_group_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_badge.dart';
import '../blood_banks/blood_bank_detail_screen.dart';
import '../hospitals/hospital_detail_screen.dart';

/// Find Blood: pick a blood group, optionally filter by area and
/// facility type, and see every facility stocking it.
class FindBloodScreen extends StatefulWidget {
  const FindBloodScreen({super.key});

  @override
  State<FindBloodScreen> createState() => _FindBloodScreenState();
}

class _FindBloodScreenState extends State<FindBloodScreen> {
  String _selectedGroup = 'O+';
  String _selectedArea = ''; // '' = all areas
  String _selectedType = ''; // '' = both types
  bool _showUnavailable = false;

  static const List<String> _types = ['Hospital', 'Blood Bank'];

  @override
  Widget build(BuildContext context) {
    final service = BloodService.instance;

    // Facilities that stock the group (respecting the unavailable toggle).
    final rows = service.findFacilitiesWithBlood(
      group: _selectedGroup,
      area: _selectedArea,
      facilityType: _selectedType,
      includeUnavailable: _showUnavailable,
    );

    final totalFacilities = service.hospitals.where((h) => h.hasBloodBank).length +
        service.bloodBanks.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Find Blood')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // ---- Step 1: blood group ----
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Select blood group',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppTheme.textGrey,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FacilityStock.allGroups
                  .map(
                    (g) => BloodGroupChip(
                      group: g,
                      selected: _selectedGroup == g,
                      onTap: () => setState(() => _selectedGroup = g),
                    ),
                  )
                  .toList(),
            ),
          ),

          // ---- Step 2: area filter ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedArea.isEmpty ? null : _selectedArea,
              decoration: const InputDecoration(
                labelText: 'Filter by area (All areas)',
                prefixIcon: Icon(Icons.location_on_outlined, size: 20),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All areas')),
                ...kAreas.map((a) => DropdownMenuItem(value: a, child: Text(a))),
              ],
              onChanged: (v) => setState(() => _selectedArea = v ?? ''),
            ),
          ),

          // ---- Step 3: facility type filter ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All facilities'),
                  selected: _selectedType.isEmpty,
                  onSelected: (_) => setState(() => _selectedType = ''),
                ),
                for (final t in _types)
                  ChoiceChip(
                    label: Text(t),
                    selected: _selectedType == t,
                    onSelected: (_) => setState(() => _selectedType = t),
                  ),
              ],
            ),
          ),

          // ---- Availability legend ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                const StatusBadge(status: StockStatus.available),
                const SizedBox(width: 8),
                const StatusBadge(status: StockStatus.limited),
                const SizedBox(width: 8),
                const StatusBadge(status: StockStatus.unavailable),
                const Spacer(),
                FilterChip(
                  label: const Text('Show unavailable'),
                  selected: _showUnavailable,
                  onSelected: (v) => setState(() => _showUnavailable = v),
                ),
              ],
            ),
          ),

          // ---- Results ----
          SectionHeader(
            title:
                '$totalFacilities facilities · ${rows.length} result(s) for $_selectedGroup',
            seeAllLabel: '',
          ),
          if (rows.isEmpty)
            const EmptyState(
              icon: Icons.bloodtype_outlined,
              title: 'No facilities found',
              message:
                  'Try a different blood group, widen the area filter, or include unavailable facilities.',
            )
          else
            for (final r in rows)
            _FacilityResultCard(row: r, group: _selectedGroup),
        ],
      ),
    );
  }
}

/// Result row: facility name, area, and the selected group's status/units.
class _FacilityResultCard extends StatelessWidget {
  const _FacilityResultCard({required this.row, required this.group});

  final FacilityRow row;
  final String group;

  @override
  Widget build(BuildContext context) {
    final entry = row.stock.forGroup(group)!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // Jump to the matching detail screen for the full stock grid.
          if (row.type == 'Hospital') {
            final h = BloodService.instance.hospitals
                .firstWhere((h) => h.id == row.id);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => HospitalDetailScreen(hospital: h)),
            );
          } else {
            final b = BloodService.instance.bloodBanks
                .firstWhere((b) => b.id == row.id);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => BloodBankDetailScreen(bloodBank: b)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  group,
                  style: const TextStyle(
                    color: AppTheme.red,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${row.type} · ${row.area}',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textGrey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(status: entry.status),
                  const SizedBox(height: 4),
                  Text(
                    '${entry.units} units',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
