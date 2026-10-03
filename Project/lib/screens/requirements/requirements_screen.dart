import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../data/hospitals_data.dart';
import '../../models/blood_requirement.dart';
import '../../services/blood_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/requirement_card.dart';

/// Area-Wise Blood Requirements screen with filters for area,
/// emergency level and status.
class RequirementsScreen extends StatefulWidget {
  const RequirementsScreen({super.key});

  @override
  State<RequirementsScreen> createState() => _RequirementsScreenState();
}

class _RequirementsScreenState extends State<RequirementsScreen> {
  String _area = '';
  EmergencyLevel? _level;
  bool _showFulfilled = false;

  @override
  Widget build(BuildContext context) {
    final list = BloodService.instance.requirements(
      area: _area,
      level: _level,
      openOnly: !_showFulfilled,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Blood Requirements')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Column(
              children: [
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
                    Expanded(
                      child: DropdownButtonFormField<EmergencyLevel>(
                        initialValue: _level,
                        decoration: const InputDecoration(
                          labelText: 'Emergency (All)',
                          isDense: true,
                          prefixIcon: Icon(Icons.warning_amber_outlined,
                              size: 18),
                        ),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('All levels')),
                          ...EmergencyLevel.values.map(
                            (l) => DropdownMenuItem(
                                value: l, child: Text(l.label)),
                          ),
                        ],
                        onChanged: (v) => setState(() => _level = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FilterChip(
                      label: const Text('Show fulfilled'),
                      selected: _showFulfilled,
                      onSelected: (v) => setState(() => _showFulfilled = v),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${list.length} requirement(s)',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const EmptyState(
                    icon: Icons.playlist_remove,
                    title: 'No requirements found',
                    message:
                        'Try widening the area or emergency level filter.',
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      for (final r in list) RequirementCard(requirement: r),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
