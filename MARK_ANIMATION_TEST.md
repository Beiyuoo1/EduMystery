# Mark Animation Test Guide

## Setup Verification

All files are now properly configured for Mark's animated portrait:

✅ **Script**: `scenes/portraits/mark_animated_portrait.gd`
✅ **Scene**: `scenes/portraits/mark_animated_portrait.tscn`
✅ **Character**: `content/characters/Mark.dch` → Mark_half portrait uses animated scene
✅ **Animation Frames**: `Characters/animation/mark/` (Mark_half.png + 5 talking frames)

## How to Test

1. **Restart Godot completely** - This is CRITICAL! Close and reopen the project.

2. **Run Chapter 5, Scene 0** - This is a good test scene since Mark speaks several times.

3. **Watch the console output** - You should see these debug messages when Mark speaks:
   ```
   Mark portrait: text_started signal received
   Mark portrait: Checking if speaking. character = [Character:123456]
   Mark portrait: character.display_name = Mark
   Mark portrait: current_speaker = [Character:123456]
   Mark portrait: Mark is speaking!
   Mark: Started talking animation
   ```

4. **Visual check** - Mark's mouth should animate through frames 1-5 when he speaks, return to idle when he stops.

## Troubleshooting

### If Mark stays idle all the time:

**Check 1: Is the animated portrait being loaded?**
- Open Godot
- Open `content/characters/Mark.dch` in the Dialogic editor
- Check the "Mark_half" portrait settings
- Scene path should be: `res://scenes/portraits/mark_animated_portrait.tscn`
- If it shows the old path, manually update it in the Dialogic editor

**Check 2: Are signals connecting?**
- Look for this in console when the scene starts:
  ```
  Mark portrait: Signals connected
  ```
- If missing, the `_ready()` function isn't running

**Check 3: Character name mismatch?**
- The script checks for `character.display_name == "Mark"`
- Verify in console output what name Dialogic is using
- If different, update line 68 in `mark_animated_portrait.gd`

**Check 4: Godot caching issue**
- Close Godot
- Delete `.godot/` folder (will regenerate on next open)
- Reopen project

### If you see errors in console:

**"Cannot find portrait scene"**
- Scene path in Mark.dch is wrong
- Manually check and fix the path

**"AnimatedSprite2D is null"**
- Scene structure is broken
- Reopen `mark_animated_portrait.tscn` in Godot editor
- Verify AnimatedSprite2D node exists under root

## Expected Behavior

When working correctly:
- Mark's portrait appears with mouth closed (idle frame)
- When `Mark:` dialogue starts, mouth animates through 5 frames
- Animation loops continuously while Mark speaks
- Returns to idle frame when dialogue ends or another character speaks
- Portrait highlights (becomes brighter) when Mark is the active speaker

## Files Modified

1. `scenes/portraits/mark_animated_portrait.gd` (NEW)
2. `scenes/portraits/mark_animated_portrait.tscn` (NEW)
3. `content/characters/Mark.dch` (UPDATED - line 36 scene path)
4. `CLAUDE.md` (UPDATED - documentation)

## Comparison with Conrad

Mark's animation system is identical to Conrad's:
- Same script structure (just "Conrad" replaced with "Mark")
- Same animation names: "idle" and "talking"
- Same signal connections
- Same frame rate (10 FPS for talking)

If Conrad's animation works but Mark's doesn't, it's likely a Godot cache issue or the character file needs to be updated in the Dialogic editor UI.
