# Curriculum Minigame Initialization Fix

## Issue

When selecting the **Science** subject in Chapter 1, the first minigame (Runner) was asking "What is the capital of France?" instead of showing science-related questions about plate tectonics.

## Root Cause

The curriculum minigames (Runner, Pacman, Platformer) were starting the game in `_ready()` with hardcoded test questions **before** `configure_puzzle()` was called to provide the proper subject-specific questions from `curriculum_questions.gd`.

**Problematic Flow:**
1. Minigame scene instantiated
2. `_ready()` runs → Starts game with test questions (capital of France, etc.)
3. `configure_puzzle()` called later → Questions updated, but game already started with wrong questions

## Files Fixed

### 1. Runner Minigame ✅
**File:** `minigames/Runner/scripts/Main.gd`

**Before:**
```gdscript
func _ready():
    screen_size = get_viewport_rect().size
    _setup_lanes()

    # Default questions for testing
    if questions.is_empty():
        questions = [
            {
                "question": "What is the capital of France?",
                "correct": "Paris",
                "wrong": ["London", "Berlin", "Madrid"]
            },
            # ... more test questions
        ]

    _start_game()  # ❌ Starts with test questions

func configure_puzzle(config: Dictionary):
    if config.has("questions"):
        questions = config.questions
    # No game start here
```

**After:**
```gdscript
func _ready():
    screen_size = get_viewport_rect().size
    _setup_lanes()
    # Don't start game yet - wait for configure_puzzle()

func configure_puzzle(config: Dictionary):
    if config.has("questions"):
        questions = config.questions
    if config.has("answers_needed"):
        correct_answers_needed = config.answers_needed
    if config.has("starting_speed"):
        game_speed = config.starting_speed

    # ✅ Start game after configuration
    _start_game()
```

### 2. Pacman Minigame ✅
**File:** `minigames/Pacman/scripts/Main.gd`

**Before:**
```gdscript
func _ready():
    if not is_configured:
        start_game()  # ❌ Starts with test questions

func configure_puzzle(config: Dictionary) -> void:
    if config.has("questions"):
        questions = config.questions
    is_configured = true
    start_game()  # ✅ Starts again with configured questions (double start!)
```

**After:**
```gdscript
func _ready():
    # Don't start game yet - wait for configure_puzzle()
    pass

func configure_puzzle(config: Dictionary) -> void:
    if config.has("questions"):
        questions = config.questions
    is_configured = true
    start_game()  # ✅ Only starts once, with configured questions
```

### 3. Platformer Minigame ✅
**File:** `minigames/Platformer/scripts/Main.gd`

**Before:**
```gdscript
func _ready():
    # Default questions for testing
    if questions.is_empty():
        questions = [...]  # Test questions

    _start_game()  # ❌ Starts with test questions

func configure_puzzle(config: Dictionary):
    if config.has("questions"):
        questions = config.questions
    # ❌ Never restarts game with configured questions
```

**After:**
```gdscript
func _ready():
    # Don't start game yet - wait for configure_puzzle()
    pass

func configure_puzzle(config: Dictionary):
    if config.has("questions"):
        questions = config.questions
    if config.has("answers_needed"):
        correct_answers_needed = config.answers_needed
    if config.has("level_width"):
        level_width = config.level_width

    # ✅ Start game after configuration
    _start_game()
```

### 4. Maze Minigame ✅
**File:** `minigames/Maze/scripts/Main.gd`

**Status:** Already correct - no changes needed

The Maze minigame was already implemented correctly:
```gdscript
func _ready():
    # Quick fade-in for smooth transition
    modulate.a = 0.0
    var fade_tween = create_tween()
    fade_tween.tween_property(self, "modulate:a", 1.0, 0.15)

    # Default question for testing (only used if configure_puzzle is not called)
    question = {...}
    # ✅ Don't start game yet - wait for configure_puzzle() to be called

func configure_puzzle(config: Dictionary):
    # ... configuration code ...
    # ✅ Starts game after configuration
    _start_game()
```

## Testing Verification

### Test Steps:
1. Start new game
2. Select **Science** subject
3. Play through Chapter 1, Scene 2 (first minigame - janitor approach)
4. Verify Runner minigame shows science questions about plate tectonics:
   - "The Ring of Fire is in which ocean?" → **Pacific**
   - "What instrument measures earthquakes?" → **Seismograph**
   - "Continental drift was proposed by?" → **Wegener**

### Expected Results:
- ✅ No more "What is the capital of France?" questions
- ✅ All curriculum minigames use proper subject-specific questions
- ✅ Science students see Earth Science questions (Q1 - Plate Tectonics)
- ✅ Math students see General Mathematics questions (Q1 - Functions)
- ✅ English students see Oral Communication questions

## Technical Details

**Correct Initialization Flow:**
```
1. MinigameManager._start_curriculum_minigame(minigame_type)
2. Instantiates minigame scene (Runner/Pacman/Maze/Platformer)
3. Adds to scene tree → _ready() runs (now does NOT start game)
4. Calls configure_puzzle(curriculum_config) with subject-specific questions
5. configure_puzzle() sets questions array and starts game
6. Game runs with correct curriculum questions
```

**Question Source:**
All curriculum questions come from `autoload/curriculum_questions.gd`:
- Subject: `Dialogic.VAR.selected_subject` (math/science/english)
- Quarter: Auto-mapped from chapter (Ch1-2=Q1, Ch3=Q2, Ch4=Q3, Ch5=Q4)
- Format: `{question: String, correct: String, wrong: Array}`

## Summary

✅ **Fixed all curriculum minigames** (Runner, Pacman, Platformer)
✅ **Removed hardcoded test questions** from initial game start
✅ **Delayed game start** until proper curriculum questions are configured
✅ **Science students** now see Earth Science questions from the start
✅ **No more "What is the capital of France?"** in science mode

All curriculum-based minigames now correctly wait for configuration before starting, ensuring students see subject-appropriate educational content from the first question.
