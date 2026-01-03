import os

def fix_register_calls():
    target_dir = os.path.expanduser("~/Desktop/HOMECARE/homecare0x1")
    
    if not os.path.exists(target_dir):
        print(f"Error: Directory {target_dir} not found.")
        return

    print(f"Changing directory to: {target_dir}")
    os.chdir(target_dir)

    # ---------------------------------------------------------
    # 1. Fix lib/setup.dart
    # ---------------------------------------------------------
    print("\n--- Fixing lib/setup.dart ---")
    setup_path = os.path.join("lib", "setup.dart")
    
    with open(setup_path, "r", encoding="utf-8") as f:
        setup_content = f.read()

    # The current call looks like:
    # await authService.register(
    #   email: user['email']!,
    #   password: user['password']!,
    #   role: user['role']!,
    #   name: user['name']!,
    # );
    
    # We need to change it to positional:
    # await authService.register(
    #   user['email']!,
    #   user['password']!,
    #   user['name']!,
    #   user['role']!,
    # );

    # Regex replacement for robust handling of multiline calls
    # Note: AuthService signature is (email, password, name, role)
    if "await authService.register(" in setup_content:
        # We replace the specific named argument block with positional args
        setup_content = setup_content.replace(
            "email: user['email']!,",
            "user['email']!,"
        ).replace(
            "password: user['password']!,",
            "user['password']!,"
        ).replace(
            "role: user['role']!,",
            "user['name']!, // name is 3rd arg\n        user['role']!, // role is 4th arg" 
        ).replace(
            "name: user['name']!,",
            "" # Removed because we merged it above to correct order
        )
        
    with open(setup_path, "w", encoding="utf-8") as f:
        f.write(setup_content)
    print("Fixed register call in setup.dart")

    # ---------------------------------------------------------
    # 2. Fix lib/screens/signup_screen.dart
    # ---------------------------------------------------------
    print("\n--- Fixing lib/screens/signup_screen.dart ---")
    signup_path = os.path.join("lib", "screens", "signup_screen.dart")
    
    with open(signup_path, "r", encoding="utf-8") as f:
        signup_content = f.read()

    # Current call:
    # await authService.register(
    #   email: _emailController.text.trim(),
    #   password: _passwordController.text,
    #   role: _selectedRole!,
    #   name: _nameController.text.trim(),
    # );

    # Fix to positional: (email, password, name, role)
    if "await authService.register(" in signup_content:
        signup_content = signup_content.replace(
            "email: _emailController.text.trim(),",
            "_emailController.text.trim(),"
        ).replace(
            "password: _passwordController.text,",
            "_passwordController.text,"
        ).replace(
            "role: _selectedRole!,",
            "_nameController.text.trim(), // Name\n          _selectedRole!, // Role"
        ).replace(
            "name: _nameController.text.trim(),",
            ""
        )

    with open(signup_path, "w", encoding="utf-8") as f:
        f.write(signup_content)
    print("Fixed register call in signup_screen.dart")

if __name__ == "__main__":
    fix_register_calls()