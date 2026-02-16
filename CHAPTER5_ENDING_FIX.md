# Chapter 5 Ending Flow Fix

## Problem

**Original Issue:**
After completing Chapter 5 (the final chapter), the game showed "The chain continues" text and then transitioned to the **main menu** instead of returning to the **character selection screen**.

**Additional Issue (Fixed):**
When loading a save file near the ending and completing Chapter 5, the game returned to the **Load Game screen** instead of character selection. This was because the cleanup code didn't remove all UI scenes from the scene tree.

---

## Solution
Changed the ending flow to return to the **character selection screen** after Chapter 5 completion.

This allows players to:
- ✅ **Replay the entire story** with the other protagonist (Conrad or Celestine)
- ✅ **Experience dual protagonist content** without having to navigate through the main menu
- ✅ **Compare different playthroughs** easily
- ✅ **Test chapter skip feature** (press 1-5 on character selection) for development

---

## Implementation

**File: `scenes/ui/the_end_screen.gd`**

### Change 1: Scene Transition Target (Line 109)

**Before:**
```gdscript
# Change scene to main menu
get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
```

**After:**
```gdscript
# Change scene to character selection screen (to allow replaying with different character)
get_tree().change_scene_to_file("res://scenes/ui/character_selection.tscn")
```

### Change 2: Comprehensive Scene Tree Cleanup (Lines 92-117)

**Before (Limited Cleanup):**
```gdscript
# Clean up all CanvasLayers that might be blocking input
var root = get_tree().root
for child in root.get_children():
    if child is CanvasLayer and child.layer >= 100:
        print("DEBUG: Cleaning up CanvasLayer with layer ", child.layer)
        child.queue_free()
```

**After (Complete Cleanup):**
```gdscript
# Clean up ALL scenes in the scene tree except the root viewport
# This ensures we don't carry over Load Game screens, Main Menu, or other UI
var root = get_tree().root
var children_to_remove = []

for child in root.get_children():
    # Skip the current scene (we'll remove it when changing scenes)
    if child == get_tree().current_scene:
        continue
    # Skip Window nodes (essential system nodes)
    if child is Window:
        continue
    # Queue everything else for removal (UI screens, CanvasLayers, etc.)
    children_to_remove.append(child)

for child in children_to_remove:
    print("DEBUG: Cleaning up scene tree child: ", child.name, " (", child.get_class(), ")")
    child.queue_free()
```

**Why This Matters:**
- The old cleanup only removed CanvasLayers with layer >= 100
- This missed UI screens like Load Game, Main Menu, Save screens, etc.
- The new cleanup removes ALL non-essential nodes from the scene tree
- This ensures a clean transition to character selection regardless of how you reached the ending

---

## Flow Diagram

### Before (Old Flow)
```
Chapter 5 Complete
    ↓
Simple Results Screen (LEVEL UP! + Stars)
    ↓
Mind Games Reviewer (Educational Content)
    ↓
"The End" Screen ("The chain continues")
    ↓
Main Menu ❌ (Player has to click New Game → Choose Character again)
```

### After (New Flow)
```
Chapter 5 Complete
    ↓
Simple Results Screen (LEVEL UP! + Stars)
    ↓
Mind Games Reviewer (Educational Content)
    ↓
"The End" Screen ("The chain continues")
    ↓
Character Selection Screen ✅ (Player can immediately replay with other protagonist)
```

---

## Testing

To verify the fix works correctly:

### Test Case 1: Normal Playthrough
1. **Play through Chapter 5** (or use debug skip by pressing `5` on character selection)
2. **Complete the chapter** and watch all three result screens:
   - ✅ Simple Results Screen (LEVEL UP!)
   - ✅ Mind Games Reviewer
   - ✅ "The End" Screen
3. **Press any key** after "The chain continues" appears
4. **Verify** you return to the character selection screen (not main menu)
5. **Select the other protagonist** to replay the story

### Test Case 2: Load Save Near Ending (IMPORTANT!)
1. From **Main Menu**, click **Continue** to open Load Game screen
2. **Load a save file** that's at or near Chapter 5 ending (c5s3, c5s4, or c5s5)
3. **Complete Chapter 5** and watch all three result screens
4. **Press any key** after "The chain continues" appears
5. **Verify** you return to the character selection screen (NOT Load Game screen!)
6. The Load Game screen should be completely cleaned up from memory

### Expected Results
✅ Both test cases should return to character selection screen
✅ No UI screens should remain in the background
✅ Character selection screen should be fully functional
✅ You can start a new game or use debug skip immediately

---

## Related Features

### Dual Protagonist System
The game supports 100% feature parity between Conrad (male) and Celestine (female):
- All 5 chapters fully support both protagonists
- Different dialogue and perspectives
- Both protagonists have full voice narration coverage
- Same educational content and minigames

### Debug Chapter Skip
For testing purposes, press **1-5** on the character selection screen to skip to any chapter:
- **1** = Chapter 1 (Stolen Exam Papers)
- **2** = Chapter 2 (Student Council Mystery)
- **3** = Chapter 3 (Art Week Vandalism)
- **4** = Chapter 4 (Anonymous Notes)
- **5** = Chapter 5 (B.C. Revelation)

---

## Benefits

✅ **Better UX** - Players can easily replay with the other protagonist
✅ **Encourages replayability** - Seamless transition to second playthrough
✅ **Testing-friendly** - Developers can quickly test dual protagonist content
✅ **Narrative continuity** - Character selection screen fits the "choose your path" theme
✅ **No extra clicks** - Direct transition without menu navigation

---

## Files Modified

- **scenes/ui/the_end_screen.gd** - Changed scene transition from main menu to character selection

---

## Notes

- The main menu is still accessible via the "< Back" button on the character selection screen
- This change only affects Chapter 5 endings
- Chapters 1-4 still resume Dialogic normally and continue to the next chapter
- Save/load system is unaffected by this change
