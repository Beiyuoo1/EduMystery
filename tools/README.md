# Tools

Utility scripts for the EduMys project.

---

## mp3_volume_booster.py

Increase the volume of MP3 files by up to **200%**.

### Requirements

```bash
pip install pydub
```

Also requires **ffmpeg** on your PATH:
```bash
winget install ffmpeg
```

### Usage

**GUI mode** (double-click the `.bat` or run with no arguments):
```bash
python mp3_volume_booster.py
```

**CLI mode** (pass MP3 files directly):
```bash
python mp3_volume_booster.py file1.mp3 file2.mp3 file3.mp3
```

**Windows launcher** (handles dependency checks automatically):
```
Double-click: mp3_volume_booster.bat
```
You can also drag and drop MP3 files onto the `.bat` file.

### GUI Features

- **Add Files** — browse and select multiple MP3s
- **Remove Selected** — remove highlighted files from list
- **Clear All** — empty the file list
- **Volume slider** — 1% to 200% (default 150%)
- **Output folder** — save boosted files elsewhere, or same folder with `_boosted` suffix
- **Progress bar** — tracks processing of multiple files
- Drag & drop support (Windows)

### Output

Files are saved as `originalname_boosted.mp3` in the chosen output folder
(or next to the original file if no output folder is set).
