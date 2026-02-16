#!/usr/bin/env python3
"""
Generate a detailed report of all narration changes from 3rd to 2nd person.
Shows before/after comparisons for manual review.
"""

import re
import subprocess
from pathlib import Path

def get_git_diff():
    """Get git diff for timeline files"""
    try:
        result = subprocess.run(
            ['git', 'diff', 'content/timelines/'],
            capture_output=True,
            text=True,
            encoding='utf-8'
        )
        return result.stdout
    except Exception as e:
        print(f"Error running git diff: {e}")
        return ""

def parse_diff_changes(diff_text):
    """Parse git diff output into structured changes"""
    changes = []
    current_file = None
    current_change = None

    for line in diff_text.split('\n'):
        # New file
        if line.startswith('diff --git'):
            if current_change:
                changes.append(current_change)
                current_change = None
            # Extract filename
            match = re.search(r'content/timelines/(.+?)\.dtl', line)
            if match:
                current_file = match.group(1)

        # Line removed (original)
        elif line.startswith('-') and not line.startswith('---'):
            if current_file and not line.startswith('--'):
                if current_change is None:
                    current_change = {
                        'file': current_file,
                        'before': [],
                        'after': []
                    }
                current_change['before'].append(line[1:])  # Remove '-' prefix

        # Line added (new)
        elif line.startswith('+') and not line.startswith('+++'):
            if current_file and current_change and not line.startswith('++'):
                current_change['after'].append(line[1:])  # Remove '+' prefix

        # Context separator - save current change
        elif line.startswith('@@') or line.startswith('diff'):
            if current_change and (current_change['before'] or current_change['after']):
                changes.append(current_change)
                current_change = None

    # Don't forget last change
    if current_change and (current_change['before'] or current_change['after']):
        changes.append(current_change)

    return changes

def format_change_report(changes):
    """Format changes into a readable report"""
    report = []
    report.append("=" * 80)
    report.append("NARRATOR DIALOGUE CONVERSION REPORT")
    report.append("3rd Person → 2nd Person Changes")
    report.append("=" * 80)
    report.append("")
    report.append("Total changes: " + str(len(changes)))
    report.append("")
    report.append("INSTRUCTIONS:")
    report.append("  - Review each change below")
    report.append("  - Fix any grammatical errors or awkward phrasing")
    report.append("  - Mark issues that need manual editing")
    report.append("  - Re-record voice narration to match the new text")
    report.append("")
    report.append("=" * 80)
    report.append("")

    current_file = None
    change_num = 0

    for change in changes:
        if change['file'] != current_file:
            current_file = change['file']
            report.append("")
            report.append("-" * 80)
            report.append(f"FILE: {current_file}.dtl")
            report.append("-" * 80)
            report.append("")

        change_num += 1

        report.append(f"Change #{change_num}:")
        report.append("")

        # Show before
        if change['before']:
            report.append("  BEFORE (3rd person):")
            for line in change['before']:
                report.append(f"    - {line}")

        # Show after
        if change['after']:
            report.append("  AFTER (2nd person):")
            for line in change['after']:
                report.append(f"    + {line}")

        report.append("")
        report.append("  [ ] Reviewed  [ ] Needs Fix  [ ] Voice Re-record Needed")
        report.append("")

    report.append("=" * 80)
    report.append("END OF REPORT")
    report.append("=" * 80)

    return '\n'.join(report)

def main():
    print("Generating change report...")
    print()

    # Get git diff
    diff_text = get_git_diff()

    if not diff_text:
        print("No changes found in git diff.")
        print("Make sure you've run the conversion script first.")
        return

    # Parse changes
    changes = parse_diff_changes(diff_text)

    # Generate report
    report = format_change_report(changes)

    # Save to file
    output_file = Path("NARRATION_CHANGES_REPORT.txt")
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(report)

    print(f"Report generated: {output_file}")
    print(f"Total changes documented: {len(changes)}")
    print()
    print("Open the report file to review all changes.")
    print("You can use the checkboxes to track your review progress.")

if __name__ == "__main__":
    main()
