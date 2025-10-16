import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/screens/admin_initiate_shift.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/providers/client_provider.dart';
import 'package:homecare0x1/screens/admin_caregiver_approval.dart';
import 'package:homecare0x1/screens/client_profile_screen.dart';
import 'package:homecare0x1/screens/caregiver_profile_screen.dart';
import 'dart:math';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _statsAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late List<Animation<double>> _statsAnimations;
  int _activeClients = 0;
  int _activeCaregivers = 0;
  int _pendingTasks = 0;
  bool _isLoading = true;
  String? _errorMessage;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchData();
  }

  void _initializeAnimations() {
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
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _statsAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _statsAnimationController,
          curve: Interval(index * 0.2, 0.6 + (index * 0.2), curve: Curves.elasticOut),
        ),
      );
    });
    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _statsAnimationController.forward();
    });
  }

  void _showOverlay(String message, {bool isError = false}) {
    _removeOverlay();
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        left: 20,
        right: 20,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isError ? Colors.red[700] : Colors.green[700],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isError ? Icons.error_outline : Icons.info_outline,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    Future.delayed(const Duration(seconds: 3), _removeOverlay);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _fetchData() async {
    Random random = Random(DateTime.now().millisecondsSinceEpoch);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<String> messages = [
        'Hi, I am fetching your latest data...hold on for a second',
        'Loading information...',
        'Hello, retrieving caregiver details...',
        'Hang on. I am updating information for you...',
        'Fetching the latest updates for you...',
        'Please wait while I gather the latest data...',
        'Just a moment, I am loading the latest information...',
        'Retrieving the latest updates for you...',
      ];
      String randomMessage = messages[random.nextInt(messages.length)];
      _showOverlay(randomMessage);
    });

    try {
      final shiftProvider = Provider.of<ShiftAssignmentProvider>(context, listen: false);
      final clientProvider = Provider.of<ClientProvider>(context, listen: false);

      await Future.wait([
        clientProvider.fetchClients(),
        shiftProvider.fetchCaregivers(),
        shiftProvider.fetchShifts(),
      ]);

      setState(() {
        _activeClients = clientProvider.clients.length;
        _activeCaregivers = shiftProvider.availableCaregivers.length;
        _pendingTasks = shiftProvider.shifts.where((shift) => shift.status == 'pending').length;
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        List<String> successMessages = [
          'Data loaded successfully!',
          'Information retrieved successfully!',
          'Great. Details fetched successfully!',
          'All systems operational!',
          'Data updated successfully!',
          'Information refreshed successfully!',
          'Details loaded successfully!',
          'All data is up-to-date!',
        ];
        final successMessage = successMessages[random.nextInt(successMessages.length)];
        _showOverlay(successMessage);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data: $e';
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOverlay(_errorMessage!, isError: true);
      });
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _animationController.dispose();
    _statsAnimationController.dispose();
    super.dispose();
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
                        duration: Duration(milliseconds: 1000 + (animation.value * 500).round()),
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
                  duration: Duration(milliseconds: 1000 + (animation.value * 500).round()),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDashboardActions(BuildContext context) {
    return [
      _buildModernActionCard(
        title: 'Calendar',
        subtitle: 'View schedule',
        icon: Icons.calendar_today,
        color: const Color(0xFF1E88E5),
        onTap: () => Navigator.pushNamed(context, Routes.adminCalendar),
      ),
      _buildModernActionCard(
        title: 'Shifts',
        subtitle: 'Assign tasks',
        icon: Icons.schedule_outlined,
        color: const Color(0xFF00A86B),
        onTap: () => Navigator.pushNamed(context, Routes.shiftAssignment),
      ),
      _buildModernActionCard(
        title: 'Care Notes',
        subtitle: 'View notes',
        icon: Icons.event_note_outlined,
        color: const Color(0xFF3498DB),
        onTap: () => Navigator.pushNamed(context, Routes.adminNotesManagement),
      ),
      _buildModernActionCard(
        title: 'Client Recipients',
        subtitle: 'Client records',
        icon: Icons.people_outline,
        color: const Color(0xFF3498DB),
        onTap: () => Navigator.pushNamed(context, Routes.clientList),
      ),
      _buildModernActionCard(
        title: 'System',
        subtitle: 'Monitor activity',
        icon: Icons.security_outlined,
        color: const Color(0xFF9B59B6),
        onTap: () => Navigator.pushNamed(context, Routes.auditLog),
      ),
      _buildModernActionCard(
        title: 'Analytics',
        subtitle: 'View metrics',
        icon: Icons.analytics_outlined,
        color: const Color(0xFFE67E22),
        onTap: () {},
      ),
      _buildModernActionCard(
        title: 'Approve Caregivers',
        subtitle: 'Manage staff',
        icon: Icons.medical_services_outlined,
        color: const Color(0xFF00A86B),
        onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (context) => AdminCaregiverApprovalPage(
              adminId: Provider.of<UserProvider>(context, listen: false).user?.id ?? '',
            ),
          ),
        ),
      ),
      _buildModernActionCard(
        title: 'New Shift',
        subtitle: 'Add shift',
        icon: Icons.add_task,
        color: const Color(0xFF00A86B),
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (context) => const AdminInitiateShift(),
        )),
      ),
      _buildModernActionCard(
        title: 'Add Client',
        subtitle: 'Add new client',
        icon: Icons.add,
        color: const Color(0xFF00A86B),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ClientProfileScreen(isAdding: true),
          ),
        ),
      ),
      _buildModernActionCard(
        title: 'Add Caregiver',
        subtitle: 'Add new caregiver',
        icon: Icons.person_add,
        color: const Color(0xFF00A86B),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CaregiverProfileScreen(isAdding: true),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Logout Confirmation'),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        );
        if (shouldExit ?? false) {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.clearUser();
          Navigator.pushReplacementNamed(context, Routes.login);
        }
        return false;
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
                  color: const Color(0xFF00A86B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.health_and_safety,
                  color: Color(0xFF00A86B),
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'HomeCare Admin',
                style: TextStyle(
                  color: Color(0xFF2C3E50),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : RefreshIndicator(
                    onRefresh: _fetchData,
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
                                    colors: [Color(0xFF00A86B), Color(0xFF00C975)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF00A86B).withOpacity(0.3),
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
                                                'Welcome Back, Admin!',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Managing healthcare excellence, one patient at a time',
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
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.health_and_safety_outlined,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.8,
                                children: [
                                  _buildModernStat(
                                    title: 'Active Clients',
                                    value: _activeClients.toString(),
                                    percent: _activeClients / 100.0,
                                    color: const Color(0xFF00A86B),
                                    icon: Icons.people_outline,
                                    animation: _statsAnimations[0],
                                  ),
                                  _buildModernStat(
                                    title: 'Available Caregivers',
                                    value: _activeCaregivers.toString(),
                                    percent: _activeCaregivers / 50.0,
                                    color: const Color(0xFF3498DB),
                                    icon: Icons.medical_services_outlined,
                                    animation: _statsAnimations[1],
                                  ),
                                  _buildModernStat(
                                    title: 'Pending Tasks',
                                    value: _pendingTasks.toString(),
                                    percent: _pendingTasks / 20.0,
                                    color: const Color(0xFFE74C3C),
                                    icon: Icons.schedule_outlined,
                                    animation: _statsAnimations[2],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.75,
                                children: _buildDashboardActions(context),
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
}