"""
inject_voices.py
Automatically inserts [voice path="..."] events before matching narration lines
in Dialogic timeline (.dtl) files.

Voice file names are partial matches of the narration text they belong to.
A narration line is any line that does NOT start with a character name (no "Name: " pattern)
and is not a Dialogic command (no "[", "if ", "elif ", "else:", "set ", "join ", etc.)

Usage: python inject_voices.py
"""

import os
import re

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
VOICE_DIR = os.path.join(BASE_DIR, "assets", "audio", "voice")
TIMELINE_DIR = os.path.join(BASE_DIR, "content", "timelines")

# Map timeline scene IDs to voice subdirectory paths (relative to VOICE_DIR)
# Format: "scene_id" -> "relative/path/in/voice/dir"
SCENE_VOICE_MAP = {
    # Chapter 1
    "Chapter 1/c1s1": "Chapter 1/c1s1",
    "Chapter 1/c1s2": "Chapter 1/c1s2",
    "Chapter 1/c1s2b": "Chapter 1/c1s2b",
    "Chapter 1/c1s3": "Chapter 1/c1s3",
    "Chapter 1/c1s4": "Chapter 1/c1s4",
    "Chapter 1/c1s5": "Chapter 1/c1s5",
    # Chapter 2
    "Chapter 2/c2s0": "Chapter 2/c2s0 mathilda COUNCIL_ROOM",
    "Chapter 2/c2s1": "Chapter 2/c2s1 mathilda HALLWAY",
    "Chapter 2/c2s2": "Chapter 2/c2s2 narrator mathilda",
    "Chapter 2/c2s3": "Chapter 2/c2s3 narrator mathilda",
    "Chapter 2/c2s4": "Chapter 2/c2s4 mathilda",
    "Chapter 2/c2s5": "Chapter 2/c2s5 mathilda",
    "Chapter 2/c2s6": "Chapter 2/c2s6 mathilda",
    # Chapter 3
    "Chapter 3/c3s0": "Chapter 3/c3s0",
    "Chapter 3/c3s1": "Chapter 3/c3s1",
    "Chapter 3/c3s2": "Chapter 3/c3s2",
    "Chapter 3/c3s3": "Chapter 3/c3s3",
    "Chapter 3/c3s4": "Chapter 3/c3s4",
    "Chapter 3/c3s5": "Chapter 3/c3s5",
    "Chapter 3/c3s6": "Chapter 3/c3s6",
    # Chapter 4
    "Chapter 4/c4s0": "Chapter 4/C4S0",
    "Chapter 4/c4s1": "Chapter 4/C4S1",
    "Chapter 4/c4s2": "Chapter 4/C4S2",
    "Chapter 4/c4s3": "Chapter 4/C4S3",
    "Chapter 4/c4s4": "Chapter 4/c4S4",
    "Chapter 4/c4s5": "Chapter 4/C4S5",
    "Chapter 4/c4s6": "Chapter 4/C4S6",
    # Chapter 5
    "Chapter 5/c5s0": "Chapter 5/C5S0",
    "Chapter 5/c5s1": "Chapter 5/C5S1",
    "Chapter 5/c5s2": "Chapter 5/c5s2",
    "Chapter 5/c5s3": "Chapter 5/c5s3",
    "Chapter 5/c5s4": "Chapter 5/C5S4",
    "Chapter 5/c5s5": "Chapter 5/C5S5",
}

# Lines that are NOT narration (skip voice injection)
COMMAND_PREFIXES = (
    "[", "if ", "elif ", "else:", "set ", "join ", "leave ", "update ",
    "jump ", "label ", "-", "#", "...", "wait ", "call "
)

def is_narration_line(line: str) -> bool:
    """Returns True if line is a narrator line (not a command or character dialogue)."""
    stripped = line.strip()
    if not stripped:
        return False
    # Skip commands
    for prefix in COMMAND_PREFIXES:
        if stripped.startswith(prefix):
            return False
    # Skip character dialogue lines like "Conrad: ..." or "Mark: ..."
    if re.match(r'^[A-Za-z\s"\'\.]+:', stripped):
        return False
    return True

def normalize(text: str) -> str:
    """Normalize text for matching: lowercase, strip punctuation/whitespace."""
    text = text.lower()
    text = re.sub(r'[\\\[\](){}]', '', text)       # remove escape chars and brackets
    text = re.sub(r'\[b\]|\[/b\]|\[i\]|\[/i\]|\[wave\]|\[/wave\]', '', text)  # bbcode
    text = re.sub(r'\s+', ' ', text)
    text = text.strip()
    return text

def load_voice_files(voice_subdir: str) -> list[tuple[str, str]]:
    """
    Load all .mp3 files from a voice subdirectory.
    Returns list of (normalized_name, full_res_path) tuples.
    """
    full_path = os.path.join(VOICE_DIR, voice_subdir)
    if not os.path.isdir(full_path):
        return []
    entries = []
    for fname in os.listdir(full_path):
        if fname.lower().endswith(".mp3"):
            name_no_ext = os.path.splitext(fname)[0]
            normalized = normalize(name_no_ext)
            # Build res:// path
            rel = os.path.join("assets", "audio", "voice", voice_subdir, fname)
            res_path = "res://" + rel.replace("\\", "/")
            entries.append((normalized, res_path))
    return entries

def find_voice_for_line(narration: str, voice_files: list[tuple[str, str]]) -> str | None:
    """
    Find the best matching voice file for a narration line.
    Returns the res:// path or None.
    """
    norm_narr = normalize(narration)
    best_match = None
    best_score = 0

    for (vname, vpath) in voice_files:
        # Check if voice file name is a substring of the narration (or vice versa)
        if vname in norm_narr or norm_narr in vname:
            score = len(vname)
            if score > best_score:
                best_score = score
                best_match = vpath

    return best_match

def process_timeline(dtl_path: str, voice_subdir: str) -> int:
    """
    Process a single .dtl file, inserting [voice] events before matching narration lines.
    Returns number of voice lines injected.
    """
    voice_files = load_voice_files(voice_subdir)
    if not voice_files:
        print(f"  [SKIP] No voice files found in: {voice_subdir}")
        return 0

    with open(dtl_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    new_lines = []
    injected = 0
    already_has_voice_above = False

    for i, line in enumerate(lines):
        stripped = line.rstrip("\n")

        # Don't double-inject: skip if previous meaningful line was already a [voice]
        if stripped.strip().startswith("[voice "):
            already_has_voice_above = True
            new_lines.append(line)
            continue

        if is_narration_line(stripped):
            # Check if the line above was already a [voice] tag
            # (look at new_lines backwards skipping empty lines)
            prev_voice = False
            for prev in reversed(new_lines):
                ps = prev.strip()
                if ps:
                    prev_voice = ps.startswith("[voice ")
                    break

            if not prev_voice:
                match = find_voice_for_line(stripped, voice_files)
                if match:
                    # Preserve indentation
                    indent = len(line) - len(line.lstrip())
                    indent_str = line[:indent]
                    new_lines.append(f'{indent_str}[voice path="{match}" volume=0 bus="Master"]\n')
                    injected += 1

        already_has_voice_above = False
        new_lines.append(line)

    if injected > 0:
        with open(dtl_path, "w", encoding="utf-8") as f:
            f.writelines(new_lines)
        print(f"  [OK] {os.path.basename(dtl_path)}: injected {injected} voice line(s)")
    else:
        print(f"  [--] {os.path.basename(dtl_path)}: no matches found")

    return injected

def find_voice_subdir(chapter_key: str) -> str | None:
    """Try to find the voice subdirectory even if exact folder name differs."""
    # First try exact match from map
    if chapter_key in SCENE_VOICE_MAP:
        return SCENE_VOICE_MAP[chapter_key]
    return None

def main():
    total = 0
    for chapter in ["Chapter 1", "Chapter 2", "Chapter 3", "Chapter 4", "Chapter 5"]:
        chapter_timeline_dir = os.path.join(TIMELINE_DIR, chapter)
        if not os.path.isdir(chapter_timeline_dir):
            continue
        print(f"\n=== {chapter} ===")
        for fname in sorted(os.listdir(chapter_timeline_dir)):
            if not fname.endswith(".dtl"):
                continue
            scene_id = os.path.splitext(fname)[0]  # e.g. "c1s1"
            key = f"{chapter}/{scene_id}"
            voice_subdir = find_voice_subdir(key)
            dtl_path = os.path.join(chapter_timeline_dir, fname)
            if voice_subdir:
                total += process_timeline(dtl_path, voice_subdir)
            else:
                print(f"  [???] {fname}: no voice directory mapping found (key={key})")

    print(f"\nDone! Total voice lines injected: {total}")

if __name__ == "__main__":
    main()
