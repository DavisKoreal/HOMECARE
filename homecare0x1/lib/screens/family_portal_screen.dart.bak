import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/user_provider.dart';
import 'package:homecare0x1/widgets/cards/dashboard_card.dart';
import 'package:homecare0x1/widgets/cards/stats_card.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:provider/provider.dart';

class FamilyPortalScreen extends StatelessWidget {
  const FamilyPortalScreen({super.key});

  Future<bool> _confirmLogout(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Logout'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Family Member';

    return ModernScreenLayout(
      title: 'Family Portal',
      showBackButton: true,
      onBackPressed: () async {
        final shouldLogout = await _confirmLogout(context);
        if (shouldLogout && context.mounted) {
          userProvider.clearUser();
          Navigator.pushReplacementNamed(context, Routes.login);
        }
      },
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $userName',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Stay updated with caregiving services',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            StatsCard(
              title: 'Recent Visits',
              value: '4',
              change: '+1',
              isPositive: true,
              icon: Icons.event,
              color: Theme.of(context).colorScheme.primary,
            ),
            StatsCard(
              title: 'Care Notes',
              value: '12',
              change: '+3',
              isPositive: true,
              icon: Icons.note,
              color: Theme.of(context).colorScheme.secondary,
            ),
            StatsCard(
              title: 'Messages',
              value: '5',
              change: '+2',
              isPositive: true,
              icon: Icons.message,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            DashboardCard(
              title: 'Client Profile',
              subtitle: 'View profile',
              icon: Icons.person,
              iconColor: Theme.of(context).colorScheme.primary,
              onTap: () => Navigator.pushNamed(context, Routes.clientProfile),
            ),
            DashboardCard(
              title: 'Messages',
              subtitle: 'View messages',
              icon: Icons.message,
              iconColor: Theme.of(context).colorScheme.secondary,
              onTap: () => Navigator.pushNamed(context, Routes.messages),
            ),
            DashboardCard(
              title: 'Care Notes',
              subtitle: 'View notes',
              icon: Icons.note,
              iconColor: Theme.of(context).colorScheme.primary,
              onTap: () => Navigator.pushNamed(context, Routes.careNotes),
            ),
            DashboardCard(
              title: 'Payment Status',
              subtitle: 'View payments',
              icon: Icons.payment,
              iconColor: Theme.of(context).colorScheme.secondary,
              onTap: () => Navigator.pushNamed(context, Routes.paymentStatus),
            ),
          ],
        ),
      ),
    );
  }
}
