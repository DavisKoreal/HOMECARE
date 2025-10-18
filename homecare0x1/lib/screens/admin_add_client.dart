// lib/screens/admin_add_client.dart
// Screen for adding new clients to the system.
// Provides a form with validation for client information entry.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:homecare0x1/models/client.dart';
import 'package:homecare0x1/services/client_service.dart';

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

  /// Validates and submits the form to create a new client.
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show confirmation dialog before creating
    final confirmed = await _showConfirmationDialog();
    if (confirmed != true) {
      return;
    }

    setState(() => _isLoading = true);

    final client = Client(
      id: '', // Will be assigned by Firestore
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      carePlan: _carePlanController.text.trim(),
    );

    try {
      final result = await FirebaseClientService.instance.createClient(client);

      if (!mounted) return;

      if (result.startsWith('Error')) {
        _showMessage('Failed to create client: $result', isError: true);
      } else {
        _showMessage('Client created successfully!');
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('An error occurred: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Shows a confirmation dialog with client details and a random message.
  Future<bool?> _showConfirmationDialog() async {
    final random = Random();
    List<String> messages = [
      'Great choice! This client is in good hands.',
      'Ready to make a difference in their care journey?',
      'Every client deserves exceptional care. Let\'s do this!',
      'Another step towards better healthcare. Confirm?',
      'Quality care starts here. Proceed with creation?',
      'Your dedication makes all the difference!',
      'Building trust, one client at a time.',
      'Excellence in care begins with you!',
    ];
    String randomMessage = messages[random.nextInt(messages.length)];

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Client Creation'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          randomMessage,
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Please review the details:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Name', _nameController.text.trim()),
                _buildDetailRow('Email', _emailController.text.trim()),
                _buildDetailRow('Address', _addressController.text.trim()),
                _buildDetailRow('Care Plan', _carePlanController.text.trim()),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm & Create'),
            ),
          ],
        );
      },
    );
  }

  /// Builds a row displaying a detail label and value.
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a snackbar message to the user.
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Client'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter client name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter email address';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.home,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _carePlanController,
                label: 'Care Plan',
                icon: Icons.medical_services,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter care plan';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Create Client',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a styled text field with consistent appearance.
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      enabled: !_isLoading,
    );
  }
}
