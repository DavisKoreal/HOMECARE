import 'package:flutter/material.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
// import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:provider/provider.dart';

Future<void> showCreateClientDialog({
  required BuildContext context,
  required VoidCallback onClientAdded,
  required void Function(String, {bool isError}) showOverlay,
}) async {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  String? selectedStatus = 'Active';
  String? errorMessage;
  OverlayEntry? dropdownOverlay;
  final statusFocusNode = FocusNode();

  void showStatusDropdown(BuildContext context, GlobalKey textFieldKey) {
    dropdownOverlay?.remove();
    final renderBox = textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final statuses = ['Active', 'Inactive'];

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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: statuses
                      .map((status) => ListTile(
                            title: Text(
                              status,
                              style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 14),
                            ),
                            onTap: () {
                              selectedStatus = status;
                              dropdownOverlay?.remove();
                              dropdownOverlay = null;
                              statusFocusNode.unfocus();
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
                          Icons.person_add,
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
                              'Add New Client',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Enter client details to create a new profile',
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
                  // Name Field
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.person),
                      suffixIcon: nameController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => nameController.clear(),
                            )
                          : null,
                    ),
                    onChanged: (value) => setState(() => errorMessage = null),
                  ),
                  const SizedBox(height: 16),
                  // Email Field
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email (Optional)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email),
                      suffixIcon: emailController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => emailController.clear(),
                            )
                          : null,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => setState(() => errorMessage = null),
                  ),
                  const SizedBox(height: 16),
                  // Phone Field
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone (Optional)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.phone),
                      suffixIcon: phoneController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => phoneController.clear(),
                            )
                          : null,
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => setState(() => errorMessage = null),
                  ),
                  const SizedBox(height: 16),
                  // Status Selection
                  GestureDetector(
                    onTap: () {
                      final statusTextFieldKey = GlobalKey();
                      showStatusDropdown(context, statusTextFieldKey);
                    },
                    child: Container(
                      key: GlobalKey(),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE9ECEF)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.toggle_on, color: AppTheme.secondaryTeal),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Status: $selectedStatus',
                              style: const TextStyle(
                                color: Color(0xFF2C3E50),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: AppTheme.secondaryTeal),
                        ],
                      ),
                    ),
                  ),
                  // Error Message
                  if (errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.errorRed.withOpacity(0.2), width: 1),
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
                              if (nameController.text.trim().isEmpty) {
                                setState(() {
                                  errorMessage = 'Please enter a client name';
                                });
                                return;
                              }
                              try {
                                await Provider.of<ShiftAssignmentProvider>(context, listen: false).addClient(
                                  name: nameController.text.trim(),
                                  email: emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
                                  phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
                                  status: selectedStatus!,
                                  context: context,
                                );
                                dropdownOverlay?.remove();
                                Navigator.pop(context);
                                onClientAdded();
                                showOverlay('Client added successfully');
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
                                const Icon(Icons.person_add, size: 18),
                                const SizedBox(width: 8),
                                const Text(
                                  'Add Client',
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