import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/blood_availability.dart';

/// Shows all 8 blood groups with status + unit count for a facility.
class StockGrid extends StatelessWidget {
  const StockGrid({super.key, required this.stock});

  final FacilityStock stock;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 3.4,
      ),
      itemCount: stock.entries.length,
      itemBuilder: (context, i) {
        final e = stock.entries[i];
        final color = switch (e.status) {
          StockStatus.available => AppTheme.available,
          StockStatus.limited => AppTheme.limited,
          StockStatus.unavailable => AppTheme.unavailable,
        };
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Text(
                e.bloodGroup,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: AppTheme.textDark,
                ),
              ),
              const Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    e.status.label,
                    style: TextStyle(
                      color: color,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${e.units} units',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
