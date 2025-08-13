import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';

class FamilyPortalScreen extends StatefulWidget {
  const FamilyPortalScreen({super.key});

  @override
  State<FamilyPortalScreen> createState() => _FamilyPortalScreenState();
}

class _FamilyPortalScreenState extends State<FamilyPortalScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _statsAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late List<Animation<double>> _statsAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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

    _statsAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _statsAnimationController,
          curve: Interval(
            index * 0.2,
            0.6 + (index * 0.2),
            curve: Curves.elasticOut,
          ),
        ),
      );
    });

    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _statsAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _statsAnimationController.dispose();
    super.dispose();
  }

  Future<void> _showRequestShiftDialog(BuildContext context) async {
    DateTime? startTime = DateTime.now().add(const Duration(hours: 1));
    DateTime? endTime = startTime.add(const Duration(hours: 2));
    String? errorMessage;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with icon and title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.schedule,
                            color: AppTheme.secondaryTeal,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Request Caregiving Session',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Schedule a new care session',
                                style: TextStyle(
                                  color: Color(0xFF7F8C8D),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Start Time Selection Card
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE9ECEF),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF3498DB)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow,
                                        color: Color(0xFF3498DB),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Start Time',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: startTime!,
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now()
                                              .add(const Duration(days: 365)),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme: Theme.of(context)
                                                    .colorScheme
                                                    .copyWith(
                                                      primary: const Color(
                                                          0xFF3498DB),
                                                    ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );
                                        if (date != null) {
                                          final time = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.fromDateTime(
                                                startTime!),
                                            builder: (context, child) {
                                              return Theme(
                                                data:
                                                    Theme.of(context).copyWith(
                                                  colorScheme: Theme.of(context)
                                                      .colorScheme
                                                      .copyWith(
                                                        primary: const Color(
                                                            0xFF3498DB),
                                                      ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );
                                          if (time != null) {
                                            setState(() {
                                              startTime = DateTime(
                                                date.year,
                                                date.month,
                                                date.day,
                                                time.hour,
                                                time.minute,
                                              );
                                              endTime = startTime!.add(
                                                  const Duration(hours: 2));
                                              errorMessage = null;
                                            });
                                          }
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3498DB)
                                              .withOpacity(0.05),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFF3498DB)
                                                .withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.access_time,
                                              color: Color(0xFF3498DB),
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                startTime != null
                                                    ? DateFormat(
                                                            'MMM dd, yyyy • hh:mm a')
                                                        .format(startTime!)
                                                    : 'Select start time',
                                                style: TextStyle(
                                                  color: startTime != null
                                                      ? const Color(0xFF2C3E50)
                                                      : const Color(0xFF7F8C8D),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const Icon(
                                              Icons.chevron_right,
                                              color: Color(0xFF3498DB),
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // End Time Selection Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE67E22)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.stop,
                                        color: Color(0xFFE67E22),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'End Time',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: endTime!,
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now()
                                              .add(const Duration(days: 365)),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme: Theme.of(context)
                                                    .colorScheme
                                                    .copyWith(
                                                      primary: const Color(
                                                          0xFFE67E22),
                                                    ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );
                                        if (date != null) {
                                          final time = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.fromDateTime(
                                                endTime!),
                                            builder: (context, child) {
                                              return Theme(
                                                data:
                                                    Theme.of(context).copyWith(
                                                  colorScheme: Theme.of(context)
                                                      .colorScheme
                                                      .copyWith(
                                                        primary: const Color(
                                                            0xFFE67E22),
                                                      ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );
                                          if (time != null) {
                                            setState(() {
                                              endTime = DateTime(
                                                date.year,
                                                date.month,
                                                date.day,
                                                time.hour,
                                                time.minute,
                                              );
                                              errorMessage = null;
                                            });
                                          }
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE67E22)
                                              .withOpacity(0.05),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFFE67E22)
                                                .withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.access_time,
                                              color: Color(0xFFE67E22),
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                endTime != null
                                                    ? DateFormat(
                                                            'MMM dd, yyyy • hh:mm a')
                                                        .format(endTime!)
                                                    : 'Select end time',
                                                style: TextStyle(
                                                  color: endTime != null
                                                      ? const Color(0xFF2C3E50)
                                                      : const Color(0xFF7F8C8D),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const Icon(
                                              Icons.chevron_right,
                                              color: Color(0xFFE67E22),
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Duration Display
                    if (startTime != null && endTime != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.secondaryTeal.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryTeal.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.schedule,
                                color: AppTheme.secondaryTeal,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Duration: ${endTime!.difference(startTime!).inHours}h ${endTime!.difference(startTime!).inMinutes % 60}m',
                              style: const TextStyle(
                                color: AppTheme.secondaryTeal,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Error Message
                    if (errorMessage != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.errorRed.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.errorRed.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.error_outline,
                                color: AppTheme.errorRed,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(
                                  color: AppTheme.errorRed,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: Color(0xFFE9ECEF),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Color(0xFF7F8C8D),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (startTime == null || endTime == null) {
                                  setState(() {
                                    errorMessage =
                                        'Please select both start and end times';
                                  });
                                  return;
                                }
                                if (startTime!.isBefore(DateTime.now())) {
                                  setState(() {
                                    errorMessage =
                                        'Start time must be in the future';
                                  });
                                  return;
                                }
                                if (startTime!.isAfter(endTime!)) {
                                  setState(() {
                                    errorMessage =
                                        'Start time must be before end time';
                                  });
                                  return;
                                }
                                try {
                                  final userProvider =
                                      Provider.of<UserProvider>(context,
                                          listen: false);
                                  final shiftProvider =
                                      Provider.of<ShiftAssignmentProvider>(
                                          context,
                                          listen: false);
                                  await shiftProvider.requestShift(
                                    clientId: userProvider.user!.id,
                                    clientName: userProvider.user!.name,
                                    startTime: startTime!,
                                    endTime: endTime!,
                                    context: context,
                                  );
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Container(
                                        padding: const EdgeInsets.all(4),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Caregiving session request submitted successfully',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      backgroundColor: const Color(0xFF00A86B),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.all(16),
                                    ),
                                  );
                                } catch (e) {
                                  setState(() {
                                    errorMessage = e.toString();
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.send,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Submit Request',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernStat({
    required String title,
    required String value,
    required double percent,
    required Color color,
    required IconData icon,
    required Animation<double> animation,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: color.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 70,
                      width: 70,
                      child: TweenAnimationBuilder<double>(
                        duration: Duration(
                            milliseconds:
                                1000 + (animation.value * 500).round()),
                        tween:
                            Tween(begin: 0.0, end: percent * animation.value),
                        builder: (context, value, child) {
                          return CircularProgressIndicator(
                            value: value,
                            backgroundColor: color.withOpacity(0.1),
                            strokeWidth: 5,
                            valueColor: AlwaysStoppedAnimation(color),
                            strokeCap: StrokeCap.round,
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TweenAnimationBuilder<int>(
                  duration: Duration(
                      milliseconds: 1000 + (animation.value * 500).round()),
                  tween: IntTween(begin: 0, end: int.parse(value)),
                  builder: (context, value, child) {
                    return Text(
                      value.toString(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF7F8C8D),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 28,
                      ),
                    ),
                    if (badge != null) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF7F8C8D),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View',
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        color: color,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmLogout(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Logout Confirmation'),
              ],
            ),
            content: const Text(
              'Are you sure you want to logout and return to the login screen?',
              style: TextStyle(height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Family Member';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldLogout = await _confirmLogout(context);
        if (shouldLogout && context.mounted) {
          userProvider.clearUser();
          Navigator.pushReplacementNamed(context, Routes.login);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9B59B6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.family_restroom,
                  color: Color(0xFF9B59B6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Family Portal',
                style: TextStyle(
                  color: Color(0xFF2C3E50),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Stack(
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF7F8C8D),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: const Text(
                          '2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () => Navigator.pushNamed(context, Routes.messages),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF7F8C8D),
                ),
                onPressed: () =>
                    Navigator.pushNamed(context, Routes.userProfile),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async =>
              await Future.delayed(const Duration(seconds: 1)),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF9B59B6),
                            Color(0xFFAB7FB8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9B59B6).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Welcome, $userName!",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Stay connected with your loved one's care",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 16,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.family_restroom,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.update,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Last update: 2 hours ago',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Today's Overview
                    const Text(
                      'Care Overview',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildModernStat(
                            title: 'Recent Visits',
                            value: '4',
                            percent: 0.8,
                            color: const Color(0xFF3498DB),
                            icon: Icons.event_available,
                            animation: _statsAnimations[0],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildModernStat(
                            title: 'Care Notes',
                            value: '12',
                            percent: 0.75,
                            color: const Color(0xFF00A86B),
                            icon: Icons.note_outlined,
                            animation: _statsAnimations[1],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildModernStat(
                            title: 'Messages',
                            value: '5',
                            percent: 0.5,
                            color: const Color(0xFFE67E22),
                            icon: Icons.message_outlined,
                            animation: _statsAnimations[2],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Quick Actions Section
                    const Text(
                      'Quick Access',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 16),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                      children: [
                        _buildModernActionCard(
                          title: 'Request Caregiving Session',
                          subtitle:
                              'Request a new caregiving session for your loved one',
                          icon: Icons.schedule,
                          color: AppTheme.secondaryTeal,
                          onTap: () => _showRequestShiftDialog(context),
                        ),
                        // _buildModernActionCard(
                        //   title: 'Messages',
                        //   subtitle:
                        //       'Communicate with your caregiver and give instructions',
                        //   icon: Icons.message,
                        //   color: const Color(0xFF9B59B6),
                        //   onTap: () =>
                        //       Navigator.pushNamed(context, Routes.messages),
                        //   badge: '5',
                        // ),
                        _buildModernActionCard(
                          title: 'Care Notes',
                          subtitle: 'View detailed notes from your caregiver',
                          icon: Icons.note,
                          color: const Color(0xFF00A86B),
                          onTap: () => Navigator.pushNamed(
                              context, Routes.familyCareNotes),
                          badge: '3',
                        ),
                        _buildModernActionCard(
                          title: 'Visit History',
                          subtitle: 'Track all recent visits and activities',
                          icon: Icons.history,
                          color: const Color(0xFFE67E22),
                          onTap: () => Navigator.pushNamed(
                              context, Routes.clientViewShiftHistory),
                        ),
                        _buildModernActionCard(
                          title: 'Caregiver Profile',
                          subtitle:
                              'View your caregiver\'s details and contact information',
                          icon: Icons.person,
                          color: const Color(0xFF3498DB),
                          onTap: () => Navigator.pushNamed(
                              context, Routes.caregiverProfile),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Payment & Support Section
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernActionCard(
                            title: 'Payment Status',
                            subtitle: 'View billing and payment information',
                            icon: Icons.payment,
                            color: const Color(0xFF16A085),
                            onTap: () => Navigator.pushNamed(
                                context, Routes.paymentStatus),
                          ),
                        ),
                        // const SizedBox(width: 16),
                        // Expanded(
                        //   child: _buildModernActionCard(
                        //     title: 'Support Center',
                        //     subtitle: 'Get help and contact our support team',
                        //     icon: Icons.support_agent,
                        //     color: const Color(0xFFF39C12),
                        //     onTap: () {
                        //       ScaffoldMessenger.of(context).showSnackBar(
                        //         const SnackBar(
                        //           content: Text('Opening support center...'),
                        //         ),
                        //       );
                        //     },
                        //   ),
                        // ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildModernActionCard(
                            title: 'Support Testing',
                            subtitle: 'Get help and contact our support team',
                            icon: Icons.support_agent,
                            color: const Color(0xFFF39C12),
                            // onTap: () {
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     const SnackBar(
                            //       content: Text(
                            //           'Opening the tap of this test widget...'),
                            //     ),
                            //   );
                            // },
                            onTap: () => Navigator.pushNamed(
                                context, Routes.paymentStatus),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Recent Activity Section
                    const Text(
                      'Recent Updates',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildActivityItem(
                            title: 'New care note added',
                            subtitle:
                                'Daily wellness check completed successfully',
                            time: '2 hours ago',
                            icon: Icons.note_add,
                            color: const Color(0xFF00A86B),
                          ),
                          const Divider(height: 1),
                          _buildActivityItem(
                            title: 'Message received',
                            subtitle: 'Your caregiver sent you an update',
                            time: '4 hours ago',
                            icon: Icons.message,
                            color: const Color(0xFF9B59B6),
                          ),
                          const Divider(height: 1),
                          _buildActivityItem(
                            title: 'Visit completed',
                            subtitle: 'Morning care visit - 3 hours',
                            time: 'Yesterday',
                            icon: Icons.check_circle,
                            color: const Color(0xFF3498DB),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF95A5A6),
            ),
          ),
        ],
      ),
    );
  }
}
