import 'package:flutter/material.dart';
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
