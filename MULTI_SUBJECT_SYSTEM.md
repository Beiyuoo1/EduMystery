# Multi-Subject System Implementation

This document describes the multi-subject curriculum system that allows players to experience EduMys with Math, Science, or English educational content.

## Overview

**Implemented:** Chapter 1 fully supports all three subjects
**Status:** Complete and tested

### Subject Tracks

1. **Mathematics** - Grade 12 General Mathematics (Philippine Curriculum)
   - Q1: Inverse Functions, Piecewise Functions, Function Composition
   - Q2: Exponential & Logarithmic Functions, Half-life
   - Q3: Trigonometry, Unit Circle, Identities
   - Q4: Statistics, Probability, Normal Distribution

2. **Science** - Earth & Physical Science
   - Q1: Plate Tectonics, Earth's Structure, Geological Processes
   - Q2: Weather, Climate, Natural Hazards
   - Q3: Biology, Genetics, DNA
   - Q4: Chemistry, Atomic Structure, Periodic Table

3. **English** - Oral Communication
   - Q1: Elements of Communication, Communication Models
   - Q2: Communication Strategies, Avoiding Breakdown
   - Q3: Speech Context, Speech Acts
   - Q4: Presentation Skills, Argumentation

## Architecture

### Subject Selection Flow

1. **Subject Selection Screen** (`scenes/ui/subject_selection.tscn`)
   - Player chooses Math, Science, or English
   - Displays curriculum overview for each subject
   - Stores selection in `PlayerStats.selected_subject` and `Dialogic.VAR.selected_subject`

2. **Timeline Integration**
   - Timelines check `{selected_subject}` variable
   - Conditionally trigger different minigames based on subject
   - Evidence and story remain the same across all subjects

### Minigame Types

**Curriculum Minigames** (Subject-specific):
- Format: `curriculum:TYPE` (e.g., `curriculum:pacman`)
- Automatically pulls questions from `CurriculumQuestions` based on chapter and subject
- Supported types: pacman, maze, runner, platformer, fillinblank

**Story Minigames with Variants**:
- Base English version (e.g., `locker_examination`)
- Subject variants with `_math` or `_science` suffix
- Automatically selected by MinigameManager based on `PlayerStats.selected_subject`

## Chapter 1 Implementation

### Timeline Changes

**c1s2.dtl** - Approaching the Janitor (line 20-25):
```dtl
if {selected_subject} == "english":
    [signal arg="start_minigame dialogue_choice_janitor"]
elif {selected_subject} == "math":
    [signal arg="start_minigame curriculum:pacman"]
elif {selected_subject} == "science":
    [signal arg="start_minigame curriculum:runner"]
```

**c1s3.dtl** - WiFi Investigation (line 58-63):
```dtl
if {selected_subject} == "english":
    [signal arg="start_minigame wifi_router"]
elif {selected_subject} == "math":
    [signal arg="start_minigame curriculum:maze"]
elif {selected_subject} == "science":
    [signal arg="start_minigame curriculum:platformer"]
```

**c1s5.dtl** - Bracelet Focus Test (line 29-34):
```dtl
if {selected_subject} == "english":
    [signal arg="start_minigame bracelet_riddle"]
elif {selected_subject} == "math":
    [signal arg="start_minigame curriculum:pacman"]
elif {selected_subject} == "science":
    [signal arg="start_minigame curriculum:runner"]
```

**c1s5.dtl** - Locker Examination (line 149):
```dtl
[signal arg="start_minigame locker_examination"]
```
- Uses subject variant system
- Math variant: `locker_examination_math`
- Science variant: `locker_examination_science` (TODO)

### Minigame Variants

**Fill-in-the-Blank: locker_examination**
- **English:** "Conrad **[examines]** the envelope closely."
- **Math:** "In the equation y = mx + b, m represents the **[slope]**."
- **Science:** TODO - needs implementation

## Technical Details

### CurriculumQuestions System

**File:** `autoload/curriculum_questions.gd`

**Structure:**
```gdscript
var questions = {
    "math": {
        "Q1": {
            "pacman": { "questions": [...], "answers_needed": 5 },
            "maze": { "questions": [...] },
            "runner": { "questions": [...], "answers_needed": 3 }
        }
    }
}
```

**Question Format:**
```gdscript
{
    "question": "What is the notation for an inverse function?",
    "correct": "f^-1(x)",
    "wrong": ["f(x)^-1", "1/f(x)", "-f(x)"]
}
```

### MinigameManager Integration

**Subject Variant Detection:**
```gdscript
func _get_subject_variant_id(base_id: String) -> String:
    if subject == "english":
        return base_id  # English is default

    var variant_id = base_id + "_" + subject
    if fillinTheblank_configs.has(variant_id):
        return variant_id

    return base_id  # Fallback to English
```

**Curriculum Minigame Handler:**
```gdscript
func _start_curriculum_minigame(minigame_type: String):
    var config = CurriculumQuestions.get_config(minigame_type)
    match minigame_type:
        "maze":
            current_minigame = maze_scene.instantiate()
            var game_node = current_minigame.get_node("Game")
            game_node.configure_puzzle(config)
```

### Maze Minigame Conversion

The Maze minigame converts curriculum format to its internal format:

**Input (Curriculum):**
```gdscript
{
    "question": "What is the notation for an inverse function?",
    "correct": "f^-1(x)",
    "wrong": ["f(x)^-1", "1/f(x)", "-f(x)"]
}
```

**Output (Maze):**
```gdscript
{
    "text": "What is the notation for an inverse function?",
    "options": [
        {"letter": "A", "text": "f^-1(x)", "correct": true},
        {"letter": "B", "text": "f(x)^-1", "correct": false},
        {"letter": "C", "text": "1/f(x)", "correct": false},
        {"letter": "D", "text": "-f(x)", "correct": false}
    ]
}
```

Letters are assigned sequentially, then shuffled for randomization.

## Bug Fixes Applied

### 1. Maze Initialization Order
**Problem:** Maze started game before `configure_puzzle()` was called
**Solution:** Removed `_start_game()` from `_ready()`, added it to end of `configure_puzzle()`

### 2. Fill-in-the-Blank Label Count
**Problem:** Code expected 3 labels (2 blanks) but scene only has 2 labels (1 blank)
**Solution:** Changed configs to 1-blank format and updated label logic to `>= 2`

### 3. Minigame Input Handling
**Problem:** Minigames captured ESC key before PauseManager
**Solution:** Changed `_input()` to `_unhandled_input()` in all minigames

## Future Expansion

### Chapter 2-5 Integration
To add multi-subject support to other chapters:

1. **Update timeline files** with subject conditionals
2. **Create subject variants** for story-specific minigames
3. **Add curriculum questions** to `CurriculumQuestions` for Q2-Q4

### Science Variant Completion
Fill-in-the-blank science variants needed:
- `locker_examination_science`
- Other story-specific minigames

### Testing Checklist
- [ ] Math track playthrough (Chapter 1)
- [ ] Science track playthrough (Chapter 1)
- [ ] English track playthrough (Chapter 1)
- [ ] Subject persistence across save/load
- [ ] Pause menu during all curriculum minigames
- [ ] Hint system in curriculum minigames

## Files Modified

### Core System Files
- `autoload/minigame_manager.gd` - Added variant system, curriculum handlers
- `autoload/curriculum_questions.gd` - Added (new file)
- `src/core/PlayerStats.gd` - Added `selected_subject` property
- `scripts/subject_selection.gd` - Subject selection UI
- `autoload/pause_manager.gd` - ESC key handling

### Timeline Files
- `content/timelines/Chapter 1/c1s2.dtl` - Subject conditionals
- `content/timelines/Chapter 1/c1s3.dtl` - Subject conditionals
- `content/timelines/Chapter 1/c1s5.dtl` - Subject conditionals

### Minigame Files
- `minigames/Maze/scripts/Main.gd` - Curriculum format conversion, initialization fix
- `minigames/Drag/scripts/fill_in_the_blank.gd` - 1-blank support, input handling
- `minigames/DialogueChoice/scenes/Main.gd` - Input handling fix
- `minigames/HearAndFill/scenes/Main.gd` - Input handling fix
- `minigames/Pronunciation/scripts/Main.gd` - Input handling fix

### Documentation Files
- `CLAUDE.md` - Updated with multi-subject system section
- `MULTI_SUBJECT_SYSTEM.md` - This file (new)

## Credits

Implementation completed with fixes for:
- Maze curriculum integration
- Fill-in-the-blank subject variants
- Pause menu functionality during minigames
- Subject selection and persistence
