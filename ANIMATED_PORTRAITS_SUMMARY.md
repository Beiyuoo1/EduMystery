# Animated Portraits Summary

This document summarizes all the animated character portraits created for the EduMys visual novel game.

## Overview

All animated portraits use the same system:
- **Extends** `DialogicPortrait` for Dialogic 2.x compatibility
- **Uses** `AnimatedSprite2D` with "idle" and "talking" animations
- **Automatically** plays "talking" animation when the character speaks
- **Returns** to "idle" when dialogue stops or another character speaks
- **5 animation frames** at 10 FPS for talking animation
- **Highlight/unhighlight** effects when becoming active/inactive speaker

## Complete Character List (18 Animated Portraits)

### Main Characters

#### 1. Conrad (Main Protagonist - Male)
- **Files**: `scenes/portraits/conrad_animated_portrait.tscn/gd`
- **Idle**: `Conrad_half.png`
- **Talking**: `Conrad_half_mouth_animation_1-5.png`
- **Usage**: `join Conrad (animated) left`

#### 2. Celestine (Main Protagonist - Female)
- **Files**: `scenes/portraits/celestine_animated_portrait.tscn/gd`
- **Idle**: `Sprites/mouth_animation/Celestine/Thebe_half.png`
- **Talking**: `Celestine_half_mouth_animation_1-5.png`
- **Usage**: `join Celestine (animated) left`

#### 3. Mark (Best Friend)
- **Files**: `scenes/portraits/mark_animated_portrait.tscn/gd`
- **Idle**: `Characters/animation/mark/Mark_half.png`
- **Talking**: `Mark_half mouth animation 1-5.png`
- **Usage**: `join Mark (animated) left`

---

### Chapter 1: The Stolen Exam Papers

#### 4. Janitor Fred
- **Files**: `scenes/portraits/janitor_animated_portrait.tscn/gd`
- **Idle**: `Sprites/Janitor_half.png`
- **Talking**: `Sprites/mouth_animation/Janitor/Janitor_half mouth animation 1-5.png`
- **Usage**: `join "Janitor Fred" (animated) left`

#### 5. Principal Alan
- **Files**: `scenes/portraits/principal_animated_portrait.tscn/gd`
- **Idle**: `Sprites/mouth_animation/Principal/Principal_half idle.png`
- **Talking**: `Principal_half mouth animation 1-5.png`
- **Special**: Supports both "Principal Alan" and "Principal" display names
- **Usage**: `join "Principal Alan" (animated) left`

#### 6. Greg (Regular Expression)
- **Files**: `scenes/portraits/greg_animated_portrait.tscn/gd`
- **Idle**: `Sprites/Greg_half.png`
- **Talking**: `Sprites/mouth_animation/Greg/Greg_half mouth animation 1-5.png`
- **Usage**: `join Greg (animated) left`

#### 7. Greg (Sad Expression)
- **Files**: `scenes/portraits/greg_sad_animated_portrait.tscn/gd`
- **Idle**: `Sprites/Greg_sad_half.png`
- **Talking**: `Sprites/mouth_animation/Greg_sad/Greg_half sad mouth animation 1-5.png`
- **Usage**: `join Greg (animated_sad) left`
- **Note**: Use for emotional scenes after being caught

---

### Chapter 2: The Student Council Mystery

#### 8. Diwata Laya (Student Council President)
- **Files**: `scenes/portraits/laya_animated_portrait.tscn/gd`
- **Idle**: `Sprites/Laya_half.png`
- **Talking**: `Sprites/mouth_animation/Laya/Laya_half mouth animation 1-5.png`
- **Usage**: `join "Diwata Laya" (animated) left`

#### 9. Ms. Santos (Faculty Advisor)
- **Files**: `scenes/portraits/ms_santos_animated_portrait.tscn/gd`
- **Idle**: `Sprites/MsSantos_half.png`
- **Talking**: `Sprites/mouth_animation/MsSantos/MsSantos_half mouth animation 1-5.png`
- **Usage**: `join "Ms. Santos" (animated) left`

#### 10. Ria (Student Council Treasurer)
- **Files**: `scenes/portraits/ria_animated_portrait.tscn/gd`
- **Idle**: `Sprites/Ria_half.png`
- **Talking**: `Sprites/mouth_animation/Ria/Ria_half mouth animation 1-5.png`
- **Usage**: `join Ria (animated) left`

#### 11. Ryan (Former Student Council President - Blackmailer)
- **Files**: `scenes/portraits/ryan_animated_portrait.tscn/gd`
- **Idle**: `Sprites/Ryan_half.png`
- **Talking**: `Sprites/mouth_animation/Ryan/Ryan_half mouth animation 1-5.png`
- **Usage**: `join Ryan (animated) left`

---

### Chapter 3: Art Week Vandalism

#### 12. Victor (Art Student - Vandal)
- **Files**: `scenes/portraits/victor_animated_portrait.tscn/gd`
- **Idle**: `Characters/Victor.png`
- **Talking**: `Sprites/mouth_animation/Victor/Victor_half mouth animation 1-5.png`
- **Usage**: `join Victor (animated) left`

---

### Chapter 4: Anonymous Notes Mystery

#### 13. Alex (Former Student Council Treasurer - Note Sender)
- **Files**: `scenes/portraits/alex_animated_portrait.tscn/gd`
- **Idle**: `Sprites/Alex_half.png`
- **Talking**: `Sprites/mouth_animation/Alice/Alex_half  mouth animation 1-5.png`
- **Usage**: `join Alex (animated) left`

#### 14. Ben (Student)
- **Files**: `scenes/portraits/ben_animated_portrait.tscn/gd`
- **Idle**: `Sprites/Ben_half.png`
- **Talking**: `Sprites/mouth_animation/Ben/Ben_half mouth animation 1-5.png`
- **Usage**: `join Ben (animated) left`

---

## Technical Implementation

### File Structure
Each animated portrait consists of:
1. **Scene file** (`.tscn`) - Godot scene with AnimatedSprite2D node
2. **Script file** (`.gd`) - GDScript extending DialogicPortrait
3. **UID files** (`.tscn.uid` and `.gd.uid`) - Godot resource identifiers

### Animation System
- **Idle Animation**: 1 frame, looping at 5 FPS
- **Talking Animation**: 5 frames, looping at 10 FPS
- **Signal-based**: Connects to Dialogic.Text signals
  - `text_started` - Checks if character should start talking
  - `text_finished` - Stops talking animation
  - `speaker_updated` - Checks if speaker changed

### Character Configuration
Each character's `.dch` file includes:
```gdscript
"animated": {
    "export_overrides": {},
    "mirror": false,
    "offset": Vector2(0, 0),
    "scale": 0.7,  // or 0.8 depending on character
    "scene": "res://scenes/portraits/[character]_animated_portrait.tscn"
}
```

## Usage in Timelines

### Basic Usage
```dtl
join CharacterName (animated) left
CharacterName: Dialogue text appears here.
```

### Multiple Expressions (Greg Example)
```dtl
# Regular expression
join Greg (animated) left
Greg: I didn't mean to do it...

# Switch to sad expression
join Greg (animated_sad) left
Greg: I'm sorry... I was desperate...
```

### Special Display Names
Some characters require quotes in timeline files:
```dtl
join "Diwata Laya" (animated) left
join "Ms. Santos" (animated) left
join "Janitor Fred" (animated) left
join "Principal Alan" (animated) left
```

## Performance Notes

- All portraits use the same animation system for consistency
- 5 talking frames at 10 FPS provides smooth mouth movement
- Idle frames use single static image for memory efficiency
- Signal-based activation ensures accurate sync with dialogue
- Modulate tweening provides smooth highlight/unhighlight effects

## Future Additions

To add a new animated portrait:
1. Create 5 mouth animation frames in `Sprites/mouth_animation/[CharacterName]/`
2. Create scene file using template from existing portraits
3. Create script file extending DialogicPortrait
4. Update character's `.dch` file with animated portrait entry
5. Set animated portrait as default if desired
6. Test in game to verify animation triggers correctly

---

**Last Updated**: February 2026
**Total Animated Portraits**: 14 characters (18 including expression variants)
