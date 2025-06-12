import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/cards/dashboard_card.dart';
import 'package:homecare0x1/widgets/cards/stats_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  List<Widget> _buildDashboardCards(BuildContext context) {
    return [
      DashboardCard(
        title: 'Client Management',
        subtitle: 'Manage client profiles and information',
        icon: Icons.people_outline,
        iconColor: AppTheme.primaryBlue,
        onTap: () => Navigator.pushNamed(context, Routes.clientList),
      ),
      DashboardCard(
        title: 'Shift Assignment',
        subtitle: 'Assign caregivers to client schedules',
        icon: Icons.schedule,
        iconColor: AppTheme.secondaryTeal,
        onTap: () => Navigator.pushNamed(context, Routes.shiftAssignment),
      ),
      DashboardCard(
        title: 'Billing Dashboard',
        subtitle: 'Monitor billing and financial reports',
        icon: Icons.payment,
        iconColor: AppTheme.accentOrange,
        onTap: () => Navigator.pushNamed(context, Routes.billingDashboard),
      ),
      DashboardCard(
        title: 'Reports & Analytics',
        subtitle: 'View comprehensive system reports',
        icon: Icons.analytics_outlined,
        iconColor: AppTheme.successGreen,
        onTap: () => Navigator.pushNamed(context, Routes.reportsDashboard),
      ),
      DashboardCard(
        title: 'Audit Logs',
        subtitle: 'Review system activity and changes',
        icon: Icons.history,
        iconColor: AppTheme.neutral600,
        badge: '3',
        onTap: () => Navigator.pushNamed(context, Routes.auditLog),
      ),
      DashboardCard(
        title: 'Invoice Generation',
        subtitle: 'Create and manage client invoices',
        icon: Icons.receipt_long,
        iconColor: AppTheme.warningYellow,
        onTap: () => Navigator.pushNamed(context, Routes.invoiceGeneration),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool? shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Application'),
            content: const Text('Are you sure you want to exit the application?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        if (shouldExit ?? false) {
          SystemNavigator.pop();
        }
        return false;
      },
      child: ModernScreenLayout(
        title: 'Admin Dashboard',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, Routes.userProfile),
          ),
        ],
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryBlue, AppTheme.primaryBlueLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome back, Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Manage your homecare operations efficiently',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 600) {
                      return Row(
                        children: [
                          Expanded(
                            child: StatsCard(
                              title: 'Active Clients',
                              value: '24',
                              change: '+12%',
                              isPositive: true,
                              icon: Icons.people,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StatsCard(
                              title: 'Caregivers',
                              value: '15',
                              change: '+5%',
                              isPositive: true,
                              icon: Icons.medical_services,
                              color: AppTheme.secondaryTeal,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StatsCard(
                              title: 'Pending Invoices',
                              value: '8',
                              change: '-3%',
                              isPositive: false,
                              icon: Icons.receipt,
                              color: AppTheme.accentOrange,
                            ),
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        StatsCard(
                          title: 'Active Clients',
                          value: '24',
                          change: '+12%',
                          isPositive: true,
                          icon: Icons.people,
                          color: AppTheme.primaryBlue,
                        ),
                        const SizedBox(height: 16),
                        StatsCard(
                          title: 'Caregivers',
                          value: '15',
                          change: '+5%',
                          isPositive: true,
                          icon: Icons.medical_services,
                          color: AppTheme.secondaryTeal,
                        ),
                        const SizedBox(height: 16),
                        StatsCard(
                          title: 'Pending Invoices',
                          value: '8',
                          change: '-3%',
                          isPositive: false,
                          icon: Icons.receipt,
                          color: AppTheme.accentOrange,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: _buildDashboardCards(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
