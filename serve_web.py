#!/usr/bin/env python3
"""
Simple local server for Godot web export.
Adds required CORS headers for SharedArrayBuffer (needed by Godot).
Also auto-patches web/index.html with AudioContext unlock on startup.
Run this script then open http://localhost:8080 in Chrome.
"""

import http.server
import socketserver
import os
import re
import shutil

PORT = 8080
ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
WEB_DIR = os.path.join(ROOT_DIR, "web")
INDEX_PATH = os.path.join(WEB_DIR, "index.html")

# Audio files to copy into web/ folder so browser Audio API can access them
# Format: (source_path_relative_to_project, destination_filename_in_web)
# In-game audio uses "audio_<name>.mp3" prefix to avoid collisions.
WEB_AUDIO_FILES = [
    # Main menu background music
    (os.path.join("Bg", "main menu bg music.mp3"), "bgmusic.mp3"),
    # In-game background music (Dialogic audio events)
    (os.path.join("assets", "audio", "bg", "suspicious.mp3"),   "audio_suspicious.mp3"),
    (os.path.join("assets", "audio", "bg", "suspicious2.mp3"),  "audio_suspicious2.mp3"),
    (os.path.join("assets", "audio", "bg", "suspicious3.mp3"),  "audio_suspicious3.mp3"),
    (os.path.join("assets", "audio", "bg", "chill.mp3"),        "audio_chill.mp3"),
    (os.path.join("assets", "audio", "bg", "chill2.mp3"),       "audio_chill2.mp3"),
    (os.path.join("assets", "audio", "bg", "chill3.mp3"),       "audio_chill3.mp3"),
    (os.path.join("assets", "audio", "bg", "controversy.mp3"),  "audio_controversy.mp3"),
    (os.path.join("assets", "audio", "bg", "sad.mp3"),          "audio_sad.mp3"),
    (os.path.join("assets", "audio", "bg", "night.mp3"),        "audio_night.mp3"),
    (os.path.join("assets", "audio", "bg", "final.mp3"),        "audio_final.mp3"),
    (os.path.join("assets", "audio", "bg", "Break it Down -elp version-.mp3"), "audio_breakitdown.mp3"),
    (os.path.join("assets", "audio", "bg", "Alleycat.mp3"),     "audio_alleycat.mp3"),
    # Chapter end and minigame music
    (os.path.join("assets", "audio", "chapter_end_bg.mp3"),     "audio_chapter_end_bg.mp3"),
    (os.path.join("assets", "audio", "minigame.mp3"),           "audio_minigame.mp3"),
    (os.path.join("assets", "audio", "comfortable-mystery-4.mp3"), "audio_comfortable_mystery.mp3"),
    # Sound effects (minigames + evidence unlock)
    (os.path.join("assets", "audio", "sound_effect", "correct.wav"),  "sfx_correct.wav"),
    (os.path.join("assets", "audio", "sound_effect", "wrong.wav"),    "sfx_wrong.wav"),
    (os.path.join("assets", "audio", "sound_effect", "clue_found.wav"), "sfx_clue_found.wav"),
    (os.path.join("assets", "audio", "sound_effect", "Vase Breaking (Sound Effect).mp3"), "sfx_vase_breaking.mp3"),
    # Timeline/Detective minigame countdown sounds
    (os.path.join("assets", "audio", "sound_effect", "timeline_analysis_minigame", "card_sound_effect.wav"), "sfx_card.wav"),
    (os.path.join("assets", "audio", "sound_effect", "timeline_analysis_minigame", "one.mp3"),               "sfx_one.mp3"),
    (os.path.join("assets", "audio", "sound_effect", "timeline_analysis_minigame", "two.mp3"),               "sfx_two.mp3"),
    (os.path.join("assets", "audio", "sound_effect", "timeline_analysis_minigame", "three.mp3"),             "sfx_three.mp3"),
    (os.path.join("assets", "audio", "sound_effect", "timeline_analysis_minigame", "start.mp3"),             "sfx_start.mp3"),
    (os.path.join("assets", "audio", "sound_effect", "timeline_analysis_minigame", "Whistle.mp3"),           "sfx_whistle.mp3"),
    (os.path.join("assets", "audio", "sound_effect", "timeline_analysis_minigame", "one_minute_left.mp3"),   "sfx_one_minute_left.mp3"),
    (os.path.join("assets", "audio", "sound_effect", "timeline_analysis_minigame", "thirty_seconds_left.mp3"), "sfx_thirty_seconds_left.mp3"),
    (os.path.join("assets", "audio", "sound_effect", "timeline_analysis_minigame", "ten_seconds_left.mp3"),  "sfx_ten_seconds_left.mp3"),
]

# AudioContext unlock script - injected into index.html before <script src="index.js">
# Chrome's autoplay policy suspends AudioContext until user gesture.
# This resumes it on first click/keydown/touchstart/mousedown.
AUDIO_UNLOCK_SCRIPT = """
\t\t<!-- AudioContext unlock for Chrome autoplay policy (auto-injected by serve_web.py) -->
\t\t<script>
(function() {
\tvar _OrigAudioContext = window.AudioContext || window.webkitAudioContext;
\tif (!_OrigAudioContext) return;
\tvar _PatchedAudioContext = function() {
\t\tvar ctx = new _OrigAudioContext(...arguments);
\t\twindow._godotAudioContext = ctx;
\t\treturn ctx;
\t};
\t_PatchedAudioContext.prototype = _OrigAudioContext.prototype;
\twindow.AudioContext = _PatchedAudioContext;
\tif (window.webkitAudioContext) window.webkitAudioContext = _PatchedAudioContext;
\tfunction resumeAudio() {
\t\tif (window._godotAudioContext) {
\t\t\tconsole.log('[AudioFix] AudioContext state:', window._godotAudioContext.state);
\t\t\tif (window._godotAudioContext.state === 'suspended') {
\t\t\t\twindow._godotAudioContext.resume().then(function() {
\t\t\t\t\tconsole.log('[AudioFix] AudioContext resumed!');
\t\t\t\t});
\t\t\t}
\t\t} else {
\t\t\tconsole.log('[AudioFix] No AudioContext captured yet');
\t\t}
\t}
\tdocument.addEventListener('click', resumeAudio, true);
\tdocument.addEventListener('keydown', resumeAudio, true);
\tdocument.addEventListener('touchstart', resumeAudio, true);
\tdocument.addEventListener('mousedown', resumeAudio, true);
})();
\t\t</script>
"""

def copy_audio_files():
    """Copy audio files into web/ folder so browser Audio API can serve them."""
    for src_rel, dest_name in WEB_AUDIO_FILES:
        src = os.path.join(ROOT_DIR, src_rel)
        dest = os.path.join(WEB_DIR, dest_name)
        if not os.path.exists(src):
            print(f"  WARNING: Audio source not found: {src_rel}")
            continue
        shutil.copy2(src, dest)
        print(f"  Copied {src_rel} -> web/{dest_name}")

def copy_voice_files():
    """Copy voice narration folder into web/voice/ preserving directory structure.
    This lets the browser Audio API serve 488 voice MP3s directly.
    GDScript maps res://assets/audio/voice/... -> voice/... URLs."""
    src_voice_dir = os.path.join(ROOT_DIR, "assets", "audio", "voice")
    dest_voice_dir = os.path.join(WEB_DIR, "voice")

    if not os.path.exists(src_voice_dir):
        print("  WARNING: assets/audio/voice/ not found, skipping voice copy.")
        return

    # Count files for progress reporting
    total = sum(len(files) for _, _, files in os.walk(src_voice_dir) if files)
    copied = 0
    skipped = 0

    for dirpath, dirnames, filenames in os.walk(src_voice_dir):
        # Compute destination directory
        rel = os.path.relpath(dirpath, src_voice_dir)
        dest_dir = os.path.join(dest_voice_dir, rel)
        os.makedirs(dest_dir, exist_ok=True)

        for filename in filenames:
            if not filename.lower().endswith(".mp3"):
                continue
            src_file = os.path.join(dirpath, filename)
            dest_file = os.path.join(dest_dir, filename)
            # Skip if destination is already up-to-date (same size and mtime)
            if (os.path.exists(dest_file)
                    and os.path.getmtime(dest_file) >= os.path.getmtime(src_file)
                    and os.path.getsize(dest_file) == os.path.getsize(src_file)):
                skipped += 1
                continue
            shutil.copy2(src_file, dest_file)
            copied += 1

    print(f"  Voice narration: {copied} copied, {skipped} already up-to-date ({total} total files)")

def patch_index_html():
    """Inject AudioContext unlock into index.html if not already present."""
    if not os.path.exists(INDEX_PATH):
        print("  WARNING: web/index.html not found. Export the game first.")
        return

    with open(INDEX_PATH, "r", encoding="utf-8") as f:
        content = f.read()

    if "auto-injected by serve_web.py" in content:
        print("  index.html already patched with AudioContext unlock.")
        return

    # Insert before <script src="index.js">
    marker = '<script src="index.js"></script>'
    if marker not in content:
        print("  WARNING: Could not find injection point in index.html.")
        return

    patched = content.replace(marker, AUDIO_UNLOCK_SCRIPT + "\t\t" + marker)
    with open(INDEX_PATH, "w", encoding="utf-8") as f:
        f.write(patched)

    print("  Patched index.html with AudioContext unlock for Chrome autoplay.")


class GodotWebHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def end_headers(self):
        # Required headers for Godot web export (SharedArrayBuffer)
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Cross-Origin-Resource-Policy", "cross-origin")
        super().end_headers()

    def log_message(self, format, *args):
        print(f"  {self.address_string()} - {format % args}")


if __name__ == "__main__":
    print("=" * 50)
    print("  EduMys Web Server")
    print("=" * 50)

    # Copy audio files so browser Audio API can access them
    copy_audio_files()

    # Copy voice narration files into web/voice/ (488 MP3s, ~30MB)
    copy_voice_files()

    # Auto-patch index.html every time the server starts
    patch_index_html()

    print(f"  Open in Chrome: http://localhost:{PORT}")
    print(f"  Serving from:   {WEB_DIR}")
    print()
    print("  Press Ctrl+C to stop the server.")
    print("=" * 50)

    with socketserver.TCPServer(("", PORT), GodotWebHandler) as httpd:
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n  Server stopped.")
