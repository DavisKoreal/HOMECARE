import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/providers/location_provider.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/models/shift.dart';
import 'package:homecare0x1/models/location.dart';

class VisitCheckInScreen extends StatefulWidget {
  final Shift? selectedShift;

  const VisitCheckInScreen({super.key, this.selectedShift});

  @override
  State<VisitCheckInScreen> createState() => _VisitCheckInScreenState();
}

class _VisitCheckInScreenState extends State<VisitCheckInScreen>
    with TickerProviderStateMixin {
  String? _selectedShiftId;
  Location? _selectedLocation;
  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    _selectedShiftId = widget.selectedShift?.id;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
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

    // Create staggered animations for cards
    _cardAnimations = List.generate(4, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardAnimationController,
          curve: Interval(
            index * 0.2,
            0.6 + (index * 0.1),
            curve: Curves.elasticOut,
          ),
        ),
      );
    });

    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  Widget _buildModernCard({
    required Widget child,
    required Animation<double> animation,
    Color? borderColor,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Transform.scale(
          scale: animation.value,
          child: Container(
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
              border: borderColor != null
                  ? Border.all(color: borderColor.withOpacity(0.2), width: 1)
                  : null,
            ),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool enabled = true,
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
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: enabled
                        ? color.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: enabled ? color : Colors.grey,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              enabled ? const Color(0xFF2C3E50) : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color:
                              enabled ? const Color(0xFF7F8C8D) : Colors.grey,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: enabled ? color : Colors.grey,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _selectedLocation != null
            ? const Color(0xFF00A86B).withOpacity(0.1)
            : const Color(0xFFE67E22).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _selectedLocation != null
              ? const Color(0xFF00A86B).withOpacity(0.3)
              : const Color(0xFFE67E22).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _selectedLocation != null
                  ? const Color(0xFF00A86B).withOpacity(0.2)
                  : const Color(0xFFE67E22).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _selectedLocation != null
                  ? Icons.location_on
                  : Icons.location_off,
              color: _selectedLocation != null
                  ? const Color(0xFF00A86B)
                  : const Color(0xFFE67E22),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedLocation != null
                      ? 'Location Verified'
                      : 'Location Required',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _selectedLocation != null
                        ? const Color(0xFF00A86B)
                        : const Color(0xFFE67E22),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedLocation != null
                      ? 'Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, Lng: ${_selectedLocation!.longitude.toStringAsFixed(4)}'
                      : 'Please verify your location before checking in',
                  style: TextStyle(
                    color: _selectedLocation != null
                        ? const Color(0xFF00A86B)
                        : const Color(0xFFE67E22),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftCard(Shift shift, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF3498DB).withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF3498DB)
              : Colors.grey.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF3498DB).withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedShiftId = shift.id;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3498DB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF3498DB),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shift.clientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('h:mm a').format(shift.startTime)} - ${DateFormat('h:mm a').format(shift.endTime)}',
                        style: const TextStyle(
                          color: Color(0xFF7F8C8D),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF3498DB),
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shiftProvider = Provider.of<ShiftAssignmentProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final caregiverShifts = userProvider.user != null
        ? shiftProvider.getShiftsForCaregiver(userProvider.user!.id)
        : [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF2C3E50),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00A86B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.login,
                color: Color(0xFF00A86B),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Visit Check-In',
              style: TextStyle(
                color: Color(0xFF2C3E50),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: FadeTransition(
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
                        Color(0xFF00A86B),
                        Color(0xFF2ECC71),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00A86B).withOpacity(0.3),
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
                                const Text(
                                  "Ready to Check In?",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Start your visit and begin providing excellent care",
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
                              Icons.schedule,
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
                              Icons.access_time,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Current time: ${DateFormat('h:mm a').format(DateTime.now())}',
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

                // Location Status
                const Text(
                  'Location Status',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 16),

                _buildModernCard(
                  animation: _cardAnimations[0],
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildLocationStatus(),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedLocation =
                                    locationProvider.getRandomLocation();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3498DB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.my_location, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedLocation != null
                                      ? 'Update Location'
                                      : 'Get Current Location',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Select Shift Section
                const Text(
                  'Select Your Shift',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 16),

                _buildModernCard(
                  animation: _cardAnimations[1],
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        if (caregiverShifts.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE67E22).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.schedule_outlined,
                                  color: const Color(0xFFE67E22),
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No Shifts Assigned',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE67E22),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Contact your supervisor to get shifts assigned',
                                  style: TextStyle(
                                    color: Color(0xFFE67E22),
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          ...caregiverShifts.map((shift) => _buildShiftCard(
                              shift, _selectedShiftId == shift.id)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Check-In Button
                _buildModernCard(
                  animation: _cardAnimations[2],
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_selectedShiftId != null &&
                                _selectedLocation != null)
                            ? () async {
                                try {
                                  await shiftProvider.updateShiftStatus(
                                    shiftId: _selectedShiftId!,
                                    status: 'in_session',
                                    location: _selectedLocation,
                                  );

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Row(
                                          children: [
                                            Icon(Icons.check_circle,
                                                color: Colors.white),
                                            SizedBox(width: 8),
                                            Text('Successfully checked in!'),
                                          ],
                                        ),
                                        backgroundColor:
                                            const Color(0xFF00A86B),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    );
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.error,
                                                color: Colors.white),
                                            const SizedBox(width: 8),
                                            Text('Error: $e'),
                                          ],
                                        ),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (_selectedShiftId != null &&
                                  _selectedLocation != null)
                              ? const Color(0xFF00A86B)
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: (_selectedShiftId != null &&
                                  _selectedLocation != null)
                              ? 4
                              : 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.login, size: 24),
                            const SizedBox(width: 12),
                            const Text(
                              'Check In to Visit',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Quick Actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 16),

                _buildModernCard(
                  animation: _cardAnimations[3],
                  child: Column(
                    children: [
                      _buildActionButton(
                        title: 'View Tasks',
                        subtitle: 'Check assigned tasks for this visit',
                        icon: Icons.task_alt,
                        color: const Color(0xFF3498DB),
                        onPressed: () =>
                            Navigator.pushNamed(context, Routes.taskList),
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        title: 'Medication Log',
                        subtitle: 'Record medication administration',
                        icon: Icons.medical_services,
                        color: const Color(0xFF9B59B6),
                        onPressed: () =>
                            Navigator.pushNamed(context, Routes.emar),
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        title: 'Care Notes',
                        subtitle: 'Add observations and care updates',
                        icon: Icons.note_add,
                        color: const Color(0xFFE67E22),
                        onPressed: () =>
                            Navigator.pushNamed(context, Routes.careNotes),
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
    );
  }
}
