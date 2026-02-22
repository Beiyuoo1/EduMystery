#!/usr/bin/env python3
"""
Simple local server for Godot web export.
Adds required CORS headers for SharedArrayBuffer (needed by Godot).
Run this script then open http://localhost:8080 in Chrome.
"""

import http.server
import socketserver
import os

PORT = 8080
WEB_DIR = os.path.join(os.path.dirname(__file__), "web")

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
    with socketserver.TCPServer(("", PORT), GodotWebHandler) as httpd:
        print("=" * 50)
        print("  EduMys Web Server Running!")
        print("=" * 50)
        print(f"  Open in Chrome: http://localhost:{PORT}")
        print(f"  Serving from:   {WEB_DIR}")
        print()
        print("  Press Ctrl+C to stop the server.")
        print("=" * 50)
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n  Server stopped.")
