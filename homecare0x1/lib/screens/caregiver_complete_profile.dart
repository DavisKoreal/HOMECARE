import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/caregiver_profile.dart';
import 'package:homecare0x1/providers/caregiver_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';

class CaregiverCompleteProfileScreen extends StatefulWidget {
  const CaregiverCompleteProfileScreen({super.key});

  @override
  _CaregiverCompleteProfileScreenState createState() => _CaregiverCompleteProfileScreenState();
}

class _CaregiverCompleteProfileScreenState extends State<CaregiverCompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _employeeIDController = TextEditingController();
  final _positionController = TextEditingController();
  final _addressController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _phoneController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();
  final _certificationsController = TextEditingController();
  final _availabilityController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _employeeIDController.dispose();
    _positionController.dispose();
    _addressController.dispose();
    _dateOfBirthController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    _certificationsController.dispose();
    _availabilityController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      try {
        await Provider.of<CaregiverProvider>(context, listen: false).addCaregiver(
          name: _nameController.text.trim(),
          position: _positionController.text.trim(),
          dateOfBirth: DateTime.tryParse(_dateOfBirthController.text) ?? DateTime(1980),
          address: _addressController.text.trim(),
          phone: _phoneController.text.trim(),
          experience: _experienceController.text.trim(),
          bio: _bioController.text.trim(),
          certifications: _certificationsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
          availability: _availabilityController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        );
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, Routes.login);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile submitted for approval')),
          );
        }
      } catch (error) {
        setState(() {
          _isSubmitting = false;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModernScreenLayout(
      title: 'Complete Caregiver Profile',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Complete Your Profile',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Provide additional details to complete your caregiver profile',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _employeeIDController,
                decoration: const InputDecoration(
                  labelText: 'Employee ID (e.g., CG0001)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter your employee ID' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(
                  labelText: 'Position (e.g., Nurse)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter your position' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter your address' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateOfBirthController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter your date of birth';
                  if (DateTime.tryParse(value) == null) return 'Please enter a valid date';
                  return null;
                },
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    _dateOfBirthController.text = pickedDate.toIso8601String().substring(0, 10);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _experienceController,
                decoration: const InputDecoration(
                  labelText: 'Years of Experience',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter your years of experience' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) => value!.isEmpty ? 'Please enter your bio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _certificationsController,
                decoration: const InputDecoration(
                  labelText: 'Certifications (comma-separated)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter your certifications' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _availabilityController,
                decoration: const InputDecoration(
                  labelText: 'Availability (comma-separated days)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter your availability' : null,
              ),
              const SizedBox(height: 24),
              ModernButton(
                text: 'Submit Profile',
                icon: Icons.save,
                onPressed: () {
                  if (_isSubmitting) return;
                  _submitProfile();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}