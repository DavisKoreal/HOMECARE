import 'package:flutter/material.dart';
import 'package:homecare0x1/models/audit_log.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:intl/intl.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Filter and search states
  String _selectedFilter = 'All';
  String _selectedDateRange = 'All Time';
  String _selectedUserType = 'All Users';
  String _searchQuery = '';
  bool _isSearchActive = false;
  bool _showFilters = false;

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  // Sort options
  String _sortBy = 'timestamp';
  bool _sortAscending = false;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Mock audit logs with more diverse data
  final List<AuditLog> _allLogs = [
    AuditLog(
      id: '1',
      userId: 'admin1',
      action: 'Client Profile Updated',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      details: 'Updated care plan for John Doe - Modified medication schedule',
      actionType: 'Update',
      severity: 'Medium',
    ),
    AuditLog(
      id: '2',
      userId: 'caregiver1',
      action: 'Medication Logged',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      details: 'Logged Aspirin 81mg for John Doe - Morning dose administered',
      actionType: 'Create',
      severity: 'Low',
    ),
    AuditLog(
      id: '3',
      userId: 'admin1',
      action: 'Shift Assigned',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      details:
          'Assigned caregiver Sarah Johnson to Jane Smith for evening shift',
      actionType: 'Assignment',
      severity: 'Medium',
    ),
    AuditLog(
      id: '4',
      userId: 'system',
      action: 'Security Alert',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      details: 'Failed login attempt detected from IP 192.168.1.100',
      actionType: 'Security',
      severity: 'High',
    ),
    AuditLog(
      id: '5',
      userId: 'caregiver2',
      action: 'Care Note Added',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      details:
          'Added progress note for patient Mary Wilson - Vital signs stable',
      actionType: 'Create',
      severity: 'Low',
    ),
    AuditLog(
      id: '6',
      userId: 'admin2',
      action: 'User Account Created',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      details: 'Created new caregiver account for David Brown',
      actionType: 'Create',
      severity: 'Medium',
    ),
    AuditLog(
      id: '7',
      userId: 'caregiver1',
      action: 'Emergency Contact Updated',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      details: 'Updated emergency contact information for John Doe',
      actionType: 'Update',
      severity: 'Medium',
    ),
    AuditLog(
      id: '8',
      userId: 'system',
      action: 'Data Backup Completed',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      details: 'Automated daily backup completed successfully',
      actionType: 'System',
      severity: 'Low',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _scrollController.addListener(_onScroll);
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load more items when reaching the bottom
      _loadMoreItems();
    }
  }

  void _loadMoreItems() {
    if (_currentPage * _itemsPerPage < _getFilteredLogs().length) {
      setState(() {
        _currentPage++;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<AuditLog> _getFilteredLogs() {
    List<AuditLog> filtered = List.from(_allLogs);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((log) {
        return log.action.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            log.details.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            log.userId.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply action type filter
    if (_selectedFilter != 'All') {
      filtered =
          filtered.where((log) => log.actionType == _selectedFilter).toList();
    }

    // Apply user type filter
    if (_selectedUserType != 'All Users') {
      filtered = filtered.where((log) {
        if (_selectedUserType == 'Admins') return log.userId.contains('admin');
        if (_selectedUserType == 'Caregivers')
          return log.userId.contains('caregiver');
        if (_selectedUserType == 'System') return log.userId == 'system';
        return true;
      }).toList();
    }

    // Apply date range filter
    if (_selectedDateRange != 'All Time') {
      final now = DateTime.now();
      DateTime cutoff;
      switch (_selectedDateRange) {
        case 'Today':
          cutoff = DateTime(now.year, now.month, now.day);
          break;
        case 'This Week':
          cutoff = now.subtract(Duration(days: now.weekday - 1));
          break;
        case 'This Month':
          cutoff = DateTime(now.year, now.month, 1);
          break;
        default:
          cutoff = DateTime(1970);
      }
      filtered =
          filtered.where((log) => log.timestamp.isAfter(cutoff)).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'action':
          comparison = a.action.compareTo(b.action);
          break;
        case 'userId':
          comparison = a.userId.compareTo(b.userId);
          break;
        case 'severity':
          final severityOrder = {'Low': 0, 'Medium': 1, 'High': 2};
          comparison = (severityOrder[a.severity] ?? 0)
              .compareTo(severityOrder[b.severity] ?? 0);
          break;
        default:
          comparison = a.timestamp.compareTo(b.timestamp);
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  List<AuditLog> _getPaginatedLogs() {
    final filtered = _getFilteredLogs();
    final endIndex = (_currentPage * _itemsPerPage).clamp(0, filtered.length);
    return filtered.take(endIndex).toList();
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _currentPage = 1; // Reset pagination
          });
        },
        onTap: () {
          setState(() {
            _isSearchActive = true;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search audit logs...',
          prefixIcon: Icon(
            Icons.search,
            color: _isSearchActive ? AppTheme.primaryBlue : Colors.grey[600],
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _isSearchActive = false;
                      _currentPage = 1;
                    });
                  },
                  icon: const Icon(Icons.clear),
                )
              : IconButton(
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                  icon: Icon(
                    _showFilters ? Icons.filter_list_off : Icons.filter_list,
                    color:
                        _showFilters ? AppTheme.primaryBlue : Colors.grey[600],
                  ),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showFilters ? null : 0,
      child: _showFilters
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Action Type Filter
                  _buildFilterRow(
                    'Action Type',
                    [
                      'All',
                      'Create',
                      'Update',
                      'Assignment',
                      'Security',
                      'System'
                    ],
                    _selectedFilter,
                    (value) => setState(() {
                      _selectedFilter = value;
                      _currentPage = 1;
                    }),
                  ),

                  const SizedBox(height: 12),

                  // User Type Filter
                  _buildFilterRow(
                    'User Type',
                    ['All Users', 'Admins', 'Caregivers', 'System'],
                    _selectedUserType,
                    (value) => setState(() {
                      _selectedUserType = value;
                      _currentPage = 1;
                    }),
                  ),

                  const SizedBox(height: 12),

                  // Date Range Filter
                  _buildFilterRow(
                    'Date Range',
                    ['All Time', 'Today', 'This Week', 'This Month'],
                    _selectedDateRange,
                    (value) => setState(() {
                      _selectedDateRange = value;
                      _currentPage = 1;
                    }),
                  ),

                  const SizedBox(height: 16),

                  // Sort Options
                  Row(
                    children: [
                      Text(
                        'Sort by:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: _sortBy,
                        onChanged: (value) {
                          setState(() {
                            _sortBy = value!;
                            _currentPage = 1;
                          });
                        },
                        items: [
                          DropdownMenuItem(
                              value: 'timestamp', child: Text('Time')),
                          DropdownMenuItem(
                              value: 'action', child: Text('Action')),
                          DropdownMenuItem(
                              value: 'userId', child: Text('User')),
                          DropdownMenuItem(
                              value: 'severity', child: Text('Severity')),
                        ],
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _sortAscending = !_sortAscending;
                            _currentPage = 1;
                          });
                        },
                        icon: Icon(
                          _sortAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildFilterRow(
    String title,
    List<String> options,
    String selected,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (bool value) {
                onChanged(option);
              },
              backgroundColor: Colors.white,
              selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryBlue : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryBlue : Colors.grey[300]!,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    final filteredLogs = _getFilteredLogs();
    final highSeverityCount =
        filteredLogs.where((log) => log.severity == 'High').length;
    final todayCount = filteredLogs.where((log) {
      final today = DateTime.now();
      final logDate = log.timestamp;
      return logDate.year == today.year &&
          logDate.month == today.month &&
          logDate.day == today.day;
    }).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total\nLogs',
              filteredLogs.length.toString(),
              Icons.history,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              'Today\'s\nActivity',
              todayCount.toString(),
              Icons.today,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              'High\nSeverity',
              highSeverityCount.toString(),
              Icons.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLogItem(AuditLog log, int index) {
    final isEven = index % 2 == 0;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getSeverityColor(log.severity).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getActionIcon(log.actionType),
            color: _getSeverityColor(log.severity),
            size: 24,
          ),
        ),
        title: Text(
          log.action,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  log.userId,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, h:mm a').format(log.timestamp),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(log.severity).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    log.severity,
                    style: TextStyle(
                      color: _getSeverityColor(log.severity),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    log.actionType,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Details',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  log.details,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ID: ${log.id}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'High':
        return Colors.red[600]!;
      case 'Medium':
        return Colors.orange[600]!;
      case 'Low':
        return Colors.green[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getActionIcon(String actionType) {
    switch (actionType) {
      case 'Create':
        return Icons.add_circle;
      case 'Update':
        return Icons.edit;
      case 'Assignment':
        return Icons.assignment;
      case 'Security':
        return Icons.security;
      case 'System':
        return Icons.settings;
      default:
        return Icons.history;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No logs match your search'
                : 'No audit logs found',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedFilter = 'All';
                  _selectedDateRange = 'All Time';
                  _selectedUserType = 'All Users';
                  _currentPage = 1;
                });
              },
              child: const Text('Clear filters'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paginatedLogs = _getPaginatedLogs();
    final filteredLogs = _getFilteredLogs();
    final hasMoreItems = _currentPage * _itemsPerPage < filteredLogs.length;

    return ModernScreenLayout(
      title: 'Audit Log',
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Stats card
              _buildStatsCard(),

              // Search bar
              _buildSearchBar(),

              // Filters section
              _buildFiltersSection(),

              if (_showFilters) const SizedBox(height: 16),

              // Results header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.assignment,
                      color: AppTheme.primaryBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Audit Logs',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.primaryBlue.withOpacity(0.3)),
                      ),
                      child: Text(
                        '${filteredLogs.length} ${filteredLogs.length == 1 ? 'log' : 'logs'}',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Logs list
              Expanded(
                child: paginatedLogs.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          setState(() {
                            _currentPage = 1;
                          });
                          // Simulate refresh delay
                          await Future.delayed(
                              const Duration(milliseconds: 500));
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount:
                              paginatedLogs.length + (hasMoreItems ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < paginatedLogs.length) {
                              return _buildLogItem(paginatedLogs[index], index);
                            } else {
                              // Loading indicator for pagination
                              return Container(
                                padding: const EdgeInsets.all(16),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extended AuditLog model to include additional fields
extension AuditLogExtension on AuditLog {
  String get actionType => this.actionType ?? 'Unknown';
  String get severity => this.severity ?? 'Low';
}
