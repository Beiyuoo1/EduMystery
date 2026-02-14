# Image-Based Timeline Reconstruction - User Guide

## Overview

The Timeline Reconstruction minigame has been completely redesigned with a modern, horizontal layout featuring **visual images** for each event. This makes the minigame more intuitive and engaging!

## New Layout

### Visual Structure
```
┌─────────────────────────────────────────────────┐
│         ⏱ Timeline Reconstruction              │
│  Arrange events using mathematical reasoning    │
├─────────────────────────────────────────────────┤
│  ⏱ Timer: 02:00  │  💡 Use Hint  │ Hints: 3   │
├─────────────────────────────────────────────────┤
│  Context: Janitor mopped at 3:00 PM...         │
├─────────────────────────────────────────────────┤
│                                                 │
│    📊 Timeline (Earliest → Latest)             │
│  ┌────┐  ┌────┐  ┌────┐  ┌────┐  ┌────┐      │
│  │ 1  │  │ 2  │  │ 3  │  │ 4  │  │ 5  │      │
│  │ ⬇  │  │ ⬇  │  │ ⬇  │  │ ⬇  │  │ ⬇  │      │
│  │Empty│  │Empty│  │Empty│  │Empty│  │Empty│      │
│  └────┘  └────┘  └────┘  └────┘  └────┘      │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│         📦 Events Pool                          │
│  ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐     │
│  │[IMAGE]│ │[IMAGE]│ │[IMAGE]│ │[IMAGE]│     │
│  │       │ │       │ │       │ │       │     │
│  │  Text │ │  Text │ │  Text │ │  Text │     │
│  └───────┘ └───────┘ └───────┘ └───────┘     │
│                                                 │
├─────────────────────────────────────────────────┤
│           ✓ Submit Timeline                     │
└─────────────────────────────────────────────────┘
```

### Key Changes
1. **Horizontal Layout**: Both timeline and event pool are now in rows (left-to-right)
2. **Timeline in Middle**: 5 numbered slots show where to place events
3. **Event Pool at Bottom**: Shuffled image cards with text captions
4. **Visual Feedback**: Slots highlight green when filled, cards glow on hover

## Image Integration

### Image Requirements
- **Format**: PNG (recommended)
- **Size**: 164x164 pixels minimum (square aspect ratio works best)
- **Location**: `assets/minigame_asset/timeline_analysis/chapter_N_name/`
- **Naming**: Descriptive names (e.g., `janitor_mopping.png`, `floor_drying.png`)

### Card Structure
Each event card consists of:
```
┌──────────────┐
│              │
│    [IMAGE]   │  164x164px texture
│              │
├──────────────┤
│  Caption Text│  14px, centered, word-wrap
│  (3:00 PM)   │
└──────────────┘
```

### Protagonist-Specific Images
Use `{protagonist}` placeholder in image paths for character-specific images:
```gdscript
"image_path": "res://assets/minigame_asset/timeline_analysis/.../footprint_discovered_{protagonist}.png"
```

This will automatically replace `{protagonist}` with:
- `"conrad"` if Conrad is selected
- `"celestine"` if Celestine is selected

**Example Files:**
- `footprint_discovered_conrad.png`
- `footprint_discovered_celestine.png`

## Configuration Format

### Updated Event Structure
```gdscript
"timeline_footprints_math": {
    "title": "Footprint Timeline Analysis",
    "context": "Arrange the events in chronological order...",
    "events": [
        {
            "id": "event1",
            "text": "Janitor mops floor\n(3:00 PM)",  // Text shown below image
            "image_path": "res://assets/minigame_asset/timeline_analysis/chapter_1_time_analysis/janitor_mopping.png"
        },
        {
            "id": "event5",
            "text": "Footprints discovered\n(5:30 PM)",
            "image_path": "res://assets/.../footprint_discovered_{protagonist}.png"  // Protagonist-specific!
        }
    ],
    "correct_order": ["event1", "event2", "event3", "event4", "event5"],
    "explanation": "[b]Mathematical Reasoning:[/b]\n..."
}
```

### Text Caption Guidelines
- **Keep it short**: 2-3 lines maximum
- **Include time**: Add timestamp in parentheses
- **Use `\n`**: Line breaks for readability
- **Centered**: Text auto-centers below image

## Gameplay Flow

### 1. Initial State
- Timeline slots are empty with down arrows (⬇) and "Empty" text
- Event pool shows 5 shuffled image cards at the bottom
- All cards have blue borders and drop shadows

### 2. Clicking an Event Card
- Card animates with hover glow (blue border brightens)
- Click moves card to first empty timeline slot
- Slot border changes to green (filled state)
- Placeholder content replaced with card

### 3. Removing a Card
- Click card in timeline to move it back to event pool
- Slot reverts to empty state (gray border, down arrow)
- Card returns to events pool at bottom

### 4. Submitting
- Click "✓ Submit Timeline" button
- Checks if order matches `correct_order` array
- Shows feedback modal with icon and explanation

## Modern Styling

### Color Scheme
- **Events Pool Header**: Blue (`#7FB2F2`) - "📦 Events Pool"
- **Timeline Header**: Green (`#6DD662`) - "📊 Timeline"
- **Empty Slots**: Gray-blue, dashed border
- **Filled Slots**: Green border, darker background
- **Event Cards**: Blue-gray gradient with shadows

### Hover Effects
- **Cards**: Elevate with 10px shadow, blue glow
- **Buttons**: Lighten background, add shadow

### Animations
- **Feedback Modal**: 0.3s fade-in, 0.2s fade-out
- **Hint Flash**: 3 cycles of yellow pulsing
- **Card Hover**: Smooth 0.15s transition

## Example: Chapter 1 Footprint Timeline

### Images Used
1. `janitor_mopping.png` - Janitor with mop bucket
2. `floor_drying.png` - Wet floor gradually drying
3. `entered_faculty.png` - Door opening to faculty room
4. `complete_dry.png` - Completely dry floor surface
5. `footprint_discovered_conrad.png` - Conrad finding footprints
6. `footprint_discovered_celestine.png` - Celestine finding footprints

### Timeline Order (Correct)
```
Slot 1: [Janitor mopping] (3:00 PM)
Slot 2: [Floor drying] (3:00 PM - 3:45 PM)
Slot 3: [Someone enters] (3:30 PM)
Slot 4: [Complete dry] (3:45 PM)
Slot 5: [Footprints discovered] (5:30 PM)
```

### Mathematical Reasoning
- **t = 0 min**: Janitor mops at 3:00 PM
- **t = 0 to 45**: Floor dries over 45 minutes
- **t = 30 min**: Footprints made at 3:30 PM (still wet)
- **t = 45 min**: Floor fully dry at 3:45 PM
- **t = 150 min**: Protagonist discovers footprints at 5:30 PM

## Testing Checklist

### Visual Tests
- [ ] Images load correctly for all events
- [ ] Text captions are readable and centered
- [ ] Cards are properly sized (180x220px container)
- [ ] Protagonist-specific images work for both Conrad and Celestine

### Interaction Tests
- [ ] Clicking event card moves it to first empty slot
- [ ] Clicking timeline card moves it back to pool
- [ ] Hover effects work on all cards
- [ ] Submit button validates order correctly

### Feedback Tests
- [ ] Correct order shows green checkmark and success message
- [ ] Incorrect order shows red X with correct sequence
- [ ] Mathematical reasoning displays with proper formatting
- [ ] Retry button resets all cards to pool

### Responsive Tests
- [ ] Layout scales on different screen sizes
- [ ] Scroll containers work for overflow
- [ ] Timer updates every second
- [ ] Hint system places correct card

## Troubleshooting

### Images Not Loading
**Problem**: TextureRect shows empty/gray
**Solution**:
1. Check image path is correct (`res://assets/...`)
2. Ensure image file exists in folder
3. Verify Godot imported the image (check `.import` files)
4. Reload project if images were just added

### Protagonist Placeholder Not Working
**Problem**: `{protagonist}` not replaced
**Solution**:
1. Verify `PlayerStats.selected_character` is set
2. Check spelling: `{protagonist}` (lowercase, singular)
3. Ensure replacement happens before `load()`
4. Debug print the final path

### Cards Not Clickable
**Problem**: Clicking cards does nothing
**Solution**:
1. Check button signal is connected: `button.pressed.connect(...)`
2. Verify `_on_event_card_pressed()` is called
3. Ensure mouse filter is not blocking clicks
4. Check if card is properly added to scene tree

### Timeline Slots Not Updating
**Problem**: Cards don't move to slots
**Solution**:
1. Verify `_move_card_to_slot()` is called
2. Check placeholder_container structure
3. Ensure card is reparented correctly
4. Call `_update_current_order()` after changes

## Future Enhancements

### Potential Features
- [ ] Drag-and-drop instead of click-to-place
- [ ] Animation when card moves to slot
- [ ] Sound effects for interactions
- [ ] Particle effects on correct placement
- [ ] Zoom preview on image hover
- [ ] Multiple timeline variations per chapter
- [ ] Accessibility: Keyboard navigation
- [ ] Mobile: Touch gesture support

## Credits

**Design Pattern**: Horizontal timeline visualization
**Inspired By**: Educational timeline tools, museum exhibits
**Art Style**: Modern minimalist with depth shadows
**UI Framework**: Godot 4.5 Control nodes with StyleBoxFlat

---

For more information, see:
- [MODERN_UI_DESIGN.md](MODERN_UI_DESIGN.md) - Complete styling guide
- [Main.gd](scenes/Main.gd) - Implementation details
- [minigame_manager.gd](../../autoload/minigame_manager.gd) - Configuration examples
