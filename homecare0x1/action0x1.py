import os
import subprocess
import re
import sys

def setup_ui_refactor():
    # 1. Set Target Directory
    target_dir = os.path.expanduser("~/Desktop/HOMECARE/homecare0x1")
    
    if not os.path.exists(target_dir):
        print(f"Error: Directory {target_dir} not found.")
        return

    print(f"Changing directory to: {target_dir}")
    os.chdir(target_dir)

    # 2. Git Branch: ui-refactor
    print("--- Git Operations ---")
    try:
        # Check if branch exists
        result = subprocess.run(["git", "branch", "--list", "ui-refactor"], capture_output=True, text=True)
        if "ui-refactor" in result.stdout:
            print("Branch 'ui-refactor' exists. Switching to it...")
            subprocess.run(["git", "checkout", "ui-refactor"], check=True)
        else:
            print("Creating and switching to new branch: ui-refactor")
            subprocess.run(["git", "checkout", "-b", "ui-refactor"], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Git error: {e}")
        return

    # 3. Add Dependencies (Google Fonts)
    print("\n--- Adding Dependencies ---")
    try:
        # Check if google_fonts is already in pubspec
        with open("pubspec.yaml", "r") as f:
            if "google_fonts:" not in f.read():
                print("Adding google_fonts package...")
                subprocess.run(["flutter", "pub", "add", "google_fonts"], shell=True, check=True)
            else:
                print("google_fonts already present.")
    except Exception as e:
        print(f"Error checking/adding dependencies: {e}")

    # 4. Create Theme File
    print("\n--- Creating Theme File ---")
    theme_dir = os.path.join("lib", "theme")
    os.makedirs(theme_dir, exist_ok=True)
    
    theme_content = """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 1. Color Palette (Homebase/SaaS Style)
  static const Color primaryPurple = Color(0xFF7B16FF);
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color backgroundCanvas = Color(0xFFF4F5F7);
  static const Color borderGray = Color(0xFFDFE6E9);
  
  // 2. The Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundCanvas,
      colorScheme: ColorScheme.light(
        primary: primaryPurple,
        surface: Colors.white,
        onSurface: textPrimary,
      ),
      // Use Inter font for that clean SaaS look
      textTheme: GoogleFonts.interTextTheme(),
      
      // 3. Button Styles
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: borderGray),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      
      // 4. Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: borderGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: borderGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: primaryPurple, width: 2),
        ),
      ),
    );
  }
}
"""
    with open(os.path.join(theme_dir, "app_theme.dart"), "w", encoding="utf-8") as f:
        f.write(theme_content)
    print("Successfully wrote lib/theme/app_theme.dart")

    # 5. Rewrite Login Screen
    print("\n--- Refactoring Login Screen ---")
    login_path = os.path.join("lib", "screens", "login_screen.dart")
    
    login_content = """import 'package:flutter/material.dart';
import 'package:homecare0x1/services/auth_service.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:provider/provider.dart';
import 'package:homecare0x1/screens/signup_screen.dart';
import 'package:homecare0x1/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // SaaS Layout: Center box on a plain background
    return Scaffold(
      backgroundColor: AppTheme.backgroundCanvas,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 450, // Fixed width for desktop/web look
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderGray),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Logo/Brand Section
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.favorite, color: AppTheme.primaryPurple, size: 32),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'homecare',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome back',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 2. Email Field
                  Text('Email', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'name@company.com',
                      prefixIcon: Icon(Icons.email_outlined, size: 20),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 3. Password Field
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Password', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {}, 
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero, 
                          minimumSize: Size.zero, 
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap
                        ),
                        child: const Text('Forgot password?', style: TextStyle(fontSize: 12)),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your password';
                      return null;
                    },
                  ),

                  // 4. Error Message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, size: 18, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // 5. Primary Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Log In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 6. Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: TextStyle(color: AppTheme.textSecondary)),
                      GestureDetector(
                        onTap: () {
                           Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpScreen()),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: AppTheme.primaryPurple,
                            fontWeight: FontWeight.bold,
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
    );
  }
}
"""
    with open(login_path, "w", encoding="utf-8") as f:
        f.write(login_content)
    print("Successfully rewritten lib/screens/login_screen.dart")

    # 6. Update main.dart
    print("\n--- Updating main.dart ---")
    main_path = os.path.join("lib", "main.dart")
    
    if os.path.exists(main_path):
        with open(main_path, "r", encoding="utf-8") as f:
            main_code = f.read()

        # Add Import
        if "import 'package:homecare0x1/theme/app_theme.dart';" not in main_code:
            # Find the last import and append
            imports = re.findall(r"import .*?;", main_code)
            if imports:
                last_import = imports[-1]
                main_code = main_code.replace(last_import, last_import + "\nimport 'package:homecare0x1/theme/app_theme.dart';")
            else:
                main_code = "import 'package:homecare0x1/theme/app_theme.dart';\n" + main_code
            print("Added app_theme import.")

        # Replace Theme
        # We look for 'theme: ...,' and replace it
        if "theme: AppTheme.lightTheme" not in main_code:
            if re.search(r"theme:\s*ThemeData\(.*?\),", main_code, re.DOTALL):
                main_code = re.sub(r"theme:\s*ThemeData\(.*?\),", "theme: AppTheme.lightTheme,", main_code, flags=re.DOTALL)
                print("Replaced ThemeData.")
            elif re.search(r"theme:\s*[^,]+,", main_code): 
                # Catch generic theme: ...
                main_code = re.sub(r"theme:\s*[^,]+,", "theme: AppTheme.lightTheme,", main_code)
                print("Replaced generic theme property.")
            elif "MaterialApp(" in main_code:
                 main_code = main_code.replace("MaterialApp(", "MaterialApp(\n      theme: AppTheme.lightTheme,", 1)
                 print("Inserted theme property.")

        with open(main_path, "w", encoding="utf-8") as f:
            f.write(main_code)
        print("Successfully updated lib/main.dart")
    else:
        print("Error: lib/main.dart not found.")

    print("\n---------------------------------------------------------")
    print("Refactor Complete.")
    print("Run 'flutter run -d chrome' to see the new Homebase-style Login.")

if __name__ == "__main__":
    setup_ui_refactor()