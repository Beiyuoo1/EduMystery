# Local Configuration System

## Overview

The game now supports **local configuration files** that allow per-user settings without affecting the shared repository. This is useful for development when different team members have different hardware capabilities.

---

## How It Works

### For Users Who Want to Disable Vosk Loading

If your computer has issues with Vosk voice recognition (slow loading, crashes, compatibility issues), you can disable it locally:

1. **Create a file** named `local_config.json` in the project root directory
2. **Add this content:**
   ```json
   {
       "disable_vosk_loading": true
   }
   ```
3. **Save and run the game** - Vosk loading will be skipped!

### Benefits

✅ **Faster game startup** - No 2.7GB model loading on startup
✅ **No crashes** - Skip Vosk entirely if it causes issues on your hardware
✅ **Minigames still work** - You can still press F5 to skip voice recognition minigames
✅ **Won't affect teammates** - This file is NOT committed to git (it's in `.gitignore`)

---

## File Location

```
C:\Projects\edu-mys-dev\
├── local_config.json  ← Create this file (NOT committed to git)
├── autoload/
│   └── minigame_manager.gd  ← Checks for local_config.json on startup
└── .gitignore  ← Contains "local_config.json" to prevent committing
```

---

## Configuration Options

### Current Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `disable_vosk_loading` | `bool` | `false` | Skip Vosk model loading on startup |

### Example Configuration

**Disable Vosk (Faster Startup):**
```json
{
    "disable_vosk_loading": true
}
```

**Enable Vosk (Default Behavior):**
```json
{
    "disable_vosk_loading": false
}
```

Or simply **delete** `local_config.json` to use default behavior.

---

## For Team Members

### If You Pull from Git

When you pull the latest changes, you might see:
- ✅ Updated `.gitignore` (committed)
- ✅ Updated `autoload/minigame_manager.gd` (committed)
- ✅ New `LOCAL_CONFIG_README.md` (committed - you're reading it now!)
- ❌ **No** `local_config.json` (NOT committed, each user creates their own)

### If Vosk Works Fine on Your Computer

**Do nothing!** The game will work exactly as before. The local config system only activates if you create `local_config.json` with `disable_vosk_loading: true`.

### If Vosk Doesn't Work on Your Computer

Create `local_config.json` as described above to disable it locally.

---

## Technical Details

### How MinigameManager Checks Config

On `_ready()`, the MinigameManager:

1. Checks if `res://local_config.json` exists
2. If it exists, parses the JSON
3. If `disable_vosk_loading` is `true`, skips Vosk loading entirely
4. Sets `vosk_is_loaded = true` and `shared_vosk_recognizer = null`
5. Game continues without voice recognition features

### Fallback Behavior

If `local_config.json`:
- Doesn't exist → Load Vosk normally
- Has invalid JSON → Load Vosk normally (prints warning)
- Has `disable_vosk_loading: false` → Load Vosk normally
- Has `disable_vosk_loading: true` → Skip Vosk loading

---

## Subject Assignment (Team Workflow)

Since Vosk is disabled on some laptops, the team can divide subjects:

### Laptop 1 (Vosk Working)
- **Subject:** English (Oral Communication)
- **Minigames:** Voice recognition (Dialogue Choice, Pronunciation)
- **Testing:** Voice narration system

### Laptop 2 (Vosk Disabled)
- **Subject:** Math (General Mathematics)
- **Minigames:** Logic Grid, Timeline Reconstruction, Detective Analysis
- **Testing:** Math-focused curriculum content

### Laptop 3 (Vosk Disabled)
- **Subject:** Science (Earth & Physical Science - Physics)
- **Minigames:** Physics Q1-Q4 science minigames
- **Testing:** Science-focused curriculum content

---

## Troubleshooting

### Vosk Still Loading After Creating Config File

**Check these:**
1. File name is exactly `local_config.json` (case-sensitive)
2. File is in the project root directory (same folder as `project.godot`)
3. JSON syntax is valid (no trailing commas, proper quotes)
4. Value is exactly `true` (lowercase, not `"true"` as a string)

**Example of CORRECT syntax:**
```json
{
    "disable_vosk_loading": true
}
```

**Example of INCORRECT syntax:**
```json
{
    "disable_vosk_loading": "true",  ❌ String instead of boolean
}
```

### Want to Re-enable Vosk Later

Simply:
- Delete `local_config.json`, OR
- Change `"disable_vosk_loading": true` to `false`

---

## Git Workflow

### What Gets Committed

✅ `.gitignore` update (adds `local_config.json` to ignore list)
✅ `autoload/minigame_manager.gd` update (adds config checking logic)
✅ `LOCAL_CONFIG_README.md` (this file)

### What DOESN'T Get Committed

❌ `local_config.json` (each team member creates their own)
❌ Any `*.local.json` files

This ensures everyone can have their own configuration without conflicts!

---

## Future Configuration Options

This system can be extended to support other local settings:

```json
{
    "disable_vosk_loading": true,
    "skip_intro_videos": true,
    "debug_mode": true,
    "default_chapter": 3
}
```

Just add the corresponding checks in the relevant scripts!
