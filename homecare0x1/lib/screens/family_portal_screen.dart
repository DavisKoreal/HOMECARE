import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/widgets/request_shift_dialog.dart';
import 'package:homecare0x1/widgets/modern_stat.dart';
import 'package:homecare0x1/widgets/modern_action_card.dart';
import 'package:homecare0x1/widgets/activity_item.dart';

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

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          ModernStat(
                            title: 'Recent Visits',
                            value: '4',
                            percent: 0.8,
                            color: const Color(0xFF3498DB),
                            icon: Icons.event_available,
                            animation: _statsAnimations[0],
                          ),
                          const SizedBox(width: 16),
                          ModernStat(
                            title: 'Care Notes',
                            value: '12',
                            percent: 0.75,
                            color: const Color(0xFF00A86B),
                            icon: Icons.note_outlined,
                            animation: _statsAnimations[1],
                          ),
                          const SizedBox(width: 16),
                          ModernStat(
                            title: 'Messages',
                            value: '5',
                            percent: 0.5,
                            color: const Color(0xFFE67E22),
                            icon: Icons.message_outlined,
                            animation: _statsAnimations[2],
                          ),
                        ],
                      ),
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
                        ModernActionCard(
                          title: 'Request Care Session',
                          subtitle:
                              'Request a new caregiving session for your loved one',
                          icon: Icons.schedule,
                          color: AppTheme.secondaryTeal,
                          onTap: () => showRequestShiftDialog(context),
                        ),
                        ModernActionCard(
                          title: 'Care Notes',
                          subtitle: 'View detailed notes from your caregiver',
                          icon: Icons.note,
                          color: const Color(0xFF00A86B),
                          onTap: () => Navigator.pushNamed(
                              context, Routes.familyCareNotes),
                          badge: '3',
                        ),
                        ModernActionCard(
                          title: 'Visit History',
                          subtitle: 'Track all recent visits and activities',
                          icon: Icons.history,
                          color: const Color(0xFFE67E22),
                          onTap: () => Navigator.pushNamed(
                              context, Routes.clientViewShiftHistory),
                        ),
                        ModernActionCard(
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
                          child: ModernActionCard(
                            title: 'Payment Status',
                            subtitle: 'View billing and payment information',
                            icon: Icons.payment,
                            color: const Color(0xFF16A085),
                            onTap: () => Navigator.pushNamed(
                                context, Routes.paymentStatus),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ModernActionCard(
                            title: 'Support Testing',
                            subtitle: 'Get help and contact our support team',
                            icon: Icons.support_agent,
                            color: const Color(0xFFF39C12),
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
                          ActivityItem(
                            title: 'New care note added',
                            subtitle:
                                'Daily wellness check completed successfully',
                            time: '2 hours ago',
                            icon: Icons.note_add,
                            color: const Color(0xFF00A86B),
                          ),
                          const Divider(height: 1),
                          ActivityItem(
                            title: 'Message received',
                            subtitle: 'Your caregiver sent you an update',
                            time: '4 hours ago',
                            icon: Icons.message,
                            color: const Color(0xFF9B59B6),
                          ),
                          const Divider(height: 1),
                          ActivityItem(
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
}