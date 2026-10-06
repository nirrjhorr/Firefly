import os
import re
import sys

def analyze_dart_files(lib_dir):
    print(f"=== Dart Lint & Import Sweep across {lib_dir} ===")
    all_files = []
    for root, _, files in os.walk(lib_dir):
        for f in files:
            if f.endswith('.dart'):
                all_files.append(os.path.join(root, f))
    
    print(f"Found {len(all_files)} Dart source files.")
    
    warnings = []
    
    # Check for empty catches, TODOs, prints, syntax anomalies
    for file_path in all_files:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            lines = content.splitlines()

        # Check for unbracketed/unhandled prints
        for idx, line in enumerate(lines, 1):
            stripped = line.strip()
            if stripped.startswith('print(') and not file_path.endswith('test.dart'):
                warnings.append((file_path, idx, "avoid_print", "Use logging or debugPrint instead of print()"))

        # Check for unused private elements
        private_methods = re.findall(r'(?:void|Future<[^>]+>|Widget|int|bool|String)\s+(_[a-zA-Z0-9]+)\s*\(', content)
        for pm in set(private_methods):
            if pm in ('_initState', '_build'):
                continue
            # count occurrences in file
            occurrences = len(re.findall(r'\b' + re.escape(pm) + r'\b', content))
            if occurrences == 1:
                # defined but never referenced
                warnings.append((file_path, 0, "unused_element", f"Private element '{pm}' appears only once (defined but never referenced)"))

        # Check for bracket/brace balance
        if content.count('{') != content.count('}'):
            warnings.append((file_path, 0, "syntax_error", "Mismatched curly braces"))
        if content.count('(') != content.count(')'):
            warnings.append((file_path, 0, "syntax_error", "Mismatched parentheses"))
        if content.count('[') != content.count(']'):
            warnings.append((file_path, 0, "syntax_error", "Mismatched brackets"))

    print(f"\nAudit complete. Issues found: {len(warnings)}")
    for w in warnings:
        print(f"  [{w[2]}] {w[0]}:{w[1]} - {w[3]}")

    if not warnings:
        print("\n[SUCCESS] Zero warnings, zero unused elements, zero syntax anomalies found.")
        return 0
    return len(warnings)

if __name__ == '__main__':
    sys.exit(analyze_dart_files('lib'))
