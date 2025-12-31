import os

def refactor_forms():
    target_dir = os.path.expanduser("~/Desktop/HOMECARE/homecare0x1")
    
    if not os.path.exists(target_dir):
        print(f"Error: Directory {target_dir} not found.")
        return

    print(f"Changing directory to: {target_dir}")
    os.chdir(target_dir)

    # ---------------------------------------------------------
    # 1. Refactor Admin Add Client
    # ---------------------------------------------------------
    print("\n--- Refactoring lib/screens/admin_add_client.dart ---")
    client_path = os.path.join("lib", "screens", "admin_add_client.dart")
    
    client_content = """import 'package:flutter/material.dart';
import 'package:homecare0x1/models/client.dart';
import 'package:homecare0x1/services/client_service.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/constants.dart';

class AdminAddClientScreen extends StatefulWidget {
  const AdminAddClientScreen({Key? key}) : super(key: key);

  @override
  State<AdminAddClientScreen> createState() => _AdminAddClientScreenState();
}

class _AdminAddClientScreenState extends State<AdminAddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _carePlanController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _carePlanController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final client = Client(
      id: '',
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      carePlan: _carePlanController.text.trim(),
    );

    try {
      final result = await FirebaseClientService.instance.createClient(client);

      if (!mounted) return;

      if (result.startsWith('Error')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result), backgroundColor: AppTheme.errorRed));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Client added successfully'), backgroundColor: AppTheme.successGreen));
        // In SPA mode, we might want to navigate back to list or clear form
        // For now, let's go back to Client List if possible, or just clear.
        // Assuming navigation stack:
        Navigator.maybePop(context); 
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
    // Centered Form Container for Desktop Aesthetics
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
                      'Add New Client',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.maybePop(context),
                    )
                  ],
                ),
                const Divider(height: 48),

                // Form Fields
                _buildLabel('Full Name'),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'e.g. John Doe'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),

                _buildLabel('Email Address'),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(hintText: 'e.g. john@example.com'),
                  validator: (v) => !v!.contains('@') ? 'Invalid email' : null,
                ),
                const SizedBox(height: 24),

                _buildLabel('Physical Address'),
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(hintText: 'Enter full address'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),

                _buildLabel('Care Plan Details'),
                TextFormField(
                  controller: _carePlanController,
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: 'Describe needs, medication, schedule...'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 40),

                // Action Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.maybePop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Client'),
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
}
"""
    with open(client_path, "w", encoding="utf-8") as f:
        f.write(client_content)
    print("Rewrote admin_add_client.dart")


    # ---------------------------------------------------------
    # 2. Refactor Admin Add Caregiver
    # ---------------------------------------------------------
    print("\n--- Refactoring lib/screens/admin_add_caregiver.dart ---")
    caregiver_path = os.path.join("lib", "screens", "admin_add_caregiver.dart")
    
    caregiver_content = """import 'package:flutter/material.dart';
import 'package:homecare0x1/models/caregiver_profile.dart';
import 'package:homecare0x1/services/firebase_caregiver_service.dart';
import 'package:homecare0x1/theme/app_theme.dart';

class AdminAddCaregiverPage extends StatefulWidget {
  const AdminAddCaregiverPage({Key? key}) : super(key: key);

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
        Navigator.maybePop(context);
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
                      onPressed: () => Navigator.maybePop(context),
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
                      onPressed: () => Navigator.maybePop(context),
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
"""
    with open(caregiver_path, "w", encoding="utf-8") as f:
        f.write(caregiver_content)
    print("Rewrote admin_add_caregiver.dart")

if __name__ == "__main__":
    refactor_forms()