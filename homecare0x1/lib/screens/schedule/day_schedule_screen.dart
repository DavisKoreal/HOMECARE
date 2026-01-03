import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/theme/app_theme.dart'; // Import Theme for colors
import 'package:intl/intl.dart';

// Models
import 'package:homecare0x1/models/caregiver_profile.dart';
import 'package:homecare0x1/models/shift.dart';
import 'package:homecare0x1/models/client.dart'; // Needed for dropdown

// Services
import 'package:homecare0x1/services/firebase_caregiver_service.dart';
import 'package:homecare0x1/services/firebase_shift_service.dart';

class DayScheduleScreen extends StatefulWidget {
  const DayScheduleScreen({super.key});

  @override
  State<DayScheduleScreen> createState() => _DayScheduleScreenState();
}

class _DayScheduleScreenState extends State<DayScheduleScreen> {
  final FirebaseCaregiverService _caregiverService = FirebaseCaregiverService.instance;
  final FirebaseShiftService _shiftService = FirebaseShiftService.instance;

  DateTime _currentDate = DateTime.now();
  bool _isLoading = true;
  
  List<CaregiverProfile> _caregivers = [];
  List<Client> _clients = []; // To populate "Add Shift" dropdown
  List<Shift> _dailyShifts = [];

  final ScrollController _headerHorizontalCtrl = ScrollController();
  final ScrollController _gridHorizontalCtrl = ScrollController();
  final ScrollController _leftColVerticalCtrl = ScrollController();
  final ScrollController _gridVerticalCtrl = ScrollController();

  final List<String> _timeSlots = List.generate(14, (index) => "${index + 7}:00"); // 7am to 8pm

  @override
  void initState() {
    super.initState();
    _setupScrollLinking();
    _loadData();
  }

  void _setupScrollLinking() {
    _headerHorizontalCtrl.addListener(() {
      if (_headerHorizontalCtrl.position.pixels != _gridHorizontalCtrl.position.pixels) {
        _gridHorizontalCtrl.jumpTo(_headerHorizontalCtrl.position.pixels);
      }
    });
    _gridHorizontalCtrl.addListener(() {
      if (_gridHorizontalCtrl.position.pixels != _headerHorizontalCtrl.position.pixels) {
        _headerHorizontalCtrl.jumpTo(_gridHorizontalCtrl.position.pixels);
      }
    });
    _leftColVerticalCtrl.addListener(() {
      if (_leftColVerticalCtrl.position.pixels != _gridVerticalCtrl.position.pixels) {
        _gridVerticalCtrl.jumpTo(_leftColVerticalCtrl.position.pixels);
      }
    });
    _gridVerticalCtrl.addListener(() {
      if (_gridVerticalCtrl.position.pixels != _leftColVerticalCtrl.position.pixels) {
        _leftColVerticalCtrl.jumpTo(_gridVerticalCtrl.position.pixels);
      }
    });
  }

  @override
  void dispose() {
    _headerHorizontalCtrl.dispose();
    _gridHorizontalCtrl.dispose();
    _leftColVerticalCtrl.dispose();
    _gridVerticalCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final caregivers = await _caregiverService.getAllCaregiverProfiles();
      final clients = await _shiftService.getAllClients(); // Need clients for adding shifts
      final allShifts = await _shiftService.getAllShifts();
      
      if (mounted) {
        setState(() {
          _caregivers = caregivers;
          _clients = clients;
          _updateDailyShifts(allShifts);
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading schedule data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateDailyShifts(List<Shift> allShifts) {
    _dailyShifts = allShifts.where((s) {
      return s.startTime.year == _currentDate.year &&
             s.startTime.month == _currentDate.month &&
             s.startTime.day == _currentDate.day;
    }).toList();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _currentDate) {
      setState(() {
        _currentDate = picked;
        _isLoading = true;
      });
      final allShifts = await _shiftService.getAllShifts();
      if (mounted) {
        setState(() {
          _updateDailyShifts(allShifts);
          _isLoading = false;
        });
      }
    }
  }

  // --- Actions & Dialogs ---

  void _showAddShiftDialog(CaregiverProfile caregiver, DateTime startTime) {
    String? selectedClientId;
    DateTime endTime = startTime.add(const Duration(hours: 4)); // Default 4 hour shift

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("New Shift"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Caregiver: ${caregiver.name}"),
                const SizedBox(height: 8),
                Text("Date: ${DateFormat('MMM d, yyyy').format(_currentDate)}"),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedClientId,
                  hint: const Text("Select Client"),
                  items: _clients.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name),
                  )).toList(),
                  onChanged: (val) => setState(() => selectedClientId = val),
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.all(12)),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Start', border: OutlineInputBorder()),
                        child: Text(DateFormat('HH:mm').format(startTime)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(endTime));
                          if (time != null) {
                            setState(() {
                              endTime = DateTime(_currentDate.year, _currentDate.month, _currentDate.day, time.hour, time.minute);
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'End', border: OutlineInputBorder()),
                          child: Text(DateFormat('HH:mm').format(endTime)),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: selectedClientId == null ? null : () async {
                  final client = _clients.firstWhere((c) => c.id == selectedClientId);
                  Navigator.pop(context); // Close dialog
                  
                  // Call Service
                  // Note: addShift in service requires context for user validation usually, but we are in admin screen
                  // We'll assume the service handles basic creation or we might need to update it slightly to not rely on Provider context for User if possible, 
                  // or we ensure we pass context. Here we pass context.
                  
                  final result = await _shiftService.addShift(
                    clientId: client.id,
                    clientName: client.name,
                    startTime: startTime,
                    endTime: endTime,
                    context: context,
                    caregiverId: caregiver.id,
                    caregiverName: caregiver.name,
                  );
                  
                  if (result == "success") {
                    _loadData(); // Refresh grid
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Shift added!"), backgroundColor: AppTheme.successGreen));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to add shift"), backgroundColor: AppTheme.errorRed));
                  }
                },
                child: const Text("Create Shift"),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showShiftOptions(Shift shift) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(shift.clientName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.access_time, "${DateFormat('HH:mm').format(shift.startTime)} - ${DateFormat('HH:mm').format(shift.endTime)}"),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.person, "Staff: ${shift.caregiverName ?? 'Unassigned'}"),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.info_outline, "Status: ${shift.status.toUpperCase()}"),
          ],
        ),
        actions: [
          if (shift.status != 'completed')
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _shiftService.updateShiftStatus(shiftId: shift.id, status: 'completed');
                _loadData();
              },
              child: const Text("Mark Complete", style: TextStyle(color: AppTheme.successGreen)),
            ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Assuming we update status to cancelled
              await _shiftService.updateShiftStatus(shiftId: shift.id, status: 'cancelled');
              _loadData();
            }, 
            child: const Text("Cancel Shift", style: TextStyle(color: AppTheme.errorRed)),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(children: [Icon(icon, size: 16, color: AppTheme.textSecondary), const SizedBox(width: 8), Text(text)]);
  }

  // --- UI Components ---

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildHeaderControls(context),
          Expanded(child: _buildMainGrid()),
          _buildFooterSummary(),
        ],
      ),
    );
  }

  Widget _buildHeaderControls(BuildContext context) {
    // ... (Keeping header logic same as previous, just compacted for brevity in this script)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 950) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildDateNavigation(isCompact: true)]),
                const SizedBox(height: 12),
                SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: _buildActionButtons(context))),
              ],
            );
          } else {
            return Row(children: [_buildDateNavigation(isCompact: false), const Spacer(), ..._buildActionButtons(context)]);
          }
        }
      ),
    );
  }

  Widget _buildDateNavigation({required bool isCompact}) {
    return Row(
      children: [
        OutlinedButton(onPressed: () { setState(() => _currentDate = DateTime.now()); _loadData(); }, child: const Text("Today")),
        const SizedBox(width: 16),
        IconButton(icon: const Icon(Icons.chevron_left), onPressed: () { setState(() => _currentDate = _currentDate.subtract(const Duration(days: 1))); _loadData(); }),
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(4)),
            child: Row(children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(isCompact ? DateFormat('MMM d, yyyy').format(_currentDate) : DateFormat('EEEE, MMM d, yyyy').format(_currentDate), style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ]),
          ),
        ),
        IconButton(icon: const Icon(Icons.chevron_right), onPressed: () { setState(() => _currentDate = _currentDate.add(const Duration(days: 1))); _loadData(); }),
      ],
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    return [
      _buildDropdownButton("Day"),
      const SizedBox(width: 12),
      PopupMenuButton<String>(child: _buildActionButton("Filters", Icons.filter_list), itemBuilder: (context) => [const PopupMenuItem(child: Text("Active Employees"))]),
      const SizedBox(width: 12),
      _buildActionButton("Tools", Icons.build),
      const SizedBox(width: 12),
      ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPurple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
        child: const Text("Publish"),
      ),
    ];
  }

  Widget _buildMainGrid() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 250, child: Column(children: [
          Container(height: 50, decoration: const BoxDecoration(color: Color(0xFFF9FAFB), border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)), right: BorderSide(color: Color(0xFFE5E7EB)))), alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 16), child: Text("Employees", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)))),
          Expanded(child: ListView.builder(controller: _leftColVerticalCtrl, itemCount: _caregivers.length, itemBuilder: (context, index) => _buildCaregiverRow(_caregivers[index]))),
        ])),
        Expanded(child: Column(children: [
          SingleChildScrollView(scrollDirection: Axis.horizontal, controller: _headerHorizontalCtrl, child: Row(children: _timeSlots.map((time) => Container(width: 120, height: 50, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFF9FAFB), border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)), right: BorderSide(color: Color(0xFFE5E7EB)))), child: Text(time, style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: const Color(0xFF6B7280))))).toList())),
          Expanded(child: SingleChildScrollView(controller: _gridVerticalCtrl, child: SingleChildScrollView(scrollDirection: Axis.horizontal, controller: _gridHorizontalCtrl, child: Column(children: _caregivers.map((cg) { return Row(children: _timeSlots.map((time) => _buildGridCell(cg, time)).toList()); }).toList())))),
        ])),
      ],
    );
  }

  Widget _buildCaregiverRow(CaregiverProfile caregiver) {
    // Basic Metrics (placeholder logic for display)
    final shiftCount = _dailyShifts.where((s) => s.caregiverId == caregiver.id).length;
    
    return Container(
      height: 80,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)), right: BorderSide(color: Color(0xFFE5E7EB)))),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: AppTheme.primaryPurple.withOpacity(0.1), child: Text(caregiver.name.isNotEmpty ? caregiver.name[0] : '?', style: const TextStyle(color: AppTheme.primaryPurple, fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(caregiver.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                Text("$shiftCount shifts", style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCell(CaregiverProfile caregiver, String timeSlot) {
    final hour = int.parse(timeSlot.split(':')[0]);
    final slotStart = DateTime(_currentDate.year, _currentDate.month, _currentDate.day, hour);
    final slotEnd = slotStart.add(const Duration(hours: 1));

    // Find shift overlapping this hour
    final shift = _dailyShifts.firstWhere(
      (s) => s.caregiverId == caregiver.id && (s.startTime.isBefore(slotEnd) && s.endTime.isAfter(slotStart)),
      orElse: () => Shift(id: '', clientId: '', clientName: '', startTime: DateTime.now(), endTime: DateTime.now(), status: 'none'),
    );

    final hasShift = shift.status != 'none';
    
    // Determine Color based on status
    Color cellColor = Colors.white;
    Color borderColor = Colors.transparent;
    Color textColor = AppTheme.textPrimary;

    if (hasShift) {
      final statusColor = AppTheme.getStatusColor(shift.status);
      cellColor = statusColor.withOpacity(0.15);
      borderColor = statusColor;
      textColor = statusColor; // Or darker shade
    }

    return InkWell(
      onTap: () {
        if (hasShift) {
          _showShiftOptions(shift);
        } else {
          _showAddShiftDialog(caregiver, slotStart);
        }
      },
      child: Container(
        width: 120,
        height: 80,
        decoration: BoxDecoration(
          color: hasShift ? cellColor : Colors.white,
          border: Border(
            bottom: const BorderSide(color: Color(0xFFE5E7EB)), 
            right: const BorderSide(color: Color(0xFFE5E7EB)),
            left: hasShift ? BorderSide(color: borderColor, width: 3) : BorderSide.none, // Status indicator bar
          ),
        ),
        child: hasShift 
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shift.clientName, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary), overflow: TextOverflow.ellipsis),
                  Text("${DateFormat('HH:mm').format(shift.startTime)} - ${DateFormat('HH:mm').format(shift.endTime)}", style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                ],
              ),
            )
          : Center(child: Icon(Icons.add, size: 14, color: Colors.grey.withOpacity(0.2))), // Subtle add icon
      ),
    );
  }

  Widget _buildFooterSummary() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(color: Color(0xFFF9FAFB), border: Border(top: BorderSide(color: Color(0xFFE5E7EB)))),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text("Summary", style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
          const Spacer(),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text("${_dailyShifts.length}", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
            Text("Total Shifts", style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
          ]),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(4)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: const Color(0xFF374151)), const SizedBox(width: 8), Text(label, style: const TextStyle(color: Color(0xFF374151)))]),
    );
  }

  Widget _buildDropdownButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(4)),
      child: Row(children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(width: 4), const Icon(Icons.arrow_drop_down, size: 18)]),
    );
  }
}
