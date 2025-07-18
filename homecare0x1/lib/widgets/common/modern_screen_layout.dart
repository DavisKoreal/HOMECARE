import 'package:flutter/material.dart';
import 'package:homecare0x1/theme/app_theme.dart';

class ModernScreenLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? leading;
  final VoidCallback? onBackPressed;

  const ModernScreenLayout({
    super.key,
    required this.title,
    required this.body,
    this.showBackButton = true,
    this.actions,
    this.floatingActionButton,
    this.leading,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: leading ??
            (showBackButton
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBackPressed ?? () => Navigator.pop(context),
                  )
                : null),
        actions: actions,
        backgroundColor: AppTheme.neutral100,
        elevation: 0,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      backgroundColor: AppTheme.neutral100,
    );
  }
}
