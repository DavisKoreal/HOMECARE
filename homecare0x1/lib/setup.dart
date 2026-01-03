import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homecare0x1/services/auth_service.dart';

Future<void> setupMockData() async {
  final authService = AuthService();
  final firestore = FirebaseFirestore.instance;

  // Define mock users
  final users = [
    {
      'email': 'admin@example.com',
      'password': 'admin123',
      'role': 'admin',
      'name': 'Business Owner',
    },
    {
      'email': 'caregiver@example.com',
      'password': 'care123',
      'role': 'caregiver',
      'name': 'Kind Nurse',
    },
    {
      'email': 'family@example.com',
      'password': 'fam123',
      'role': 'family',
      'name': 'Family Member',
    },
  ];

  // Register users and get their IDs
  final userIds = <String, String>{}; // Map of email to user ID
  for (var user in users) {
    try {
      final existingUser = await firestore
          .collection('users')
          .where('email', isEqualTo: user['email'])
          .get();
      if (existingUser.docs.isNotEmpty) {
        userIds[user['email']!] = existingUser.docs.first.id;
        print('User ${user['email']} already exists, using ID: ${userIds[user['email']]}');
        continue;
      }

      final registeredUser = await authService.register(
        user['email']!,
        user['password']!,
        user['name']!, // name is 3rd arg
        user['role']!, // role is 4th arg
        
      );
      if (registeredUser != null) {
        userIds[user['email']!] = registeredUser.id;
        print('Registered user ${user['email']} with ID: ${registeredUser.id}');
      } else {
        print('Failed to register user ${user['email']}: Registration returned null');
      }
    } catch (e) {
      print('Error setting up user ${user['email']}: $e');
    }
  }

  // Define mock data for Firestore collections
  final adminId = userIds['admin@example.com'];
  final caregiverId = userIds['caregiver@example.com'];
  final familyId = userIds['family@example.com'];

  // Clients
  final clients = [
    {
      'id': 'f1',
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'address': '123 Elm St, Springfield',
      'carePlan': 'Daily care',
    },
    {
      'id': 'f2',
      'name': 'Jane Smith',
      'email': 'jane.smith@example.com',
      'address': '456 Oak Ave, Springfield',
      'carePlan': 'Weekly check-in',
    },
    {
      'id': 'f3',
      'name': 'Alice Johnson',
      'email': 'alice.johnson@example.com',
      'address': '789 Pine Rd, Springfield',
      'carePlan': 'Post-op care',
    },
  ];

  for (var client in clients) {
    try {
      final clientRef = firestore.collection('clients').doc(client['id']);
      final existingClient = await clientRef.get();
      if (!existingClient.exists) {
        await clientRef.set(client);
        print('Added client ${client['name']}');
      }
    } catch (e) {
      print('Error adding client ${client['name']}: $e');
    }
  }

  // Caregivers
  final caregivers = [
    if (caregiverId != null)
      {
        'id': caregiverId,
        'name': 'Kind Nurse',
        'isAvailable': true,
      },
    {
      'id': 'cg2',
      'name': 'Liam Brown',
      'isAvailable': true,
    },
    {
      'id': 'cg3',
      'name': 'Olivia Davis',
      'isAvailable': false,
    },
  ];

  for (var caregiver in caregivers) {
    try {
      final caregiverRef = firestore.collection('caregivers').doc(caregiver['id'] as String);
      final existingCaregiver = await caregiverRef.get();
      if (!existingCaregiver.exists) {
        await caregiverRef.set({
          'name': caregiver['name'],
          'isAvailable': caregiver['isAvailable'],
        });
        print('Added caregiver ${caregiver['name']}');
      }
    } catch (e) {
      print('Error adding caregiver ${caregiver['name']}: $e');
    }
  }

  // Caregiver Profiles
  final caregiverProfiles = [
    if (caregiverId != null)
      {
        'id': caregiverId,
        'name': 'Kind Nurse',
        'role': 'Senior Caregiver',
        'experience': '8 years',
        'certifications': ['CNA', 'CPR', 'First Aid'],
        'phone': '+1 (555) 123-4567',
        'email': 'kind.nurse@example.com',
        'bio': 'Dedicated caregiver with a passion for providing compassionate care to seniors. Experienced in managing daily activities, medication administration, and emotional support.',
        'availability': ['Monday-Friday', '9 AM - 5 PM'],
        'rating': 4.8,
        'reviews': 42,
      },
    {
      'id': 'cg2',
      'name': 'Liam Brown',
      'role': 'Care Assistant',
      'experience': '5 years',
      'certifications': ['CPR', 'Home Health Aide'],
      'phone': '+1 (555) 234-5678',
      'email': 'liam.brown@example.com',
      'bio': 'Experienced caregiver specializing in mobility assistance and daily living support.',
      'availability': ['Monday-Wednesday', '8 AM - 4 PM'],
      'rating': 4.5,
      'reviews': 30,
    },
    {
      'id': 'cg3',
      'name': 'Olivia Davis',
      'role': 'Nurse Aide',
      'experience': '3 years',
      'certifications': ['CNA', 'First Aid'],
      'phone': '+1 (555) 345-6789',
      'email': 'olivia.davis@example.com',
      'bio': 'Compassionate caregiver focused on patient comfort and well-being.',
      'availability': ['Thursday-Saturday', '10 AM - 6 PM'],
      'rating': 4.2,
      'reviews': 25,
    },
  ];

  for (var profile in caregiverProfiles) {
    try {
      final profileRef = firestore.collection('caregiver_profiles').doc(profile['id'] as String);
      final existingProfile = await profileRef.get();
      if (!existingProfile.exists) {
        await profileRef.set({
          'name': profile['name'],
          'role': profile['role'],
          'experience': profile['experience'],
          'certifications': profile['certifications'],
          'phone': profile['phone'],
          'email': profile['email'],
          'bio': profile['bio'],
          'availability': profile['availability'],
          'rating': profile['rating'],
          'reviews': profile['reviews'],
        });
        print('Added caregiver profile ${profile['name']}');
      }
    } catch (e) {
      print('Error adding caregiver profile ${profile['name']}: $e');
    }
  }

  // Shifts
  final shifts = [
    if (caregiverId != null)
      {
        'id': 's1',
        'clientId': 'f1',
        'clientName': 'John Doe',
        'startTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1, hours: 9))),
        'endTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1, hours: 11))),
        'caregiverId': caregiverId,
        'caregiverName': 'Kind Nurse',
        'status': 'completed',
        'location': {
          'latitude': 37.7749,
          'longitude': -122.4194,
        },
      },
    {
      'id': 's2',
      'clientId': 'f2',
      'clientName': 'Jane Smith',
      'startTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1, hours: 14))),
      'endTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1, hours: 16))),
      'status': 'pending',
      'location': {
        'latitude': 37.7749,
        'longitude': -122.4194,
      },
      'caregiverId': null,
      'caregiverName': null,
    },
    {
      'id': 's3',
      'clientId': 'f3',
      'clientName': 'Alice Johnson',
      'startTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 2, hours: 10))),
      'endTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 2, hours: 12))),
      'status': 'pending',
      'location': {
        'latitude': 37.7849,
        'longitude': -122.4094,
      },
      'caregiverId': null,
      'caregiverName': null,
    },
    if (caregiverId != null)
      {
        'id': 's4',
        'clientId': 'f1',
        'clientName': 'John Doe',
        'startTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2, hours: 9))),
        'endTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2, hours: 11))),
        'caregiverId': 'cg2',
        'caregiverName': 'Liam Brown',
        'status': 'completed',
        'location': {
          'latitude': 37.7749,
          'longitude': -122.4194,
        },
      },
  ];

  for (var shift in shifts) {
    try {
      final shiftRef = firestore.collection('shifts').doc(shift['id'] as String);
      final existingShift = await shiftRef.get();
      if (!existingShift.exists) {
        await shiftRef.set(shift);
        print('Added shift ${shift['id']}');
      }
    } catch (e) {
      print('Error adding shift ${shift['id']}: $e');
    }
  }

// Care Notes
final careNotes = [
  if (caregiverId != null)
    {
      'id': 'cn1',
      'clientId': 'f1',
      'caregiverId': caregiverId,
      'shiftId': 's1',
      'healthStatus': 'Stable, no new issues',
      'activities': 'Assisted with morning walk and meal prep',
      'observations': 'Client was cooperative',
      'medicationAdherence': 'Aspirin 100mg taken as prescribed',
      'mood': 'Cheerful',
      'note': 'Daily check completed',
      'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
      'isVisibleToClient': true,
      'isLate': false,
      'foodAndDrinks': 'Breakfast: Oatmeal and orange juice; Snack: Apple slices',
      'mealQuantityPercentage': 90,
      'hydrationMl': 500,
      'hasBowelMovement': true,
      'bowelMovementDescription': 'Normal, Bristol scale type 4',
      'bowelMovementFrequency': 0,
      'mobilityAndShower': 'Client walked 100 meters with walker; showered with assistance',
    },
  if (caregiverId != null)
    {
      'id': 'cn2',
      'clientId': 'f1',
      'caregiverId': caregiverId,
      'shiftId': 's4',
      'healthStatus': 'Slight fatigue reported',
      'activities': 'Helped with bathing and exercises',
      'observations': 'Client needed extra rest',
      'medicationAdherence': 'Lisinopril 10mg taken',
      'mood': 'Calm',
      'note': 'Evening check',
      'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
      'isVisibleToClient': false,
      'isLate': true,
      'foodAndDrinks': 'Dinner: Grilled chicken, vegetables, and water',
      'mealQuantityPercentage': 70,
      'hydrationMl': 300,
      'hasBowelMovement': false,
      'bowelMovementDescription': null,
      'bowelMovementFrequency': 1,
      'mobilityAndShower': 'Client required full assistance with bathing; limited mobility due to fatigue',
    },
];

  for (var note in careNotes) {
    try {
      final noteRef = firestore.collection('care_notes').doc(note['id'] as String);
      final existingNote = await noteRef.get();
      if (!existingNote.exists) {
        await noteRef.set(note);
        print('Added care note ${note['id']}');
      }
    } catch (e) {
      print('Error adding care note ${note['id']}: $e');
    }
  }

  // Medication Records
  final medicationRecords = [
    {
      'id': 'mr1',
      'clientId': 'f1',
      'medicationName': 'Aspirin',
      'dosage': '100mg',
      'administrationTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
      'notes': 'Taken with water',
    },
    {
      'id': 'mr2',
      'clientId': 'f1',
      'medicationName': 'Lisinopril',
      'dosage': '10mg',
      'administrationTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 4))),
      'notes': 'No side effects',
    },
  ];

  for (var record in medicationRecords) {
    try {
      final recordRef = firestore.collection('medication_records').doc(record['id'] as String);
      final existingRecord = await recordRef.get();
      if (!existingRecord.exists) {
        await recordRef.set(record);
        print('Added medication record ${record['id']}');
      }
    } catch (e) {
      print('Error adding medication record ${record['id']}: $e');
    }
  }

  // Payments
  final payments = [
    {
      'id': 'p1',
      'invoiceNumber': 'HC-2025-001',
      'amount': 850.0,
      'dueDate': Timestamp.fromDate(DateTime(2025, 2, 15)),
      'status': 'Pending',
      'description': 'January 2025 caregiving services',
      'servicePeriod': 'Jan 1-31, 2025',
      'hoursBilled': 120.0,
      'rate': 25.0,
    },
    {
      'id': 'p2',
      'invoiceNumber': 'HC-2024-012',
      'amount': 400.0,
      'dueDate': Timestamp.fromDate(DateTime(2025, 1, 10)),
      'status': 'Overdue',
      'description': 'December 2024 caregiving services',
      'servicePeriod': 'Dec 1-31, 2024',
      'hoursBilled': 80.0,
      'rate': 20.0,
    },
  ];

  for (var payment in payments) {
    try {
      final paymentRef = firestore.collection('payments').doc(payment['id'] as String);
      final existingPayment = await paymentRef.get();
      if (!existingPayment.exists) {
        await paymentRef.set(payment);
        print('Added payment ${payment['id']}');
      }
    } catch (e) {
      print('Error adding payment ${payment['id']}: $e');
    }
  }

  // Payment Methods
  final paymentMethods = [
    {
      'id': 'pm1',
      'title': 'Credit Card ending in 4532',
      'subtitle': 'Primary payment method',
      'color': 4281564955, // Color(0xFF3498DB).value
      'isDefault': true,
    },
    {
      'id': 'pm2',
      'title': 'Bank Account ending in 8901',
      'subtitle': 'Backup payment method',
      'color': 4279900933, // Color(0xFF16A085).value
      'isDefault': false,
    },
  ];

  for (var method in paymentMethods) {
    try {
      final methodRef = firestore.collection('payment_methods').doc(method['id'] as String);
      final existingMethod = await methodRef.get();
      if (!existingMethod.exists) {
        await methodRef.set(method);
        print('Added payment method ${method['id']}');
      }
    } catch (e) {
      print('Error adding payment method ${method['id']}: $e');
    }
  }

  // Tasks
  final tasks = [
    {
      'id': 't1',
      'title': 'Check Vitals',
      'dueDate': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 2))),
      'isCompleted': false,
      'clientId': 'f1',
      'clientName': 'John Doe',
      'description': 'Check blood pressure and heart rate',
    },
    {
      'id': 't2',
      'title': 'Medication Admin',
      'dueDate': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 4))),
      'isCompleted': true,
      'clientId': 'f1',
      'clientName': 'John Doe',
      'description': 'Administer morning medications',
    },
    {
      'id': 't3',
      'title': 'Physical Therapy',
      'dueDate': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 6))),
      'isCompleted': false,
      'clientId': 'f2',
      'clientName': 'Jane Smith',
      'description': 'Assist with mobility exercises',
    },
  ];

  for (var task in tasks) {
    try {
      final taskRef = firestore.collection('tasks').doc(task['id'] as String);
      final existingTask = await taskRef.get();
      if (!existingTask.exists) {
        await taskRef.set(task);
        print('Added task ${task['id']}');
      }
    } catch (e) {
      print('Error adding task ${task['id']}: $e');
    }
  }

  // add mock audit logs
  final auditLogs = [
    if (adminId != null)
      {
        'id': 'al1',
        'userId': adminId,
        'userName': 'Business Owner',
        'action': 'User Login',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 5))),
        'details': 'Admin logged into the system',
        'actionType': 'login',
        'severity': 'info',
      },
    if (caregiverId != null)
      {
        'id': 'al2',
        'userId': caregiverId,
        'userName': 'Kind Nurse',
        'action': 'Shift Completed',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 3))),
        'details': 'Completed shift for client John Doe on Jan 10, 2025',
        'actionType': 'data_change',
        'severity': 'info',
      },
    if (adminId != null)
      {
        'id': 'al3',
        'userId': adminId,
        'userName': 'Business Owner',
        'action': 'Password Change',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        'details': 'Changed password for user',
        'actionType': 'security',
        'severity': 'warning',
      },
  ];
  for (var log in auditLogs) {
    try {
      final logRef = firestore.collection('audit_logs').doc(log['id'] as String);
      final existingLog = await logRef.get();
      if (!existingLog.exists) {
        await logRef.set(log);
        print('Added audit log ${log['id']}');
      }
    } catch (e) {
      print('Error adding audit log ${log['id']}: $e');
    }
  }
  
}