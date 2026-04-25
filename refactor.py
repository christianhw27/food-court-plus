import os
import re

lib_dir = r"d:\Coolyeah\Mobile\foodcourtplus\lib"

# Regex pattern to match ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('...')));
# We want to match: ScaffoldMessenger.of(context).showSnackBar( ... SnackBar(content: Text(...)) ... );
# This is hard because of nested parentheses.
# Instead of full regex, let's just find files containing ScaffoldMessenger.of(context).showSnackBar
# Then we will do manual string manipulation.

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    if 'ScaffoldMessenger.of(context).showSnackBar' not in content:
        return

    # Add import if needed
    import_stmt = "import '../../core/app_notification.dart';"
    # Count depth of folder to adjust relative import path
    parts = filepath.replace('\\', '/').split('/lib/')
    if len(parts) == 2:
        depth = parts[1].count('/')
        if depth == 0:
            import_stmt = "import 'core/app_notification.dart';"
        elif depth == 1:
            import_stmt = "import '../core/app_notification.dart';"
        elif depth == 2:
            import_stmt = "import '../../core/app_notification.dart';"
            
    if 'app_notification.dart' not in content and 'ScaffoldMessenger' in content:
        # insert after last import
        lines = content.split('\n')
        last_import = 0
        for i, line in enumerate(lines):
            if line.startswith('import '):
                last_import = i
        lines.insert(last_import + 1, import_stmt)
        content = '\n'.join(lines)

    # Let's replace simple instances: 
    # ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('message')));
    # ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('message')));
    # ScaffoldMessenger.of(context).showSnackBar(\n  const SnackBar(content: Text('message')),\n);
    
    # We will use regex for common cases.
    
    # Case 1: Single line or simple multiline
    pattern1 = re.compile(r'ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*(?:const\s*)?SnackBar\(\s*content:\s*Text\(\s*\'(.*?)\'\s*\)\s*\),?\s*\);', re.DOTALL)
    content = pattern1.sub(lambda m: f"AppNotification.showSuccess(context, '{m.group(1)}');", content)
    
    # Case 2: Using double quotes
    pattern2 = re.compile(r'ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*(?:const\s*)?SnackBar\(\s*content:\s*Text\(\s*"(.*?)"\s*\)\s*\),?\s*\);', re.DOTALL)
    content = pattern2.sub(lambda m: f'AppNotification.showSuccess(context, "{m.group(1)}");', content)
    
    # Case 3: Error messages with variables: SnackBar(content: Text('Error: $e'))
    pattern3 = re.compile(r'ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*(?:const\s*)?SnackBar\(\s*content:\s*Text\(\s*([^)]*Error[^)]*)\s*\)\s*\),?\s*\);', re.DOTALL)
    content = pattern3.sub(lambda m: f'AppNotification.showError(context, {m.group(1)});', content)

    # Case 4: Any other Text(...) inside
    pattern4 = re.compile(r'ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*(?:const\s*)?SnackBar\(\s*content:\s*Text\(\s*([^)]+)\s*\)\s*\),?\s*\);', re.DOTALL)
    content = pattern4.sub(lambda m: f'AppNotification.showInfo(context, {m.group(1)});', content)

    # Case 5: The one in setup_password_screen where it chains .showSnackBar(...) after ScaffoldMessenger.of(context)
    pattern5 = re.compile(r'\)\.showSnackBar\(\s*(?:const\s*)?SnackBar\(\s*content:\s*Text\(\s*\'(.*?)\'\s*\)\s*\),?\s*\);', re.DOTALL)
    content = pattern5.sub(lambda m: f");\n      AppNotification.showInfo(context, '{m.group(1)}');", content)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

print("Refactoring complete.")
