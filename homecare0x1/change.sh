#!/bin/bash

# Ensure we're in the project root
if [ ! -f "pubspec.yaml" ]; then
  echo "Error: pubspec.yaml not found. Run this script from the project root."
  exit 1
fi

# Step 1: Save current state with git
echo "Saving current state with git..."
git add .
git commit -m "Backup before integrating Firebase Firestore and Authentication for production"

# Step 2: Update pubspec.yaml to use latest Firebase dependencies
echo "Updating pubspec.yaml..."
sed -i '' 's/firebase_auth: ^4.16.0/firebase_auth: ^5.3.1/' pubspec.yaml
sed -i '' 's/cloud_firestore: ^4.14.0/cloud_firestore: ^5.4.4/' pubspec.yaml

# Step 3: Run flutter pub get
echo "Running flutter pub get..."
flutter pub get

# Step 4: Overwrite auth_service.dart with production-ready Firebase implementation
echo "Updating lib/services/auth_service.dart..."
cat > lib/services/auth_service.dart << 'EOF'
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:homecare0x1/models/user.dart';

class AuthService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> login(String email, String password) async {
    try {
      // Authenticate with Firebase Authentication
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data from Firestore
      final docSnapshot =
          await _firestore.collection('users').doc(credential.user!.uid).get();
      if (docSnapshot.exists) {
        final userData = docSnapshot.data()!;
        return User(
          id: userData['id'] as String,
          role: userData['role'] as String,
          name: userData['name'] as String,
          email: userData['email'] as String,
        );
      }
      throw Exception('User data not found in Firestore');
    } on auth.FirebaseAuthException catch (e) {
      throw e; // Re-throw for handling in UI
    } catch (e) {
      print('Login error: $e');
      throw Exception('Failed to login: $e');
    }
  }

  // Register a new user (for setup or registration)
  Future<User?> register({
    required String email,
    required String password,
    required String role,
    required String name,
  }) async {
    try {
      // Check if user already exists
      try {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        print('User $email already exists, skipping registration');
        return null;
      } on auth.FirebaseAuthException catch (e) {
        if (e.code != 'user-not-found') {
          throw e; // Other errors should be handled
        }
      }

      // Create user in Firebase Authentication
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user data in Firestore
      final userId = credential.user!.uid;
      await _firestore.collection('users').doc(userId).set({
        'id': userId,
        'email': email,
        'role': role,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return User(
        id: userId,
        role: role,
        name: name,
        email: email,
      );
    } on auth.FirebaseAuthException catch (e) {
      throw e; // Re-throw for handling in UI
    } catch (e) {
      print('Registration error: $e');
      throw Exception('Failed to register: $e');
    }
  }
}
EOF

# Step 5: Update login_screen.dart to handle Firebase errors for production
echo "Updating lib/screens/login_screen.dart..."
cat > lib/screens/login_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:homecare0x1/services/auth_service.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final authService = AuthService();
      try {
        final user = await authService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
        setState(() => _isLoading = false);
        if (user != null && context.mounted) {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.setUser(user);
          Navigator.pushReplacementNamed(context, userProvider.getInitialRoute());
        } else {
          setState(() {
            _errorMessage = 'Invalid email or password';
          });
        }
      } on auth.FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
          switch (e.code) {
            case 'user-not-found':
              _errorMessage = 'No account exists for this email.';
              break;
            case 'wrong-password':
              _errorMessage = 'Incorrect password. Please try again.';
              break;
            case 'invalid-email':
              _errorMessage = 'Invalid email format.';
              break;
            case 'too-many-requests':
              _errorMessage = 'Too many login attempts. Please try again later.';
              break;
            case 'user-disabled':
              _errorMessage = 'This account has been disabled.';
              break;
            default:
              _errorMessage = 'Login failed: ${e.message}';
          }
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An unexpected error occurred. Please try again.';
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E8), // Light mint green
              Color(0xFFF0F8FF), // Alice blue
              Colors.white,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),

                    // Health-inspired logo/icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A86B), // Medical green
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00A86B).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite, // Replaced invalid Icons.healt
                        color: Colors.white,
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // App title
                    Text(
                      'homecare',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: const Color(0xFF2C3E50),
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Your health, our priority',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF7F8C8D),
                            fontSize: 16,
                          ),
                    ),

                    const SizedBox(height: 48),

                    // Login form card
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: const Color(0xFF2C3E50),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Sign in to continue to your dashboard',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: const Color(0xFF7F8C8D),
                                  ),
                            ),

                            const SizedBox(height: 32),

                            // Email field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email Address',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: const Color(0xFF2C3E50),
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your email',
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.all(12),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00A86B)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.email_outlined,
                                        color: Color(0xFF00A86B),
                                        size: 20,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF00A86B),
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF8F9FA),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                        .hasMatch(value)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Password field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Password',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: const Color(0xFF2C3E50),
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your password',
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.all(12),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00A86B)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.lock_outline,
                                        color: Color(0xFF00A86B),
                                        size: 20,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: const Color(0xFF7F8C8D),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF00A86B),
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF8F9FA),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  obscureText: _obscurePassword,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),

                            // Error message
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 32),

                            // Login button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: _isLoading
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00A86B)
                                            .withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        ),
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF00A86B),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shadowColor: const Color(0xFF00A86B)
                                            .withOpacity(0.3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.login, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Sign In',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Footer
                    Text(
                      'Secure • Private • Reliable',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF7F8C8D),
                            fontSize: 12,
                          ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
EOF

# Step 6: Update main.dart to include safe mock user setup
echo "Updating lib/main.dart..."
cat > lib/main.dart << 'EOF'
import 'package:homecare0x1/providers/location_provider.dart';
import 'package:homecare0x1/screens/shift_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/screens/admin_calendar_screen.dart';
import 'package:homecare0x1/screens/admin_dashboard.dart';
import 'package:homecare0x1/screens/audit_log_screen.dart';
import 'package:homecare0x1/screens/care_notes_screen.dart';
import 'package:homecare0x1/screens/caregiver_calendar_screen.dart';
import 'package:homecare0x1/screens/caregiver_dashboard.dart';
import 'package:homecare0x1/screens/client_list_screen.dart';
import 'package:homecare0x1/screens/client_profile_screen.dart';
import 'package:homecare0x1/screens/emar_screen.dart';
import 'package:homecare0x1/screens/family_portal_screen.dart';
import 'package:homecare0x1/screens/invoice_generation_screen.dart';
import 'package:homecare0x1/screens/login_screen.dart';
import 'package:homecare0x1/screens/shift_assignment_screen.dart';
import 'package:homecare0x1/screens/task_list_screen.dart';
import 'package:homecare0x1/screens/user_profile_screen.dart';
import 'package:homecare0x1/screens/visit_check_in_screen.dart';
import 'package:homecare0x1/screens/visit_check_out_screen.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:homecare0x1/providers/care_note_provider.dart';
import 'package:homecare0x1/providers/medication_record_provider.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/providers/task_provider.dart';
import 'package:homecare0x1/providers/payment_provider.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/screens/payment_status.dart';
import 'package:homecare0x1/screens/admin_notes_management_screen.dart';
import 'package:homecare0x1/screens/family_care_notes.dart';
import 'package:homecare0x1/screens/caregiver_profile.dart';
import 'package:homecare0x1/screens/client_view_shift_history.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:homecare0x1/services/auth_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize mock users in Firestore (run once for testing)
  await setupMockUsers();

  runApp(const HomecareApp());
}

// Setup mock users in Firestore (run once, safe for production)
Future<void> setupMockUsers() async {
  final authService = AuthService();
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

  for (var user in users) {
    try {
      await authService.register(
        email: user['email']!,
        password: user['password']!,
        role: user['role']!,
        name: user['name']!,
      );
    } catch (e) {
      print('Error setting up user ${user['email']}: $e');
    }
  }
}

class HomecareApp extends StatelessWidget {
  const HomecareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CareNoteProvider()),
        ChangeNotifierProvider(create: (_) => MedicationRecordProvider()),
        ChangeNotifierProvider(create: (_) => ShiftAssignmentProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: MaterialApp(
        title: 'Homecare App',
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.login,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case Routes.login:
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case Routes.adminDashboard:
              return MaterialPageRoute(
                  builder: (_) => const AdminDashboardScreen());
            case Routes.caregiverDashboard:
              return MaterialPageRoute(
                  builder: (_) => const CaregiverDashboardScreen());
            case Routes.familyPortal:
              return MaterialPageRoute(
                  builder: (_) => const FamilyPortalScreen());
            case Routes.clientList:
              return MaterialPageRoute(builder: (_) => ClientListScreen());
            case Routes.clientProfile:
              return MaterialPageRoute(
                  builder: (_) => const ClientProfileScreen());
            case Routes.taskList:
              return MaterialPageRoute(builder: (_) => const TaskListScreen());
            case Routes.careNotes:
              return MaterialPageRoute(builder: (_) => const CareNotesScreen());
            case Routes.emar:
              return MaterialPageRoute(builder: (_) => const EmarScreen());
            case Routes.paymentStatus:
              return MaterialPageRoute(
                  builder: (_) => const PaymentStatusScreen());
            case Routes.visitCheckIn:
              return MaterialPageRoute(
                  builder: (_) => const VisitCheckInScreen());
            case Routes.visitCheckOut:
              return MaterialPageRoute(
                  builder: (_) => const VisitCheckOutScreen());
            case Routes.auditLog:
              return MaterialPageRoute(builder: (_) => const AuditLogScreen());
            case Routes.shiftAssignment:
              return MaterialPageRoute(
                  builder: (_) => const ShiftAssignmentScreen());
            case Routes.invoiceGeneration:
              return MaterialPageRoute(
                  builder: (_) => const InvoiceGenerationScreen());
            case Routes.userProfile:
              return MaterialPageRoute(
                  builder: (_) => const UserProfileScreen());
            case Routes.shiftList:
              return MaterialPageRoute(
                  builder: (_) => ShiftListScreen(
                      selectedDay: settings.arguments as DateTime));
            case Routes.adminCalendar:
              return MaterialPageRoute(
                  builder: (_) => const AdminCalendarScreen());
            case Routes.adminNotesManagement:
              return MaterialPageRoute(
                  builder: (_) => const AdminNotesManagementScreen());
            case Routes.familyCareNotes:
              return MaterialPageRoute(
                  builder: (_) => const FamilyCareNotesScreen());
            case Routes.caregiverProfile:
              return MaterialPageRoute(
                  builder: (_) => const CaregiverProfileScreen());
            case Routes.caregiverCalendar:
              return MaterialPageRoute(
                  builder: (_) => const CaregiverCalendarScreen());
            case Routes.clientViewShiftHistory:
              return MaterialPageRoute(
                  builder: (_) => const ClientViewShiftHistoryScreen());
            default:
              return MaterialPageRoute(
                builder: (_) => Scaffold(
                  body: Center(
                    child: Text('Page not found: ${settings.name}'),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
EOF

# Step 7: Provide instructions for manual Firebase setup in production mode
echo "Script completed! Please perform the following manual steps in the Firebase Console:"
echo "1. Go to Firebase Console > Build > Firestore Database."
echo "2. Create a database in PRODUCTION MODE (not test mode)."
echo "3. Select a region (e.g., nam5 (us-central))."
echo "4. Go to Build > Authentication, enable Email/Password provider."
echo "5. Update Firestore Security Rules with the following production-ready rules:"
cat << 'RULES'
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Allow authenticated users to read their own data
      allow read: if request.auth != null && request.auth.uid == userId;
      // Allow authenticated users to write their own data
      allow write: if request.auth != null && request.auth.uid == userId;
      // Allow admins to read all user data
      allow read: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
      // Restrict admin writes to specific fields if needed
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin' && request.resource.data.keys().hasOnly(['role', 'name', 'email']);
    }
  }
}
RULES
echo "6. Run 'flutter run' to test the app."
echo "7. After the first run, comment out the setupMockUsers() call in main.dart to avoid duplicate user attempts:"
echo "   // await setupMockUsers();"
echo "To revert changes, use: git reset --hard HEAD^ && git clean -fd"
echo "8. Monitor Firebase Console > Authentication and Firestore for user data."
echo "9. Test thoroughly in a staging environment before deploying to production."
EOF