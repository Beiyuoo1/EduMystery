#!/usr/bin/env python3
"""
Inject [voice] tags into Dialogic timeline (.dtl) files for Chapters 2-5.
"""
import os
import re

BASE = r"c:\Users\Admin\OneDrive\Documents\edu-mys-dev"
VOICE_BASE = os.path.join(BASE, "assets", "audio", "voice")
TIMELINE_BASE = os.path.join(BASE, "content", "timelines")

# Scene → (dtl_path, voice_folder, res_path)
SCENE_MAP = [
    # Chapter 2
    ("Chapter 2", "c2s0.dtl", "Chapter 2/c2s0 mathilda COUNCIL_ROOM"),
    ("Chapter 2", "c2s1.dtl", "Chapter 2/c2s1 mathilda HALLWAY"),
    ("Chapter 2", "c2s2.dtl", "Chapter 2/c2s2 narrator mathilda"),
    ("Chapter 2", "c2s3.dtl", "Chapter 2/c2s3 narrator mathilda"),
    ("Chapter 2", "c2s4.dtl", "Chapter 2/c2s4 mathilda"),
    ("Chapter 2", "c2s5.dtl", "Chapter 2/c2s5 mathilda"),
    ("Chapter 2", "c2s6.dtl", "Chapter 2/c2s6 mathilda"),
    # Chapter 3
    ("Chapter 3", "c3s0.dtl", "Chapter 3/c3s0"),
    ("Chapter 3", "c3s1.dtl", "Chapter 3/c3s1"),
    ("Chapter 3", "c3s2.dtl", "Chapter 3/c3s2"),
    ("Chapter 3", "c3s3.dtl", "Chapter 3/c3s3"),
    ("Chapter 3", "c3s4.dtl", "Chapter 3/c3s4"),
    ("Chapter 3", "c3s5.dtl", "Chapter 3/c3s5"),
    ("Chapter 3", "c3s6.dtl", "Chapter 3/c3s6"),
    # Chapter 4
    ("Chapter 4", "c4s0.dtl", "Chapter 4/C4S0"),
    ("Chapter 4", "c4s1.dtl", "Chapter 4/C4S1"),
    ("Chapter 4", "c4s2.dtl", "Chapter 4/C4S2"),
    ("Chapter 4", "c4s3.dtl", "Chapter 4/C4S3"),
    ("Chapter 4", "c4s4.dtl", "Chapter 4/c4S4"),
    ("Chapter 4", "c4s5.dtl", "Chapter 4/C4S5"),
    ("Chapter 4", "c4s6.dtl", "Chapter 4/C4S6"),
    # Chapter 5
    ("Chapter 5", "c5s0.dtl", "Chapter 5/C5S0"),
    ("Chapter 5", "c5s1.dtl", "Chapter 5/C5S1"),
    ("Chapter 5", "c5s2.dtl", "Chapter 5/c5s2"),
    ("Chapter 5", "c5s3.dtl", "Chapter 5/c5s3"),
    ("Chapter 5", "c5s4.dtl", "Chapter 5/C5S4"),
    ("Chapter 5", "c5s5.dtl", "Chapter 5/C5S5"),
]

# These prefixes indicate a line is NOT narration
COMMAND_PREFIXES = (
    '[', 'if ', 'elif ', 'else:', 'set ', 'join ', 'leave ', 'update ',
    'jump ', 'label ', '-', '#', '...',
)

# ElevenLabs timestamp pattern: hex chars + underscore + word
ELEVENLABS_PATTERN = re.compile(r'^[a-f0-9]{10,}_\w+\.mp3$', re.IGNORECASE)

def is_narration(line):
    stripped = line.strip()
    if not stripped:
        return False
    # Check command prefixes
    for prefix in COMMAND_PREFIXES:
        if stripped.startswith(prefix):
            return False
    # Check character dialogue: "Name:" at start
    if re.match(r'^[A-Za-z][A-Za-z\s\.\-]*:', stripped):
        return False
    return True

def is_elevenlabs(filename):
    return bool(ELEVENLABS_PATTERN.match(filename))

def process_scene(chapter_folder, dtl_name, voice_rel_path):
    dtl_path = os.path.join(TIMELINE_BASE, chapter_folder, dtl_name)
    voice_dir = os.path.join(VOICE_BASE, *voice_rel_path.split('/'))
    res_voice_base = "res://assets/audio/voice/" + voice_rel_path.replace('\\', '/')

    if not os.path.exists(dtl_path):
        print(f"  DTL NOT FOUND: {dtl_path}")
        return 0

    if not os.path.exists(voice_dir):
        print(f"  VOICE DIR NOT FOUND: {voice_dir}")
        return 0

    # Get mp3 files, skip ElevenLabs timestamp ones
    mp3_files = []
    for f in os.listdir(voice_dir):
        if f.endswith('.mp3'):
            if is_elevenlabs(f):
                print(f"  SKIP ElevenLabs: {f}")
                continue
            mp3_files.append(f)

    if not mp3_files:
        print(f"  No MP3 files found in {voice_dir}")
        return 0

    with open(dtl_path, 'r', encoding='utf-8') as fh:
        lines = fh.readlines()

    injections = 0
    result_lines = list(lines)
    offset = 0  # track line offset as we insert

    for mp3_file in sorted(mp3_files):
        search_text = mp3_file[:-4]  # strip .mp3
        # Normalize apostrophes: file uses _s for 's
        search_normalized = search_text.replace("_s ", "'s ").replace("_s'", "'s'")
        res_path = res_voice_base + "/" + mp3_file

        # Find all matching narration lines in original lines (use index in result_lines)
        matched_indices = []
        for i, line in enumerate(lines):
            if not is_narration(line):
                continue
            line_content = line.strip()
            # Try both original and normalized search
            if (search_text.lower() in line_content.lower() or
                    search_normalized.lower() in line_content.lower()):
                matched_indices.append(i)

        for orig_idx in matched_indices:
            result_idx = orig_idx + offset
            # Check if voice tag already on previous line
            if result_idx > 0:
                prev = result_lines[result_idx - 1].strip()
                if prev.startswith('[voice '):
                    print(f"  SKIP (already injected): {mp3_file} -> line {orig_idx+1}")
                    continue
            # Get indentation from the narration line
            narration_line = result_lines[result_idx]
            indent = len(narration_line) - len(narration_line.lstrip())
            indent_str = narration_line[:indent]
            voice_tag = f'{indent_str}[voice path="{res_path}" volume=0 bus="Master"]\n'
            result_lines.insert(result_idx, voice_tag)
            offset += 1
            injections += 1
            print(f"  INJECT: {mp3_file} -> line {orig_idx+1}: {narration_line.strip()[:60]}")

    if injections > 0:
        with open(dtl_path, 'w', encoding='utf-8') as fh:
            fh.writelines(result_lines)

    return injections

total = 0
for chapter_folder, dtl_name, voice_rel in SCENE_MAP:
    print(f"\n=== {chapter_folder}/{dtl_name} ===")
    n = process_scene(chapter_folder, dtl_name, voice_rel)
    print(f"  Total injected: {n}")
    total += n

print(f"\n=== GRAND TOTAL: {total} voice tags injected ===")
