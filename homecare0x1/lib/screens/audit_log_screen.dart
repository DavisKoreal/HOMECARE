import 'package:flutter/material.dart';
import 'package:homecare0x1/models/audit_log.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/services/auditlog_service.dart';
import 'package:intl/intl.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  // Services & Data
  final FirebaseAuditLogService _service = FirebaseAuditLogService.instance;
  List<AuditLog> _allLogs = [];
  bool _isLoading = true;

  // Search & Filter State
  String _searchQuery = '';
  String _selectedSeverity = 'All';
  
  // Pagination (Simple client-side for now)
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      final logs = await _service.getAllAuditLogs();
      if (mounted) {
        setState(() {
          _allLogs = logs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<AuditLog> get _filteredLogs {
    return _allLogs.where((log) {
      final matchesSearch = log.action.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            log.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            log.details.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesSeverity = _selectedSeverity == 'All' || log.severity == _selectedSeverity;
      
      return matchesSearch && matchesSeverity;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen width for responsive layout
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 800;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Logs',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track system activity and security events.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadLogs,
                tooltip: 'Refresh Logs',
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 2. Filter Bar (Card)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderGray),
            ),
            child: Flex(
              direction: isDesktop ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: isDesktop ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
              children: [
                // Search Field
                SizedBox(
                  width: isDesktop ? 300 : null,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search actions, users...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.borderGray),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.borderGray),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                if (isDesktop) const SizedBox(width: 16) else const SizedBox(height: 16),
                
                // Severity Dropdown
                DropdownButtonHideUnderline(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.borderGray),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedSeverity,
                      icon: const Icon(Icons.filter_list, size: 20),
                      items: ['All', 'Low', 'Medium', 'High', 'Critical', 'Info'].map((s) {
                        return DropdownMenuItem(value: s, child: Text(s));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedSeverity = val!),
                    ),
                  ),
                ),
                
                if (isDesktop) const Spacer(),
                
                // Export Button (Placeholder)
                if (isDesktop) ...[
                  OutlinedButton.icon(
                    onPressed: () {}, 
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Export CSV'),
                  )
                ]
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Data Table
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
                    rowsPerPage: _rowsPerPage,
                    onRowsPerPageChanged: (val) => setState(() => _rowsPerPage = val!),
                    columns: const [
                      DataColumn(label: Text('Timestamp')),
                      DataColumn(label: Text('User')),
                      DataColumn(label: Text('Action')),
                      DataColumn(label: Text('Severity')),
                      DataColumn(label: Text('Details')),
                    ],
                    source: _AuditLogDataSource(_filteredLogs, context),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _AuditLogDataSource extends DataTableSource {
  final List<AuditLog> _logs;
  final BuildContext context;

  _AuditLogDataSource(this._logs, this.context);

  @override
  DataRow? getRow(int index) {
    if (index >= _logs.length) return null;
    final log = _logs[index];
    
    return DataRow(cells: [
      DataCell(Text(DateFormat('MMM d, h:mm a').format(log.timestamp))),
      DataCell(Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppTheme.neutral100,
            child: Text(log.userName.isNotEmpty ? log.userName[0] : '?', style: const TextStyle(fontSize: 10)),
          ),
          const SizedBox(width: 8),
          Text(log.userName, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      )),
      DataCell(Text(log.action)),
      DataCell(_buildSeverityChip(log.severity)),
      DataCell(
        SizedBox(
          width: 200, 
          child: Text(
            log.details, 
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.textSecondary),
          )
        )
      ),
    ]);
  }

  Widget _buildSeverityChip(String severity) {
    Color color;
    switch (severity.toLowerCase()) {
      case 'critical': color = AppTheme.errorRed; break;
      case 'high': color = Colors.orange; break;
      case 'medium': color = Colors.amber; break;
      default: color = AppTheme.successGreen; // Info/Low
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        severity, 
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _logs.length;
  @override
  int get selectedRowCount => 0;
}
