import 'package:flutter/material.dart';
import 'package:homecare0x1/models/caregiver_profile.dart';
import 'package:homecare0x1/services/firebase_caregiver_service.dart';
import 'package:homecare0x1/theme/app_theme.dart';

class AdminAddCaregiverPage extends StatefulWidget {
  final VoidCallback? onBack;
  const AdminAddCaregiverPage({Key? key, this.onBack}) : super(key: key);

  @override
  State<AdminAddCaregiverPage> createState() => _AdminAddCaregiverPageState();
}

class _AdminAddCaregiverPageState extends State<AdminAddCaregiverPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _experienceController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _certInputController = TextEditingController();
  final _availInputController = TextEditingController();

  final List<String> _certifications = [];
  final List<String> _availability = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _experienceController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _certInputController.dispose();
    _availInputController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.maybePop(context);
    }
  }

  void _addToList(TextEditingController controller, List<String> list) {
    if (controller.text.trim().isNotEmpty) {
      setState(() {
        list.add(controller.text.trim());
        controller.clear();
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final profile = CaregiverProfile(
      id: '',
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
      approved: false,
      approverId: null,
    );

    try {
      final result = await FirebaseCaregiverService.instance.createCaregiver(profile);
      
      if (!mounted) return;

      if (result.startsWith('Error')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result), backgroundColor: AppTheme.errorRed));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Caregiver added successfully'), backgroundColor: AppTheme.successGreen));
        _handleBack();
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderGray),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Care Staff',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _handleBack,
                    )
                  ],
                ),
                const Divider(height: 48),

                // Grid Layout for inputs
                LayoutBuilder(builder: (context, constraints) {
                  // If wide enough, put Name/Role side by side
                  bool isWide = constraints.maxWidth > 500;
                  return Column(
                    children: [
                      _buildResponsiveRow([
                        _buildInputGroup('Full Name', _nameController, 'Required'),
                        _buildInputGroup('Role / Title', _roleController, 'e.g. Nurse, Aid'),
                      ], isWide),
                      const SizedBox(height: 24),
                      _buildResponsiveRow([
                        _buildInputGroup('Email', _emailController, 'Required', TextInputType.emailAddress),
                        _buildInputGroup('Phone', _phoneController, 'Required', TextInputType.phone),
                      ], isWide),
                    ],
                  );
                }),
                
                const SizedBox(height: 24),
                _buildLabel('Experience'),
                TextFormField(
                  controller: _experienceController,
                  decoration: const InputDecoration(hintText: 'e.g. 5 years in elderly care'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),

                const SizedBox(height: 24),
                _buildLabel('Biography'),
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'Brief professional summary...'),
                ),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 24),

                // Dynamic Lists (Certifications)
                _buildDynamicListInput(
                  'Certifications', 
                  _certInputController, 
                  _certifications, 
                  'Add Certification'
                ),

                const SizedBox(height: 24),

                // Dynamic Lists (Availability)
                _buildDynamicListInput(
                  'Availability', 
                  _availInputController, 
                  _availability, 
                  'Add Slot (e.g. Mon 9-5)'
                ),

                const SizedBox(height: 40),

                // Action Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _handleBack,
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Add Caregiver'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputGroup(String label, TextEditingController controller, String hint, [TextInputType? type]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(hintText: hint),
          validator: (v) => v!.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildResponsiveRow(List<Widget> children, bool isWide) {
    if (!isWide) {
      return Column(
        children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 24), child: c)).toList(),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: children[0]),
        const SizedBox(width: 24),
        Expanded(child: children[1]),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildDynamicListInput(String title, TextEditingController controller, List<String> list, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(title),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(hintText: hint),
                onFieldSubmitted: (_) => _addToList(controller, list),
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              onPressed: () => _addToList(controller, list),
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(backgroundColor: AppTheme.primaryPurple.withOpacity(0.1), foregroundColor: AppTheme.primaryPurple),
            )
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: list.asMap().entries.map((entry) {
            return Chip(
              label: Text(entry.value),
              backgroundColor: AppTheme.backgroundCanvas,
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => setState(() => list.removeAt(entry.key)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), 
                side: const BorderSide(color: AppTheme.borderGray)
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
