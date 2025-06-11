import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/cards/dashboard_card.dart';
import 'package:homecare0x1/widgets/cards/stats_card.dart';

class FamilyPortalScreen extends StatelessWidget {
  const FamilyPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModernScreenLayout(
      title: 'Family Portal',
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
                    colors: [AppTheme.accentOrange, AppTheme.warningYellow],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome, Family Member',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Stay connected with your loved one\'s care',
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
                'Care Overview',
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
                            title: 'Upcoming Visits',
                            value: '4',
                            change: '+2',
                            isPositive: true,
                            icon: Icons.schedule,
                            color: AppTheme.secondaryTeal,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatsCard(
                            title: 'Care Notes',
                            value: '7',
                            change: '+3',
                            isPositive: true,
                            icon: Icons.note,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      StatsCard(
                        title: 'Upcoming Visits',
                        value: '4',
                        change: '+2',
                        isPositive: true,
                        icon: Icons.schedule,
                        color: AppTheme.secondaryTeal,
                      ),
                      const SizedBox(height: 16),
                      StatsCard(
                        title: 'Care Notes',
                        value: '7',
                        change: '+3',
                        isPositive: true,
                        icon: Icons.note,
                        color: AppTheme.primaryBlue,
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
                children: [
                  DashboardCard(
                    title: 'Care Schedule',
                    subtitle: 'View upcoming visits',
                    icon: Icons.calendar_today,
                    iconColor: AppTheme.secondaryTeal,
                    onTap: () => Navigator.pushNamed(context, Routes.scheduleOverview),
                  ),
                  DashboardCard(
                    title: 'Messages',
                    subtitle: 'Contact caregivers',
                    icon: Icons.message,
                    iconColor: AppTheme.accentOrange,
                    badge: '2',
                    onTap: () => Navigator.pushNamed(context, Routes.messages),
                  ),
                  DashboardCard(
                    title: 'Payments',
                    subtitle: 'Check payment status',
                    icon: Icons.payment,
                    iconColor: AppTheme.primaryBlue,
                    onTap: () => Navigator.pushNamed(context, Routes.paymentStatus),
                  ),
                  DashboardCard(
                    title: 'My Profile',
                    subtitle: 'Manage account details',
                    icon: Icons.person,
                    iconColor: AppTheme.neutral600,
                    onTap: () => Navigator.pushNamed(context, Routes.userProfile),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
