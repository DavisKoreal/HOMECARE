import 'package:flutter/material.dart';
import 'package:homecare0x1/theme/app_theme.dart';

class ModernButton extends StatefulWidget {
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
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? 120.0, // Default finite width to avoid infinite width error
      height: 48,
      child: widget.isOutlined
          ? OutlinedButton.icon(
              onPressed: widget.isLoading ? null : widget.onPressed,
              icon: widget.icon != null && !widget.isLoading ? Icon(widget.icon, color: AppTheme.primaryBlue) : const SizedBox(),
              label: widget.isLoading
                  ? const CircularProgressIndicator()
                  : Text(widget.text, style: const TextStyle(color: AppTheme.primaryBlue)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: widget.isLoading ? null : widget.onPressed,
              icon: widget.icon != null && !widget.isLoading ? Icon(widget.icon, color: Colors.white) : const SizedBox(),
              label: widget.isLoading
                  ? const CircularProgressIndicator()
                  : Text(widget.text),
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
