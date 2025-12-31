import 'package:flutter/material.dart';
import 'package:homecare0x1/models/client.dart';
import 'package:homecare0x1/models/shift.dart';
import 'package:homecare0x1/services/client_service.dart';
import 'package:homecare0x1/services/firebase_shift_service.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:intl/intl.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  // Services
  final FirebaseClientService _clientService = FirebaseClientService.instance;
  final FirebaseShiftService _shiftService = FirebaseShiftService.instance;

  // Data
  List<Client> _allClients = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() => _isLoading = true);
    try {
      final clients = await _clientService.getAllClients();
      if (mounted) {
        setState(() {
          _allClients = clients;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Client> get _filteredClients {
    if (_searchQuery.isEmpty) return _allClients;
    return _allClients.where((client) {
      return client.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             client.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             client.address.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _showClientDetails(Client client) {
    showDialog(
      context: context,
      builder: (context) => _ClientDetailsDialog(
        client: client,
        shiftService: _shiftService,
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
                    'Client Directory',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage client profiles and care histories.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadClients,
                tooltip: 'Refresh List',
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Search Bar
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
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by name, email, or address...',
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
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Contact')),
                      DataColumn(label: Text('Address')),
                      DataColumn(label: Text('Care Plan')),
                      DataColumn(label: Text('Actions')),
                    ],
                    source: _ClientDataSource(_filteredClients, context, _showClientDetails),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _ClientDataSource extends DataTableSource {
  final List<Client> _clients;
  final BuildContext context;
  final Function(Client) onViewDetails;

  _ClientDataSource(this._clients, this.context, this.onViewDetails);

  @override
  DataRow? getRow(int index) {
    if (index >= _clients.length) return null;
    final client = _clients[index];
    
    return DataRow(cells: [
      DataCell(Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
            child: Text(
              client.name.isNotEmpty ? client.name[0] : '?',
              style: const TextStyle(color: AppTheme.primaryPurple, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Text(client.name, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      )),
      DataCell(Text(client.email)),
      DataCell(
        SizedBox(
          width: 200,
          child: Text(
            client.address, 
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      ),
      DataCell(
        SizedBox(
          width: 150,
          child: Text(
            client.carePlan, 
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      ),
      DataCell(
        OutlinedButton(
          onPressed: () => onViewDetails(client),
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
  int get rowCount => _clients.length;
  @override
  int get selectedRowCount => 0;
}

class _ClientDetailsDialog extends StatelessWidget {
  final Client client;
  final FirebaseShiftService shiftService;

  const _ClientDetailsDialog({required this.client, required this.shiftService});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(0),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name, 
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 4),
                      Text('ID: ${client.id}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Contact Info'),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.email_outlined, 'Email', client.email),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.location_on_outlined, 'Address', client.address),
                    
                    const SizedBox(height: 32),
                    _buildSectionTitle('Care Plan'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.neutral100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(client.carePlan, style: const TextStyle(height: 1.5)),
                    ),

                    const SizedBox(height: 32),
                    _buildSectionTitle('Recent Shifts'),
                    const SizedBox(height: 16),
                    FutureBuilder<List<Shift>>(
                      future: shiftService.getShiftsForClient(client.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('No shift history found.', style: TextStyle(color: AppTheme.textSecondary));
                        }
                        
                        final shifts = snapshot.data!;
                        // Show last 5 shifts
                        return Column(
                          children: shifts.take(5).map((shift) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.borderGray),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.event, size: 16, color: AppTheme.textSecondary),
                                const SizedBox(width: 8),
                                Text(DateFormat('MMM dd, yyyy').format(shift.startTime)),
                                const Spacer(),
                                Text(
                                  shift.status.toUpperCase(), 
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)
                                ),
                              ],
                            ),
                          )).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            Text(value, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
          ],
        ),
      ],
    );
  }
}
