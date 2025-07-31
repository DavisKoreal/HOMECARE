import 'package:flutter/material.dart';
import 'package:homecare0x1/theme/app_theme.dart';

class ModernScreenLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? floatingActionButton;

  const ModernScreenLayout({
    super.key,
    required this.title,
    required this.body,
    this.showBackButton = false,
    this.onBackPressed,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppTheme.primaryBlue,
                ),
                onPressed: onBackPressed ??
                    () => Navigator.pop(context),
              )
            : null,
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
