import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/blood_availability.dart';
import '../models/blood_requirement.dart';

/// Colored pill showing stock status with a dot indicator.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.compact = false});

  final StockStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      StockStatus.available => AppTheme.available,
      StockStatus.limited => AppTheme.limited,
      StockStatus.unavailable => AppTheme.unavailable,
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
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Generic coloured pill for an arbitrary status label (Phase 4+).
class PillBadge extends StatelessWidget {
  const PillBadge({
    super.key,
    required this.label,
    required this.color,
    this.compact = false,
  });

  final String label;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Verified / Unverified pill.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, required this.isVerified});

  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final color = isVerified ? AppTheme.available : AppTheme.textGrey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.info_outline,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            isVerified ? 'Verified' : 'Unverified',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Open / Fulfilled pill for requirements.
class RequirementStatusBadge extends StatelessWidget {
  const RequirementStatusBadge({super.key, required this.status});

  final RequirementStatus status;

  @override
  Widget build(BuildContext context) {
    final color =
        status == RequirementStatus.open ? AppTheme.limited : AppTheme.available;
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
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Emergency level pill for requirement cards.
class EmergencyBadge extends StatelessWidget {
  const EmergencyBadge({super.key, required this.level});

  final EmergencyLevel level;

  @override
  Widget build(BuildContext context) {
    final color = switch (level) {
      EmergencyLevel.critical => AppTheme.red,
      EmergencyLevel.urgent => AppTheme.limited,
      EmergencyLevel.normal => AppTheme.available,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        level.label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
