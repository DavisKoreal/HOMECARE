import os
import re

def implement_day_schedule():
    target_dir = os.path.expanduser("~/Desktop/HOMECARE/homecare0x1")
    
    if not os.path.exists(target_dir):
        print(f"Error: Directory {target_dir} not found.")
        return

    print(f"Changing directory to: {target_dir}")
    os.chdir(target_dir)

    # ---------------------------------------------------------
    # 1. Update Constants (Routes & Navigation)
    # ---------------------------------------------------------
    print("\n--- Updating lib/constants.dart ---")
    constants_path = os.path.join("lib", "constants.dart")
    
    with open(constants_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Add Route if missing
    if "static const String daySchedule" not in content:
        content = content.replace(
            "class Routes {",
            "class Routes {\n  static const String daySchedule = '/day_schedule';"
        )

    # Add Sidebar Item if missing
    # We look for the sidebarItems list and insert the Schedule item at the 2nd position (after Dashboard)
    if "'route': Routes.daySchedule" not in content:
        new_item = """    {
      'title': 'Schedule',
      'icon': Icons.calendar_month_outlined,
      'route': Routes.daySchedule,
    },"""
        # Insert after Dashboard item
        content = content.replace(
            "'route': Routes.adminDashboard,\n    },",
            "'route': Routes.adminDashboard,\n    },\n" + new_item
        )

    with open(constants_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Updated constants.dart with new Route and Sidebar Item.")


    # ---------------------------------------------------------
    # 2. Create Day Schedule Screen
    # ---------------------------------------------------------
    print("\n--- Creating lib/screens/schedule/day_schedule_screen.dart ---")
    
    # Ensure directory exists
    os.makedirs(os.path.join("lib", "screens", "schedule"), exist_ok=True)
    
    screen_path = os.path.join("lib", "screens", "schedule", "day_schedule_screen.dart")
    
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
  // State Variables from JSON
  DateTime _currentDate = DateTime(2026, 1, 1);
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  // Mock Data from JSON
  final List<Map<String, dynamic>> _employees = [
    {
      "name": "Juliah Muthunga",
      "status": "Active",
      "metrics": "0.00 hrs / \$0.00",
      "avatar": "J"
    },
    {
      "name": "Kefilwe Khubile",
      "status": "Active",
      "metrics": "0.00 hrs / \$0.00",
      "avatar": "K"
    },
    {
      "name": "Paula",
      "status": "Active",
      "metrics": "0.00 hrs / \$0.00",
      "avatar": "P"
    },
    {
      "name": "Pauline Gatai",
      "status": "Active",
      "metrics": "0.00 hrs / \$0.00",
      "avatar": "PG"
    }
  ];

  // Time Slots (9am to 4pm based on visible_hours spec, extended for scrolling demo)
  final List<String> _timeSlots = [
    "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00"
  ];

  void _handleCellClick(String employeeName, String time) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Shift Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Employee: $employeeName"),
            Text("Time: $time"),
            const SizedBox(height: 16),
            const Text("Status: Empty/Occupied"),
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
          // Date Navigation
          OutlinedButton(
            onPressed: () => setState(() => _currentDate = DateTime.now()),
            child: const Text("Today"),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() => _currentDate = _currentDate.subtract(const Duration(days: 1))),
          ),
          // Date Picker Lookalike
          Container(
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
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() => _currentDate = _currentDate.add(const Duration(days: 1))),
          ),
          
          const Spacer(),

          // View Toggles
          _buildDropdownButton("Day"),
          const SizedBox(width: 12),
          _buildActionButton("Filters (6)", Icons.filter_list),
          const SizedBox(width: 12),
          _buildActionButton("Tools", Icons.build),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5D3FD3), // Primary Action from JSON
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
              // Corner Header
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
              // Employee Rows
              Expanded(
                child: ListView.builder(
                  controller: _verticalController, // Sync scrolling if needed
                  itemCount: _employees.length,
                  itemBuilder: (context, index) => _buildEmployeeRowHeader(_employees[index]),
                ),
              ),
            ],
          ),
        ),

        // 2. Schedule Grid (Scrollable)
        Expanded(
          child: Column(
            children: [
              // Time Headers
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalController,
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
              // Grid Cells
              Expanded(
                child: SingleChildScrollView(
                  controller: _verticalController, // Sync with employee col
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _horizontalController, // Sync with header
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
        // Placeholder for "Occupied" state would go here
        child: Center(
          child: Icon(Icons.add, size: 16, color: Colors.grey.withOpacity(0.2)),
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
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16, color: const Color(0xFF374151)),
      label: Text(label, style: const TextStyle(color: Color(0xFF374151))),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFE5E7EB)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
    print("Created Day Schedule Screen.")


    # ---------------------------------------------------------
    # 3. Update Admin Dashboard (Navigation Logic)
    # ---------------------------------------------------------
    print("\n--- Updating lib/screens/admin_dashboard.dart ---")
    dashboard_path = os.path.join("lib", "screens", "admin_dashboard.dart")
    
    with open(dashboard_path, "r", encoding="utf-8") as f:
        dash_content = f.read()

    # Add import
    if "import 'package:homecare0x1/screens/schedule/day_schedule_screen.dart';" not in dash_content:
        dash_content = "import 'package:homecare0x1/screens/schedule/day_schedule_screen.dart';\n" + dash_content

    # Update _getTitleForRoute
    if "case Routes.daySchedule:" not in dash_content:
        dash_content = dash_content.replace(
            "default: return 'HomeCare';",
            "case Routes.daySchedule: return 'Schedule Builder';\n      default: return 'HomeCare';"
        )

    # Update _getViewForRoute
    if "return const DayScheduleScreen();" not in dash_content:
        dash_content = dash_content.replace(
            "default:",
            "case Routes.daySchedule:\n        return const DayScheduleScreen();\n\n      default:"
        )

    with open(dashboard_path, "w", encoding="utf-8") as f:
        f.write(dash_content)
    print("Updated Admin Dashboard to handle Day Schedule route.")

if __name__ == "__main__":
    implement_day_schedule()