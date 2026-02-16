#!/usr/bin/env python3
"""
Find specific grammatical issues in the converted narration.
This helps identify lines that need manual fixing.
"""

import re
from pathlib import Path

def find_issues_in_file(filepath):
    """Find common conversion issues in a file"""
    issues = []

    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except:
        return issues

    for line_num, line in enumerate(lines, 1):
        # Skip commands and dialogue
        if line.strip().startswith('[') or re.match(r'^[A-Z][a-z]+.*:', line.strip()):
            continue

        # Issue 1: "fascinated your" (should be "fascinated you")
        if re.search(r'\bfascinated your\b', line):
            issues.append({
                'file': filepath.name,
                'line': line_num,
                'issue': 'Wrong possessive: "fascinated your" -> should be "fascinated you"',
                'text': line.strip()
            })

        # Issue 2: Mixed pronouns (your + she/he in same sentence)
        if re.search(r'\byour\b.*\b(she|he)\b', line) or re.search(r'\b(she|he)\b.*\byour\b', line):
            issues.append({
                'file': filepath.name,
                'line': line_num,
                'issue': 'Mixed pronouns: Contains both "your" and "she/he"',
                'text': line.strip()
            })

        # Issue 3: "visible only to your" (should be "to you")
        if re.search(r'\bto your[.\s,]', line):
            issues.append({
                'file': filepath.name,
                'line': line_num,
                'issue': 'Wrong pronoun: "to your" -> should be "to you"',
                'text': line.strip()
            })

        # Issue 4: "hear your" at end (should be "hear you")
        if re.search(r'\bhear your[.\s]', line):
            issues.append({
                'file': filepath.name,
                'line': line_num,
                'issue': 'Wrong pronoun: "hear your" -> should be "hear you"',
                'text': line.strip()
            })

        # Issue 5: Other character's possessive changed to "your"
        # (Janitor's equipment, etc.)
        if re.search(r'(Janitor|Teacher|Student|Guard).*\byour\b', line):
            issues.append({
                'file': filepath.name,
                'line': line_num,
                'issue': 'Possible error: Changed other character\'s possessive to "your"',
                'text': line.strip()
            })

    return issues

def main():
    timeline_dir = Path("content/timelines")

    all_issues = []

    print("=" * 70)
    print("SCANNING FOR CONVERSION ISSUES")
    print("=" * 70)
    print()

    # Scan all chapter files
    for chapter in ['Chapter 1', 'Chapter 2', 'Chapter 3', 'Chapter 4', 'Chapter 5']:
        chapter_path = timeline_dir / chapter
        if not chapter_path.exists():
            continue

        for dtl_file in chapter_path.glob("*.dtl"):
            issues = find_issues_in_file(dtl_file)
            if issues:
                all_issues.extend(issues)

    # Display results
    if not all_issues:
        print("[OK] No obvious issues found!")
        print("However, manual review is still recommended.")
    else:
        print(f"Found {len(all_issues)} potential issues:")
        print()

        current_file = None
        for i, issue in enumerate(all_issues, 1):
            if issue['file'] != current_file:
                current_file = issue['file']
                print()
                print(f"--- {current_file} ---")
                print()

            print(f"Issue #{i}:")
            print(f"  Line {issue['line']}: {issue['issue']}")
            print(f"  Text: {issue['text'][:100]}...")
            print()

    print("=" * 70)
    print(f"TOTAL ISSUES FOUND: {len(all_issues)}")
    print("=" * 70)
    print()
    print("Please review these lines manually in the timeline files.")
    print("See NARRATOR_CONVERSION_GUIDE.md for fixing instructions.")

if __name__ == "__main__":
    main()
