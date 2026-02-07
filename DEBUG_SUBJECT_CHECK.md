# Debug: Why Math Minigames Aren't Showing

## The Problem

You're seeing the English version of `dialogue_choice_ria_note` instead of the math variant.

**Text shown**: "She feared it would make her look guilty"
**Expected (Math)**: "The lockbox contained 20,000 pesos divided into 100, 500, and 1000 peso bills..."

## Root Cause

You're loading a save file where `PlayerStats.selected_subject = "english"`.

The math variant system works like this:

```gdscript
# MinigameManager._get_subject_variant_id()
var subject = PlayerStats.selected_subject  # This is "english" in your save file
var variant_id = base_id + "_" + subject    # "dialogue_choice_ria_note" + "_english"
# Since dialogue_choice_ria_note_english doesn't exist, it falls back to base (English)
```

## The Solution

### Option 1: Start a Fresh Game (Recommended)

1. **Exit to main menu**
2. Click **"New Game"** (not "Continue")
3. **Select "Mathematics"** on the subject selection screen
4. Play through Chapter 2
5. The math minigames will now appear

### Option 2: Delete Your Save Files

1. Navigate to the save file location:
   - Windows: `%APPDATA%\Godot\app_userdata\EduMys\saves\`
   - Or check: `user://saves/` folder
2. Delete all `.sav` files
3. Start a new game
4. Select "Mathematics"

### Option 3: Test with Console (If You Have Debug Access)

If you have access to the Godot console while the game is running:

1. Press F12 or access the debug console
2. Run: `PlayerStats.selected_subject = "math"`
3. Run: `PlayerStats.save_stats()`
4. Continue playing

## How to Verify It's Working

When you start Chapter 2 Scene 3 (c2s3) with math selected, you should see:

**Question**: "The lockbox contained 20,000 pesos divided into 100, 500, and 1000 peso bills. If there are 8 bills of 1000, 12 bills of 500, and the rest are 100 peso bills, how many 100 peso bills are there?"

**Choices**:
1. ✅ Subtract (8×1000 + 12×500) from 20000, then divide by 100
2. ❌ Add 8, 12, and 100, then multiply by 1000
3. ❌ Multiply 8 by 1000 and divide by 100
4. ❌ Divide 20000 by 100 and subtract 8 and 12

## Debug Output to Check

When the minigame starts, look for these console messages:

```
DEBUG: MinigameManager.start_minigame called with: dialogue_choice_ria_note
DEBUG: PlayerStats.selected_subject = math
DEBUG: Looking for variant: dialogue_choice_ria_note_math
DEBUG: Found in dialogue_choice_configs!
DEBUG: Using minigame variant: dialogue_choice_ria_note_math
```

If you see `selected_subject = english`, that's the issue.

## Why This Happens

Save files persist player data including:
- Level, XP, Score
- Hints remaining
- **Selected subject** ← This is the issue
- Evidence collected

When you load a save, it restores ALL this data, including the subject you originally selected.

## Prevention for Future Testing

When testing new subject variants:
1. Always start a **completely fresh game**
2. Select the subject you want to test
3. Don't load old save files from before the variant was added

---

**TL;DR**: Start a new game and select "Mathematics" at the beginning. Your current save file has `selected_subject = "english"` which is why you're seeing English minigames.
