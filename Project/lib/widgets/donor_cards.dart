import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/booking.dart';
import '../models/camp.dart';
import '../models/donor_certificate.dart';
import 'donor_badges.dart';

/// Card for an upcoming/active donation booking.
class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    this.onCancel,
    this.onReschedule,
    this.onTap,
  });

  final DonationBooking booking;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;
  final VoidCallback? onTap;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String get _dateLabel =>
      '${booking.date.day} ${_months[booking.date.month - 1]} '
      '${booking.date.year} · ${_days[booking.date.weekday - 1]}';

  @override
  Widget build(BuildContext context) {
    final icon = booking.venueType == 'Hospital'
        ? Icons.local_hospital_outlined
        : Icons.water_drop_outlined;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: AppTheme.red, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.venueName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${booking.venueType} · ${booking.venueArea}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  BookingStatusBadge(status: booking.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_month_outlined,
                      size: 16, color: AppTheme.textGrey),
                  const SizedBox(width: 5),
                  Text(
                    _dateLabel,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Icon(Icons.schedule, size: 16, color: AppTheme.textGrey),
                  const SizedBox(width: 5),
                  Text(
                    booking.time,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              if (booking.isActive &&
                  (onCancel != null || onReschedule != null)) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (onReschedule != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onReschedule,
                          icon: const Icon(Icons.edit_calendar, size: 16),
                          label: const Text('Reschedule'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.red,
                            side: const BorderSide(color: AppTheme.red),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    if (onReschedule != null && onCancel != null)
                      const SizedBox(width: 10),
                    if (onCancel != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onCancel,
                          icon: const Icon(Icons.cancel_outlined, size: 16),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.textGrey,
                            side: const BorderSide(color: Color(0xFFD1D5DB)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Card for a donation camp (list view).
class CampCard extends StatelessWidget {
  const CampCard({super.key, required this.camp, this.onTap, this.onRegister});

  final DonationCamp camp;
  final VoidCallback? onTap;
  final VoidCallback? onRegister;

  @override
  Widget build(BuildContext context) {
    final fillPct =
        camp.totalSlots == 0 ? 1.0 : camp.slotsBooked / camp.totalSlots;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B1FA2).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('📢', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          camp.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${camp.dateLabel} · ${camp.timeLabel}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7B1FA2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 15, color: AppTheme.textGrey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      camp.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textGrey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.groups_outlined,
                      size: 15, color: AppTheme.textGrey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'By ${camp.organizer}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textGrey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: fillPct,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFE5E7EB),
                        color: camp.isFull
                            ? AppTheme.textGrey
                            : const Color(0xFF7B1FA2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    camp.isFull
                        ? 'Camp full'
                        : '${camp.slotsLeft} slots left',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: camp.isFull
                          ? AppTheme.textGrey
                          : const Color(0xFF7B1FA2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final g in camp.bloodGroupsRequired)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        g,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.red,
                        ),
                      ),
                    ),
                ],
              ),
              if (onRegister != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: camp.isFull ? null : onRegister,
                    icon: const Icon(Icons.how_to_reg, size: 18),
                    label: Text(camp.isFull ? 'Camp full' : 'Register'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact certificate card for the certificates list / dashboard.
class CertificateCard extends StatelessWidget {
  const CertificateCard({
    super.key,
    required this.certificate,
    this.onTap,
    this.compact = false,
  });

  final DonorCertificate certificate;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.workspace_premium,
              color: Color(0xFF1565C0), size: 24),
        ),
        title: Text(
          certificate.certificateId,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        subtitle: compact
            ? Text(
                '${certificate.donationDateLabel} · ${certificate.bloodGroup} · '
                '${certificate.facilityName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textGrey),
              )
            : Text(
                '${certificate.donationDateLabel} · ${certificate.bloodGroup} · '
                '${certificate.facilityName}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textGrey),
              ),
        trailing:
            const Icon(Icons.chevron_right, color: AppTheme.textGrey),
      ),
    );
  }
}
