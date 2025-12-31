import os
import re

def implement_real_schedule_data():
    target_dir = os.path.expanduser("~/Desktop/HOMECARE/homecare0x1")
    
    if not os.path.exists(target_dir):
        print(f"Error: Directory {target_dir} not found.")
        return

    print(f"Changing directory to: {target_dir}")
    os.chdir(target_dir)

    # ---------------------------------------------------------
    # 1. Update Caregiver Model (caregiver.dart)
    # ---------------------------------------------------------
    print("\n--- Updating lib/models/caregiver.dart ---")
    caregiver_path = os.path.join("lib", "models", "caregiver.dart")
    
    with open(caregiver_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Add field if missing
    if "double hourlyRate" not in content:
        # Add field
        content = re.sub(
            r'final bool isAvailable;',
            r'final bool isAvailable;\n  final double hourlyRate;',
            content
        )
        # Update Constructor
        content = re.sub(
            r'required this.isAvailable,',
            r'required this.isAvailable,\n    this.hourlyRate = 0.0,',
            content
        )
        # Update fromMap
        content = re.sub(
            r'isAvailable: map\[\'isAvailable\'\] \?\? false,',
            r'isAvailable: map[\'isAvailable\'] ?? false,\n      hourlyRate: (map[\'hourlyRate\'] ?? 0.0).toDouble(),',
            content
        )
        # Update toMap
        content = re.sub(
            r'\'isAvailable\': isAvailable,',
            r'\'isAvailable\': isAvailable,\n      \'hourlyRate\': hourlyRate,',
            content
        )
        
        with open(caregiver_path, "w", encoding="utf-8") as f:
            f.write(content)
        print("Added hourlyRate to Caregiver model.")

    # ---------------------------------------------------------
    # 2. Update Caregiver Profile Model (caregiver_profile.dart)
    # ---------------------------------------------------------
    print("\n--- Updating lib/models/caregiver_profile.dart ---")
    profile_path = os.path.join("lib", "models", "caregiver_profile.dart")
    
    if os.path.exists(profile_path):
        with open(profile_path, "r", encoding="utf-8") as f:
            content = f.read()

        if "double hourlyRate" not in content:
            # We'll use a broader replacement strategy since we don't know the exact order of fields
            # 1. Add field
            if "final String name;" in content:
                content = content.replace("final String name;", "final String name;\n  final double hourlyRate;")
            
            # 2. Update Constructor (This is tricky with regex, assuming standard formatting)
            # We'll try to find a common required field in constructor
            if "required this.name," in content:
                content = content.replace("required this.name,", "required this.name,\n    this.hourlyRate = 0.0,")
            
            # 3. Update fromMap
            if "name: map['name']," in content:
                content = content.replace("name: map['name'],", "name: map['name'],\n      hourlyRate: (map['hourlyRate'] ?? 0.0).toDouble(),")
            elif "name: map['name'] ?? ''," in content: # specific variance check
                 content = content.replace("name: map['name'] ?? '',", "name: map['name'] ?? '',\n      hourlyRate: (map['hourlyRate'] ?? 0.0).toDouble(),")

            # 4. Update toMap
            if "'name': name," in content:
                content = content.replace("'name': name,", "'name': name,\n      'hourlyRate': hourlyRate,")

            with open(profile_path, "w", encoding="utf-8") as f:
                f.write(content)
            print("Added hourlyRate to CaregiverProfile model.")
    else:
        print("Warning: caregiver_profile.dart not found. Skipping.")

    # ---------------------------------------------------------
    # 3. Update Day Schedule Screen (Real Data Wiring)
    # ---------------------------------------------------------
    print("\n--- Updating lib/screens/schedule/day_schedule_screen.dart ---")
    screen_path = os.path.join("lib", "screens", "schedule", "day_schedule_screen.dart")
    
    # We will write the full file with the Service Wiring logic
    screen_code = """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homecare0x1/constants.dart';
import 'package:intl/intl.dart';

// Models
import 'package:homecare0x1/models/caregiver_profile.dart';
import 'package:homecare0x1/models/shift.dart';

// Services
import 'package:homecare0x1/services/firebase_caregiver_service.dart';
import 'package:homecare0x1/services/firebase_shift_service.dart';

class DayScheduleScreen extends StatefulWidget {
  const DayScheduleScreen({super.key});

  @override
  State<DayScheduleScreen> createState() => _DayScheduleScreenState();
}

class _DayScheduleScreenState extends State<DayScheduleScreen> {
  // Services
  final FirebaseCaregiverService _caregiverService = FirebaseCaregiverService.instance;
  final FirebaseShiftService _shiftService = FirebaseShiftService.instance;

  // State
  DateTime _currentDate = DateTime.now();
  bool _isLoading = true;
  
  // Data
  List<CaregiverProfile> _caregivers = [];
  List<Shift> _dailyShifts = [];

  // Scroll Controllers
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
      // Fetch Caregivers (Rows)
      final caregivers = await _caregiverService.getAllCaregiverProfiles();
      
      // Fetch Shifts (Cells) - For now fetching all, optimizing query later
      final allShifts = await _shiftService.getAllShifts();
      
      if (mounted) {
        setState(() {
          _caregivers = caregivers;
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
    // Filter shifts for the selected day
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
        _isLoading = true; // Trigger reload to filter shifts
      });
      // Re-fetch or re-filter
      final allShifts = await _shiftService.getAllShifts();
      if (mounted) {
        setState(() {
          _updateDailyShifts(allShifts);
          _isLoading = false;
        });
      }
    }
  }

  // --- Metrics Calculation ---
  Map<String, String> _calculateMetrics(String caregiverId, double hourlyRate) {
    final shifts = _dailyShifts.where((s) => s.caregiverId == caregiverId).toList();
    double totalHours = 0;
    
    for (var s in shifts) {
      totalHours += s.endTime.difference(s.startTime).inMinutes / 60.0;
    }
    
    double totalCost = totalHours * hourlyRate;
    
    return {
      "hours": "${totalHours.toStringAsFixed(2)} hrs",
      "cost": "\$${totalCost.toStringAsFixed(2)}"
    };
  }

  // --- UI Building ---

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [_buildDateNavigation(isCompact: true)],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: _buildActionButtons(context)),
                ),
              ],
            );
          } else {
            return Row(
              children: [
                _buildDateNavigation(isCompact: false),
                const Spacer(),
                ..._buildActionButtons(context),
              ],
            );
          }
        }
      ),
    );
  }

  Widget _buildDateNavigation({required bool isCompact}) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: () {
            setState(() => _currentDate = DateTime.now());
            _loadData();
          },
          child: const Text("Today"),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() => _currentDate = _currentDate.subtract(const Duration(days: 1)));
            _loadData();
          },
        ),
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  isCompact 
                    ? DateFormat('MMM d, yyyy').format(_currentDate) 
                    : DateFormat('EEEE, MMM d, yyyy').format(_currentDate),
                  style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() => _currentDate = _currentDate.add(const Duration(days: 1)));
            _loadData();
          },
        ),
      ],
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    return [
      _buildDropdownButton("Day"),
      const SizedBox(width: 12),
      PopupMenuButton<String>(
        child: _buildActionButton("Filters", Icons.filter_list),
        itemBuilder: (context) => [
          const PopupMenuItem(child: Text("Active Employees")),
        ],
      ),
      const SizedBox(width: 12),
      PopupMenuButton<String>(
        onSelected: (value) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exporting to $value...')));
        },
        child: _buildActionButton("Tools", Icons.build),
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'Excel', child: Text("Export to Excel")),
          const PopupMenuItem(value: 'PDF', child: Text("Print / PDF")),
        ],
      ),
      const SizedBox(width: 12),
      ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5D3FD3),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: const Text("Publish"),
      ),
    ];
  }

  Widget _buildMainGrid() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (Caregivers)
        SizedBox(
          width: 250,
          child: Column(
            children: [
              Container(
                height: 50,
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)), right: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 16),
                child: Text("Employees", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF6B7280))),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _leftColVerticalCtrl,
                  itemCount: _caregivers.length,
                  itemBuilder: (context, index) => _buildCaregiverRow(_caregivers[index]),
                ),
              ),
            ],
          ),
        ),
        // Right Grid (Schedule)
        Expanded(
          child: Column(
            children: [
              // Header
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _headerHorizontalCtrl,
                child: Row(
                  children: _timeSlots.map((time) => Container(
                    width: 120,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9FAFB),
                      border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)), right: BorderSide(color: Color(0xFFE5E7EB))),
                    ),
                    child: Text(time, style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: const Color(0xFF6B7280))),
                  )).toList(),
                ),
              ),
              // Grid
              Expanded(
                child: SingleChildScrollView(
                  controller: _gridVerticalCtrl,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _gridHorizontalCtrl,
                    child: Column(
                      children: _caregivers.map((cg) {
                        return Row(
                          children: _timeSlots.map((time) => _buildGridCell(cg, time)).toList(),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCaregiverRow(CaregiverProfile caregiver) {
    final metrics = _calculateMetrics(caregiver.id, caregiver.hourlyRate);
    return Container(
      height: 80,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)), right: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE0E7FF),
            child: Text(
              caregiver.name.isNotEmpty ? caregiver.name[0] : '?',
              style: const TextStyle(color: Color(0xFF5D3FD3), fontWeight: FontWeight.bold)
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(caregiver.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF1F2937))),
                Text("${metrics['hours']} / ${metrics['cost']}", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCell(CaregiverProfile caregiver, String timeSlot) {
    // Find shifts for this caregiver that overlap with this time slot
    final hour = int.parse(timeSlot.split(':')[0]);
    final slotStart = DateTime(_currentDate.year, _currentDate.month, _currentDate.day, hour);
    final slotEnd = slotStart.add(const Duration(hours: 1));

    final shift = _dailyShifts.firstWhere(
      (s) => s.caregiverId == caregiver.id && 
             (s.startTime.isBefore(slotEnd) && s.endTime.isAfter(slotStart)),
      orElse: () => Shift(id: '', clientId: '', clientName: '', startTime: DateTime.now(), endTime: DateTime.now(), status: 'none'),
    );

    final hasShift = shift.status != 'none';

    return InkWell(
      onTap: () {
        if (hasShift) {
          _showShiftDetails(shift);
        } else {
          // Add shift logic
        }
      },
      child: Container(
        width: 120,
        height: 80,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)), right: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: hasShift 
          ? Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF5D3FD3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF5D3FD3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(shift.clientName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  Text("${DateFormat('H:mm').format(shift.startTime)}-${DateFormat('H:mm').format(shift.endTime)}", style: const TextStyle(fontSize: 10)),
                ],
              ),
            )
          : Center(child: Icon(Icons.add, size: 16, color: Colors.grey.withOpacity(0.1))),
      ),
    );
  }

  void _showShiftDetails(Shift shift) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Shift Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Client: ${shift.clientName}"),
            Text("Time: ${DateFormat('h:mm a').format(shift.startTime)} - ${DateFormat('h:mm a').format(shift.endTime)}"),
            Text("Status: ${shift.status}"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  Widget _buildFooterSummary() {
    double totalHours = 0;
    // Calculate total hours from all daily shifts
    for (var s in _dailyShifts) {
      if (s.caregiverId != null) {
        totalHours += s.endTime.difference(s.startTime).inMinutes / 60.0;
      }
    }

    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text("Summary", style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
          const Spacer(),
          _buildFooterMetric("Labor Hours", "${totalHours.toStringAsFixed(2)} hrs"),
          const SizedBox(width: 24),
          _buildFooterMetric("Headcount", "${_caregivers.length}"),
        ],
      ),
    );
  }

  Widget _buildFooterMetric(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF374151)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Color(0xFF374151))),
        ],
      ),
    );
  }

  Widget _buildDropdownButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 18),
        ],
      ),
    );
  }
}
"""
    with open(screen_path, "w", encoding="utf-8") as f:
        f.write(screen_code)
    print("Fully wired DayScheduleScreen with real Caregivers and Shifts.")

if __name__ == "__main__":
    implement_real_schedule_data()