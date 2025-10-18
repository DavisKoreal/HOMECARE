// lib/services/client_service.dart
// Service class for handling all Firestore operations related to the Client model.
// Manages clients in the 'clients' collection, with audit logging for changes.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homecare0x1/models/client.dart';
import 'package:homecare0x1/services/auditlog_service.dart';

class FirebaseClientService {
  // Singleton instance for global access.
  static final FirebaseClientService instance =
      FirebaseClientService._constructor();

  // Firestore instance for database operations.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection name for clients in Firestore.
  final String _clientsCollection = 'clients';

  // Audit log service for tracking changes.
  final FirebaseAuditLogService _auditLogService =
      FirebaseAuditLogService.instance;

  // Private constructor to enforce singleton pattern.
  FirebaseClientService._constructor();

  /// Fetches a single client by ID.
  /// Returns the Client object if found, null otherwise.
  Future<Client?> getClient(String clientId) async {
    try {
      final doc =
          await _firestore.collection(_clientsCollection).doc(clientId).get();
      if (doc.exists) {
        return Client(
          id: doc.id,
          name: doc.data()!['name'] ?? '',
          email: doc.data()!['email'] ?? '',
          address: doc.data()!['address'] ?? '',
          carePlan: doc.data()!['carePlan'] ?? '',
        );
      }
      return null;
    } catch (e) {
      print('Error fetching client: $e');
      return null;
    }
  }

  /// Fetches all clients from the database.
  /// Returns a list of Client objects, empty on error.
  Future<List<Client>> getAllClients() async {
    try {
      final snapshot = await _firestore.collection(_clientsCollection).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Client(
          id: doc.id,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          address: data['address'] ?? '',
          carePlan: data['carePlan'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error fetching all clients: $e');
      return [];
    }
  }

  /// Searches for clients by partial name match.
  /// Returns a list of matching Client objects, empty if none found.
  Future<List<Client>> searchClientsByName(String partialName) async {
    try {
      final snapshot = await _firestore
          .collection(_clientsCollection)
          .where('name', isGreaterThanOrEqualTo: partialName)
          .where('name',
              isLessThanOrEqualTo:
                  partialName + '\uf8ff') // Unicode trick for prefix search.
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Client(
          id: doc.id,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          address: data['address'] ?? '',
          carePlan: data['carePlan'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error searching clients: $e');
      return [];
    }
  }

  /// Creates a new client in the database.
  /// Returns the ID of the created client on success, or an error message on failure.
  /// Logs the creation action.
  Future<String> createClient(Client client) async {
    try {
      final docRef = await _firestore.collection(_clientsCollection).add({
        'name': client.name,
        'email': client.email,
        'address': client.address,
        'carePlan': client.carePlan,
      });

      // Log the creation action.
      await _auditLogService.createAuditLog(
        userId: client.id, // Use a system/admin ID if client.id is empty.
        userName: 'system',
        userRole: 'admin',
        action: 'Created new client: ${client.name}',
        actionType: 'client creation',
        severity: 'info',
        details: 'Client ID: ${docRef.id}, Email: ${client.email}',
      );

      return docRef.id;
    } catch (e) {
      print('Error creating client: $e');
      return 'Error: $e';
    }
  }

  /// Updates an existing client by ID.
  /// Returns 'success' on update, or an error message on failure.
  /// Logs the update action.
  Future<String> updateClient(Client client) async {
    try {
      await _firestore.collection(_clientsCollection).doc(client.id).update({
        'name': client.name,
        'email': client.email,
        'address': client.address,
        'carePlan': client.carePlan,
      });

      // Log the update action.
      await _auditLogService.createAuditLog(
        userId: client.id,
        userName: client.name,
        userRole: 'client',
        action: 'Updated client: ${client.name}',
        actionType: 'client update',
        severity: 'info',
        details:
            'Client ID: ${client.id}, Changes: Address and Care Plan updated',
      );

      return 'success';
    } catch (e) {
      print('Error updating client: $e');
      return 'Error: $e';
    }
  }

  /// Deletes a client by ID.
  /// Returns 'success' on deletion, or an error message on failure.
  /// Logs the deletion action.
  Future<String> deleteClient(String clientId) async {
    try {
      // Fetch client name for logging before deletion.
      final client = await getClient(clientId);
      if (client == null) {
        return 'Error: Client not found';
      }

      await _firestore.collection(_clientsCollection).doc(clientId).delete();

      // Log the deletion action.
      await _auditLogService.createAuditLog(
        userId: 'system',
        userName: 'admin',
        userRole: 'admin',
        action: 'Deleted client: ${client.name}',
        actionType: 'client deletion',
        severity: 'warning',
        details: 'Client ID: $clientId',
      );

      return 'success';
    } catch (e) {
      print('Error deleting client: $e');
      return 'Error: $e';
    }
  }
}
