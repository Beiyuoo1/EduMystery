#!/usr/bin/env python3
"""
Convert narrator dialogues from 3rd person to 2nd person perspective.
This is a careful conversion that preserves:
- Character dialogue (Conrad: / Celestine:)
- Dialogic commands (join, leave, update, etc.)
- Character names when used as proper nouns
"""

import re
import os
from pathlib import Path

def is_dialogic_command_line(line):
    """Check if line is a Dialogic command"""
    stripped = line.strip()
    # Commands like join, leave, update, set, if, elif, else, signal, etc.
    dialogic_commands = ['join', 'leave', 'update', 'set ', 'if ', 'elif ', 'else', 'label ',
                         'jump ', '[', 'signal', '-', 'background', 'wait', 'voice']
    return any(stripped.startswith(cmd) for cmd in dialogic_commands)

def is_character_dialogue(line):
    """Check if line is character speaking (Name: or Name (expression):)"""
    stripped = line.strip()
    # Match pattern: "CharacterName: " or "CharacterName (expression): "
    return re.match(r'^[A-Z][a-z]+(\s+[A-Z][a-z]+)*\s*(\([^)]*\))?\s*:', stripped) is not None

def convert_narration_line(line):
    """Convert a narration line to 2nd person"""
    original = line

    # Skip if it's a command or dialogue
    if is_dialogic_command_line(line) or is_character_dialogue(line):
        return line

    # Skip empty lines
    if not line.strip():
        return line

    # Patterns for conversion (order matters!)

    # Step 1: Convert possessives
    line = re.sub(r'\bConrad\'s\b', 'your', line)
    line = re.sub(r'\bCelestine\'s\b', 'your', line)

    # Step 2: Convert "his/her" possessive (but not when it's part of a name)
    # "his best friend" → "your best friend"
    line = re.sub(r'\bhis\b(?!\s+name)', 'your', line)
    line = re.sub(r'\bher\b(?!\s+name)(?!\s+own)', 'your', line, flags=re.IGNORECASE)

    # Step 3: Convert pronouns in narrative context
    # Subject pronouns
    line = re.sub(r'\bHe\s+(walked|looked|noticed|examined|thought|felt|saw|heard|knew)', r'You \1', line)
    line = re.sub(r'\bShe\s+(walked|looked|noticed|examined|thought|felt|saw|heard|knew)', r'You \1', line)

    # Object pronouns
    line = re.sub(r'\s+him\b', ' you', line)
    line = re.sub(r'\s+her\b(?!\s+own)', ' you', line)

    # Step 4: Remove protagonist names in pure narration (but keep in dialogue references)
    # "Conrad walked" → "You walked"
    # But preserve "Conrad Santos" as a full name reference
    line = re.sub(r'\bConrad\s+(walked|looked|noticed|examined|thought|felt|saw|heard|knew|took|made|went|came|entered|left|approached|turned|found|realized|remembered|decided|began|continued|paused|stopped|tried|wanted|needed|seemed|appeared|became|remained|stayed)', r'You \1', line)
    line = re.sub(r'\bCelestine\s+(walked|looked|noticed|examined|thought|felt|saw|heard|knew|took|made|went|came|entered|left|approached|turned|found|realized|remembered|decided|began|continued|paused|stopped|tried|wanted|needed|seemed|appeared|became|remained|stayed)', r'You \1', line)

    # Step 5: Fix verb conjugations (3rd person → 2nd person)
    # "You walks" → "you walk"
    verbs_to_fix = [
        'walk', 'notice', 'examine', 'look', 'think', 'feel', 'see', 'hear', 'know',
        'say', 'ask', 'reply', 'respond', 'take', 'make', 'do', 'go', 'come',
        'enter', 'leave', 'approach', 'turn', 'find', 'realize', 'remember', 'decide',
        'begin', 'continue', 'pause', 'stop', 'try', 'want', 'need', 'seem', 'appear',
        'become', 'remain', 'stay', 'keep', 'hold', 'reach', 'pick', 'open', 'close',
        'read', 'write', 'speak', 'listen', 'watch', 'observe', 'study', 'analyze',
        'consider', 'wonder', 'believe', 'understand', 'follow', 'lead', 'wait',
        'stand', 'sit'
    ]

    for verb in verbs_to_fix:
        # "You walks" → "you walk"
        line = re.sub(rf'\byou {verb}s\b', f'you {verb}', line, flags=re.IGNORECASE)

    # Special verb fixes
    line = re.sub(r'\byou was\b', 'you were', line, flags=re.IGNORECASE)
    line = re.sub(r'\byou has\b', 'you have', line, flags=re.IGNORECASE)
    line = re.sub(r'\byou is\b', 'you are', line, flags=re.IGNORECASE)
    line = re.sub(r'\byou does\b', 'you do', line, flags=re.IGNORECASE)

    return line

def process_file(filepath):
    """Process a single .dtl file"""
    print(f"Processing: {filepath}")

    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"  [ERROR] Could not read file: {e}")
        return 0

    converted_lines = []
    changes_made = 0

    for line in lines:
        converted = convert_narration_line(line)
        if converted != line:
            changes_made += 1
        converted_lines.append(converted)

    if changes_made > 0:
        try:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.writelines(converted_lines)
            print(f"  [OK] Made {changes_made} changes")
        except Exception as e:
            print(f"  [ERROR] Could not write file: {e}")
            return 0
    else:
        print(f"  [--] No changes needed")

    return changes_made

def main():
    """Main conversion process"""
    timeline_dir = Path("content/timelines")

    if not timeline_dir.exists():
        print(f"Error: Directory '{timeline_dir}' not found!")
        return

    print("=" * 70)
    print("CONVERTING NARRATOR DIALOGUES TO 2ND PERSON (CAREFUL MODE)")
    print("=" * 70)
    print()
    print("This script converts narration from 3rd person to 2nd person ('you').")
    print("It preserves:")
    print("  - Character dialogue (Conrad:/Celestine:)")
    print("  - Dialogic commands (join, leave, update, etc.)")
    print("  - Character names in dialogue contexts")
    print()

    total_files = 0
    total_changes = 0

    # Process all .dtl files in Chapters only (skip Unused)
    for chapter_dir in ['Chapter 1', 'Chapter 2', 'Chapter 3', 'Chapter 4', 'Chapter 5']:
        chapter_path = timeline_dir / chapter_dir
        if not chapter_path.exists():
            continue

        print(f"\n--- {chapter_dir} ---")
        for dtl_file in chapter_path.glob("*.dtl"):
            changes = process_file(dtl_file)
            total_files += 1
            total_changes += changes

    print()
    print("=" * 70)
    print(f"CONVERSION COMPLETE")
    print(f"Files processed: {total_files}")
    print(f"Total changes: {total_changes}")
    print("=" * 70)
    print()
    print("IMPORTANT: Voice recordings will need to be re-recorded to match.")
    print("The text now uses 2nd person perspective ('you' instead of names).")
    print()
    print("Please test the game to ensure narration reads naturally!")

if __name__ == "__main__":
    main()
