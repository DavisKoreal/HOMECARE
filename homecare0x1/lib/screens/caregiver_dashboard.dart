import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:homecare0x1/models/care_note.dart';
import 'package:homecare0x1/models/medication_record.dart';
import 'package:homecare0x1/providers/medication_record_provider.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:homecare0x1/models/shift.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/actions/overlay.dart';
import 'package:uuid/uuid.dart';
import 'package:homecare0x1/services/firebase_care_note_service.dart';
import 'package:homecare0x1/services/firebase_caregiver_service.dart';
import 'package:homecare0x1/models/caregiver_profile.dart';

// Caregiver Dashboard Screen
// Displays a dashboard for caregivers with stats, quick actions, and recent activities.
// Includes functionality to add care notes via a comprehensive tabbed dialog.
class CaregiverDashboardScreen extends StatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  State<CaregiverDashboardScreen> createState() => _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _statsAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late List<Animation<double>> _statsAnimations;
  List<Shift> caregivershifts = [];
  late OverlayUtils _overlayUtils;
  bool isProfileComplete = true;

  @override
  void initState() {
    super.initState();
    // Initialize OverlayUtils for notifications
    _overlayUtils = OverlayUtils();
    // Set up animation controller for fade and slide effects
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    // Set up animation controller for stats animations
    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Define fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    // Define slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic));

    // Generate animations for stats cards
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

    // Start animations
    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _statsAnimationController.forward();
    });
    // Load caregiver shifts
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final shiftProvider = Provider.of<ShiftAssignmentProvider>(context, listen: false);
    if (userProvider.user != null) {
      caregivershifts = shiftProvider.getShiftsForCaregiver(userProvider.user!.id);
    }
    _fetchProfileCompleteness();
  }

  Future<void> _fetchProfileCompleteness() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final caregiverService = FirebaseCaregiverService.instance;
    final profile = await caregiverService.getCaregiverProfile(userProvider.user!.id);
    if (mounted) {
      setState(() {
        isProfileComplete = ((profile != null) && (_isProfileFullyFilled(profile))&&(_isProfileApproved(profile)));
        _overlayUtils.showOverlay(
          context,
          isProfileComplete
              ? 'Profile is complete.'
              : 'Please complete your profile for better opportunities.',
          isError: !isProfileComplete,
        );
      });
    }
  }

  bool _isProfileFullyFilled(CaregiverProfile profile) {
    return profile.name.isNotEmpty &&
           profile.role.isNotEmpty &&
           profile.experience.isNotEmpty &&
           profile.certifications.isNotEmpty &&
           profile.phone.isNotEmpty &&
           profile.email.isNotEmpty &&
           profile.bio.isNotEmpty &&
           profile.availability.isNotEmpty;
  }

  bool _isProfileApproved(CaregiverProfile profile) {
    return profile.approved;
  }

  @override
  void dispose() {
    // Clean up animation controllers and overlay
    _animationController.dispose();
    _statsAnimationController.dispose();
    _overlayUtils.dispose();
    super.dispose();
  }

  // Builds a stat card with animated progress indicator
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
                            milliseconds: 1000 + (animation.value * 500).round()),
                        tween: Tween(begin: 0.0, end: percent * animation.value),
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

  // Builds an action card for quick actions
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Builds the list of quick action cards
  List<Widget> _buildDashboardActions(BuildContext context) {
    return [
      _buildModernActionCard(
        title: 'Your Calendar',
        subtitle: 'View your assigned shifts',
        icon: Icons.calendar_today,
        color: const Color(0xFF1E88E5),
        onTap: () => Navigator.pushNamed(context, Routes.caregiverCalendar),
      ),
      _buildModernActionCard(
        title: 'Clock In',
        subtitle: 'Start your visit with location tracking',
        icon: Icons.login,
        color: const Color(0xFF00A86B),
        onTap: () => _handleCheckIn(context),
      ),
      _buildModernActionCard(
        title: 'Clock Out',
        subtitle: 'End your visit and save time logs',
        icon: Icons.logout,
        color: const Color(0xFFE67E22),
        onTap: () => _handleCheckOut(context),
      ),
      _buildModernActionCard(
        title: 'Care Notes',
        subtitle: 'Add observations and care updates',
        icon: Icons.note_add,
        color: const Color(0xFF3498DB),
        onTap: () => _handleAddCareNote(context),
        // badge: '2',
      ),
      _buildModernActionCard(
        title: 'Medications',
        subtitle: 'Log medication administration',
        icon: Icons.medical_services,
        color: const Color(0xFF9B59B6),
        onTap: () => _handleLogMedication(context),
        // badge: '1',
      ),
    ];
  }

  // Shows a confirmation dialog for logout
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

  // Requests location permission from the user
  Future<bool> _requestLocationPermission(BuildContext context) async {
    try {
      var status = await Permission.location.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        status = await Permission.location.request();
      }
      if (status.isGranted) {
        return true;
      } else {
        // the line below has been commented out as it was repetitive
        // status = await Permission.location.request();
        if (context.mounted) {
          _overlayUtils.showOverlay(
            context,
            'Location permission is required to check-in.',
            isError: true,
          );
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        _overlayUtils.showOverlay(
          context,
          'Error accessing location permissions: $e',
          isError: true,
        );
      }
      return false;
    }
  }

  // Shows a confirmation dialog for check-in
  Future<bool> _confirmCheckIn(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A86B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.login,
                    color: Color(0xFF00A86B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Confirmation'),
              ],
            ),
            content: const Text(
              'Do you want to check in for your visit?',
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
                  backgroundColor: const Color(0xFF00A86B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Check-In'),
              ),
            ],
          ),
        ) ??
        false;
  }

  // Shows a confirmation dialog for check-out
  Future<bool> _confirmCheckOut(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE67E22).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Color(0xFFE67E22),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Check-Out Confirmation'),
              ],
            ),
            content: const Text(
              'Do you want to check out from your visit?',
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
                  backgroundColor: const Color(0xFFE67E22),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Check-Out'),
              ),
            ],
          ),
        ) ??
        false;
  }

  // Shows an improved dialog to collect all CareNote fields
  Future<Map<String, dynamic>?> _showAddCareNoteDialog(BuildContext context) async {
    // Controllers for text fields
    final healthStatusController = TextEditingController();
    final activitiesController = TextEditingController();
    final observationsController = TextEditingController();
    final medicationAdherenceController = TextEditingController();
    final moodController = TextEditingController();
    final noteController = TextEditingController();
    final clientIdController = TextEditingController();
    final shiftIdController = TextEditingController();

    // State for boolean fields
    bool isVisibleToClient = false;
    bool isLate = false;

    // Page controller for tabs
    final PageController pageController = PageController();
    int currentPage = 0;

    return await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3498DB), Color(0xFF5DADE2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.note_add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Add Care Note',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                // Tab indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: currentPage >= 0 ? const Color(0xFF3498DB) : Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: currentPage >= 1 ? const Color(0xFF3498DB) : Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: currentPage >= 2 ? const Color(0xFF3498DB) : Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Page content
                Expanded(
                  child: PageView(
                    controller: pageController,
                    onPageChanged: (page) => setState(() => currentPage = page),
                    children: [
                      // Page 1: Basic Information
                      _buildCareNotePage1(
                        clientIdController,
                        shiftIdController,
                        healthStatusController,
                        moodController,
                      ),
                      // Page 2: Activities and Observations
                      _buildCareNotePage2(
                        activitiesController,
                        observationsController,
                        medicationAdherenceController,
                      ),
                      // Page 3: Notes and Settings
                      _buildCareNotePage3(
                        noteController,
                        isVisibleToClient,
                        isLate,
                        setState,
                      ),
                    ],
                  ),
                ),
                // Navigation buttons
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Color(0xFF3498DB)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Previous',
                              style: TextStyle(color: Color(0xFF3498DB)),
                            ),
                          ),
                        ),
                      if (currentPage > 0) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (currentPage < 2) {
                              // Validate current page before proceeding
                              if (_validateCurrentPage(currentPage, [
                                clientIdController.text,
                                shiftIdController.text,
                                healthStatusController.text,
                                moodController.text,
                                activitiesController.text,
                                observationsController.text,
                                medicationAdherenceController.text,
                                noteController.text,
                              ])) {
                                pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                _overlayUtils.showOverlay(
                                  context,
                                  'Please fill in all required fields.',
                                  isError: true,
                                );
                              }
                            } else {
                              // Final submission
                              if (_validateAllCareNoteFields([
                                healthStatusController.text,
                                activitiesController.text,
                                observationsController.text,
                                medicationAdherenceController.text,
                                moodController.text,
                                noteController.text,
                                clientIdController.text,
                                shiftIdController.text,
                              ])) {
                                Navigator.pop(context, {
                                  'healthStatus': healthStatusController.text.trim(),
                                  'activities': activitiesController.text.trim(),
                                  'observations': observationsController.text.trim(),
                                  'medicationAdherence': medicationAdherenceController.text.trim(),
                                  'mood': moodController.text.trim(),
                                  'note': noteController.text.trim(),
                                  'clientId': clientIdController.text.trim(),
                                  'shiftId': shiftIdController.text.trim(),
                                  'isVisibleToClient': isVisibleToClient,
                                  'isLate': isLate,
                                });
                              } else {
                                _overlayUtils.showOverlay(
                                  context,
                                  'Please fill in all required fields.',
                                  isError: true,
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3498DB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(currentPage < 2 ? 'Next' : 'Submit'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
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

  // Page 1: Basic Information
  Widget _buildCareNotePage1(
    TextEditingController clientIdController,
    TextEditingController shiftIdController,
    TextEditingController healthStatusController,
    TextEditingController moodController,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please provide the essential details for this care note.',
            style: TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          _buildImprovedTextField(
            controller: clientIdController,
            label: 'Client ID',
            icon: Icons.person_outline,
            hint: 'Enter client identifier',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildImprovedTextField(
            controller: shiftIdController,
            label: 'Shift ID',
            icon: Icons.schedule,
            hint: 'Enter shift identifier',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildImprovedTextField(
            controller: healthStatusController,
            label: 'Health Status',
            icon: Icons.favorite_outline,
            hint: 'Describe current health status',
            maxLines: 2,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildImprovedTextField(
            controller: moodController,
            label: 'Mood Assessment',
            icon: Icons.mood,
            hint: 'Describe patient mood and demeanor',
            isRequired: true,
          ),
        ],
      ),
    );
  }

  // Page 2: Activities and Observations
  Widget _buildCareNotePage2(
    TextEditingController activitiesController,
    TextEditingController observationsController,
    TextEditingController medicationAdherenceController,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activities & Observations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Document activities performed and important observations.',
            style: TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          _buildImprovedTextField(
            controller: activitiesController,
            label: 'Activities Performed',
            icon: Icons.directions_run,
            hint: 'List activities completed during visit',
            maxLines: 3,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildImprovedTextField(
            controller: observationsController,
            label: 'Clinical Observations',
            icon: Icons.visibility_outlined,
            hint: 'Note any important observations',
            maxLines: 3,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildImprovedTextField(
            controller: medicationAdherenceController,
            label: 'Medication Adherence',
            icon: Icons.medication_liquid,
            hint: 'Document medication compliance',
            maxLines: 2,
            isRequired: true,
          ),
        ],
      ),
    );
  }

  // Page 3: Notes and Settings
  Widget _buildCareNotePage3(
    TextEditingController noteController,
    bool isVisibleToClient,
    bool isLate,
    StateSetter setState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Notes & Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add any additional notes and configure visibility settings.',
            style: TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          _buildImprovedTextField(
            controller: noteController,
            label: 'Additional Notes',
            icon: Icons.note,
            hint: 'Any additional observations or comments',
            maxLines: 4,
            isRequired: true,
          ),
          const SizedBox(height: 24),
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    'Visible to Client',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    'Allow client to view this care note',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: isVisibleToClient,
                  onChanged: (value) => setState(() => isVisibleToClient = value),
                  activeColor: const Color(0xFF3498DB),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text(
                    'Late Entry',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    'Mark this as a late entry',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: isLate,
                  onChanged: (value) => setState(() => isLate = value),
                  activeColor: const Color(0xFFE67E22),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builds an improved TextField widget with better styling
  Widget _buildImprovedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
            children: isRequired
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFFBDC3C7),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF7F8C8D),
              size: 20,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  // Validates fields for the current page
  bool _validateCurrentPage(int page, List<String> allFields) {
    switch (page) {
      case 0: // Basic Information
        return allFields[6].trim().isNotEmpty && // clientId
               allFields[7].trim().isNotEmpty && // shiftId
               allFields[0].trim().isNotEmpty && // healthStatus
               allFields[4].trim().isNotEmpty;   // mood
      case 1: // Activities and Observations
        return allFields[1].trim().isNotEmpty && // activities
               allFields[2].trim().isNotEmpty && // observations
               allFields[3].trim().isNotEmpty;   // medicationAdherence
      case 2: // Notes and Settings
        return allFields[5].trim().isNotEmpty;   // note
      default:
        return false;
    }
  }

  // Validates all care note fields
  bool _validateAllCareNoteFields(List<String> fields) {
    return fields.every((field) => field.trim().isNotEmpty);
  }

  // Creates a CareNote object from dialog data
  CareNote _createCareNoteFromData(Map<String, dynamic> data) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return CareNote(
      id: const Uuid().v4(),
      clientId: data['clientId'],
      caregiverId: userProvider.user?.id ?? 'unknown',
      shiftId: data['shiftId'],
      healthStatus: data['healthStatus'],
      activities: data['activities'],
      observations: data['observations'],
      medicationAdherence: data['medicationAdherence'],
      mood: data['mood'],
      note: data['note'],
      timestamp: DateTime.now(),
      isVisibleToClient: data['isVisibleToClient'],
      isLate: data['isLate'],
    );
  }

  // Saves the CareNote to Firebase
  Future<void> _saveCareNote(BuildContext context, CareNote careNote) async {
    final service = FirebaseCareNotesService();
    try {
      await service.addCareNote(careNote);
      _overlayUtils.showOverlay(context, 'Care note added successfully');
    } catch (e) {
      _overlayUtils.showOverlay(context, 'Failed to add care note: $e', isError: true);
    }
  }

  // Handles the Care Note action
  void _handleAddCareNote(BuildContext context) async {
    final careNoteData = await _showAddCareNoteDialog(context);
    if (careNoteData != null && context.mounted) {
      final careNote = _createCareNoteFromData(careNoteData);
      await _saveCareNote(context, careNote);
      if (context.mounted) {
        Navigator.pushNamed(context, Routes.careNotes);
      }
    }
  }

  // Shows a dialog to log medication
  Future<Map<String, String>?> _logMedication(BuildContext context) async {
    final TextEditingController medController = TextEditingController();
    final TextEditingController doseController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    return await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF9B59B6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.medical_services,
                color: Color(0xFF9B59B6),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Log Medication'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: medController,
              decoration: const InputDecoration(
                labelText: 'Medication Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: doseController,
              decoration: const InputDecoration(
                labelText: 'Dosage',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (medController.text.trim().isNotEmpty &&
                  doseController.text.trim().isNotEmpty) {
                Navigator.pop(context, {
                  'medication': medController.text.trim(),
                  'dosage': doseController.text.trim(),
                  'notes': notesController.text.trim(),
                });
              } else {
                _overlayUtils.showOverlay(
                  context,
                  'Medication name and dosage are required.',
                  isError: true,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B59B6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  // Handles check-in action
  void _handleCheckIn(BuildContext context) async {
    final hasPermission = await _requestLocationPermission(context);
    if (!hasPermission || !context.mounted) return;

    final confirmed = await _confirmCheckIn(context);
    if (confirmed && context.mounted) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _overlayUtils.showOverlay(
        context,
        "${userProvider.user?.name}, you have successfully checked in to your shift.",
      );
      Navigator.pushNamed(context, Routes.visitCheckIn);
    }
  }

  // Handles check-out action
  void _handleCheckOut(BuildContext context) async {
    final confirmed = await _confirmCheckOut(context);
    if (confirmed && context.mounted) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _overlayUtils.showOverlay(
        context,
        "${userProvider.user?.name}, you have successfully checked out from your shift.",
      );
      Navigator.pushNamed(context, Routes.visitCheckOut);
    }
  }

  // Handles medication logging
  void _handleLogMedication(BuildContext context) async {
    final medication = await _logMedication(context);
    if (medication != null && context.mounted) {
      final medicationProvider =
          Provider.of<MedicationRecordProvider>(context, listen: false);
      medicationProvider.addRecord(
        MedicationRecord(
          id: (medicationProvider.records.length + 1).toString(),
          clientId: '1',
          medicationName: medication['medication']!,
          dosage: medication['dosage']!,
          administrationTime: DateTime.now(),
          notes: medication['notes'] ?? '',
        ),
      );
      _overlayUtils.showOverlay(context, 'Medication logged successfully');
      Navigator.pushNamed(context, Routes.emar);
    }
  }

  // Builds a profile completion card
  Widget _buildProfileCompletionCard({bool isSecondary = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(isSecondary ? 0.05 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withOpacity(isSecondary ? 0.2 : 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(isSecondary ? 0.15 : 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning,
              color: Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSecondary ? 'Reminder: Complete Your Profile' : 'Complete Your Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isSecondary
                      ? 'Complete your profile to ensure you can be assigned shifts.'
                      : 'Please fill your profile so that you can be assigned care shifts.',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, Routes.caregiverCompleteProfile);
              },
              child: const Text(
                'Complete Now',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Caregiver';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
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
                  color: const Color(0xFF3498DB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  color: Color(0xFF3498DB),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Caregiver Portal',
                style: TextStyle(
                  color: Color(0xFF2C3E50),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            // Container(
            //   margin: const EdgeInsets.only(right: 8),
            //   decoration: BoxDecoration(
            //     color: const Color(0xFFF8F9FA),
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: IconButton(
            //     icon: Stack(
            //       children: [
            //         const Icon(
            //           Icons.notifications_outlined,
            //           color: Color(0xFF7F8C8D),
            //         ),
            //         Positioned(
            //           right: 0,
            //           top: 0,
            //           child: Container(
            //             padding: const EdgeInsets.all(2),
            //             decoration: const BoxDecoration(
            //               color: Colors.red,
            //               shape: BoxShape.circle,
            //             ),
            //             constraints: const BoxConstraints(
            //               minWidth: 12,
            //               minHeight: 12,
            //             ),
            //             child: const Text(
            //               '3',
            //               style: TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 8,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //               textAlign: TextAlign.center,
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //     onPressed: () => Navigator.pushNamed(context, Routes.messages),
            //   ),
            // ),
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
                onPressed: () => Navigator.pushNamed(context, Routes.userProfile),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF3498DB),
                            Color(0xFF5DADE2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3498DB).withOpacity(0.3),
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
                                      "Welcome Back, $userName!",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Your compassionate care makes all the difference",
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
                                  Icons.favorite_outline,
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
                                  Icons.schedule,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Today\'s shift: 8:00 AM - 4:00 PM',
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
                    if (!isProfileComplete) ...[
                      const SizedBox(height: 20),
                      _buildProfileCompletionCard(),
                    ],
                    const SizedBox(height: 32),
                    const Text(
                      'Today\'s Overview',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          _buildModernStat(
                            title: 'Assigned Clients',
                            value: '5',
                            percent: 0.83,
                            color: const Color(0xFF3498DB),
                            icon: Icons.people_outline,
                            animation: _statsAnimations[0],
                          ),
                          const SizedBox(width: 16),
                          _buildModernStat(
                            title: 'Pending Tasks',
                            value: '3',
                            percent: 0.4,
                            color: const Color(0xFFE67E22),
                            icon: Icons.task_outlined,
                            animation: _statsAnimations[1],
                          ),
                          const SizedBox(width: 16),
                          _buildModernStat(
                            title: 'Completed Tasks',
                            value: '12',
                            percent: 0.8,
                            color: const Color(0xFF00A86B),
                            icon: Icons.check_circle_outline,
                            animation: _statsAnimations[2],
                          ),
                        ],
                      ),
                    ),
                    if (!isProfileComplete) ...[
                      const SizedBox(height: 20),
                      _buildProfileCompletionCard(isSecondary: true),
                    ],
                    const SizedBox(height: 32),
                    const Text(
                      'Quick Actions',
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
                      children: _buildDashboardActions(context),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Recent Activity',
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
                            title: 'Medication administered',
                            subtitle: 'Lisinopril 10mg - Mrs. Johnson',
                            time: '2 hours ago',
                            icon: Icons.medication,
                            color: const Color(0xFF9B59B6),
                          ),
                          const Divider(height: 1),
                          _buildActivityItem(
                            title: 'Care note added',
                            subtitle: 'Patient mobility assessment completed',
                            time: '4 hours ago',
                            icon: Icons.note_add,
                            color: const Color(0xFF3498DB),
                          ),
                          const Divider(height: 1),
                          _buildActivityItem(
                            title: 'Visit completed',
                            subtitle: 'Mr. Smith - 2.5 hour visit',
                            time: 'Yesterday',
                            icon: Icons.check_circle,
                            color: const Color(0xFF00A86B),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.emergency,
                              color: Colors.red,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Emergency Support',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Need immediate assistance? Contact support.',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextButton(
                              onPressed: () {
                                _overlayUtils.showOverlay(
                                  context,
                                  'Contacting emergency support...',
                                  isError: true,
                                );
                              },
                              child: const Text(
                                'Call Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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

  // Builds a recent activity item
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