import 'package:flutter/material.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/care_note.dart'; // Assuming CareNote is in this file

class FamilyCareNotesScreen extends StatefulWidget {
  const FamilyCareNotesScreen({super.key});

  @override
  State<FamilyCareNotesScreen> createState() => _FamilyCareNotesScreenState();
}

class _FamilyCareNotesScreenState extends State<FamilyCareNotesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Sample care notes data (replace with actual data source)
  final List<CareNote> _careNotes = [
    CareNote(
      clientId: 'client_1',
      caregiverId: 'caregiver_1',
      shiftId: 'shift_1',
      healthStatus: 'Stable',
      activities: 'Morning walk, meal preparation',
      observations: 'Client was cooperative and alert',
      medicationAdherence: 'All medications taken as prescribed',
      mood: 'Positive',
      note: 'Client enjoyed the morning activities',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isVisibleToClient: true,
    ),
    CareNote(
      clientId: 'client_1',
      caregiverId: 'caregiver_2',
      shiftId: 'shift_2',
      healthStatus: 'Good',
      activities: 'Physical therapy session',
      observations: 'Slight fatigue observed post-session',
      medicationAdherence: 'Partial adherence, missed evening dose',
      mood: 'Neutral',
      note: 'Recommended shorter sessions',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isVisibleToClient: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildCareNoteCard(CareNote note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A86B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.note,
                    color: Color(0xFF00A86B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(note.timestamp),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                if (note.isLate)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Late',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.health_and_safety,
              label: 'Health Status',
              value: note.healthStatus,
              color: const Color(0xFF3498DB),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.directions_walk,
              label: 'Activities',
              value: note.activities,
              color: const Color(0xFF00A86B),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.remove_red_eye,
              label: 'Observations',
              value: note.observations,
              color: const Color(0xFF9B59B6),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.medical_services,
              label: 'Medication',
              value: note.medicationAdherence,
              color: const Color(0xFFE67E22),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.mood,
              label: 'Mood',
              value: note.mood,
              color: const Color(0xFF16A085),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.note_alt,
              label: 'Additional Notes',
              value: note.note,
              color: const Color(0xFFF39C12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7F8C8D),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00A86B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.note,
                color: Color(0xFF00A86B),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Care Notes',
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
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.filter_list,
                color: Color(0xFF7F8C8D),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Filter functionality coming soon...'),
                  ),
                );
              },
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
                  const Text(
                    'Care Notes Overview',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_careNotes.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
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
                      child: const Center(
                        child: Text(
                          'No care notes available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF7F8C8D),
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: _careNotes
                          .where((note) => note.isVisibleToClient)
                          .map((note) => _buildCareNoteCard(note))
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
