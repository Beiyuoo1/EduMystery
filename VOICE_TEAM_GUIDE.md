# Voice Team Guide - For Members Handling Voice Attachments

## Your Role

You're responsible for:
- ✅ Attaching voice MP3 files to dialogue narration lines
- ✅ Editing dialogue in timeline (.dtl) files
- ✅ Managing voice narration files in `assets/audio/voice/`

---

## Tools You'll Use

### 1. Voice Attachment Tool (Easiest Way!)

**Location:** `voice_attachment_tool.py`

**How to use:**
```bash
# Open command prompt in project folder
cd C:\Projects\edu-mys-dev

# Run the voice attachment tool
python voice_attachment_tool.py
```

**GUI Interface:**
1. **Select Chapter** (1-5)
2. **Select Scene** (c1s1, c1s2, etc.)
3. **Click "Load Scene"**
4. **Select a narration line** from the list
5. **Click "Browse..."** to find your MP3 file
6. **Click "Attach Voice to This Line"**
7. **Click "Save Changes"** when done

**That's it!** The tool automatically:
- ✅ Adds `[voice path="..." volume=25 bus="Voice"]` tags
- ✅ Converts file paths to Godot format
- ✅ Updates the .dtl timeline file
- ✅ Shows statistics (lines with/without voice)

### 2. Manual Editing (If You Prefer)

Open `.dtl` files in VSCode and add voice tags manually:

**Format:**
```dtl
[voice path="res://assets/audio/voice/Chapter 1/C1S1/filename.mp3" volume=25 bus="Voice"]
The narration text that this voice file reads.
```

**Example:**
```dtl
[voice path="res://assets/audio/voice/Chapter 1/C1S1/c1s1 the hallway.mp3" volume=25 bus="Voice"]
The hallway is quiet, bathed in the soft light of the afternoon sun.
```

---

## File Organization

### Voice File Locations

```
assets/audio/voice/
├── Chapter 1/
│   ├── C1S1/
│   │   ├── c1s1 the hallway.mp3
│   │   ├── c1s1 unlike most.mp3
│   │   └── ... (69 files total)
│   ├── C1S2/
│   ├── C1S3/
│   ├── C1S4/
│   └── C1S5/
├── Chapter 2/
│   ├── c2s0/
│   ├── c2s1/
│   └── ... (130 files total)
└── ... (Chapters 3-5)
```

### Timeline File Locations

```
content/timelines/
├── Chapter 1/
│   ├── c1s1.dtl
│   ├── c1s2.dtl
│   ├── c1s2b.dtl
│   ├── c1s3.dtl
│   ├── c1s4.dtl
│   └── c1s5.dtl
├── Chapter 2/
│   ├── c2s0.dtl
│   └── ... (7 scenes)
└── ... (Chapters 3-5)
```

---

## Git Workflow for Voice Team

### Every Time You Start Work

```bash
# 1. Open Git Bash or Command Prompt
cd /c/Projects/edu-mys-dev

# 2. Get latest changes from team
git pull origin main

# 3. Start working!
```

### While Working (Every 30-60 Minutes)

```bash
# 1. Check what changed
git status

# 2. Add all changes (voice files + timeline files)
git add .

# 3. Commit with clear message
git commit -m "[YourName] Add voice for Chapter 1 Scene 1 (15 files)"

# 4. Push to team
git push origin main
```

### Example Commit Messages

```bash
# Good messages
git commit -m "[Sarah] Add voice narration for c1s1 (69 files)"
git commit -m "[John] Update c2s3 dialogue and attach 20 voice files"
git commit -m "[Mike] Fix typo in c3s4 line 156"
git commit -m "[Sarah] Replace c1s2 voice file with clearer recording"

# Bad messages
git commit -m "changes"
git commit -m "update"
git commit -m "voice"
```

---

## Voice File Naming Convention

**Follow this pattern:**
```
cXsY description.mp3
```

**Examples:**
- ✅ `c1s1 the hallway.mp3`
- ✅ `c2s3 conrad's thoughts.mp3`
- ✅ `c5s5 the chain continues.mp3`

**Why this matters:**
- Easy to search and find files
- Matches the narration content
- Team can understand what each file is for

---

## Adding New Voice Files - Complete Workflow

### Step 1: Record Your Voice

Use any recording software (Audacity, Windows Voice Recorder, etc.):
- **Format:** MP3
- **Quality:** 128kbps or higher
- **Mono or Stereo:** Both work
- **Clean audio:** Minimal background noise

### Step 2: Name the File

Use the naming convention:
```
c1s1 description of narration.mp3
```

### Step 3: Place in Correct Folder

```
assets/audio/voice/Chapter X/FOLDER/filename.mp3
```

**Example:**
```
assets/audio/voice/Chapter 1/C1S1/c1s1 the hallway.mp3
```

### Step 4: Attach to Timeline

**Option A: Use Voice Attachment Tool** (Recommended)
1. Run `python voice_attachment_tool.py`
2. Select chapter and scene
3. Browse and attach MP3
4. Save changes

**Option B: Edit Manually**
1. Open `content/timelines/Chapter 1/c1s1.dtl`
2. Find the narration line
3. Add voice tag above it:
   ```dtl
   [voice path="res://assets/audio/voice/Chapter 1/C1S1/c1s1 the hallway.mp3" volume=25 bus="Voice"]
   The hallway is quiet, bathed in the soft light of the afternoon sun.
   ```

### Step 5: Test in Godot

1. Open Godot 4.5
2. Press F5 to run game
3. Navigate to the scene with your voice
4. Listen and verify it plays correctly

### Step 6: Commit and Push

```bash
git add "assets/audio/voice/Chapter 1/C1S1/c1s1 the hallway.mp3"
git add "content/timelines/Chapter 1/c1s1.dtl"
git commit -m "[YourName] Add voice for c1s1 hallway narration"
git push origin main
```

---

## Updating Existing Voice Files

### If You Need to Re-record

1. **Keep the same filename** - Don't rename it!
2. **Overwrite the old file** - Replace it in the same location
3. **Timeline file doesn't need changes** - Path is the same

**Git will track the change:**
```bash
git status
# Shows: M assets/audio/voice/Chapter 1/C1S1/c1s1 the hallway.mp3

git add .
git commit -m "[YourName] Re-record c1s1 hallway with clearer audio"
git push origin main
```

---

## Editing Dialogue Text

### How to Edit Timeline Files

Open `.dtl` files in **VSCode** (or any text editor):

```dtl
# Original
Conrad: Hello, Mark.

# Edit to
Conrad: Hey there, partner!
```

### Important Rules

1. **Don't touch Dialogic commands** (lines starting with `[` or containing `{`)
   ```dtl
   # DON'T EDIT THESE:
   [background arg="res://Bg/classroom.png" fade="1.0"]
   join Conrad (half) left
   set {conrad_level} += 1
   ```

2. **Only edit character dialogue** (lines with `Character:`)
   ```dtl
   # EDIT THESE:
   Conrad: This text can be changed.
   Mark: This too!
   ```

3. **Only edit narration** (plain text lines)
   ```dtl
   # EDIT THESE:
   The hallway is quiet.
   Mysteries had always fascinated you.
   ```

4. **Keep voice tags** when editing narration
   ```dtl
   # GOOD:
   [voice path="..." volume=25 bus="Voice"]
   Your new narration text here.

   # BAD (voice tag removed):
   Your new narration text here.
   ```

---

## Testing Your Changes

### Before Pushing to GitHub

1. **Open Godot**
2. **Press F5** to run the game
3. **Navigate to your edited scene**
4. **Check:**
   - ✅ Voice plays correctly
   - ✅ Dialogue text displays correctly
   - ✅ No errors in Godot console
   - ✅ Volume is audible (25dB setting)

### If Something Breaks

**Godot shows an error:**
1. Read the error message carefully
2. Check if you accidentally deleted a bracket or command
3. Compare with a working .dtl file
4. Ask in group chat if stuck

**Voice doesn't play:**
1. Check file path spelling in voice tag
2. Verify MP3 file exists in correct location
3. Check volume setting (should be `volume=25`)
4. Test in Godot console (look for error messages)

---

## Team Coordination

### Before Starting Work Each Day

Post in group chat:

```
📋 [YourName] Voice Team - Today's Plan:
- Working on: Chapter 2 Scene 3 (c2s3)
- Adding: 30 voice files for narration
- Editing: Dialogue typos in c2s3

⚠️ Don't edit c2s3.dtl until I push (around 3pm)
```

### Dividing Work Between Voice Team Members

**Recommended Split:**

**Member 2:**
- Chapters 1-2 (199 voice files total)
- Scenes: c1s1, c1s2, c1s2b, c1s3, c1s4, c1s5
- Scenes: c2s0, c2s1, c2s2, c2s3, c2s4, c2s5, c2s6

**Member 3:**
- Chapters 3-5 (384 voice files total)
- Scenes: c3s0-c3s6 (223 files)
- Scenes: c4s0-c4s6 (55 files)
- Scenes: c5s0-c5s5 (106 files)

**Or split differently:**
- One person: Conrad's route
- One person: Celestine's route

---

## Voice Statistics (For Planning)

| Chapter | Total Voice Files | Scenes |
|---------|------------------|--------|
| Chapter 1 | 69 files | 5 scenes |
| Chapter 2 | 130 files | 7 scenes |
| Chapter 3 | 223 files | 7 scenes |
| Chapter 4 | 55 files | 7 scenes |
| Chapter 5 | 106 files | 6 scenes |
| **TOTAL** | **583 files** | **32 scenes** |

**Average:** ~18 voice files per scene

---

## Common Issues and Solutions

### Issue: "File path not found" error in Godot

**Solution:** Check voice tag path format:
```dtl
# ✅ CORRECT:
[voice path="res://assets/audio/voice/Chapter 1/C1S1/filename.mp3" volume=25 bus="Voice"]

# ❌ WRONG (missing res://):
[voice path="assets/audio/voice/Chapter 1/C1S1/filename.mp3" volume=25 bus="Voice"]

# ❌ WRONG (backslashes instead of forward slashes):
[voice path="res://assets\audio\voice\Chapter 1\C1S1\filename.mp3" volume=25 bus="Voice"]
```

### Issue: Voice files too large for GitHub

GitHub has a 100MB per-file limit.

**Solution:** Split large files or use Git LFS:
```bash
# Install Git LFS (one-time)
git lfs install

# Track MP3 files with LFS
git lfs track "*.mp3"
git add .gitattributes
git commit -m "Enable Git LFS for MP3 files"
git push origin main
```

### Issue: Merge conflict in .dtl file

See **GIT_CHEAT_SHEET.md** "Merge Conflict" section.

**Quick fix:**
1. Open conflicted file in VSCode
2. Delete conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
3. Keep the version you want
4. Save, commit, push

### Issue: Accidentally deleted voice tag

**Solution:** Use Git to restore:
```bash
# See what changed
git diff content/timelines/Chapter\ 1/c1s1.dtl

# Restore original version
git checkout -- content/timelines/Chapter\ 1/c1s1.dtl
```

---

## Quick Reference: Voice Attachment Tool

### GUI Workflow

1. **Run:** `python voice_attachment_tool.py`
2. **Chapter dropdown:** Select chapter (1-5)
3. **Scene dropdown:** Select scene (c1s1, c1s2, etc.)
4. **Load Scene button:** Click to load narration lines
5. **Narration list (left):**
   - ✅ Green = Has voice
   - ❌ Red = No voice
6. **Click a line** to select it
7. **Browse button:** Find your MP3 file
8. **Attach Voice button:** Attach to selected line
9. **Remove Voice button:** Remove voice from selected line
10. **Save Changes button:** Write changes to .dtl file

### Statistics Panel

Shows real-time counts:
- Total lines
- Lines with voice
- Lines without voice

---

## Summary Checklist

Before pushing to GitHub, verify:

- [ ] Voice files are in correct folder (`assets/audio/voice/Chapter X/`)
- [ ] Voice tags added to timeline files (`.dtl`)
- [ ] File paths use forward slashes (`/`) not backslashes (`\`)
- [ ] File paths start with `res://`
- [ ] Volume is set to `25`
- [ ] Bus is set to `"Voice"`
- [ ] Tested in Godot (voice plays correctly)
- [ ] No Godot errors in console
- [ ] Committed with clear message
- [ ] Pushed to GitHub

---

## Need Help?

1. **Check full guide:** `TEAM_GIT_WORKFLOW.md`
2. **Check commands:** `GIT_CHEAT_SHEET.md`
3. **Ask in group chat:** Your teammates can help!
4. **Test in Godot:** Always test before pushing

**You've got this!** 🎤🎙️✨
