import 'package:flutter/material.dart';
import 'package:homecare0x1/theme/app_theme.dart';

class ModernButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double? width;
  final bool isOutlined;
  final bool isLoading;

  const ModernButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.width,
    this.isOutlined = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 48,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: icon != null && !isLoading ? Icon(icon) : const SizedBox(),
              label: isLoading
                  ? const CircularProgressIndicator()
                  : Text(text),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: icon != null && !isLoading ? Icon(icon) : const SizedBox(),
              label: isLoading
                  ? const CircularProgressIndicator()
                  : Text(text),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
    );
  }
}
