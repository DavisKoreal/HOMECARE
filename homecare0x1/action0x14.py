import os

def refactor_care_notes():
    target_dir = os.path.expanduser("~/Desktop/HOMECARE/homecare0x1")
    
    if not os.path.exists(target_dir):
        print(f"Error: Directory {target_dir} not found.")
        return

    print(f"Changing directory to: {target_dir}")
    os.chdir(target_dir)

    print("\n--- Refactoring lib/screens/admin_notes_management_screen.dart ---")
    notes_path = os.path.join("lib", "screens", "admin_notes_management_screen.dart")
    
    notes_content = """import 'package:flutter/material.dart';
import 'package:homecare0x1/models/care_note.dart';
import 'package:homecare0x1/services/firebase_care_note_service.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:intl/intl.dart';

class AdminNotesManagementScreen extends StatefulWidget {
  const AdminNotesManagementScreen({super.key});

  @override
  State<AdminNotesManagementScreen> createState() => _AdminNotesManagementScreenState();
}

class _AdminNotesManagementScreenState extends State<AdminNotesManagementScreen> {
  // Service
  final FirebaseCareNotesService _service = FirebaseCareNotesService();
  
  // Data
  List<CareNote> _allNotes = [];
  Map<String, String> _clientNames = {};
  bool _isLoading = true;
  String? _error;

  // Filters
  String _searchQuery = '';
  DateTime? _selectedDate;
  bool _showLateOnly = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final notes = await _service.getAllCareNotes();
      final clients = await _service.getClientNames();
      if (mounted) {
        setState(() {
          _allNotes = notes;
          _clientNames = clients;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  List<CareNote> get _filteredNotes {
    return _allNotes.where((note) {
      // 1. Search (Client ID, Name, or Note content)
      final clientName = _clientNames[note.clientId] ?? '';
      final matchesSearch = clientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            note.clientId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            note.note.toLowerCase().contains(_searchQuery.toLowerCase());
      
      if (!matchesSearch) return false;

      // 2. Date Filter
      if (_selectedDate != null) {
        final noteDate = note.timestamp;
        if (noteDate.year != _selectedDate!.year || 
            noteDate.month != _selectedDate!.month || 
            noteDate.day != _selectedDate!.day) {
          return false;
        }
      }

      // 3. Late Filter
      if (_showLateOnly && !note.isLate) return false;

      return true;
    }).toList();
  }

  Future<void> _toggleVisibility(CareNote note) async {
    try {
      await _service.toggleNoteVisibility(note.id, !note.isVisibleToClient);
      _loadData(); // Refresh to show update
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed)
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showNoteDetails(CareNote note) {
    showDialog(
      context: context,
      builder: (context) => _NoteDetailsDialog(
        note: note,
        clientName: _clientNames[note.clientId] ?? 'Unknown',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Care Notes',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Review daily logs and caregiver observations.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Filters Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderGray),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 250,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search client, ID, or notes...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.borderGray),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(_selectedDate == null ? 'Filter Date' : DateFormat('MM/dd/yyyy').format(_selectedDate!)),
                ),
                if (_selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _selectedDate = null),
                  ),
                const Spacer(),
                Row(
                  children: [
                    Checkbox(
                      value: _showLateOnly, 
                      activeColor: AppTheme.primaryPurple,
                      onChanged: (v) => setState(() => _showLateOnly = v!)
                    ),
                    const Text('Show Late Only'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data Table
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderGray),
            ),
            child: _isLoading 
              ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
              : Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: AppTheme.borderGray,
                    dataTableTheme: DataTableThemeData(
                      headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      dataTextStyle: const TextStyle(color: AppTheme.textPrimary),
                    ),
                  ),
                  child: PaginatedDataTable(
                    header: null,
                    rowsPerPage: 10,
                    columns: const [
                      DataColumn(label: Text('Date & Time')),
                      DataColumn(label: Text('Client')),
                      DataColumn(label: Text('Health Status')),
                      DataColumn(label: Text('Notes')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Visibility')),
                      DataColumn(label: Text('Actions')),
                    ],
                    source: _NotesDataSource(
                      _filteredNotes, 
                      context, 
                      _clientNames, 
                      _toggleVisibility, 
                      _showNoteDetails
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _NotesDataSource extends DataTableSource {
  final List<CareNote> _notes;
  final BuildContext context;
  final Map<String, String> _clientNames;
  final Function(CareNote) onToggleVisibility;
  final Function(CareNote) onViewDetails;

  _NotesDataSource(this._notes, this.context, this._clientNames, this.onToggleVisibility, this.onViewDetails);

  @override
  DataRow? getRow(int index) {
    if (index >= _notes.length) return null;
    final note = _notes[index];
    final clientName = _clientNames[note.clientId] ?? note.clientId;
    
    return DataRow(cells: [
      DataCell(Text(DateFormat('MMM d, h:mm a').format(note.timestamp))),
      DataCell(Text(clientName)),
      DataCell(Text(note.healthStatus)),
      DataCell(
        SizedBox(
          width: 200,
          child: Text(
            note.note, 
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      ),
      DataCell(
        note.isLate 
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppTheme.errorRed.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: const Text('LATE', style: TextStyle(color: AppTheme.errorRed, fontSize: 10, fontWeight: FontWeight.bold)),
            )
          : const Text('On Time', style: TextStyle(color: AppTheme.successGreen, fontSize: 12)),
      ),
      DataCell(
        IconButton(
          icon: Icon(
            note.isVisibleToClient ? Icons.visibility : Icons.visibility_off,
            color: note.isVisibleToClient ? AppTheme.primaryPurple : AppTheme.textSecondary,
            size: 20,
          ),
          tooltip: note.isVisibleToClient ? 'Visible to Client' : 'Hidden from Client',
          onPressed: () => onToggleVisibility(note),
        ),
      ),
      DataCell(
        OutlinedButton(
          onPressed: () => onViewDetails(note),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('View', style: TextStyle(fontSize: 12)),
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _notes.length;
  @override
  int get selectedRowCount => 0;
}

class _NoteDetailsDialog extends StatelessWidget {
  final CareNote note;
  final String clientName;

  const _NoteDetailsDialog({required this.note, required this.clientName});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 600,
        height: 700,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.borderGray)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Note Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Client', clientName),
                    _buildInfoRow('Date', DateFormat('MMM d, yyyy h:mm a').format(note.timestamp)),
                    _buildInfoRow('Health Status', note.healthStatus),
                    _buildInfoRow('Mood', note.mood),
                    
                    const Divider(height: 32),
                    
                    _buildSection('Observations', note.observations),
                    _buildSection('Activities', note.activities),
                    _buildSection('Notes', note.note),

                    const Divider(height: 32),

                    _buildInfoRow('Hydration', '${note.hydrationMl} ml'),
                    _buildInfoRow('Food Intake', note.foodAndDrinks),
                    _buildInfoRow('Meal Quantity', '${note.mealQuantityPercentage}%'),
                    _buildInfoRow('Bowel Movement', note.hasBowelMovement ? 'Yes' : 'No'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, 
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))
          ),
          Expanded(child: Text(value, style: const TextStyle(color: AppTheme.textPrimary))),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.neutral100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(content.isEmpty ? 'None' : content, style: const TextStyle(height: 1.5)),
          ),
        ],
      ),
    );
  }
}
"""
    with open(notes_path, "w", encoding="utf-8") as f:
        f.write(notes_content)
    print("Rewrote admin_notes_management_screen.dart to Data Table format.")

if __name__ == "__main__":
    refactor_care_notes()