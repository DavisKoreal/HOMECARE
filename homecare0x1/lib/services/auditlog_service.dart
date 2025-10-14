// File: lib/services/firebase_audit_log_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homecare0x1/models/audit_log.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:provider/provider.dart';

// FirebaseAuditLogService class for managing audit log-related operations with Firestore
class FirebaseAuditLogService {
  // Singleton instance to ensure only one instance of the service exists
  static final FirebaseAuditLogService instance = FirebaseAuditLogService._constructor();

  // Firestore instance for database operations
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection name for Firestore
  final String _auditLogsCollection = 'audit_logs';

  // Private constructor for singleton pattern
  FirebaseAuditLogService._constructor();

  /// Fetches all audit logs from Firestore, limited to 500 records
  /// Returns a list of AuditLog objects
  Future<List<AuditLog>> getAllAuditLogs() async {
    try {
      // Query audit logs collection with a limit of 500
      final snapshot = await _firestore
          .collection(_auditLogsCollection)
          .limit(500)
          .get();
      print('Fetched ${snapshot.docs.length} audit logs from Firestore');
      // Map documents to AuditLog objects
      return snapshot.docs.map((doc) => AuditLog(
            id: doc.id,
            userId: doc['userId'],
            userName: doc['userName'],
            userRole: doc['userRole'],
            action: doc['action'],
            timestamp: (doc['timestamp'] as Timestamp).toDate(),
            details: doc['details'] ?? '',
            actionType: doc['actionType'],
            severity: doc['severity'],
          )).toList();
    } catch (e) {
      // Log error and return empty list on failure
      print('Error fetching audit logs: $e');
      return [];
    }
  }

  /// Fetches audit logs for a specific user
  /// Returns a list of AuditLog objects for the given userId
  Future<List<AuditLog>> getAuditLogsForUser(String userId) async {
    try {
      // Fetch all audit logs and filter by userId
      final auditLogs = await getAllAuditLogs();
      final userLogs = auditLogs.where((log) => log.userId == userId).toList();
      // Sort by most recent timestamp first
      userLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return userLogs;
    } catch (e) {
      // Log error and return empty list on failure
      print('Error fetching audit logs for user: $e');
      return [];
    }
  }

  /// Fetches audit logs by action type
  /// Returns a list of AuditLog objects for the given actionType
  Future<List<AuditLog>> getAuditLogsByActionType(String actionType) async {
    try {
      // Fetch all audit logs and filter by actionType
      final auditLogs = await getAllAuditLogs();
      return auditLogs.where((log) => log.actionType == actionType).toList();
    } catch (e) {
      // Log error and return empty list on failure
      print('Error fetching audit logs by action type: $e');
      return [];
    }
  }

  /// Fetches audit logs by severity
  /// Returns a list of AuditLog objects for the given severity
  Future<List<AuditLog>> getAuditLogsBySeverity(String severity) async {
    try {
      // Fetch all audit logs and filter by severity
      final auditLogs = await getAllAuditLogs();
      return auditLogs.where((log) => log.severity == severity).toList();
    } catch (e) {
      // Log error and return empty list on failure
      print('Error fetching audit logs by severity: $e');
      return [];
    }
  }

  /// Creates a new audit log entry
  /// Returns "success" on successful creation, "error" on failure
  Future<String> createAuditLog({
    required String userId,
    required String userName,
    required String userRole,
    required String action,
    required String actionType,
    required String severity,
    required String details,
  }) async {
    try {

      // Generate unique audit log ID
      final auditLogId = 'al${DateTime.now().millisecondsSinceEpoch}';
      final auditLog = AuditLog(
        id: auditLogId,
        userId: userId,
        userName: userName,
        userRole: userRole,
        action: action,
        timestamp: DateTime.now(),
        details: details,
        actionType: actionType,
        severity: severity,
      );

      // Save audit log to Firestore
      await _firestore.collection(_auditLogsCollection).doc(auditLogId).set({
        'userId': userId,
        'userName': userName,
        'userRole': userRole,
        'action': action,
        'timestamp': Timestamp.fromDate(auditLog.timestamp),
        'details': details,
        'actionType': actionType,
        'severity': severity,
      });
      return "success";
    } catch (e) {
      // Log error and return error status
      print('Error creating audit log: $e');
      return "error";
    }
  }

  /// Deletes an audit log entry (admin only)
  /// Returns "success" on successful deletion, "error" on failure
  Future<String> deleteAuditLog({
    required String auditLogId,
    required BuildContext context,
  }) async {
    try {
      // Check if user is admin
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user?.role != 'admin') {
        throw Exception('Only admins can delete audit logs');
      }

      // Check if audit log exists
      final doc = await _firestore.collection(_auditLogsCollection).doc(auditLogId).get();
      if (!doc.exists) {
        throw Exception('Audit log not found');
      }

      // Delete audit log from Firestore
      await _firestore.collection(_auditLogsCollection).doc(auditLogId).delete();
      return "success";
    } catch (e) {
      // Log error and return error status
      print('Error deleting audit log: $e');
      return "error";
    }
  }
}