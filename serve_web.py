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
WEB_AUDIO_FILES = [
    (os.path.join("Bg", "main menu bg music.mp3"), "bgmusic.mp3"),
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
