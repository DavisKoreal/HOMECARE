import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/caregiver_profile.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:homecare0x1/providers/caregiver_provider.dart';

class CaregiverProfileScreen extends StatefulWidget {
  final bool isAdding;
  final CaregiverProfile? caregiver;

  const CaregiverProfileScreen({super.key, this.isAdding = false, this.caregiver});

  @override
  _CaregiverProfileScreenState createState() => _CaregiverProfileScreenState();
}

class _CaregiverProfileScreenState extends State<CaregiverProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _employeeIDController;
  late TextEditingController _positionController;
  late TextEditingController _addressController;
  late TextEditingController _dateOfBirthController;
  bool _isEditing = false;
  late CaregiverProfile _caregiver;

  @override
  void initState() {
    super.initState();
    if (widget.isAdding) {
      _isEditing = true;
      _caregiver = CaregiverProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '',
        employeeID: '',
        position: '',
        dateOfBirth: DateTime.now(),
        address: '',
        role: 'Caregiver',
        experience: '',
        certifications: [],
        phone: '',
        email: '',
        bio: '',
        availability: [],
        rating: 0.0,
        reviews: 0,
        approved: false,
        approverId: null,
      );
    } else {
      _caregiver = widget.caregiver ?? CaregiverProfile(
        id: '1',
        name: 'Jane Doe',
        employeeID: 'CG0000',
        position: 'Nurse',
        dateOfBirth: DateTime(1980, 1, 1),
        address: '456 Health St',
        role: 'Caregiver',
        experience: '5 years',
        certifications: [],
        phone: '',
        email: '',
        bio: '',
        availability: [],
        rating: 0.0,
        reviews: 0,
        approved: false,
        approverId: null,
      );
    }

    _nameController = TextEditingController(text: _caregiver.name);
    _employeeIDController = TextEditingController(text: _caregiver.employeeID.isEmpty ? 'Will be generated' : _caregiver.employeeID);
    _positionController = TextEditingController(text: _caregiver.position);
    _addressController = TextEditingController(text: _caregiver.address);
    _dateOfBirthController = TextEditingController(
      text: _caregiver.dateOfBirth.toIso8601String().substring(0, 10),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _employeeIDController.dispose();
    _positionController.dispose();
    _addressController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _toggleEdit() async {
    setState(() {
      if (_isEditing && _formKey.currentState!.validate()) {
        _caregiver = CaregiverProfile(
          id: _caregiver.id,
          name: _nameController.text,
          employeeID: _caregiver.employeeID,
          position: _positionController.text,
          dateOfBirth: DateTime.tryParse(_dateOfBirthController.text) ?? _caregiver.dateOfBirth,
          address: _addressController.text,
          role: _caregiver.role,
          experience: _caregiver.experience,
          certifications: _caregiver.certifications,
          phone: _caregiver.phone,
          email: _caregiver.email,
          bio: _caregiver.bio,
          availability: _caregiver.availability,
          rating: _caregiver.rating,
          reviews: _caregiver.reviews,
          approved: _caregiver.approved,
          approverId: _caregiver.approverId,
        );
        try {
          if (widget.isAdding) {
            context.read<CaregiverProvider>().addCaregiver(
              name: _caregiver.name,
              position: _caregiver.position,
              dateOfBirth: _caregiver.dateOfBirth,
              address: _caregiver.address,
            );
            Navigator.pop(context);
          } else {
            context.read<CaregiverProvider>().updateCaregiver(_caregiver);
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
      title: widget.isAdding ? 'Add Caregiver' : 'Caregiver Profile',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isAdding ? 'Add New Caregiver' : 'Caregiver Details',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                widget.isAdding
                    ? 'Enter new caregiver information'
                    : 'View and edit caregiver information',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _employeeIDController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Employee ID',
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
                controller: _positionController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'Position',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a position' : null,
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
                      initialDate: _caregiver.dateOfBirth,
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
                    ? 'Add Caregiver'
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