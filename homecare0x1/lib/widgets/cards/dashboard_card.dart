import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homecare0x1/theme/app_theme.dart';

/// A modern, interactive card widget for displaying dashboard items with enhanced
/// visual feedback, animations, and state management.
/// Features include hover effects, press animations, loading states, and badges.
class ModernDashboardCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final Future<void> Function()? onAsyncTap;
  final String? value;
  final String? change;
  final bool? isPositive;
  final bool showBadge;
  final int badgeCount;
  final bool isLoading;
  final bool isDisabled;
  final Color? customCardColor;
  final Widget? customTrailing;
  final double elevation;
  final Duration animationDuration;

  const ModernDashboardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.onTap,
    this.onAsyncTap,
    this.value,
    this.change,
    this.isPositive,
    this.showBadge = false,
    this.badgeCount = 0,
    this.isLoading = false,
    this.isDisabled = false,
    this.customCardColor,
    this.customTrailing,
    this.elevation = 2.0,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<ModernDashboardCard> createState() => _ModernDashboardCardState();
}

class _ModernDashboardCardState extends State<ModernDashboardCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  bool _isPressed = false;
  bool _isHovered = false;
  bool _isInternalLoading = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    if (widget.isLoading) {
      _shimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(ModernDashboardCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _shimmerController.repeat();
      } else {
        _shimmerController.stop();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.isDisabled || _isInternalLoading) return;

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Animation feedback
    await _scaleController.forward();
    _scaleController.reverse();

    if (widget.onAsyncTap != null) {
      setState(() => _isInternalLoading = true);
      try {
        await widget.onAsyncTap!();
      } finally {
        if (mounted) {
          setState(() => _isInternalLoading = false);
        }
      }
    } else {
      widget.onTap?.call();
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isDisabled && !_isInternalLoading) {
      setState(() => _isPressed = true);
      _scaleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  Widget _buildShimmerEffect({required Widget child}) {
    if (!widget.isLoading && !_isInternalLoading) return child;

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Colors.transparent,
                Colors.white54,
                Colors.transparent,
              ],
              stops: [
                0.0,
                _shimmerAnimation.value.clamp(0.0, 1.0),
                1.0,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }

  Widget _buildBadge() {
    if (!widget.showBadge || widget.badgeCount <= 0)
      return const SizedBox.shrink();

    return Positioned(
      top: -4,
      right: -4,
      child: AnimatedContainer(
        duration: widget.animationDuration,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.errorRed,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.errorRed.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
        child: Text(
          widget.badgeCount > 99 ? '99+' : widget.badgeCount.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: widget.animationDuration,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.iconColor.withOpacity(_isHovered ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.icon,
            color: widget.iconColor,
            size: 32,
          ),
        ),
        _buildBadge(),
      ],
    );
  }

  Widget _buildStats() {
    if (widget.value == null &&
        widget.change == null &&
        widget.customTrailing == null) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.customTrailing != null) ...[
          widget.customTrailing!,
        ] else ...[
          if (widget.value != null)
            AnimatedDefaultTextStyle(
              duration: widget.animationDuration,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _isHovered ? widget.iconColor : null,
                      ) ??
                  const TextStyle(),
              child: Text(widget.value!),
            ),
          if (widget.change != null) ...[
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: widget.animationDuration,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: widget.isPositive == true
                    ? AppTheme.successGreen
                    : AppTheme.errorRed,
                borderRadius: BorderRadius.circular(12),
                boxShadow: _isPressed
                    ? []
                    : [
                        BoxShadow(
                          color: (widget.isPositive == true
                                  ? AppTheme.successGreen
                                  : AppTheme.errorRed)
                              .withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Text(
                widget.change!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.isLoading || _isInternalLoading;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: AnimatedContainer(
              duration: widget.animationDuration,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.1),
                    blurRadius: _isHovered ? 8 : 4,
                    offset: Offset(0, _isHovered ? 4 : 2),
                  ),
                ],
              ),
              child: Card(
                elevation: 0,
                color: widget.customCardColor ??
                    (_isHovered
                        ? Theme.of(context).cardColor.withOpacity(0.95)
                        : null),
                child: GestureDetector(
                  onTapDown: _handleTapDown,
                  onTapUp: _handleTapUp,
                  onTapCancel: _handleTapCancel,
                  onTap: _handleTap,
                  child: AnimatedOpacity(
                    duration: widget.animationDuration,
                    opacity: widget.isDisabled ? 0.6 : 1.0,
                    child: _buildShimmerEffect(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _buildIcon(),
                                const Spacer(),
                                if (isLoading)
                                  const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                else
                                  _buildStats(),
                              ],
                            ),
                            const SizedBox(height: 12),
                            AnimatedDefaultTextStyle(
                              duration: widget.animationDuration,
                              style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: _isHovered
                                            ? widget.iconColor
                                            : null,
                                      ) ??
                                  const TextStyle(),
                              child: Text(widget.title),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.subtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.neutral600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
