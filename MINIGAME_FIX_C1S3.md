# Chapter 1 Scene 3 Minigame Fix

## Issue
The second minigame in Chapter 1 (c1s3.dtl) was not functioning properly for **Science students** because it was using `curriculum:platformer`, which is currently broken.

## Fix Applied

**File:** `content/timelines/Chapter 1/c1s3.dtl` (Line 63)

**Changed:**
```dtl
elif {selected_subject} == "science":
    [signal arg="start_minigame curriculum:platformer"]  # BROKEN
```

**To:**
```dtl
elif {selected_subject} == "science":
    [signal arg="start_minigame curriculum:pacman"]  # WORKING
```

## Current Chapter 1 Minigame Distribution

### Scene 2 (c1s2.dtl) - First Minigame: Approaching the Janitor
- **English**: `dialogue_choice_janitor` (Voice recognition)
- **Math**: `curriculum:pacman` (Q1 Math - Functions)
- **Science**: `curriculum:runner` (Q1 Science - Plate Tectonics) ✅

### Scene 3 (c1s3.dtl) - Second Minigame: WiFi Router Question
- **English**: `wifi_router` (Hear & Fill pronunciation)
- **Math**: `curriculum:maze` (Q1 Math - Functions)
- **Science**: `curriculum:pacman` (Q1 Science - Plate Tectonics) ✅ **FIXED**

### Scene 5 (c1s5.dtl) - Third Minigame: Bracelet Riddle
- **English**: `bracelet_riddle` (Riddle letter selection)
- **Math**: `curriculum:pacman` (Q1 Math - Functions)
- **Science**: `curriculum:runner` (Q1 Science - Plate Tectonics) ✅

### Scene 5 (c1s5.dtl) - Fourth Minigame: Locker Examination
- **All subjects**: `locker_examination` (Fill-in-blank) ✅

## Working Curriculum Minigames

| Minigame Type | Status | Used In |
|---------------|--------|---------|
| `curriculum:runner` | ✅ Working | c1s2 (Science), c1s5 (Science) |
| `curriculum:pacman` | ✅ Working | c1s2 (Math), c1s3 (Science), c1s5 (Math) |
| `curriculum:maze` | ✅ Working | c1s3 (Math), c2s5 |
| `curriculum:platformer` | ❌ **BROKEN** | Removed from all uses |

## Science Students in Chapter 1

Science students now experience:
1. **Scene 2**: Runner minigame - Plate Tectonics questions (runner format)
2. **Scene 3**: Pacman minigame - Plate Tectonics questions (pacman format)
3. **Scene 5**: Runner minigame - Plate Tectonics questions (runner format)

All three use Q1 Science curriculum questions about:
- Earth's structure (crust, mantle, core)
- Plate tectonics and earthquakes
- Continental drift and Wegener
- Seismographs and earthquakes
- Philippines tectonic plate

## Testing Verification

✅ No more `curriculum:platformer` references in Chapter 1
✅ Science path now uses working minigames (Runner & Pacman)
✅ Math path still uses working minigames (Pacman & Maze)
✅ English path uses story-specific minigames (Dialogue, Hear & Fill, Riddle)

## Summary

The broken platformer minigame has been replaced with the working Pacman minigame for science students in Chapter 1, Scene 3. All Chapter 1 minigames should now function properly for all three subjects (English, Math, Science).
