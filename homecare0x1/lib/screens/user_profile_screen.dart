import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:homecare0x1/models/user.dart'; // Ensure the correct path to the User model
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _notificationsEnabled = true;
  String? _profileImageUrl;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _profileImageUrl = null; // Assuming no profileImageUrl in User model

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<bool?> _confirmLogout(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Log Out',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.neutral600,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppTheme.neutral600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Log Out', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _nameController.text =
            Provider.of<UserProvider>(context, listen: false).user?.name ?? '';
        _emailController.text =
            Provider.of<UserProvider>(context, listen: false).user?.email ?? '';
      }
    });
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setUser(
        User(
          id: userProvider.user!.id,
          role: userProvider.user!.role,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
        ),
      );
      setState(() {
        _isLoading = false;
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!',
              style: TextStyle(color: Colors.white)),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _uploadProfileImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image upload feature coming soon!',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.neutral600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return ModernScreenLayout(
      title: 'Profile',
      showBackButton: true,
      onBackPressed: () => Navigator.pushReplacementNamed(
        context,
        userProvider.getInitialRoute(),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: user == null
                ? _buildNotLoggedIn(context)
                : _buildProfile(context, userProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Icon(Icons.lock_outline, size: 80, color: AppTheme.neutral600),
        const SizedBox(height: 16),
        Text(
          'Not Logged In',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.neutral600,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'Please log in to access your profile.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.neutral600,
                height: 1.5,
              ),
        ),
        const SizedBox(height: 32),
        ModernButton(
          text: 'Go to Login',
          icon: Icons.login,
          width: double.infinity,
          onPressed: () =>
              Navigator.pushReplacementNamed(context, Routes.login),
        ),
      ],
    );
  }

  Widget _buildProfile(BuildContext context, UserProvider userProvider) {
    final user = userProvider.user!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryBlue, AppTheme.primaryBlueLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${user.name}!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your account settings',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Profile Card
        Card(
          elevation: 4,
          shadowColor: AppTheme.neutral100.withOpacity(0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
                      child: _profileImageUrl != null
                          ? ClipOval(
                              child: Image.network(
                                _profileImageUrl!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                  Icons.person,
                                  size: 50,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 50,
                              color: AppTheme.primaryBlue,
                            ),
                    ),
                    if (_isEditing)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _uploadProfileImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.camera_alt,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        enabled: _isEditing,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline,
                              color: AppTheme.neutral600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppTheme.neutral100,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        enabled: _isEditing,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined,
                              color: AppTheme.neutral600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppTheme.neutral100,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Chip(
                  label: Text(user.role.toUpperCase()),
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Notification Settings
        Card(
          elevation: 4,
          shadowColor: AppTheme.neutral100.withOpacity(0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ListTile(
            leading: Icon(Icons.notifications, color: AppTheme.primaryBlue),
            title: Text(
              'Push Notifications',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Notifications ${value ? 'enabled' : 'disabled'}',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppTheme.neutral100,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              activeColor: AppTheme.successGreen,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Action Buttons
        if (_isEditing)
          Row(
            children: [
              Expanded(
                child: ModernButton(
                  text: 'Cancel',
                  icon: Icons.cancel,
                  isOutlined: true,
                  width: double.infinity,
                  onPressed: _toggleEditMode,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ModernButton(
                  text: 'Save',
                  icon: Icons.save,
                  width: double.infinity,
                  isLoading: _isLoading,
                  onPressed: _saveProfile,
                ),
              ),
            ],
          )
        else
          ModernButton(
            text: 'Edit Profile',
            icon: Icons.edit,
            width: double.infinity,
            onPressed: _toggleEditMode,
          ),
        const SizedBox(height: 16),
        ModernButton(
          text: 'Log Out',
          icon: Icons.logout,
          isOutlined: true,
          width: double.infinity,
          onPressed: () async {
            final shouldLogout = await _confirmLogout(context);
            if (shouldLogout ?? false) {
              userProvider.clearUser();
              Navigator.pushReplacementNamed(context, Routes.login);
            }
          },
        ),
      ],
    );
  }
}
