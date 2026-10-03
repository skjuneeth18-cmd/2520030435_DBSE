import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/booking.dart';
import '../models/donor.dart';

/// Eligibility pill for the donor dashboard/profile.
class EligibilityBadge extends StatelessWidget {
  const EligibilityBadge({super.key, required this.status, this.note});

  final EligibilityStatus status;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      EligibilityStatus.eligible => (AppTheme.available, Icons.check_circle),
      EligibilityStatus.temporarilyDeferred => (AppTheme.limited, Icons.schedule),
      EligibilityStatus.notEligible => (AppTheme.unavailable, Icons.block),
      EligibilityStatus.unknown => (AppTheme.textGrey, Icons.help_outline),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status pill for a booking (Confirmed / Completed / Cancelled / ...).
class BookingStatusBadge extends StatelessWidget {
  const BookingStatusBadge({super.key, required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      BookingStatus.confirmed => AppTheme.available,
      BookingStatus.completed => const Color(0xFF1565C0),
      BookingStatus.cancelled => AppTheme.textGrey,
      BookingStatus.rescheduled => AppTheme.limited,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
