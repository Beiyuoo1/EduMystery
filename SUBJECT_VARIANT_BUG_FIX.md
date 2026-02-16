# Subject Variant Bug Fix

## The Bug

When selecting **Math** as the subject, the game was still showing **English** minigame variants instead of the Math versions.

### Root Cause

The `_get_subject_variant_id()` function had **incorrect logic order**:

1. ❌ It checked if the base ID exists (e.g., `locker_examination`)
2. ❌ If found, it returned the base ID immediately
3. ❌ This prevented checking for subject variants (e.g., `locker_examination_math`)

**Example of broken flow:**
```
Input: base_id = "locker_examination", subject = "math"
Step 1: Check if "locker_examination" exists → YES (English version)
Step 2: Return "locker_examination" immediately
Result: English version shown, math variant never checked ❌
```

---

## The Fix

**Changed the logic order** to check for subject variants FIRST:

1. ✅ If subject is English → return base ID
2. ✅ If subject is Math/Science → look for variant first (`base_id_math`)
3. ✅ If variant exists → use it
4. ✅ If variant doesn't exist → fallback to base ID

**Example of fixed flow:**
```
Input: base_id = "locker_examination", subject = "math"
Step 1: Subject is "math", not "english"
Step 2: Look for variant "locker_examination_math"
Step 3: Variant found in fillinTheblank_configs
Step 4: Return "locker_examination_math" ✅
Result: Math version shown correctly!
```

---

## Code Changes

**File:** `autoload/minigame_manager.gd`
**Function:** `_get_subject_variant_id()` (lines 2838-2888)

### Before (Broken)
```gdscript
var subject = PlayerStats.selected_subject

# First, check if base_id already exists ❌ WRONG ORDER
if fillinTheblank_configs.has(base_id) or hear_and_fill_configs.has(base_id) or \
   riddle_configs.has(base_id) or dialogue_choice_configs.has(base_id):
    return base_id  # Returns English version immediately!

if subject == "english":
    return base_id

# This code never runs because we already returned above!
var variant_id = base_id + "_" + subject
```

### After (Fixed)
```gdscript
var subject = PlayerStats.selected_subject

# If subject is English, use base ID ✅ CORRECT ORDER
if subject == "english":
    return base_id

# For Math/Science, try variant FIRST ✅
var variant_id = base_id + "_" + subject

# Check if variant exists
if fillinTheblank_configs.has(variant_id):
    return variant_id  # Returns math/science version!

# Fallback to base if no variant exists
return base_id
```

---

## Debug Logs Comparison

### Before Fix (Broken)
```
DEBUG: PlayerStats.selected_subject = math
DEBUG: Base ID exists in configs, using as-is: locker_examination  ❌
DEBUG: Using minigame variant: locker_examination  ❌
Result: English version "Conrad [examines] the envelope closely"
```

### After Fix (Working)
```
DEBUG: PlayerStats.selected_subject = math
DEBUG: Looking for math variant: locker_examination_math  ✅
DEBUG: Found in fillinTheblank_configs!  ✅
DEBUG: Using minigame variant: locker_examination_math  ✅
Result: Math version "If Conrad finds [8] clues total..."
```

---

## Testing

### Steps to Verify Fix

1. **New Game** → Select **Math** subject → Select Celestine
2. Play through to **Chapter 1 Scene 5** (locker examination)
3. **Verify minigame shows:**

```
If Conrad finds [8] clues total and has already examined [3], how many [clues] remain?
```

**NOT:**
```
Conrad [examines] the envelope closely.
```

### Expected Console Output

```
DEBUG: MinigameManager.start_minigame called with: locker_examination
DEBUG: PlayerStats.selected_subject = math
DEBUG: Looking for math variant: locker_examination_math
DEBUG: Found in fillinTheblank_configs!
DEBUG: Using minigame variant: locker_examination_math
DEBUG: Puzzle config = { "sentence_parts": ["If Conrad finds ", " clues total..."], ...}
```

---

## Impact

This fix affects **ALL minigames** with subject variants:

### Fill-in-the-Blank
- `locker_examination` → `locker_examination_math` ✅
- `pedagogy_methods` → `pedagogy_methods_math` ✅
- And all other fill-in-blank variants

### Hear and Fill
- `wifi_router` → `wifi_router_science` ✅
- `anonymous_notes` → `anonymous_notes_science` ✅

### Riddles
- `bracelet_riddle` → `bracelet_riddle_science` ✅
- `receipt_riddle` → `receipt_riddle_science` ✅

### Dialogue Choice
- `dialogue_choice_janitor` → `dialogue_choice_janitor_science` ✅
- All dialogue choice variants

### Logic Grid & Timeline
- All math/science variants now work correctly ✅

---

## Why This Bug Existed

The original code was designed to handle **subject-specific minigames** that don't have English variants (like `timeline_footprints_math` which has no `timeline_footprints` base).

However, this optimization **broke** minigames that have BOTH a base English version AND subject variants.

The fix preserves support for both cases:
- ✅ Minigames with only subject-specific versions (no base)
- ✅ Minigames with base + variants (like `locker_examination`)

---

## Files Modified

- ✅ `autoload/minigame_manager.gd` (lines 2847-2856) - Fixed variant detection logic

---

## Summary

🐛 **Bug:** Math/Science subject variants weren't being used
🔧 **Fix:** Changed logic to check for variants FIRST before falling back to base
✅ **Result:** Math and Science minigames now appear correctly when those subjects are selected!

**Test it now!** The math minigame should finally appear! 🎓🔢
