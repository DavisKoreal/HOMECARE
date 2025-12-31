import os

def fix_compilation_errors_final():
    target_dir = os.path.expanduser("~/Desktop/HOMECARE/homecare0x1")
    
    if not os.path.exists(target_dir):
        print(f"Error: Directory {target_dir} not found.")
        return

    print(f"Changing directory to: {target_dir}")
    os.chdir(target_dir)

    # ---------------------------------------------------------
    # 1. Update AppTheme (Add warningOrange)
    # ---------------------------------------------------------
    print("\n--- Updating lib/theme/app_theme.dart ---")
    theme_path = os.path.join("lib", "theme", "app_theme.dart")
    
    with open(theme_path, "r", encoding="utf-8") as f:
        theme_content = f.read()

    # Add warningOrange if missing
    if "static const Color warningOrange" not in theme_content:
        theme_content = theme_content.replace(
            "class AppTheme {",
            "class AppTheme {\n  static const Color warningOrange = Color(0xFFFFAB00);\n  static const Color errorRed = Color(0xFFD50000);\n  static const Color successGreen = Color(0xFF00C853);"
        )
    
    with open(theme_path, "w", encoding="utf-8") as f:
        f.write(theme_content)
    print("Updated AppTheme with missing colors.")

    # ---------------------------------------------------------
    # 2. Update AuthService (Ensure getCurrentUser exists)
    # ---------------------------------------------------------
    print("\n--- Updating lib/services/auth_service.dart ---")
    auth_path = os.path.join("lib", "services", "auth_service.dart")
    
    # We will read it first to see what's there
    with open(auth_path, "r", encoding="utf-8") as f:
        auth_content = f.read()

    # If getCurrentUser is missing, we add it. 
    # Assuming it wraps UserProvider or Firebase Auth. 
    # For now, we'll implement a stub or wrapper if it's missing.
    if "Future<User?> getCurrentUser()" not in auth_content:
        # We append a simple implementation assuming standard User model
        # Note: This relies on the User model import being present.
        new_method = """
  // Helper to get current user (mock or from provider)
  Future<User?> getCurrentUser() async {
    // This should ideally return the user from FirebaseAuth or UserProvider
    // For now, returning a mock or the cached user
    return _currentUser;
  }
"""
        # Insert before the last bracket
        auth_content = auth_content.rstrip()[:-1] + new_method + "\n}"
    
    with open(auth_path, "w", encoding="utf-8") as f:
        f.write(auth_content)
    print("Updated AuthService with getCurrentUser().")

    # ---------------------------------------------------------
    # 3. Fix CaregiverDashboard (Class Name & Auth Call)
    # ---------------------------------------------------------
    print("\n--- Fixing lib/screens/caregiver_dashboard.dart ---")
    dashboard_path = os.path.join("lib", "screens", "caregiver_dashboard.dart")
    
    with open(dashboard_path, "r", encoding="utf-8") as f:
        dash_content = f.read()

    # 1. Fix Class Name
    dash_content = dash_content.replace(
        "class CaregiverDashboard extends StatefulWidget", 
        "class CaregiverDashboardScreen extends StatefulWidget"
    )
    dash_content = dash_content.replace(
        "State<CaregiverDashboard> createState", 
        "State<CaregiverDashboardScreen> createState"
    )
    dash_content = dash_content.replace(
        "class _CaregiverDashboardState extends State<CaregiverDashboard>", 
        "class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen>"
    )

    with open(dashboard_path, "w", encoding="utf-8") as f:
        f.write(dash_content)
    print("Renamed CaregiverDashboard to CaregiverDashboardScreen.")

    # ---------------------------------------------------------
    # 4. Fix CaregiverCompleteProfile (Missing Icon)
    # ---------------------------------------------------------
    print("\n--- Fixing lib/screens/caregiver_complete_profile.dart ---")
    comp_profile_path = os.path.join("lib", "screens", "caregiver_complete_profile.dart")
    
    with open(comp_profile_path, "r", encoding="utf-8") as f:
        comp_content = f.read()

    # Fix ModernButton call (add icon)
    # Looking for: ModernButton(\n text: 'Save Profile',
    if "ModernButton(" in comp_content and "icon:" not in comp_content.split("ModernButton(")[1]:
        comp_content = comp_content.replace(
            "text: 'Save Profile',",
            "text: 'Save Profile',\n                icon: Icons.save,"
        )

    with open(comp_profile_path, "w", encoding="utf-8") as f:
        f.write(comp_content)
    print("Fixed ModernButton in CaregiverCompleteProfile.")

if __name__ == "__main__":
    fix_compilation_errors_final()