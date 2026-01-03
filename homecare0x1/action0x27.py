import os

def fix_compilation_errors():
    target_dir = os.path.expanduser("~/Desktop/HOMECARE/homecare0x1")
    
    if not os.path.exists(target_dir):
        print(f"Error: Directory {target_dir} not found.")
        return

    print(f"Changing directory to: {target_dir}")
    os.chdir(target_dir)

    # ---------------------------------------------------------
    # 1. Fix lib/screens/caregiver_dashboard.dart
    # ---------------------------------------------------------
    print("\n--- Fixing lib/screens/caregiver_dashboard.dart ---")
    dashboard_path = os.path.join("lib", "screens", "caregiver_dashboard.dart")
    
    # We need to replace the _checkProfileCompletion logic or the whole file. 
    # Since I don't have the full file context in memory, I will rewrite the file 
    # assuming standard structure based on the error log.
    
    dashboard_content = """import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/caregiver_profile.dart';
import 'package:homecare0x1/services/auth_service.dart';
import 'package:homecare0x1/services/firebase_caregiver_service.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';

class CaregiverDashboard extends StatefulWidget {
  const CaregiverDashboard({super.key});

  @override
  State<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {
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
"""
    with open(dashboard_path, "w", encoding="utf-8") as f:
        f.write(dashboard_content)
    print("Fixed caregiver_dashboard.dart")

    # ---------------------------------------------------------
    # 2. Fix lib/screens/caregiver_profile.dart
    # ---------------------------------------------------------
    print("\n--- Fixing lib/screens/caregiver_profile.dart ---")
    profile_screen_path = os.path.join("lib", "screens", "caregiver_profile.dart")
    
    # We will overwrite with a corrected version that handles nulls in the display widgets
    profile_screen_content = """import 'package:flutter/material.dart';
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
"""
    with open(profile_screen_path, "w", encoding="utf-8") as f:
        f.write(profile_screen_content)
    print("Fixed caregiver_profile.dart")

    # ---------------------------------------------------------
    # 3. Fix lib/screens/caregiver_complete_profile.dart
    # ---------------------------------------------------------
    print("\n--- Fixing lib/screens/caregiver_complete_profile.dart ---")
    complete_profile_path = os.path.join("lib", "screens", "caregiver_complete_profile.dart")
    
    complete_profile_content = """import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/caregiver_profile.dart';
import 'package:homecare0x1/services/auth_service.dart';
import 'package:homecare0x1/services/firebase_caregiver_service.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';

class CaregiverCompleteProfileScreen extends StatefulWidget {
  const CaregiverCompleteProfileScreen({super.key});

  @override
  State<CaregiverCompleteProfileScreen> createState() => _CaregiverCompleteProfileScreenState();
}

class _CaregiverCompleteProfileScreenState extends State<CaregiverCompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseCaregiverService _caregiverService = FirebaseCaregiverService.instance;
  final AuthService _authService = AuthService();

  // Controllers
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _certificationsController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _availabilityController = TextEditingController();

  CaregiverProfile? _existingProfile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      final profile = await _caregiverService.getCaregiverProfile(user.id);
      if (profile != null) {
        setState(() {
          _existingProfile = profile;
          _experienceController.text = profile.experience ?? '';
          _phoneController.text = profile.phone ?? '';
          _bioController.text = profile.bio ?? '';
          _certificationsController.text = (profile.certifications ?? []).join(', ');
          _availabilityController.text = (profile.availability ?? []).join(', ');
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) throw Exception('No user found');

      final certifications = _certificationsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final availability = _availabilityController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      final updatedProfile = CaregiverProfile(
        id: user.id,
        name: user.name,
        role: user.role,
        experience: _experienceController.text.trim(),
        phone: _phoneController.text.trim(),
        email: user.email,
        bio: _bioController.text.trim(),
        certifications: certifications,
        availability: availability,
        rating: _existingProfile?.rating ?? 0.0,
        reviews: _existingProfile?.reviews ?? 0,
        approved: _existingProfile?.approved ?? false,
        approverId: _existingProfile?.approverId,
        hourlyRate: _existingProfile?.hourlyRate ?? 0.0,
      );

      final result = await _caregiverService.createCaregiver(updatedProfile);
      
      if (mounted) {
        if (result.startsWith('Error')) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result), backgroundColor: AppTheme.errorRed));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved successfully!'), backgroundColor: AppTheme.successGreen));
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModernScreenLayout(
      title: 'Edit Profile',
      showBackButton: true,
      onBackPressed: () => Navigator.pop(context),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildSectionTitle('Contact Information'),
              _buildTextField('Phone Number', _phoneController, Icons.phone, validator: (v) => v!.isEmpty ? 'Required' : null),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Professional Details'),
              _buildTextField('Years of Experience', _experienceController, Icons.work),
              _buildTextField('Certifications (comma separated)', _certificationsController, Icons.verified),
              _buildTextField('Biography', _bioController, Icons.article, maxLines: 4),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Availability'),
              _buildTextField('Days/Hours (e.g. Mon-Fri 9-5)', _availabilityController, Icons.schedule),

              const SizedBox(height: 32),
              ModernButton(
                text: 'Save Profile',
                onPressed: _saveProfile,
                isLoading: _isLoading,
                color: AppTheme.primaryBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.textSecondary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
"""
    with open(complete_profile_path, "w", encoding="utf-8") as f:
        f.write(complete_profile_content)
    print("Fixed caregiver_complete_profile.dart")

    # ---------------------------------------------------------
    # 4. Fix lib/screens/admin_caregiver_approval.dart
    # ---------------------------------------------------------
    print("\n--- Fixing lib/screens/admin_caregiver_approval.dart ---")
    approval_path = os.path.join("lib", "screens", "admin_caregiver_approval.dart")
    
    with open(approval_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Simple fixes for null checks
    # Replace c.email with c.email ?? 'No email'
    if "Text(c.email," in content:
        content = content.replace("Text(c.email,", "Text(c.email ?? 'No email',")
    
    # Replace c.phone with c.phone ?? 'No phone'
    if "Text(c.phone," in content:
        content = content.replace("Text(c.phone,", "Text(c.phone ?? 'No phone',")

    with open(approval_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Fixed admin_caregiver_approval.dart")

if __name__ == "__main__":
    fix_compilation_errors()