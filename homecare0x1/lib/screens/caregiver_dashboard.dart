import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/cards/dashboard_card.dart';
import 'package:homecare0x1/widgets/cards/stats_card.dart';

class CaregiverDashboardScreen extends StatelessWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModernScreenLayout(
      title: 'Caregiver Dashboard',
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
                    colors: [AppTheme.secondaryTeal, AppTheme.secondaryTealLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back, Caregiver',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Manage your daily care tasks efficiently',
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
                'Today\'s Overview',
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
                            value: '3',
                            change: '+1',
                            isPositive: true,
                            icon: Icons.schedule,
                            color: AppTheme.secondaryTeal,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatsCard(
                            title: 'Completed Tasks',
                            value: '12',
                            change: '+4',
                            isPositive: true,
                            icon: Icons.check_circle,
                            color: AppTheme.successGreen,
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      StatsCard(
                        title: 'Upcoming Visits',
                        value: '3',
                        change: '+1',
                        isPositive: true,
                        icon: Icons.schedule,
                        color: AppTheme.secondaryTeal,
                      ),
                      const SizedBox(height: 16),
                      StatsCard(
                        title: 'Completed Tasks',
                        value: '12',
                        change: '+4',
                        isPositive: true,
                        icon: Icons.check_circle,
                        color: AppTheme.successGreen,
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
                    title: 'View Schedule',
                    subtitle: 'Check your upcoming visits',
                    icon: Icons.calendar_today,
                    iconColor: AppTheme.secondaryTeal,
                    onTap: () => Navigator.pushNamed(context, Routes.scheduleOverview),
                  ),
                  DashboardCard(
                    title: 'Check In',
                    subtitle: 'Start a client visit',
                    icon: Icons.login,
                    iconColor: AppTheme.primaryBlue,
                    onTap: () => Navigator.pushNamed(context, Routes.visitCheckIn),
                  ),
                  DashboardCard(
                    title: 'Messages',
                    subtitle: 'Communicate with clients',
                    icon: Icons.message,
                    iconColor: AppTheme.accentOrange,
                    badge: '2',
                    onTap: () => Navigator.pushNamed(context, Routes.messages),
                  ),
                  DashboardCard(
                    title: 'My Profile',
                    subtitle: 'Manage your account',
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
