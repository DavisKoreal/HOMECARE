import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/client.dart';

class ClientProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Client> _clients = [];

  List<Client> get clients => _clients;

  // Generate client ID from client numbers (CL0001, CL0002, etc.)
  Future<String> _generateClientId() async {
    if (_clients.isEmpty) {
      await fetchClients(); // Ensure clients are loaded before generating ID
    }
    if (_clients.isEmpty) {
      return 'CL0001';
    }

    final numbers = _clients.map((client) {
      final match = RegExp(r'CL(\d+)').firstMatch(client.clientId);
      return match != null ? int.parse(match.group(1)!) : 0;
    }).toList();

    final maxNumber = numbers.reduce((a, b) => a > b ? a : b);
    final nextNumber = maxNumber + 1;
    return 'CL${nextNumber.toString().padLeft(4, '0')}';
  }

  // Add new client
  Future<void> addClient({
    required String name,
    required String email,
    required DateTime dateOfBirth,
    required String address,
    String carePlan = 'Standard Care',
  }) async {
    try {
      final String clientId = await _generateClientId();
      final String docId = DateTime.now().millisecondsSinceEpoch.toString();

      final Client newClient = Client(
        id: docId,
        name: name,
        email: email,
        clientId: clientId,
        dateOfBirth: dateOfBirth,
        address: address,
        carePlan: carePlan,
        createdAt: DateTime.now(),
      );

      // Add to Firestore
      await _firestore.collection('clients').doc(docId).set(newClient.toMap());

      // Update local state
      _clients.add(newClient);
      notifyListeners();
    } catch (error) {
      throw Exception('Failed to add client: $error');
    }
  }

  // Fetch all clients
  Future<void> fetchClients() async {
    try {
      final querySnapshot = await _firestore.collection('clients').get();
      _clients = querySnapshot.docs
          .map((doc) => Client.fromMap(doc.data()))
          .toList();
      notifyListeners();
    } catch (error) {
      throw Exception('Failed to fetch clients: $error');
    }
  }

  // Update existing client
  Future<void> updateClient(Client updatedClient) async {
    try {
      await _firestore.collection('clients').doc(updatedClient.id).set(updatedClient.toMap());

      final index = _clients.indexWhere((client) => client.id == updatedClient.id);
      if (index != -1) {
        _clients[index] = updatedClient;
        notifyListeners();
      }
    } catch (error) {
      throw Exception('Failed to update client: $error');
    }
  }

  // Delete client
  Future<void> deleteClient(String clientId) async {
    try {
      await _firestore.collection('clients').doc(clientId).delete();
      _clients.removeWhere((client) => client.id == clientId);
      notifyListeners();
    } catch (error) {
      throw Exception('Failed to delete client: $error');
    }
  }
}