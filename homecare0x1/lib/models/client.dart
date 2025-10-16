class Client {
  final String id;
  final String name;
  final String email;
  final String address;
  final String carePlan;
  final String clientId;
  final DateTime dateOfBirth;
  final DateTime createdAt;

  Client({
    required this.id,
    required this.name,
    required this.address,
    required this.carePlan,
    required this.email,
    required this.clientId,
    required this.dateOfBirth,
    required this.createdAt,
  });

  // Factory constructor with default values for existing data
  factory Client.fromLegacyData({
    required String id,
    required String name,
    required String address,
    required String carePlan,
    required String email,
    required DateTime dateOfBirth,
  }) {
    return Client(
      id: id,
      name: name,
      address: address,
      carePlan: carePlan,
      email: email,
      clientId: 'CL0000', // Default client ID
      dateOfBirth: dateOfBirth,
      createdAt: DateTime.now(), // Default creation date
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'address': address,
      'carePlan': carePlan,
      'clientId': clientId,
      'dateOfBirth': dateOfBirth.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create from Firestore document
  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      address: map['address'],
      carePlan: map['carePlan'],
      clientId: map['clientId'] ?? 'CL0000',
      dateOfBirth: DateTime.fromMillisecondsSinceEpoch(map['dateOfBirth'] ?? DateTime(1950).millisecondsSinceEpoch),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }

  // Copy with method for updates
  Client copyWith({
    String? id,
    String? name,
    String? email,
    String? address,
    String? carePlan,
    String? clientId,
    DateTime? dateOfBirth,
    DateTime? createdAt,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
      carePlan: carePlan ?? this.carePlan,
      clientId: clientId ?? this.clientId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}