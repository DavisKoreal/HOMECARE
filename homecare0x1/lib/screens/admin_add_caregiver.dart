import 'dart:math';
import 'package:flutter/material.dart';
import 'package:homecare0x1/models/caregiver_profile.dart';
import 'package:homecare0x1/services/firebase_caregiver_service.dart';

/// Admin page for adding new caregivers to the system
/// Provides form validation, scrollable confirmation popup, and random motivational messages
class AdminAddCaregiverPage extends StatefulWidget {
  const AdminAddCaregiverPage({Key? key}) : super(key: key);

  @override
  State<AdminAddCaregiverPage> createState() => _AdminAddCaregiverPageState();
}

class _AdminAddCaregiverPageState extends State<AdminAddCaregiverPage> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // Lists for certifications and availability
  final List<String> _certifications = [];
  final List<String> _availability = [];

  // Controllers for adding new items to lists
  final TextEditingController _certificationController =
      TextEditingController();
  final TextEditingController _availabilityController = TextEditingController();

  // Service instance
  final FirebaseCaregiverService _caregiverService =
      FirebaseCaregiverService.instance;

  // Loading state
  bool _isLoading = false;

  // Motivational messages for confirmation popup
  final List<String> _messages = [
    'Great caregivers make a world of difference! 🌟',
    'Adding another superhero to our team! 💪',
    'Quality care starts with quality caregivers!',
    'Building a stronger care community together! 🤝',
    'Your dedication to excellence shows! ✨',
    'Another step towards exceptional care! 🎯',
    'Expanding our circle of compassion! ❤️',
    'Great teams are built one member at a time!',
    'Welcome to the care excellence family! 🏆',
    'Making a difference, one caregiver at a time!',
    'Your commitment to care is inspiring! 🌈',
  ];

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    _nameController.dispose();
    _roleController.dispose();
    _experienceController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _certificationController.dispose();
    _availabilityController.dispose();
    super.dispose();
  }

  /// Validates email format
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  /// Validates phone number format
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// Adds certification to the list
  void _addCertification() {
    if (_certificationController.text.trim().isNotEmpty) {
      setState(() {
        _certifications.add(_certificationController.text.trim());
        _certificationController.clear();
      });
    }
  }

  /// Removes certification from the list
  void _removeCertification(int index) {
    setState(() {
      _certifications.removeAt(index);
    });
  }

  /// Adds availability slot to the list
  void _addAvailability() {
    if (_availabilityController.text.trim().isNotEmpty) {
      setState(() {
        _availability.add(_availabilityController.text.trim());
        _availabilityController.clear();
      });
    }
  }

  /// Removes availability slot from the list
  void _removeAvailability(int index) {
    setState(() {
      _availability.removeAt(index);
    });
  }

  /// Shows scrollable confirmation dialog with entered details
  Future<void> _showConfirmationDialog() async {
    // Generate random motivational message
    final random = Random();
    String randomMessage = _messages[random.nextInt(_messages.length)];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Caregiver Addition'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Random motivational message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          randomMessage,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Please review the caregiver details:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Divider(height: 20),
                _buildDetailRow('Name:', _nameController.text),
                _buildDetailRow('Role:', _roleController.text),
                _buildDetailRow('Experience:', _experienceController.text),
                _buildDetailRow('Phone:', _phoneController.text),
                _buildDetailRow('Email:', _emailController.text),
                _buildDetailRow('Bio:', _bioController.text),
                const SizedBox(height: 12),
                const Text(
                  'Certifications:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ..._certifications.isEmpty
                    ? [const Text('None', style: TextStyle(color: Colors.grey))]
                    : _certifications
                        .map((cert) => Padding(
                              padding: const EdgeInsets.only(left: 16, top: 4),
                              child: Text('• $cert'),
                            ))
                        .toList(),
                const SizedBox(height: 12),
                const Text(
                  'Availability:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ..._availability.isEmpty
                    ? [const Text('None', style: TextStyle(color: Colors.grey))]
                    : _availability
                        .map((avail) => Padding(
                              padding: const EdgeInsets.only(left: 16, top: 4),
                              child: Text('• $avail'),
                            ))
                        .toList(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm & Add'),
          ),
        ],
      ),
    );

    // If confirmed, proceed with adding caregiver
    if (confirmed == true) {
      await _submitCaregiver();
    }
  }

  /// Helper widget to build detail rows in confirmation dialog
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '(Not provided)' : value,
              style: TextStyle(
                color: value.isEmpty ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Submits the caregiver to Firebase
  Future<void> _submitCaregiver() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create CaregiverProfile object
      final profile = CaregiverProfile(
        id: '', // Will be generated by Firebase
        name: _nameController.text.trim(),
        role: _roleController.text.trim(),
        experience: _experienceController.text.trim(),
        certifications: _certifications,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        bio: _bioController.text.trim(),
        availability: _availability,
        rating: 0.0,
        reviews: 0,
        approved: false, // Admin can approve later
        approverId: null,
      );

      // Call service to create caregiver
      final result = await _caregiverService.createCaregiver(profile);

      if (result.startsWith('Error')) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add caregiver: $result'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Caregiver added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back to previous page
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Validates form and shows confirmation dialog
  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      _showConfirmationDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Caregiver'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Role field
                    TextFormField(
                      controller: _roleController,
                      decoration: const InputDecoration(
                        labelText: 'Role/Position *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.work),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Role is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Experience field
                    TextFormField(
                      controller: _experienceController,
                      decoration: const InputDecoration(
                        labelText: 'Years of Experience *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.timeline),
                        hintText: 'e.g., 5 years or 2020-01-01',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Experience is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone field
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 16),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),

                    // Bio field
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: 'Biography',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        hintText: 'Brief description about the caregiver',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Certifications section
                    const Text(
                      'Certifications',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _certificationController,
                            decoration: const InputDecoration(
                              labelText: 'Add Certification',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _addCertification,
                          icon: const Icon(Icons.add_circle),
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Display certifications list
                    Wrap(
                      spacing: 8,
                      children: _certifications
                          .asMap()
                          .entries
                          .map(
                            (entry) => Chip(
                              label: Text(entry.value),
                              deleteIcon: const Icon(Icons.close),
                              onDeleted: () => _removeCertification(entry.key),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 24),

                    // Availability section
                    const Text(
                      'Availability',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _availabilityController,
                            decoration: const InputDecoration(
                              labelText: 'Add Availability Slot',
                              border: OutlineInputBorder(),
                              hintText: 'e.g., Monday 9AM-5PM',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _addAvailability,
                          icon: const Icon(Icons.add_circle),
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Display availability list
                    Wrap(
                      spacing: 8,
                      children: _availability
                          .asMap()
                          .entries
                          .map(
                            (entry) => Chip(
                              label: Text(entry.value),
                              deleteIcon: const Icon(Icons.close),
                              onDeleted: () => _removeAvailability(entry.key),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Add Caregiver',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
