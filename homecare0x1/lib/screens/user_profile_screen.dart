import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  Future<bool?> _confirmLogout(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return ModernScreenLayout(
      title: 'User Profile',
      showBackButton: true,
      onBackPressed: () => Navigator.pushReplacementNamed(
        context,
        userProvider.getInitialRoute(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: user == null
            ? _buildNotLoggedIn(context)
            : _buildProfile(context, userProvider),
      ),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Not Logged In',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Please log in to view your profile.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.neutral600,
              ),
        ),
        const SizedBox(height: 24),
        ModernButton(
          text: 'Go to Login',
          icon: Icons.login,
          width: double.infinity,
          onPressed: () =>
              Navigator.pushReplacementNamed(context, Routes.login),
        ),
      ],
    );
  }

  Widget _buildProfile(BuildContext context, UserProvider userProvider) {
    final user = userProvider.user!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Your Profile',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your account details.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.neutral600,
              ),
        ),
        const SizedBox(height: 24),

        // Profile Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // User Details
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.neutral600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(user.role),
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Action Buttons
        ModernButton(
          text: 'Edit Profile',
          icon: Icons.edit,
          width: double.infinity,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Edit profile feature coming soon!'),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        ModernButton(
          text: 'Log Out',
          icon: Icons.logout,
          isOutlined: true,
          width: double.infinity,
          onPressed: () async {
            final shouldLogout = await _confirmLogout(context);
            if (shouldLogout ?? false) {
              userProvider.clearUser();
              Navigator.pushReplacementNamed(context, Routes.login);
            }
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
