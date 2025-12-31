import 'package:flutter/material.dart';
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
