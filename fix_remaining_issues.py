#!/usr/bin/env python3
"""
Fix all remaining known issues from the narration conversion.
"""

import re
from pathlib import Path

def fix_file(filepath):
    """Fix all issues in a single file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except:
        return 0

    original = content
    changes = 0

    # Fix "to your" -> "to you"
    new_content = re.sub(r'\bto your([.\s,])', r'to you\1', content)
    if new_content != content:
        changes += content.count('to your') - new_content.count('to your')
        content = new_content

    # Fix "hear your" -> "hear you"
    new_content = re.sub(r'\bhear your([.\s])', r'hear you\1', content)
    if new_content != content:
        changes += 1
        content = new_content

    # Fix mixed pronouns in common patterns
    # "your... she" or "she... your" -> convert "she" to "you"
    lines = content.split('\n')
    for i, line in enumerate(lines):
        # Skip dialogue and commands
        if line.strip().startswith('[') or re.match(r'^[A-Z][a-z]+.*:', line.strip()):
            continue

        # Mixed pronoun fixes
        if re.search(r'\byour\b.*\bshe\b', line):
            lines[i] = re.sub(r'\bshe\b', 'you', line)
            changes += 1
        elif re.search(r'\bshe\b.*\byour\b', line):
            lines[i] = re.sub(r'\bshe\b', 'you', line)
            changes += 1

        if re.search(r'\byour\b.*\bhe\b', line):
            lines[i] = re.sub(r'\bhe\b', 'you', line)
            changes += 1
        elif re.search(r'\bhe\b.*\byour\b', line):
            lines[i] = re.sub(r'\bhe\b', 'you', line)
            changes += 1

    content = '\n'.join(lines)

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Fixed {filepath.name}: {changes} changes")
        return changes
    return 0

def main():
    timeline_dir = Path("content/timelines")

    print("=" * 70)
    print("FIXING REMAINING NARRATION ISSUES")
    print("=" * 70)
    print()

    total_changes = 0

    # Fix all chapter files
    for chapter in ['Chapter 1', 'Chapter 2', 'Chapter 3', 'Chapter 4', 'Chapter 5']:
        chapter_path = timeline_dir / chapter
        if not chapter_path.exists():
            continue

        print(f"\n--- {chapter} ---")
        for dtl_file in chapter_path.glob("*.dtl"):
            changes = fix_file(dtl_file)
            total_changes += changes

    print()
    print("=" * 70)
    print(f"TOTAL CHANGES: {total_changes}")
    print("=" * 70)
    print()
    print("Run 'python find_conversion_issues.py' to verify all issues are fixed.")

if __name__ == "__main__":
    main()
