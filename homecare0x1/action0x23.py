import os

def improve_day_schedule():
    target_dir = os.path.expanduser("~/Desktop/HOMECARE/homecare0x1")
    
    if not os.path.exists(target_dir):
        print(f"Error: Directory {target_dir} not found.")
        return

    print(f"Changing directory to: {target_dir}")
    os.chdir(target_dir)

    print("\n--- Updating lib/screens/schedule/day_schedule_screen.dart ---")
    screen_path = os.path.join("lib", "screens", "schedule", "day_schedule_screen.dart")
    
    # We completely rewrite the file to include the complex scrolling logic and new menus
    screen_code = """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/constants.dart';
import 'package:intl/intl.dart';

class DayScheduleScreen extends StatefulWidget {
  const DayScheduleScreen({super.key});

  @override
  State<DayScheduleScreen> createState() => _DayScheduleScreenState();
}

class _DayScheduleScreenState extends State<DayScheduleScreen> {
  // State Variables
  DateTime _currentDate = DateTime.now();
  
  // Scroll Controllers for Syncing
  final ScrollController _headerHorizontalCtrl = ScrollController();
  final ScrollController _gridHorizontalCtrl = ScrollController();
  final ScrollController _leftColVerticalCtrl = ScrollController();
  final ScrollController _gridVerticalCtrl = ScrollController();

  // Mock Data
  final List<Map<String, dynamic>> _employees = [
    {"name": "Juliah Muthunga", "status": "Active", "metrics": "0.00 hrs / \$0.00", "avatar": "J"},
    {"name": "Kefilwe Khubile", "status": "Active", "metrics": "0.00 hrs / \$0.00", "avatar": "K"},
    {"name": "Paula", "status": "Active", "metrics": "0.00 hrs / \$0.00", "avatar": "P"},
    {"name": "Pauline Gatai", "status": "Active", "metrics": "0.00 hrs / \$0.00", "avatar": "PG"},
    {"name": "Dennis Ngatia", "status": "Active", "metrics": "0.00 hrs / \$0.00", "avatar": "D"},
    {"name": "Sarah Smith", "status": "Active", "metrics": "0.00 hrs / \$0.00", "avatar": "S"},
    {"name": "John Doe", "status": "Active", "metrics": "0.00 hrs / \$0.00", "avatar": "J"},
  ];

  final List<String> _timeSlots = List.generate(14, (index) => "${index + 7}:00"); // 7am to 8pm

  @override
  void initState() {
    super.initState();
    // Link Horizontal Scrolls
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

    // Link Vertical Scrolls
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

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _currentDate) {
      setState(() => _currentDate = picked);
    }
  }

  void _handleCellClick(String employeeName, String time) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Shift Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Employee: $employeeName"),
            Text("Time: $time"),
            const SizedBox(height: 16),
            const Divider(),
            const Text("No shift assigned yet.")
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
          ElevatedButton(onPressed: () {}, child: const Text("Add Shift"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildHeaderControls(),
          Expanded(
            child: _buildMainGrid(),
          ),
          _buildFooterSummary(),
        ],
      ),
    );
  }

  // --- Header Section ---
  Widget _buildHeaderControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          // Navigation
          OutlinedButton(
            onPressed: () => setState(() => _currentDate = DateTime.now()),
            child: const Text("Today"),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() => _currentDate = _currentDate.subtract(const Duration(days: 1))),
          ),
          
          // Date Picker Dropdown
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
                    DateFormat('EEEE, MMM d, yyyy').format(_currentDate),
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
            onPressed: () => setState(() => _currentDate = _currentDate.add(const Duration(days: 1))),
          ),
          
          const Spacer(),

          // View Toggles
          _buildDropdownButton("Day"),
          const SizedBox(width: 12),
          
          // Filters Dropdown
          PopupMenuButton<String>(
            child: _buildActionButton("Filters", Icons.filter_list),
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text("Active Employees")),
              const PopupMenuItem(child: Text("Specific Role")),
              const PopupMenuItem(child: Text("Location: Main Branch")),
            ],
          ),
          
          const SizedBox(width: 12),
          
          // Tools Dropdown (Export)
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'excel') {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting to Excel...')));
                // Call ExportService.generateExcel(_allShifts)
              } else if (value == 'pdf') {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating PDF...')));
                // Call ExportService.generatePdf(_allShifts)
              }
            },
            child: _buildActionButton("Tools", Icons.build),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'excel',
                child: Row(children: [Icon(Icons.table_view, size: 18), SizedBox(width: 8), Text("Export to Excel")]),
              ),
              const PopupMenuItem(
                value: 'pdf',
                child: Row(children: [Icon(Icons.picture_as_pdf, size: 18), SizedBox(width: 8), Text("Print / PDF")]),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(child: Text("Clear Schedule")),
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
        ],
      ),
    );
  }

  // --- Main Grid Section ---
  Widget _buildMainGrid() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Employee Column (Fixed Left)
        SizedBox(
          width: 250,
          child: Column(
            children: [
              // Corner Header (Fixed Top-Left)
              Container(
                height: 50,
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E7EB)),
                    right: BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 16),
                child: Text("Employees", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF6B7280))),
              ),
              // Employee Rows (Vertical Scroll Only)
              Expanded(
                child: ListView.builder(
                  controller: _leftColVerticalCtrl,
                  itemCount: _employees.length,
                  itemBuilder: (context, index) => _buildEmployeeRowHeader(_employees[index]),
                ),
              ),
            ],
          ),
        ),

        // 2. Schedule Grid (Right Side)
        Expanded(
          child: Column(
            children: [
              // Time Headers (Horizontal Scroll Only)
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
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE5E7EB)),
                        right: BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    child: Text(time, style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: const Color(0xFF6B7280))),
                  )).toList(),
                ),
              ),
              // Grid Cells (Bi-directional Scroll)
              Expanded(
                child: SingleChildScrollView(
                  controller: _gridVerticalCtrl,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _gridHorizontalCtrl,
                    child: Column(
                      children: _employees.map((emp) {
                        return Row(
                          children: _timeSlots.map((time) => _buildGridCell(emp, time)).toList(),
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

  // --- Row Components ---
  Widget _buildEmployeeRowHeader(Map<String, dynamic> employee) {
    return Container(
      height: 80, // Fixed height for row
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
          right: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE0E7FF),
            child: Text(employee['avatar'], style: const TextStyle(color: Color(0xFF5D3FD3), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(employee['name'], style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF1F2937))),
                Text(employee['metrics'], style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCell(Map<String, dynamic> employee, String time) {
    return InkWell(
      onTap: () => _handleCellClick(employee['name'], time),
      child: Container(
        width: 120,
        height: 80,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E7EB)),
            right: BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        child: Center(
          child: Icon(Icons.add, size: 16, color: Colors.grey.withOpacity(0.1)),
        ),
      ),
    );
  }

  // --- Footer Section ---
  Widget _buildFooterSummary() {
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
          _buildFooterMetric("Labor Hours", "0.00 hrs"),
          const SizedBox(width: 24),
          _buildFooterMetric("Est. Cost", "\$0.00"),
          const SizedBox(width: 24),
          _buildFooterMetric("Headcount", "0"),
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

  // --- Helper Widgets ---
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
    print("Rewrote DayScheduleScreen with Synced Scrolling and Dropdowns.")

if __name__ == "__main__":
    improve_day_schedule()