import os
import re

lib_dir = r"d:\Coolyeah\Mobile\foodcourtplus\lib"

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # We want to fix malformed AppNotification calls.
    # E.g. AppNotification.showSuccess(context, 'Pilih gambar terlebih dahulu', backgroundColor: Colors.red,);
    # To AppNotification.showError(context, 'Pilih gambar terlebih dahulu');
    
    # Also fix multiline issues where the closing parenthesis was missed.
    # Actually, the simplest fix is to just run a regex that captures everything after the string until the closing parenthesis and semicolon.
    
    # Fix: AppNotification.showSuccess(context, 'string', ... );
    content = re.sub(r"AppNotification\.showSuccess\(context,\s*'([^']*)'[^)]*\);", r"AppNotification.showSuccess(context, '\1');", content)
    content = re.sub(r'AppNotification\.showSuccess\(context,\s*"([^"]*)"[^)]*\);', r'AppNotification.showSuccess(context, "\1");', content)
    
    content = re.sub(r"AppNotification\.showError\(context,\s*'([^']*)'[^)]*\);", r"AppNotification.showError(context, '\1');", content)
    content = re.sub(r'AppNotification\.showError\(context,\s*"([^"]*)"[^)]*\);', r'AppNotification.showError(context, "\1");', content)
    
    content = re.sub(r"AppNotification\.showInfo\(context,\s*'([^']*)'[^)]*\);", r"AppNotification.showInfo(context, '\1');", content)
    content = re.sub(r'AppNotification\.showInfo\(context,\s*"([^"]*)"[^)]*\);', r'AppNotification.showInfo(context, "\1");', content)
    
    # Also fix: AppNotification.showError(context, e.toString().replaceAll('Exception: ', ''), backgroundColor: Colors.red);
    content = re.sub(r"AppNotification\.showError\(context,\s*([^,]*e\.toString\(\)[^,]*)[^)]*\);", r"AppNotification.showError(context, \1);", content)

    # Let's clean up orphaned closing parentheses that the previous script left.
    # E.g.
    # AppNotification.showSuccess(context, 'Berhasil');
    #       ),
    #     );
    # This is tricky. 
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

print("Fixing complete.")
