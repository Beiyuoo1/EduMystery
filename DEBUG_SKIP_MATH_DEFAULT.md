# Debug Skip - Math Default

## Problem

When using the debug chapter skip feature (pressing 1-5 on character selection screen), the game was defaulting to **English** subject instead of **Math**, causing math minigame variants to not appear.

---

## Solution

Changed the debug skip default subject from `"english"` to `"math"`.

**File:** `scripts/character_selection.gd`
**Lines:** 251-253

**Before:**
```gdscript
if PlayerStats.selected_subject == "":
    PlayerStats.selected_subject = "english"  # Fallback to English if not set
```

**After:**
```gdscript
if PlayerStats.selected_subject == "":
    PlayerStats.selected_subject = "math"  # Debug default: Math
    print("DEBUG: No subject set, defaulting to MATH for debug skip")
```

---

## How to Use

### Method 1: Debug Chapter Skip (Quick Testing) ✅

1. Run the game
2. Main Menu → **New Game**
3. **Select Character** (Conrad or Celestine)
4. **Press 1-5** on character selection screen to skip to chapter
   - **1** = Chapter 1
   - **2** = Chapter 2
   - **3** = Chapter 3
   - **4** = Chapter 4
   - **5** = Chapter 5
5. **Subject will automatically be set to MATH** ✅
6. Math minigame variants will appear!

### Method 2: Normal Playthrough (Full Experience)

1. Run the game
2. Main Menu → **New Game**
3. **Select Character** (Conrad or Celestine)
4. **Select Subject** - Choose **"Math"** on subject selection screen
5. Play through the game normally
6. Math minigame variants will appear!

---

## Testing the Math Minigame

### Using Debug Skip

1. **New Game** → Select **Celestine** (or Conrad)
2. **Press 1** to skip to Chapter 1
3. Navigate to **Chapter 1 Scene 5** (locker examination)
4. Minigame should show:

```
If Conrad finds [8] clues total and has already examined [3], how many [clues] remain?
```

**NOT:**
```
Conrad [examines] the envelope closely.
```

---

## Changing Debug Default Subject

If you want to test a different subject via debug skip, edit this line in `character_selection.gd`:

```gdscript
PlayerStats.selected_subject = "math"  # Change to "science" or "english"
```

**Options:**
- `"math"` - Math (General Mathematics)
- `"science"` - Science (Physics Q1-Q4)
- `"english"` - English (Oral Communication)

---

## Debug Console Output

When using debug skip, you should see:

```
DEBUG: selected_character = celestine
DEBUG: Skipping to Chapter 1 with character: celestine
DEBUG: Set PlayerStats.selected_character to: celestine
DEBUG: No subject set, defaulting to MATH for debug skip
DEBUG: After save_stats, PlayerStats.selected_character = celestine
```

Then when the minigame loads:

```
DEBUG: MinigameManager.start_minigame called with: locker_examination
DEBUG: PlayerStats.selected_subject = math
DEBUG: Looking for variant: locker_examination_math
DEBUG: Found in fillinTheblank_configs!
DEBUG: Using minigame variant: locker_examination_math
```

---

## Why This Happened

The debug chapter skip bypasses the **subject selection screen**, so `PlayerStats.selected_subject` was empty (`""`). The code then defaulted to `"english"`, causing English minigame variants to appear even when testing Math.

Now it defaults to `"math"` for easier testing of Math content during development.

---

## For Your Team

**If teammates want to test Science or English:**

Tell them to edit `scripts/character_selection.gd` line 252:

```gdscript
# For Science testing:
PlayerStats.selected_subject = "science"

# For English testing:
PlayerStats.selected_subject = "english"

# For Math testing (default):
PlayerStats.selected_subject = "math"
```

Or better yet, they should use **Method 2** (normal playthrough) and select their subject properly on the subject selection screen!

---

## Summary

✅ **Debug skip now defaults to Math** - Faster testing for Math subject
✅ **Math minigame variants will appear** - No more English version showing
✅ **Easy to change** - Just edit one line to test other subjects
✅ **Normal playthrough still works** - Subject selection screen still functional

**Try it now!** Run game → New Game → Select character → Press **1** → Math minigames will appear! 🎓🔢
