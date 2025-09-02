import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:homecare0x1/services/firebase_caregiver_service.dart';
import 'package:homecare0x1/models/caregiver_profile.dart';
import 'package:homecare0x1/actions/overlay.dart';
import 'package:provider/provider.dart';

// Caregiver Complete Profile Screen
// Displays a form with all caregiver profile fields, highlighting incomplete fields for editing.
// Allows updating the profile via FirebaseCaregiverService.
class CaregiverCompleteProfileScreen extends StatefulWidget {
  const CaregiverCompleteProfileScreen({super.key});

  @override
  State<CaregiverCompleteProfileScreen> createState() => _CaregiverCompleteProfileScreenState();
}

class _CaregiverCompleteProfileScreenState extends State<CaregiverCompleteProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _experienceController;
  late TextEditingController _certificationsController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _availabilityController;
  late OverlayUtils _overlayUtils;
  CaregiverProfile? _caregiverProfile;
  bool _isLoading = true;
  Map<String, bool> _incompleteFields = {
    'name': true,
    'role': true,
    'experience': true,
    'certifications': true,
    'phone': true,
    'email': true,
    'bio': true,
    'availability': true,
  };

  @override
  void initState() {
    super.initState();
    _overlayUtils = OverlayUtils();
    // Initialize controllers
    _nameController = TextEditingController();
    _roleController = TextEditingController();
    _experienceController = TextEditingController();
    _certificationsController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _bioController = TextEditingController();
    _availabilityController = TextEditingController();
    // Fetch profile data
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _overlayUtils.showOverlay(
          context,
          'No user logged in. Please log in and try again.',
          isError: true,
        );
        Navigator.pushReplacementNamed(context, Routes.login);
      }
      return;
    }

    final caregiverService = FirebaseCaregiverService.instance;
    try {
      final profile = await caregiverService.getCaregiverProfile(userProvider.user!.id);
      if (mounted) {
        setState(() {
          _caregiverProfile = profile;
          _isLoading = false;
          // Populate controllers with profile data or empty strings
          _nameController.text = profile?.name ?? '';
          _roleController.text = profile?.role ?? '';
          _experienceController.text = profile?.experience ?? '';
          _certificationsController.text = profile?.certifications.join(', ') ?? '';
          _phoneController.text = profile?.phone ?? '';
          _emailController.text = profile?.email ?? '';
          _bioController.text = profile?.bio ?? '';
          _availabilityController.text = profile?.availability.join(', ') ?? '';
          // Update incomplete fields
          _incompleteFields = {
            'name': _nameController.text.trim().isEmpty,
            'role': _roleController.text.trim().isEmpty,
            'experience': _experienceController.text.trim().isEmpty,
            'certifications': _certificationsController.text.trim().isEmpty,
            'phone': _phoneController.text.trim().isEmpty,
            'email': _emailController.text.trim().isEmpty,
            'bio': _bioController.text.trim().isEmpty,
            'availability': _availabilityController.text.trim().isEmpty,
          };
        });
      }
    } catch (e) {
      if (mounted) {
        _overlayUtils.showOverlay(context, 'Failed to load profile: $e', isError: true);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Dispose controllers and overlay
    _nameController.dispose();
    _roleController.dispose();
    _experienceController.dispose();
    _certificationsController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _availabilityController.dispose();
    _overlayUtils.dispose();
    super.dispose();
  }

  // Builds an improved TextField widget with highlighting for incomplete fields
  Widget _buildImprovedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    bool isRequired = false,
    bool isIncomplete = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
            children: isRequired
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFFBDC3C7),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF7F8C8D),
              size: 20,
            ),
            filled: true,
            fillColor: isIncomplete ? Colors.red.withOpacity(0.05) : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isIncomplete ? Colors.red : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isIncomplete ? Colors.red : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isIncomplete ? Colors.red : const Color(0xFF3498DB),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        if (isIncomplete)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'This field is required',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  // Validates all profile fields
  bool _validateProfileFields() {
    return _nameController.text.trim().isNotEmpty &&
        _roleController.text.trim().isNotEmpty &&
        _experienceController.text.trim().isNotEmpty &&
        _certificationsController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _bioController.text.trim().isNotEmpty &&
        _availabilityController.text.trim().isNotEmpty;
  }

  // Handles profile update
  Future<void> _handleUpdateProfile() async {
    if (!_validateProfileFields()) {
      _overlayUtils.showOverlay(
        context,
        'Please fill in all required fields.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user == null) {
      _overlayUtils.showOverlay(
        context,
        'No user logged in. Please log in and try again.',
        isError: true,
      );
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacementNamed(context, Routes.login);
      return;
    }

    final caregiverService = FirebaseCaregiverService.instance;
    final updatedProfile = CaregiverProfile(
      id: userProvider.user!.id,
      name: _nameController.text.trim(),
      role: _roleController.text.trim(),
      experience: _experienceController.text.trim(),
      certifications: _certificationsController.text.trim().isEmpty
          ? []
          : _certificationsController.text.trim().split(',').map((s) => s.trim()).toList(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      bio: _bioController.text.trim(),
      availability: _availabilityController.text.trim().isEmpty
          ? []
          : _availabilityController.text.trim().split(',').map((s) => s.trim()).toList(),
      rating: _caregiverProfile?.rating ?? 0.0,
      reviews: _caregiverProfile?.reviews ?? 0,
    );

    try {
      await caregiverService.upsertCaregiverProfile(updatedProfile);
      if (mounted) {
        _overlayUtils.showOverlay(context, 'Profile updated successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _overlayUtils.showOverlay(context, 'Failed to update profile: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isProfileComplete = _incompleteFields.values.every((isIncomplete) => !isIncomplete);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3498DB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person_outline,
                color: Color(0xFF3498DB),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Complete Your Profile',
              style: TextStyle(
                color: Color(0xFF2C3E50),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isProfileComplete ? 'Edit Your Profile' : 'Complete Your Profile',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isProfileComplete
                              ? 'Update your profile details below.'
                              : 'Please fill in the required fields to complete your profile.',
                          style: const TextStyle(
                            color: Color(0xFF7F8C8D),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildImprovedTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          icon: Icons.person,
                          hint: 'Enter your full name',
                          isRequired: true,
                          isIncomplete: _incompleteFields['name'] ?? true,
                        ),
                        const SizedBox(height: 16),
                        _buildImprovedTextField(
                          controller: _roleController,
                          label: 'Role',
                          icon: Icons.work_outline,
                          hint: 'Enter your role (e.g., Registered Nurse)',
                          isRequired: true,
                          isIncomplete: _incompleteFields['role'] ?? true,
                        ),
                        const SizedBox(height: 16),
                        _buildImprovedTextField(
                          controller: _experienceController,
                          label: 'Experience',
                          icon: Icons.history,
                          hint: 'Describe your experience (e.g., 5 years in home care)',
                          maxLines: 2,
                          isRequired: true,
                          isIncomplete: _incompleteFields['experience'] ?? true,
                        ),
                        const SizedBox(height: 16),
                        _buildImprovedTextField(
                          controller: _certificationsController,
                          label: 'Certifications',
                          icon: Icons.verified,
                          hint: 'List your certifications, separated by commas (e.g., CPR, CNA)',
                          maxLines: 2,
                          isRequired: true,
                          isIncomplete: _incompleteFields['certifications'] ?? true,
                        ),
                        const SizedBox(height: 16),
                        _buildImprovedTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone,
                          hint: 'Enter your phone number',
                          isRequired: true,
                          isIncomplete: _incompleteFields['phone'] ?? true,
                        ),
                        const SizedBox(height: 16),
                        _buildImprovedTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          icon: Icons.email,
                          hint: 'Enter your email address',
                          isRequired: true,
                          isIncomplete: _incompleteFields['email'] ?? true,
                        ),
                        const SizedBox(height: 16),
                        _buildImprovedTextField(
                          controller: _bioController,
                          label: 'Bio',
                          icon: Icons.description,
                          hint: 'Write a short bio about yourself',
                          maxLines: 4,
                          isRequired: true,
                          isIncomplete: _incompleteFields['bio'] ?? true,
                        ),
                        const SizedBox(height: 16),
                        _buildImprovedTextField(
                          controller: _availabilityController,
                          label: 'Availability',
                          icon: Icons.schedule,
                          hint: 'Specify your availability, separated by commas (e.g., Mon-Fri 9AM-5PM, Sat 10AM-2PM)',
                          maxLines: 2,
                          isRequired: true,
                          isIncomplete: _incompleteFields['availability'] ?? true,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleUpdateProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3498DB),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Update Profile',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}