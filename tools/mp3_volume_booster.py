"""
MP3 Volume Booster Tool
=======================
Increase the volume of one or more MP3 files by up to 200%.

Uses ffmpeg directly (no pydub dependency) — works on Python 3.12+/3.14+.

Usage:
    python mp3_volume_booster.py                      # GUI mode
    python mp3_volume_booster.py file1.mp3 file2.mp3  # CLI mode

Requirements:
    ffmpeg on PATH — installed via:  winget install ffmpeg
"""

import sys
import os
import subprocess
import tkinter as tk
from tkinter import ttk, filedialog, messagebox
from pathlib import Path


# ──────────────────────────────────────────────
#  ffmpeg check
# ──────────────────────────────────────────────

def find_ffmpeg() -> str | None:
    """Return path to ffmpeg executable, or None if not found."""
    # Check PATH
    for name in ("ffmpeg", "ffmpeg.exe"):
        result = subprocess.run(
            ["where" if sys.platform == "win32" else "which", name],
            capture_output=True, text=True
        )
        if result.returncode == 0:
            return result.stdout.strip().splitlines()[0]

    # Common winget install locations
    winget_candidates = [
        os.path.expandvars(r"%LOCALAPPDATA%\Microsoft\WinGet\Links\ffmpeg.exe"),
        os.path.expandvars(r"%LOCALAPPDATA%\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-8.0.1-full_build\bin\ffmpeg.exe"),
    ]
    # Also glob for any Gyan.FFmpeg install
    winget_base = os.path.expandvars(r"%LOCALAPPDATA%\Microsoft\WinGet\Packages")
    if os.path.isdir(winget_base):
        for entry in os.listdir(winget_base):
            if entry.startswith("Gyan.FFmpeg"):
                candidate = os.path.join(winget_base, entry)
                # Walk one level to find bin/ffmpeg.exe
                for sub in os.listdir(candidate):
                    ff = os.path.join(candidate, sub, "bin", "ffmpeg.exe")
                    if os.path.isfile(ff):
                        winget_candidates.append(ff)

    for wpath in winget_candidates:
        if os.path.isfile(wpath):
            return wpath

    return None


# ──────────────────────────────────────────────
#  Core logic
# ──────────────────────────────────────────────

def get_output_path(input_path: str, output_dir: str | None = None) -> Path:
    """Return the output path (same name as source, in output_dir or same folder)."""
    src = Path(input_path)
    if output_dir:
        out_dir = Path(output_dir)
        out_dir.mkdir(parents=True, exist_ok=True)
        return out_dir / src.name
    return src  # same file, same location


def boost_volume(input_path: str, percent: int, output_dir: str | None = None,
                 ffmpeg_path: str = "ffmpeg") -> str:
    """
    Boost the volume of an MP3 file using ffmpeg.

    Args:
        input_path:  Path to source MP3.
        percent:     Target volume as % of original (1–200).
        output_dir:  Output folder. None = overwrite source in-place.
        ffmpeg_path: Path to ffmpeg binary.

    Returns:
        Path of saved output file.
    """
    percent = max(1, min(200, percent))

    # ffmpeg volume filter uses a multiplier (1.0 = original, 2.0 = double)
    multiplier = percent / 100.0

    out_path = get_output_path(input_path, output_dir)

    # Use a temp file so we never corrupt the source if ffmpeg fails
    tmp_path = out_path.with_suffix(".tmp.mp3")

    cmd = [
        ffmpeg_path,
        "-y",                          # overwrite temp file without asking
        "-i", str(input_path),
        "-filter:a", f"volume={multiplier}",
        "-codec:a", "libmp3lame",
        "-q:a", "2",                   # high quality VBR
        str(tmp_path)
    ]

    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        if tmp_path.exists():
            tmp_path.unlink()
        raise RuntimeError(f"ffmpeg error:\n{result.stderr[-1000:]}")

    # Replace the target (atomic-ish: rename over destination)
    tmp_path.replace(out_path)
    return str(out_path)


# ──────────────────────────────────────────────
#  GUI
# ──────────────────────────────────────────────

class VolumeBoosterApp(tk.Tk):
    def __init__(self, ffmpeg_path: str):
        super().__init__()
        self.ffmpeg_path = ffmpeg_path
        self.title("MP3 Volume Booster")
        self.resizable(False, False)
        self.configure(bg="#1e1e2e")
        self._files: list[str] = []
        self._build_ui()

    # ── UI construction ──────────────────────

    def _build_ui(self):
        PAD    = 14
        BG     = "#1e1e2e"
        FG     = "#cdd6f4"
        ACC    = "#89b4fa"
        BTN    = "#313244"
        BTN_H  = "#45475a"

        s = ttk.Style(self)
        s.theme_use("clam")
        s.configure("TFrame",        background=BG)
        s.configure("TLabel",        background=BG, foreground=FG,
                    font=("Segoe UI", 10))
        s.configure("H.TLabel",      background=BG, foreground=ACC,
                    font=("Segoe UI", 15, "bold"))
        s.configure("TButton",       background=BTN, foreground=FG,
                    font=("Segoe UI", 10), borderwidth=0, focuscolor=BG)
        s.map("TButton",             background=[("active", BTN_H)])
        s.configure("A.TButton",     background=ACC, foreground="#1e1e2e",
                    font=("Segoe UI", 10, "bold"))
        s.map("A.TButton",           background=[("active", "#74c7ec")])
        s.configure("TProgressbar",  troughcolor=BTN, background=ACC, thickness=10)

        f = ttk.Frame(self, padding=PAD)
        f.pack(fill="both", expand=True)

        # Header
        ttk.Label(f, text="🎵  MP3 Volume Booster", style="H.TLabel"
                  ).pack(anchor="w", pady=(0, PAD))

        # File list
        lf = ttk.Frame(f)
        lf.pack(fill="both", expand=True)
        self.lb = tk.Listbox(
            lf, selectmode="extended", height=10, width=62,
            bg="#313244", fg=FG, selectbackground=ACC,
            selectforeground="#1e1e2e", font=("Segoe UI", 9),
            borderwidth=0, relief="flat", activestyle="none"
        )
        sb = ttk.Scrollbar(lf, orient="vertical", command=self.lb.yview)
        self.lb.configure(yscrollcommand=sb.set)
        self.lb.pack(side="left", fill="both", expand=True)
        sb.pack(side="right", fill="y")

        ttk.Label(f, text="Tip: Add files with the button below, or drag & drop onto this window.",
                  font=("Segoe UI", 8), foreground="#6c7086"
                  ).pack(anchor="w", pady=(4, 0))

        # File action buttons
        br = ttk.Frame(f)
        br.pack(fill="x", pady=(8, 0))
        ttk.Button(br, text="➕  Add Files",        command=self._add_files      ).pack(side="left", padx=(0,6))
        ttk.Button(br, text="🗑  Remove Selected",  command=self._remove_selected).pack(side="left", padx=(0,6))
        ttk.Button(br, text="✖  Clear All",         command=self._clear_files    ).pack(side="left")

        # Volume slider
        vr = ttk.Frame(f)
        vr.pack(fill="x", pady=(14, 0))
        ttk.Label(vr, text="Volume:").pack(side="left")
        self.vol_var   = tk.IntVar(value=150)
        self.vol_lbl   = ttk.Label(vr, text="150%", width=5,
                                   foreground=ACC, font=("Segoe UI", 10, "bold"))
        self.vol_lbl.pack(side="right")
        ttk.Label(vr, text="200%", foreground="#6c7086").pack(side="right")
        ttk.Scale(vr, from_=1, to=200, orient="horizontal",
                  variable=self.vol_var, command=self._on_slider
                  ).pack(side="left", fill="x", expand=True, padx=6)
        ttk.Label(vr, text="1%", foreground="#6c7086").pack(side="left")

        # Output folder
        or_ = ttk.Frame(f)
        or_.pack(fill="x", pady=(10, 0))
        ttk.Label(or_, text="Output folder:").pack(side="left")
        self.out_var = tk.StringVar(value="(same folder as source)")
        tk.Entry(or_, textvariable=self.out_var, width=36,
                 bg="#313244", fg=FG, insertbackground=FG,
                 font=("Segoe UI", 9), borderwidth=0, relief="flat"
                 ).pack(side="left", fill="x", expand=True, padx=6)
        ttk.Button(or_, text="Browse…", command=self._browse_out).pack(side="left")

        # Progress + status
        self.progress = ttk.Progressbar(f, orient="horizontal",
                                        mode="determinate", style="TProgressbar")
        self.progress.pack(fill="x", pady=(12, 0))
        self.status_var = tk.StringVar(value="Ready — add MP3 files and click Boost.")
        ttk.Label(f, textvariable=self.status_var,
                  foreground="#6c7086", font=("Segoe UI", 8)
                  ).pack(anchor="w", pady=(4, 0))

        # Boost button
        ttk.Button(f, text="🚀  Boost Volume", style="A.TButton",
                   command=self._run_boost
                   ).pack(pady=(12, 0), fill="x")

    # ── Handlers ──────────────────────────────

    def _on_slider(self, _=None):
        self.vol_lbl.config(text=f"{self.vol_var.get()}%")

    def _add_files(self):
        paths = filedialog.askopenfilenames(
            title="Select MP3 files",
            filetypes=[("MP3 files", "*.mp3"), ("All files", "*.*")]
        )
        for p in paths:
            if p not in self._files:
                self._files.append(p)
                self.lb.insert("end", os.path.basename(p))

    def _remove_selected(self):
        for idx in reversed(self.lb.curselection()):
            self.lb.delete(idx)
            self._files.pop(idx)

    def _clear_files(self):
        self.lb.delete(0, "end")
        self._files.clear()

    def _browse_out(self):
        folder = filedialog.askdirectory(title="Select output folder")
        if folder:
            self.out_var.set(folder)

    def _run_boost(self):
        if not self._files:
            messagebox.showwarning("No files", "Please add at least one MP3 file.")
            return

        percent  = self.vol_var.get()
        out_raw  = self.out_var.get()
        out_dir  = None if out_raw.startswith("(same") else out_raw

        # ── Overwrite check ──────────────────────────────────────────────
        # Collect files that will overwrite an existing file
        conflicts = []
        for path in self._files:
            out_path = get_output_path(path, out_dir)
            if out_path.exists():
                conflicts.append(os.path.basename(path))

        if conflicts:
            names = "\n  • ".join(conflicts)
            answer = messagebox.askyesno(
                "Same filename detected",
                f"The following file(s) already exist at the destination "
                f"and will be overwritten:\n\n  • {names}\n\n"
                f"Do you want to overwrite them?",
                icon="warning"
            )
            if not answer:
                self.status_var.set("Cancelled — no files were changed.")
                return
        # ────────────────────────────────────────────────────────────────

        total  = len(self._files)
        errors = []

        self.progress.configure(maximum=total, value=0)

        for i, path in enumerate(self._files, 1):
            self.status_var.set(f"Processing {i}/{total}: {os.path.basename(path)}")
            self.update_idletasks()
            try:
                result = boost_volume(path, percent, out_dir, self.ffmpeg_path)
                print(f"✔  {result}")
            except Exception as e:
                errors.append(f"{os.path.basename(path)}: {e}")
            self.progress.configure(value=i)
            self.update_idletasks()

        if errors:
            messagebox.showerror("Some files failed",
                                 "Errors:\n" + "\n".join(errors))
            self.status_var.set(f"Done with {len(errors)} error(s).")
        else:
            self.status_var.set(f"✔ Done! {total} file(s) boosted to {percent}%.")
            messagebox.showinfo("Complete",
                                f"Successfully boosted {total} file(s) to {percent}%!\n"
                                f"Saved to: {out_dir or 'same folder as each source file'}")


# ──────────────────────────────────────────────
#  CLI mode
# ──────────────────────────────────────────────

def cli_mode(files: list[str], ffmpeg_path: str):
    print("MP3 Volume Booster — CLI Mode")
    print(f"Files: {len(files)}")

    try:
        raw = input("Volume percent (1-200) [default 150]: ").strip()
        percent = int(raw) if raw else 150
        percent = max(1, min(200, percent))
    except (ValueError, EOFError):
        percent = 150

    try:
        out_dir = input("Output folder (leave blank = same as source): ").strip() or None
    except EOFError:
        out_dir = None

    for path in files:
        if not os.path.isfile(path):
            print(f"✘  Not found: {path}")
            continue

        out_path = get_output_path(path, out_dir)
        if out_path.exists():
            answer = input(f"  ⚠  '{out_path.name}' already exists. Overwrite? [y/N]: ").strip().lower()
            if answer != "y":
                print(f"  Skipped: {os.path.basename(path)}")
                continue

        print(f"  Boosting {os.path.basename(path)} → {percent}% ...", end=" ", flush=True)
        try:
            result = boost_volume(path, percent, out_dir, ffmpeg_path)
            print(f"✔  {result}")
        except Exception as e:
            print(f"✘  ERROR: {e}")

    print("Done.")


# ──────────────────────────────────────────────
#  Entry point
# ──────────────────────────────────────────────

if __name__ == "__main__":
    ffmpeg = find_ffmpeg()
    if not ffmpeg:
        # Try the default name and let subprocess raise an error later
        ffmpeg = "ffmpeg"
        print("WARNING: ffmpeg not found on PATH. Install with:  winget install ffmpeg")

    args    = sys.argv[1:]
    mp3args = [a for a in args if a.lower().endswith(".mp3")]

    if mp3args:
        cli_mode(mp3args, ffmpeg)
    else:
        app = VolumeBoosterApp(ffmpeg)
        app.mainloop()
