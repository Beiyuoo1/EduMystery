#!/usr/bin/env python3
"""
Convert narrator dialogues from 3rd person (Conrad/Celestine) to 2nd person (you).
This script processes .dtl timeline files and converts protagonist references.
"""

import re
import os
from pathlib import Path

# Conversion mappings for Conrad
CONRAD_CONVERSIONS = [
    # Possessive
    (r'\bConrad\'s\b', 'your'),
    (r'\bHis\b', 'Your'),
    (r'\bhis\b', 'your'),

    # Pronouns (object)
    (r'\bhim\b', 'you'),
    (r'\bHim\b', 'You'),

    # Pronouns (subject) - must come after object pronouns
    (r'\bHe\b', 'You'),
    (r'\bhe\b', 'you'),

    # Direct name references
    (r'\bConrad\b', 'You'),
]

# Conversion mappings for Celestine
CELESTINE_CONVERSIONS = [
    # Possessive
    (r'\bCelestine\'s\b', 'your'),
    (r'\bHer\b', 'Your'),
    (r'\bher\b', 'your'),

    # Pronouns (object)
    (r'\bher\b', 'you'),  # This handles "to her", "with her"

    # Pronouns (subject)
    (r'\bShe\b', 'You'),
    (r'\bshe\b', 'you'),

    # Direct name references
    (r'\bCelestine\b', 'You'),
]

# Verb conjugation fixes (3rd person singular → 2nd person)
VERB_FIXES = [
    # Common verbs
    (r'\byou walks\b', 'you walk'),
    (r'\byou notices\b', 'you notice'),
    (r'\byou examines\b', 'you examine'),
    (r'\byou looks\b', 'you look'),
    (r'\byou thinks\b', 'you think'),
    (r'\byou feels\b', 'you feel'),
    (r'\byou sees\b', 'you see'),
    (r'\byou hears\b', 'you hear'),
    (r'\byou knows\b', 'you know'),
    (r'\byou says\b', 'you say'),
    (r'\byou asks\b', 'you ask'),
    (r'\byou replies\b', 'you reply'),
    (r'\byou responds\b', 'you respond'),
    (r'\byou takes\b', 'you take'),
    (r'\byou makes\b', 'you make'),
    (r'\byou does\b', 'you do'),
    (r'\byou goes\b', 'you go'),
    (r'\byou comes\b', 'you come'),
    (r'\byou enters\b', 'you enter'),
    (r'\byou leaves\b', 'you leave'),
    (r'\byou approaches\b', 'you approach'),
    (r'\byou turns\b', 'you turn'),
    (r'\byou finds\b', 'you find'),
    (r'\byou realizes\b', 'you realize'),
    (r'\byou remembers\b', 'you remember'),
    (r'\byou decides\b', 'you decide'),
    (r'\byou begins\b', 'you begin'),
    (r'\byou continues\b', 'you continue'),
    (r'\byou pauses\b', 'you pause'),
    (r'\byou stops\b', 'you stop'),
    (r'\byou tries\b', 'you try'),
    (r'\byou wants\b', 'you want'),
    (r'\byou needs\b', 'you need'),
    (r'\byou seems\b', 'you seem'),
    (r'\byou appears\b', 'you appear'),
    (r'\byou becomes\b', 'you become'),
    (r'\byou remains\b', 'you remain'),
    (r'\byou stays\b', 'you stay'),
    (r'\byou keeps\b', 'you keep'),
    (r'\byou holds\b', 'you hold'),
    (r'\byou reaches\b', 'you reach'),
    (r'\byou picks\b', 'you pick'),
    (r'\byou opens\b', 'you open'),
    (r'\byou closes\b', 'you close'),
    (r'\byou reads\b', 'you read'),
    (r'\byou writes\b', 'you write'),
    (r'\byou speaks\b', 'you speak'),
    (r'\byou listens\b', 'you listen'),
    (r'\byou watches\b', 'you watch'),
    (r'\byou observes\b', 'you observe'),
    (r'\byou studies\b', 'you study'),
    (r'\byou analyzes\b', 'you analyze'),
    (r'\byou considers\b', 'you consider'),
    (r'\byou wonders\b', 'you wonder'),
    (r'\byou believes\b', 'you believe'),
    (r'\byou understands\b', 'you understand'),
    (r'\byou follows\b', 'you follow'),
    (r'\byou leads\b', 'you lead'),
    (r'\byou waits\b', 'you wait'),
    (r'\byou stands\b', 'you stand'),
    (r'\byou sits\b', 'you sit'),

    # "You was" → "You were"
    (r'\byou was\b', 'you were'),
    (r'\bYou was\b', 'You were'),

    # "You has" → "You have"
    (r'\byou has\b', 'you have'),
    (r'\bYou has\b', 'You have'),

    # "You is" → "You are"
    (r'\byou is\b', 'you are'),
    (r'\bYou is\b', 'You are'),
]

def is_dialogue_line(line):
    """Check if a line is character dialogue (not narration)"""
    # Lines that start with character names followed by colon or parentheses
    if re.match(r'^[A-Z][a-z]+(\s+[A-Z][a-z]+)*\s*(\([^)]*\))?\s*:', line.strip()):
        return True
    # Lines inside conditional branches for character dialogue
    if line.strip().startswith('if ') or line.strip().startswith('elif ') or line.strip().startswith('else'):
        return True
    return False

def is_dialogic_command(line):
    """Check if line is a Dialogic command (like [signal], [voice], etc.)"""
    return line.strip().startswith('[') and line.strip().endswith(']')

def convert_line_to_second_person(line):
    """Convert a single narration line from 3rd person to 2nd person"""
    # Skip dialogue lines and Dialogic commands
    if is_dialogue_line(line) or is_dialogic_command(line):
        return line

    # Skip empty lines
    if not line.strip():
        return line

    original = line

    # Apply Conrad conversions
    for pattern, replacement in CONRAD_CONVERSIONS:
        line = re.sub(pattern, replacement, line)

    # Apply Celestine conversions
    for pattern, replacement in CELESTINE_CONVERSIONS:
        line = re.sub(pattern, replacement, line)

    # Fix verb conjugations
    for pattern, replacement in VERB_FIXES:
        line = re.sub(pattern, replacement, line, flags=re.IGNORECASE)

    return line

def process_file(filepath):
    """Process a single .dtl file"""
    print(f"Processing: {filepath}")

    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    converted_lines = []
    changes_made = 0

    for line in lines:
        converted = convert_line_to_second_person(line)
        if converted != line:
            changes_made += 1
        converted_lines.append(converted)

    if changes_made > 0:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(converted_lines)
        print(f"  [OK] Made {changes_made} changes")
    else:
        print(f"  [--] No changes needed")

    return changes_made

def main():
    """Main conversion process"""
    timeline_dir = Path("content/timelines")

    if not timeline_dir.exists():
        print(f"Error: Directory '{timeline_dir}' not found!")
        return

    print("=" * 60)
    print("CONVERTING NARRATOR DIALOGUES TO 2ND PERSON")
    print("=" * 60)
    print()

    total_files = 0
    total_changes = 0

    # Process all .dtl files recursively
    for dtl_file in timeline_dir.rglob("*.dtl"):
        changes = process_file(dtl_file)
        total_files += 1
        total_changes += changes

    print()
    print("=" * 60)
    print(f"CONVERSION COMPLETE")
    print(f"Files processed: {total_files}")
    print(f"Total changes: {total_changes}")
    print("=" * 60)
    print()
    print("Note: Voice recordings will need to be re-recorded to match the new text.")
    print("The text now uses 2nd person perspective ('you' instead of 'Conrad'/'Celestine').")

if __name__ == "__main__":
    main()
