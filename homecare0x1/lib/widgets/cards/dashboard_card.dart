import 'package:flutter/material.dart';
import 'package:homecare0x1/theme/app_theme.dart';

/// A customizable card widget for displaying dashboard items with an icon, title, subtitle,
/// optional stats (value and change), and a tap action.
/// Used in the FamilyPortalScreen to represent actionable items like Client Profile, Messages,
/// Care Notes, Recent Visits, and Payment Status.
class DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final String? value; // Optional stat value (e.g., '5' for Messages)
  final String? change; // Optional change value (e.g., '+2' for Messages)
  final bool? isPositive; // Indicates if the change is positive (affects color)

  const DashboardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.onTap,
    this.value,
    this.change,
    this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 32),
                  if (value != null || change != null) ...[
                    const Spacer(),
                    if (value != null)
                      Text(
                        value!,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    if (change != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPositive == true
                              ? AppTheme.successGreen
                              : AppTheme.errorRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          change!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.neutral600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
