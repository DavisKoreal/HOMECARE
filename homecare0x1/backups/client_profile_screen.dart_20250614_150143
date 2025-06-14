import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/client.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  _ClientProfileScreenState createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _carePlanController;
  bool _isEditing = false;

  // Mock client data
  Client _client = Client(
      id: '1',
      name: 'John Doe',
      address: '123 Main St',
      carePlan: 'Daily care, mobility assistance',
      email: 'test@email.com');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _client.name);
    _addressController = TextEditingController(text: _client.address);
    _carePlanController = TextEditingController(text: _client.carePlan);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _carePlanController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Save changes (mock save)
        _client = Client(
          id: _client.id,
          name: _nameController.text,
          address: _addressController.text,
          carePlan: _carePlanController.text,
          email: _client.email, // Assuming email is not editable
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModernScreenLayout(
      title: 'Client Profile',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Client Details',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'View and edit client information',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an address' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _carePlanController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'Care Plan',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a care plan' : null,
              ),
              const SizedBox(height: 24),
              ModernButton(
                text: _isEditing ? 'Save Changes' : 'Edit Profile',
                icon: _isEditing ? Icons.save : Icons.edit,
                width: double.infinity,
                onPressed: () {
                  if (_isEditing && _formKey.currentState!.validate()) {
                    _toggleEdit();
                  } else if (!_isEditing) {
                    _toggleEdit();
                  }
                },
              ),
              const SizedBox(height: 16),
              ModernButton(
                text: 'Back to Client List',
                icon: Icons.arrow_back,
                isOutlined: true,
                width: double.infinity,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
