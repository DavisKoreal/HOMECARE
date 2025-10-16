import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/client.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:homecare0x1/providers/client_provider.dart';

class ClientProfileScreen extends StatefulWidget {
  final bool isAdding;
  final Client? client;

  const ClientProfileScreen({super.key, this.isAdding = false, this.client});

  @override
  _ClientProfileScreenState createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _carePlanController;
  late TextEditingController _emailController;
  late TextEditingController _dateOfBirthController;
  bool _isEditing = false;
  late Client _client;

  @override
  void initState() {
    super.initState();
    if (widget.isAdding) {
      _isEditing = true; // Start in edit mode for adding
      _client = Client(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '',
        address: '',
        carePlan: '',
        email: '',
        clientId: '',
        dateOfBirth: DateTime.now(),
        createdAt: DateTime.now(),
      );
    } else {
      _client = widget.client ?? Client.fromLegacyData(
        id: '1',
        name: 'John Doe',
        address: '123 Main St',
        carePlan: 'Daily care, mobility assistance',
        email: 'test@email.com',
        dateOfBirth: DateTime(1950, 1, 1), // Fixed: Added dateOfBirth
      );
    }

    _nameController = TextEditingController(text: _client.name);
    _addressController = TextEditingController(text: _client.address);
    _carePlanController = TextEditingController(text: _client.carePlan);
    _emailController = TextEditingController(text: _client.email);
    _dateOfBirthController = TextEditingController(
      text: _client.dateOfBirth != null
          ? _client.dateOfBirth.toIso8601String().substring(0, 10)
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _carePlanController.dispose();
    _emailController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _toggleEdit() async {
    setState(() {
      if (_isEditing && _formKey.currentState!.validate()) {
        _client = _client.copyWith(
          name: _nameController.text,
          address: _addressController.text,
          carePlan: _carePlanController.text,
          email: _emailController.text,
          dateOfBirth: DateTime.tryParse(_dateOfBirthController.text) ?? _client.dateOfBirth,
        );
        try {
          if (widget.isAdding) {
            context.read<ClientProvider>().addClient(
              name: _client.name,
              email: _client.email,
              dateOfBirth: _client.dateOfBirth,
              address: _client.address,
              carePlan: _client.carePlan,
            );
            Navigator.pop(context);
          } else {
            context.read<ClientProvider>().updateClient(_client);
          }
          _isEditing = false;
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        }
      } else if (!widget.isAdding) {
        _isEditing = !_isEditing;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModernScreenLayout(
      title: widget.isAdding ? 'Add Client' : 'Client Profile',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isAdding ? 'Add New Client' : 'Client Details',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                widget.isAdding
                    ? 'Enter new client information'
                    : 'View and edit client information',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              // Client ID (Read-only)
              TextFormField(
                initialValue: _client.clientId.isEmpty ? 'Will be generated' : _client.clientId,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Client ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
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
                controller: _emailController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an email' : null,
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateOfBirthController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a date of birth' : null,
                onTap: () async {
                  if (_isEditing) {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _client.dateOfBirth,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      _dateOfBirthController.text =
                          pickedDate.toIso8601String().substring(0, 10);
                    }
                  }
                },
              ),
              const SizedBox(height: 24),
              ModernButton(
                text: widget.isAdding
                    ? 'Add Client'
                    : (_isEditing ? 'Save Changes' : 'Edit Profile'),
                icon: widget.isAdding
                    ? Icons.add
                    : (_isEditing ? Icons.save : Icons.edit),
                onPressed: () {
                  if (_isEditing && _formKey.currentState!.validate()) {
                    _toggleEdit();
                  } else if (!widget.isAdding && !_isEditing) {
                    _toggleEdit();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}