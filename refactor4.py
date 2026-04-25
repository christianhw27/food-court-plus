import os
import re

lib_dir = r"d:\Coolyeah\Mobile\foodcourtplus\lib"

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Clean up trailing garbage in AppNotification lines
    # E.g. AppNotification.showSuccess(context, 'message'), backgroundColor: Colors.green),
    # To   AppNotification.showSuccess(context, 'message');
    
    # We match AppNotification.show*(context, 'something') and remove anything after the ) until the newline
    
    # Replace AppNotification.show*(context, 'something'), backgroundColor: Colors... );
    content = re.sub(r"(AppNotification\.(?:showSuccess|showError|showInfo)\(context,\s*['\"][^'\"]*['\"]\))\s*,\s*backgroundColor:\s*Colors\.[a-zA-Z]+\s*\)\s*,", r"\1;", content)
    content = re.sub(r"(AppNotification\.(?:showSuccess|showError|showInfo)\(context,\s*[^,)]+\))\s*,\s*backgroundColor:\s*Colors\.[a-zA-Z]+\s*\)\s*,", r"\1;", content)

    # Clean up cases where there's an extra ),
    content = re.sub(r"(AppNotification\.(?:showSuccess|showError|showInfo)\(context,\s*['\"][^'\"]*['\"]\))\s*\)\s*,", r"\1;", content)
    content = re.sub(r"(AppNotification\.(?:showSuccess|showError|showInfo)\(context,\s*[^,)]+\))\s*\)\s*,", r"\1;", content)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

print("Fix 2 complete.")
