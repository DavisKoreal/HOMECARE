import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:homecare0x1/widgets/cards/stats_card.dart';

class BillingDashboardScreen extends StatelessWidget {
  const BillingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModernScreenLayout(
      title: 'Billing Dashboard',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Billing Overview',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Monitor and manage financial operations',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: 'Total Revenue',
                          value: '\$12,450',
                          change: '+8%',
                          isPositive: true,
                          icon: Icons.monetization_on,
                          color: AppTheme.successGreen,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatsCard(
                          title: 'Pending Payments',
                          value: '\$1,230',
                          change: '-5%',
                          isPositive: false,
                          icon: Icons.payment,
                          color: AppTheme.errorRed,
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    StatsCard(
                      title: 'Total Revenue',
                      value: '\$12,450',
                      change: '+8%',
                      isPositive: true,
                      icon: Icons.monetization_on,
                      color: AppTheme.successGreen,
                    ),
                    const SizedBox(height: 16),
                    StatsCard(
                      title: 'Pending Payments',
                      value: '\$1,230',
                      change: '-5%',
                      isPositive: false,
                      icon: Icons.payment,
                      color: AppTheme.errorRed,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            ModernButton(
              text: 'Generate Invoice',
              icon: Icons.receipt_long,
              width: double.infinity,
              onPressed: () => Navigator.pushNamed(context, Routes.invoiceGeneration),
            ),
            const SizedBox(height: 16),
            ModernButton(
              text: 'Process Payroll',
              icon: Icons.account_balance_wallet,
              width: double.infinity,
              onPressed: () => Navigator.pushNamed(context, Routes.payrollProcessing),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
