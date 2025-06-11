# File to modify
$File = "lib/screens/admin_dashboard.dart"

# Check if the file exists
if (-not (Test-Path $File)) {
    Write-Host "Error: $File not found!" -ForegroundColor Red
    exit 1
}

# Create a backup with timestamp
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupFile = "${File}.backup_${Timestamp}"
Copy-Item -Path $File -Destination $BackupFile
Write-Host "Created backup: $BackupFile" -ForegroundColor Green

# Write the updated content to the file
$Content = @"
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show confirmation dialog
        bool? shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Application'),
            content: const Text('Are you sure you want to exit the application?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Stay in app
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Exit app
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        return shouldExit ?? false; // Exit if true, stay if false or dialog dismissed
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text('Welcome to AdminDashboardScreen'),
              const SizedBox(height: 10),
              const Text(
                'Central hub for managing clients, shifts, staff, billing, and reports.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, Routes.clientList),
                child: const Text('Manage Clients'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, Routes.shiftAssignment),
                child: const Text('Assign Shifts'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, Routes.billingDashboard),
                child: const Text('View Billing'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, Routes.reportsDashboard),
                child: const Text('View Reports'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, Routes.userProfile),
                child: const Text('Edit Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
"@
try {
    Set-Content -Path $File -Value $Content -ErrorAction Stop
    Write-Host "Successfully updated $File" -ForegroundColor Green
}
catch {
    Write-Host "Error: Failed to update $File" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

exit 0