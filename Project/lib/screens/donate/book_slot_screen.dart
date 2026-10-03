import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/booking.dart';
import '../../services/blood_service.dart';
import '../../services/donor_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

/// Book a donation slot: pick facility → date → time slot → confirm.
class BookSlotScreen extends StatefulWidget {
  const BookSlotScreen({super.key});

  @override
  State<BookSlotScreen> createState() => _BookSlotScreenState();
}

class _BookSlotScreenState extends State<BookSlotScreen> {
  final _searchCtrl = TextEditingController();

  List<BookingVenue> _venues = [];
  BookingVenue? _venue;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  String? _slot;
  bool _booking = false;

  @override
  void initState() {
    super.initState();
    _venues = BloodService.instance.bookableFacilities();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<BookingVenue> get _filteredVenues {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _venues;
    return _venues
        .where((v) =>
            v.name.toLowerCase().contains(q) ||
            v.area.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      helpText: 'Select donation date',
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _slot = null; // availability depends on the date
      });
    }
  }

  Future<void> _confirm() async {
    if (_venue == null || _slot == null || _booking) return;
    setState(() => _booking = true);
    await Future<void>.delayed(const Duration(milliseconds: 600)); // mock IO
    final error = DonorService.instance.bookSlot(
      venueId: _venue!.id,
      venueName: _venue!.name,
      venueType: _venue!.type,
      venueArea: _venue!.area,
      date: _date,
      slot: _slot!,
    );
    if (!mounted) return;
    setState(() => _booking = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppTheme.red),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Slot confirmed! See you at the venue.'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const slots = DonationBooking.kTimeSlots;

    return Scaffold(
      appBar: AppBar(title: const Text('Book a donation slot')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // ---- Step 1: facility ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: CustomTextField(
              controller: _searchCtrl,
              label: 'Step 1 · Choose facility',
              hint: 'Search hospital or blood bank…',
              icon: Icons.search,
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (_venue == null)
            ..._filteredVenues.map(
              (v) => _VenueTile(
                venue: v,
                onSelect: (picked) => setState(() {
                  _venue = picked;
                  _slot = null;
                }),
              ),
            )
          else ...[
            ListTile(
              leading: Icon(
                _venue!.type == 'Hospital'
                    ? Icons.local_hospital
                    : Icons.water_drop,
                color: AppTheme.red,
              ),
              title: Text(
                _venue!.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 14),
              ),
              subtitle: Text(
                '${_venue!.type} · ${_venue!.area}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: TextButton(
                onPressed: () => setState(() {
                  _venue = null;
                  _slot = null;
                }),
                child: const Text('Change'),
              ),
            ),
          ],

          // ---- Step 2: date ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              'Step 2 · Pick a date',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark.withValues(alpha: 0.75),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: OutlinedButton.icon(
              onPressed: _venue == null ? null : _pickDate,
              icon: const Icon(Icons.calendar_month_outlined, size: 18),
              label: Text(_dateLabel(_date)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.red,
                side: const BorderSide(color: AppTheme.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.centerLeft,
              ),
            ),
          ),

          // ---- Step 3: time slot ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Step 3 · Choose a time slot '
              '(${_venue == null ? 'select a facility first' : '4 seats per slot'})',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark.withValues(alpha: 0.75),
              ),
            ),
          ),
          if (_venue == null)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Pick a facility above to see available time slots.',
                style: TextStyle(fontSize: 12.5, color: AppTheme.textGrey),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in slots)
                    _SlotChip(
                      label: s,
                      selected: _slot == s,
                      available: DonorService.instance.isSlotAvailable(
                        venueId: _venue!.id,
                        date: _date,
                        slot: s,
                      ),
                      onSelected: (sel) =>
                          setState(() => _slot = sel ? s : null),
                    ),
                ],
              ),
            ),

          // ---- Confirm ----
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PrimaryButton(
              label: _slot == null ? 'Confirm slot' : 'Confirm $_slot on ${_shortDate(_date)}',
              icon: Icons.check_circle_outline,
              isLoading: _booking,
              onPressed: (_venue != null && _slot != null) ? _confirm : null,
            ),
          ),
          if (_venue != null && _slot == null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  'Select a time slot to continue',
                  style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _dateLabel(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${d.day} ${months[d.month - 1]} ${d.year} · ${days[d.weekday - 1]}';
  }

  static String _shortDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}

/// Facility row in the picker list.
class _VenueTile extends StatelessWidget {
  const _VenueTile({required this.venue, required this.onSelect});

  final BookingVenue venue;
  final void Function(BookingVenue) onSelect;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: () => onSelect(venue),
        leading: Icon(
          venue.type == 'Hospital'
              ? Icons.local_hospital_outlined
              : Icons.water_drop_outlined,
          color: AppTheme.red,
        ),
        title: Text(
          venue.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontSize: 13.5, fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${venue.type} · ${venue.area}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing:
            const Icon(Icons.chevron_right, color: AppTheme.textGrey),
      ),
    );
  }
}

/// Time-slot chip; disabled look when the slot is full.
class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.label,
    required this.selected,
    required this.available,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final bool available;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final color = !available
        ? AppTheme.textGrey
        : selected
            ? Colors.white
            : AppTheme.red;
    return ChoiceChip(
      label: Text(available ? label : '$label · full'),
      selected: selected,
      onSelected: available ? onSelected : null,
      selectedColor: AppTheme.red,
      labelStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.w700,
        fontSize: 12.5,
      ),
      checkmarkColor: Colors.white,
    );
  }
}


