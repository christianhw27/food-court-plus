import os

lib_dir = r"d:\Coolyeah\Mobile\foodcourtplus\lib"

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    if 'ScaffoldMessenger.of(context).showSnackBar' not in content:
        return

    # Let's find index of ScaffoldMessenger.of(context).showSnackBar(
    while 'ScaffoldMessenger.of(context).showSnackBar(' in content:
        start_idx = content.find('ScaffoldMessenger.of(context).showSnackBar(')
        
        # We need to find the matching closing parenthesis
        paren_count = 0
        end_idx = -1
        in_string = False
        string_char = ''
        
        for i in range(start_idx, len(content)):
            char = content[i]
            if not in_string:
                if char == '('     : paren_count += 1
                elif char == ')'   : paren_count -= 1
                elif char in ("'", '"'):
                    in_string = True
                    string_char = char
            else:
                if char == string_char and content[i-1] != '\\':
                    in_string = False
            
            if paren_count == 0 and char == ')':
                # find the semicolon after this
                semicolon_idx = content.find(';', i)
                end_idx = semicolon_idx + 1
                break
                
        if end_idx != -1:
            # We found the block: content[start_idx:end_idx]
            block = content[start_idx:end_idx]
            
            # Extract what's inside Text( ... )
            # Just do a rough extraction: find Text( and then its matching closing paren
            text_start = block.find('Text(')
            if text_start != -1:
                t_paren_count = 0
                t_end = -1
                for i in range(text_start, len(block)):
                    if block[i] == '(': t_paren_count += 1
                    elif block[i] == ')': t_paren_count -= 1
                    
                    if t_paren_count == 0 and block[i] == ')':
                        t_end = i
                        break
                
                if t_end != -1:
                    inner_text = block[text_start+5:t_end].strip()
                    # Check if it looks like an error
                    if 'error' in inner_text.lower() or 'gagal' in inner_text.lower() or 'e.toString' in inner_text:
                        replacement = f"AppNotification.showError(context, {inner_text});"
                    else:
                        replacement = f"AppNotification.showSuccess(context, {inner_text});"
                        
                    content = content[:start_idx] + replacement + content[end_idx:]
                else:
                    break
            else:
                break
        else:
            break

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

print("Refactoring 2 complete.")
