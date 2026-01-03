import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/caregiver_profile.dart';
import 'package:homecare0x1/services/auth_service.dart';
import 'package:homecare0x1/services/firebase_caregiver_service.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';

class CaregiverProfileScreen extends StatefulWidget {
  const CaregiverProfileScreen({super.key});

  @override
  State<CaregiverProfileScreen> createState() => _CaregiverProfileScreenState();
}

class _CaregiverProfileScreenState extends State<CaregiverProfileScreen> {
  final FirebaseCaregiverService _caregiverService = FirebaseCaregiverService.instance;
  final AuthService _authService = AuthService();
  CaregiverProfile? _profile;
  bool _isLoading = true;

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
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModernScreenLayout(
      title: 'My Profile',
      showBackButton: true,
      onBackPressed: () => Navigator.pop(context),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _profile == null 
          ? const Center(child: Text("Profile not found"))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(_profile!),
                  const SizedBox(height: 24),
                  _buildDetails(_profile!),
                  const SizedBox(height: 24),
                  ModernButton(
                    text: 'Edit Profile',
                    icon: Icons.edit,
                    onPressed: () => Navigator.pushNamed(context, Routes.caregiverCompleteProfile),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(CaregiverProfile profile) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
            child: Text(
              profile.name.isNotEmpty ? profile.name[0] : '?',
              style: const TextStyle(fontSize: 40, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          Text(
            profile.role,
            style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          _buildStatusChip(profile.approved),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool approved) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: approved ? AppTheme.successGreen.withOpacity(0.1) : AppTheme.warningOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        approved ? 'Approved' : 'Pending Approval',
        style: TextStyle(
          color: approved ? AppTheme.successGreen : AppTheme.warningOrange,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDetails(CaregiverProfile profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Email', profile.email ?? 'Not specified', Icons.email),
          _buildInfoRow('Phone', profile.phone ?? 'Not specified', Icons.phone),
          _buildInfoRow('Experience', profile.experience ?? 'Not specified', Icons.work),
          const Divider(height: 32),
          const Text('Bio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(profile.bio?.isNotEmpty == true ? profile.bio! : 'No biography added.', style: const TextStyle(color: AppTheme.textSecondary)),
          const Divider(height: 32),
          const Text('Certifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          if (profile.certifications != null && profile.certifications!.isNotEmpty)
            Wrap(
              spacing: 8,
              children: profile.certifications!.map((cert) => Chip(label: Text(cert))).toList(),
            )
          else
            const Text('No certifications listed.', style: TextStyle(color: AppTheme.textSecondary)),
          const Divider(height: 32),
          const Text('Availability', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          if (profile.availability != null && profile.availability!.isNotEmpty)
            Wrap(
              spacing: 8,
              children: profile.availability!.map((slot) => Chip(label: Text(slot))).toList(),
            )
          else
            const Text('No availability set.', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}
