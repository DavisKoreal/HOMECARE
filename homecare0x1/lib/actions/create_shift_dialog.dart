import 'package:flutter/material.dart';
import 'package:homecare0x1/models/client.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Future<void> showCreateShiftDialog({
  required BuildContext context,
  required VoidCallback onShiftAdded,
  required void Function(String, {bool isError}) showOverlay,
}) async {
  final clientController = TextEditingController();
  final caregiverController = TextEditingController();
  String? selectedClientId;
  String? selectedClientName;
  String? selectedCaregiverId;
  String? selectedCaregiverName;
  String? errorMessage;
  DateTime? startTime = DateTime.now().add(const Duration(hours: 1));
  DateTime? endTime = startTime.add(const Duration(hours: 2));
  String clientFilterText = '';
  String caregiverFilterText = '';
  OverlayEntry? dropdownOverlay;
  final clientFocusNode = FocusNode();
  final caregiverFocusNode = FocusNode();

  void showClientDropdown(BuildContext context, GlobalKey textFieldKey) {
    dropdownOverlay?.remove();
    final renderBox = textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final clients = Provider.of<ShiftAssignmentProvider>(context, listen: false)
        .clients
        .where((client) =>
            client.name.toLowerCase().contains(clientFilterText.toLowerCase()) ||
            client.id.toLowerCase().contains(clientFilterText.toLowerCase()))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final topClients = clients.take(5).toList();

    dropdownOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                dropdownOverlay?.remove();
                dropdownOverlay = null;
              },
              behavior: HitTestBehavior.translucent,
            ),
          ),
          Positioned(
            left: offset.dx,
            top: offset.dy + size.height,
            width: size.width,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: topClients.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No clients found',
                          style: TextStyle(
                            color: const Color(0xFF7F8C8D),
                            fontSize: 14,
                          ),
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: topClients
                            .map((client) => ListTile(
                                  title: Text(
                                    '${client.name} (${client.id})',
                                    style: const TextStyle(
                                      color: Color(0xFF2C3E50),
                                      fontSize: 14,
                                    ),
                                  ),
                                  onTap: () {
                                    clientController.text = client.name;
                                    selectedClientId = client.id;
                                    selectedClientName = client.name;
                                    dropdownOverlay?.remove();
                                    dropdownOverlay = null;
                                    clientFocusNode.unfocus();
                                  },
                                ))
                            .toList(),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(dropdownOverlay!);
  }

  void showCaregiverDropdown(BuildContext context, GlobalKey textFieldKey) {
    dropdownOverlay?.remove();
    final renderBox = textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final caregivers = Provider.of<ShiftAssignmentProvider>(context, listen: false)
        .availableCaregivers
        .where((caregiver) =>
            caregiver.name.toLowerCase().contains(caregiverFilterText.toLowerCase()) ||
            caregiver.id.toLowerCase().contains(caregiverFilterText.toLowerCase()))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final topCaregivers = caregivers.take(5).toList();

    dropdownOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                dropdownOverlay?.remove();
                dropdownOverlay = null;
              },
              behavior: HitTestBehavior.translucent,
            ),
          ),
          Positioned(
            left: offset.dx,
            top: offset.dy + size.height,
            width: size.width,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: topCaregivers.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No caregivers found',
                          style: TextStyle(
                            color: const Color(0xFF7F8C8D),
                            fontSize: 14,
                          ),
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: topCaregivers
                            .map((caregiver) => ListTile(
                                  title: Text(
                                    '${caregiver.name} (${caregiver.id})',
                                    style: const TextStyle(
                                      color: Color(0xFF2C3E50),
                                      fontSize: 14,
                                    ),
                                  ),
                                  onTap: () {
                                    caregiverController.text = caregiver.name;
                                    selectedCaregiverId = caregiver.id;
                                    selectedCaregiverName = caregiver.name;
                                    dropdownOverlay?.remove();
                                    dropdownOverlay = null;
                                    caregiverFocusNode.unfocus();
                                  },
                                ))
                            .toList(),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(dropdownOverlay!);
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.schedule,
                          color: AppTheme.secondaryTeal,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create New Shift',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Schedule a new caregiving shift',
                              style: TextStyle(
                                color: Color(0xFF7F8C8D),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Client Selection
                  Consumer<ShiftAssignmentProvider>(
                    builder: (context, provider, child) {
                      final clientTextFieldKey = GlobalKey();
                      return TextField(
                        controller: clientController,
                        focusNode: clientFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Search Clients',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: clientController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      clientController.clear();
                                      clientFilterText = '';
                                      selectedClientId = null;
                                      selectedClientName = null;
                                      errorMessage = null;
                                    });
                                  },
                                )
                              : null,
                        ),
                        onTap: () => showClientDropdown(context, clientTextFieldKey),
                        onChanged: (value) {
                          setState(() {
                            clientFilterText = value;
                            dropdownOverlay?.remove();
                            dropdownOverlay = null;
                            showClientDropdown(context, clientTextFieldKey);
                          });
                        },
                        key: clientTextFieldKey,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Caregiver Selection
                  Consumer<ShiftAssignmentProvider>(
                    builder: (context, provider, child) {
                      final caregiverTextFieldKey = GlobalKey();
                      return TextField(
                        controller: caregiverController,
                        focusNode: caregiverFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Search Caregivers (Optional)',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: caregiverController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      caregiverController.clear();
                                      caregiverFilterText = '';
                                      selectedCaregiverId = null;
                                      selectedCaregiverName = null;
                                      errorMessage = null;
                                    });
                                  },
                                )
                              : null,
                        ),
                        onTap: () => showCaregiverDropdown(context, caregiverTextFieldKey),
                        onChanged: (value) {
                          setState(() {
                            caregiverFilterText = value;
                            dropdownOverlay?.remove();
                            dropdownOverlay = null;
                            showCaregiverDropdown(context, caregiverTextFieldKey);
                          });
                        },
                        key: caregiverTextFieldKey,
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  // Start Time Selection Card
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3498DB).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Color(0xFF3498DB),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Start Time',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: startTime!,
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(const Duration(days: 365)),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: Theme.of(context).colorScheme.copyWith(
                                                    primary: const Color(0xFF3498DB),
                                                  ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (date != null) {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.fromDateTime(startTime!),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme: Theme.of(context).colorScheme.copyWith(
                                                      primary: const Color(0xFF3498DB),
                                                    ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );
                                        if (time != null) {
                                          setState(() {
                                            startTime = DateTime(
                                              date.year,
                                              date.month,
                                              date.day,
                                              time.hour,
                                              time.minute,
                                            );
                                            endTime = startTime!.add(const Duration(hours: 2));
                                            errorMessage = null;
                                          });
                                        }
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF3498DB).withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFF3498DB).withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            color: Color(0xFF3498DB),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              startTime != null
                                                  ? DateFormat('MMM dd, yyyy • hh:mm a').format(startTime!)
                                                  : 'Select start time',
                                              style: TextStyle(
                                                color: startTime != null
                                                    ? const Color(0xFF2C3E50)
                                                    : const Color(0xFF7F8C8D),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.chevron_right,
                                            color: Color(0xFF3498DB),
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // End Time Selection Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE67E22).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.stop,
                                      color: Color(0xFFE67E22),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'End Time',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: endTime!,
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(const Duration(days: 365)),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: Theme.of(context).colorScheme.copyWith(
                                                    primary: const Color(0xFFE67E22),
                                                  ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (date != null) {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.fromDateTime(endTime!),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme: Theme.of(context).colorScheme.copyWith(
                                                      primary: const Color(0xFFE67E22),
                                                    ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );
                                        if (time != null) {
                                          setState(() {
                                            endTime = DateTime(
                                              date.year,
                                              date.month,
                                              date.day,
                                              time.hour,
                                              time.minute,
                                            );
                                            errorMessage = null;
                                          });
                                        }
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE67E22).withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE67E22).withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            color: Color(0xFFE67E22),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              endTime != null
                                                  ? DateFormat('MMM dd, yyyy • hh:mm a').format(endTime!)
                                                  : 'Select end time',
                                              style: TextStyle(
                                                color: endTime != null
                                                    ? const Color(0xFF2C3E50)
                                                    : const Color(0xFF7F8C8D),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.chevron_right,
                                            color: Color(0xFFE67E22),
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Duration Display
                  if (startTime != null && endTime != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.secondaryTeal.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryTeal.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.schedule,
                              color: AppTheme.secondaryTeal,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Duration: ${endTime!.difference(startTime!).inHours}h ${endTime!.difference(startTime!).inMinutes % 60}m',
                            style: const TextStyle(
                              color: AppTheme.secondaryTeal,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Error Message
                  if (errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.errorRed.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.errorRed.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.error_outline,
                              color: AppTheme.errorRed,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(
                                color: AppTheme.errorRed,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          child: TextButton(
                            onPressed: () {
                              dropdownOverlay?.remove();
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xFFE9ECEF), width: 1),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xFF7F8C8D),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (selectedClientId == null) {
                                setState(() {
                                  errorMessage = 'Please select a client';
                                });
                                return;
                              }
                              if (startTime == null || endTime == null) {
                                setState(() {
                                  errorMessage = 'Please select both start and end times';
                                });
                                return;
                              }
                              if (startTime!.isBefore(DateTime.now())) {
                                setState(() {
                                  errorMessage = 'Start time must be in the future';
                                });
                                return;
                              }
                              if (startTime!.isAfter(endTime!)) {
                                setState(() {
                                  errorMessage = 'Start time must be before end time';
                                });
                                return;
                              }
                              try {
                                await Provider.of<ShiftAssignmentProvider>(context, listen: false).addShift(
                                  clientId: selectedClientId!,
                                  clientName: selectedClientName!,
                                  startTime: startTime!,
                                  endTime: endTime!,
                                  caregiverId: selectedCaregiverId,
                                  caregiverName: selectedCaregiverName,
                                  context: context,
                                );
                                dropdownOverlay?.remove();
                                Navigator.pop(context);
                                onShiftAdded();
                                showOverlay('Shift created successfully');
                              } catch (e) {
                                showOverlay('Error: $e', isError: true);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add, size: 18),
                                const SizedBox(width: 8),
                                const Text(
                                  'Create Shift',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}