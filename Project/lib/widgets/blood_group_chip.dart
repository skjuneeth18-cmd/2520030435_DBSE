import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// A round selectable chip showing a blood group (A+, O-, ...).
class BloodGroupChip extends StatelessWidget {
  const BloodGroupChip({
    super.key,
    required this.group,
    required this.selected,
    this.onTap,
    this.compact = false,
  });

  final String group;
  final bool selected;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppTheme.red : Colors.white;
    final fg = selected ? Colors.white : AppTheme.textDark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppTheme.red : const Color(0xFFE5E7EB),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          group,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w800,
            fontSize: compact ? 13 : 14,
          ),
        ),
      ),
    );
  }
}
