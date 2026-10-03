import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/booking.dart';
import '../../services/donor_service.dart';
import '../../widgets/donor_cards.dart';
import '../../widgets/empty_state.dart';
import 'book_slot_screen.dart';

/// All of the donor's slot bookings with cancel/reschedule actions.
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    DonorService.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    DonorService.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _cancel(DonationBooking b) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel this booking?'),
        content: Text(
          '${b.venueName} · ${b.time}\nYour slot will be released for another donor.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () {
              DonorService.instance.cancelBooking(b.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking cancelled.')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.red),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _reschedule(DonationBooking b) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: b.date.isAfter(DateTime.now())
          ? b.date
          : DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      helpText: 'Pick a new date',
    );
    if (picked == null || !mounted) return;

    // Simple slot picker for the new date.
    final newSlot = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Pick a new time slot',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in DonationBooking.kTimeSlots)
                  ChoiceChip(
                    label: Text(s),
                    selected: false,
                    onSelected: (ok) =>
                        ok ? Navigator.pop(ctx, s) : null,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
    if (newSlot == null || !mounted) return;

    final error = DonorService.instance.rescheduleBooking(
      bookingId: b.id,
      newDate: picked,
      newSlot: newSlot,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Booking moved to the new slot. ✅'),
        backgroundColor: error == null ? Colors.green : AppTheme.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookings = DonorService.instance.myBookings();
    final upcoming = bookings.where((b) => b.isUpcoming).toList();
    final past = bookings.where((b) => !b.isUpcoming).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My donation slots')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookSlotScreen()),
        ),
        backgroundColor: AppTheme.red,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New booking'),
      ),
      body: bookings.isEmpty
          ? const EmptyState(
              icon: Icons.event_busy_outlined,
              title: 'No bookings yet',
              message:
                  'Tap “New booking” to schedule your next blood donation.',
            )
          : ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 88),
              children: [
                if (upcoming.isNotEmpty) ...[
                  const _Header('Upcoming'),
                  for (final b in upcoming)
                    BookingCard(
                      booking: b,
                      onCancel: b.isActive ? () => _cancel(b) : null,
                      onReschedule:
                          b.isActive ? () => _reschedule(b) : null,
                    ),
                ],
                if (past.isNotEmpty) ...[
                  const _Header('Past & cancelled'),
                  for (final b in past) BookingCard(booking: b),
                ],
              ],
            ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
          color: AppTheme.textGrey,
        ),
      ),
    );
  }
}
