import os
import re

def fix_constants_imports():
    target_dir = os.path.expanduser("~/Desktop/HOMECARE/homecare0x1")
    
    if not os.path.exists(target_dir):
        print(f"Error: Directory {target_dir} not found.")
        return

    print(f"Changing directory to: {target_dir}")
    os.chdir(target_dir)

    constants_path = os.path.join("lib", "constants.dart")
    print(f"Fixing import order in {constants_path}...")

    with open(constants_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    imports = []
    code_lines = []

    # Separate imports from code
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("import ") or stripped.startswith("export ") or stripped.startswith("library "):
            imports.append(line)
        else:
            code_lines.append(line)

    # De-duplicate imports
    imports = list(set(imports))
    
    # Reassemble content
    new_content = "".join(imports) + "\n" + "".join(code_lines)

    with open(constants_path, "w", encoding="utf-8") as f:
        f.write(new_content)
    
    print("Successfully reordered directives in lib/constants.dart")

if __name__ == "__main__":
    fix_constants_imports()