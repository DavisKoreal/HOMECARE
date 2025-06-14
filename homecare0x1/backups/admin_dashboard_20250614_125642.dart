import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/cards/dashboard_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Widget _buildCircularStat({
    required String title,
    required String value,
    required double percent,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: CircularProgressIndicator(
                  value: percent,
                  backgroundColor: Colors.white10,
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              Icon(icon, color: Colors.white, size: 28),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  List<Widget> _buildDashboardActions(BuildContext context) {
    return [
      DashboardCard(
        title: 'Clients',
        subtitle: 'Profiles',
        icon: Icons.people_outline,
        iconColor: AppTheme.primaryBlue,
        onTap: () => Navigator.pushNamed(context, Routes.clientList),
      ),
      DashboardCard(
        title: 'Shifts',
        subtitle: 'Assign caregivers',
        icon: Icons.schedule,
        iconColor: AppTheme.secondaryTeal,
        onTap: () => Navigator.pushNamed(context, Routes.shiftAssignment),
      ),
      DashboardCard(
        title: 'Billing',
        subtitle: 'Payments & tracking',
        icon: Icons.payment,
        iconColor: AppTheme.accentOrange,
        onTap: () => Navigator.pushNamed(context, Routes.billingDashboard),
      ),
      DashboardCard(
        title: 'Reports',
        subtitle: 'Insights',
        icon: Icons.analytics_outlined,
        iconColor: AppTheme.successGreen,
        onTap: () => Navigator.pushNamed(context, Routes.reportsDashboard),
      ),
      DashboardCard(
        title: 'Audit Logs',
        subtitle: 'User activity',
        icon: Icons.history,
        iconColor: AppTheme.neutral600,
        badge: '3',
        onTap: () => Navigator.pushNamed(context, Routes.auditLog),
      ),
      DashboardCard(
        title: 'Invoices',
        subtitle: 'Manage',
        icon: Icons.receipt_long,
        iconColor: AppTheme.warningYellow,
        onTap: () => Navigator.pushNamed(context, Routes.invoiceGeneration),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        bool? shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Log out and return to login screen?',),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Logout'),),
            ],
          ),
        );
        if (shouldExit ?? false && context.mounted) {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.clearUser();
          Navigator.pushReplacementNamed(context, Routes.login);
        }
      },
      },
      child: ModernScreenLayout(
        title: '',
        showBackButton: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () =>
                  Navigator.pushNamed(context, Routes.userProfile)),
        ],
        body: RefreshIndicator(
          onRefresh: () async =>
              await Future.delayed(const Duration(seconds: 1)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue.withOpacity(0.7),
                        AppTheme.primaryBlueLight.withOpacity(0.4)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Welcome Back, Admin!",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text("Here's your overview for today.",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // KPI Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildCircularStat(
                        title: 'Active Clients',
                        value: '24',
                        percent: 0.75,
                        color: AppTheme.primaryBlue,
                        icon: Icons.people,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCircularStat(
                        title: 'Caregivers',
                        value: '15',
                        percent: 0.6,
                        color: AppTheme.secondaryTeal,
                        icon: Icons.medical_services,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCircularStat(
                        title: 'Invoices',
                        value: '8',
                        percent: 0.3,
                        color: AppTheme.accentOrange,
                        icon: Icons.receipt,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Quick Actions
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 600 ? 3 : 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.1,
                  children: _buildDashboardActions(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
