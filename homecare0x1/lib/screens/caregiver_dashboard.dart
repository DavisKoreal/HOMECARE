import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/caregiver_profile.dart';
import 'package:homecare0x1/services/auth_service.dart';
import 'package:homecare0x1/services/firebase_caregiver_service.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';

class CaregiverDashboardScreen extends StatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  State<CaregiverDashboardScreen> createState() => _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
  final FirebaseCaregiverService _caregiverService = FirebaseCaregiverService.instance;
  final AuthService _authService = AuthService();
  
  CaregiverProfile? _profile;
  bool _isLoading = true;
  bool _isProfileComplete = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        final profile = await _caregiverService.getCaregiverProfile(user.id);
        if (mounted) {
          setState(() {
            _profile = profile;
            _checkProfileCompletion(profile);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _checkProfileCompletion(CaregiverProfile? profile) {
    if (profile == null) {
      _isProfileComplete = false;
      return;
    }
    // Fixed logic using null-aware operators
    bool hasExperience = profile.experience?.isNotEmpty ?? false;
    bool hasCerts = profile.certifications?.isNotEmpty ?? false;
    bool hasPhone = profile.phone?.isNotEmpty ?? false;
    bool hasEmail = profile.email?.isNotEmpty ?? false;
    bool hasBio = profile.bio?.isNotEmpty ?? false;
    bool hasAvailability = profile.availability?.isNotEmpty ?? false;

    _isProfileComplete = hasExperience && hasCerts && hasPhone && hasEmail && hasBio && hasAvailability;
  }

  @override
  Widget build(BuildContext context) {
    return ModernScreenLayout(
      title: 'Dashboard',
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              children: [
                _buildWelcomeCard(),
                const SizedBox(height: 24),
                if (!_isProfileComplete) _buildIncompleteProfileWarning(),
                const SizedBox(height: 24),
                _buildQuickActions(),
              ],
            ),
          ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppTheme.primaryBlue, Color(0xFF64B5F6)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${_profile?.name ?? "Caregiver"}',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Here is your daily overview.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildIncompleteProfileWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warningOrange.withOpacity(0.1),
        border: Border.all(color: AppTheme.warningOrange),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppTheme.warningOrange, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile Incomplete',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Complete your profile to get approved for shifts.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, Routes.caregiverCompleteProfile),
            child: const Text('Complete Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildActionCard('My Shifts', Icons.calendar_today, () {}),
        _buildActionCard('Available Shifts', Icons.event_available, () {}),
        _buildActionCard('My Profile', Icons.person, () => Navigator.pushNamed(context, Routes.caregiverProfile)),
        _buildActionCard('Earnings', Icons.attach_money, () {}),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppTheme.primaryBlue),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }
}
