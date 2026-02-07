# Chapter 2 Math Minigames

## Overview

Chapter 2 now fully supports the **Math (General Mathematics)** subject track with appropriate math-themed minigames.

## Implementation Summary

### Added Minigames

#### 1. Dialogue Choice: Ria's Note (Math Variant)
**Location**: [autoload/minigame_manager.gd:1818-1829](autoload/minigame_manager.gd#L1818-L1829)

**ID**: `dialogue_choice_ria_note_math`

**Question**:
> The lockbox contained 20,000 pesos divided into 100, 500, and 1000 peso bills. If there are 8 bills of 1000, 12 bills of 500, and the rest are 100 peso bills, how many 100 peso bills are there?

**Choices**:
1. ✅ **Subtract (8×1000 + 12×500) from 20000, then divide by 100** (CORRECT)
   - Solution: (20,000 - 8,000 - 6,000) / 100 = 60 bills
2. ❌ Add 8, 12, and 100, then multiply by 1000
3. ❌ Multiply 8 by 1000 and divide by 100
4. ❌ Divide 20000 by 100 and subtract 8 and 12

**Educational Concept**: Multi-step arithmetic and algebraic reasoning

**Timeline Trigger**: [content/timelines/Chapter 2/c2s3.dtl:63](content/timelines/Chapter 2/c2s3.dtl#L63)
```
[signal arg="start_minigame dialogue_choice_ria_note"]
```

**How it works**:
- When `dialogue_choice_ria_note` is triggered, the `MinigameManager._get_subject_variant_id()` function automatically checks the player's selected subject
- If subject is `"math"`, it transforms the ID to `dialogue_choice_ria_note_math`
- The math variant is loaded and displayed

---

#### 2. Fill-in-the-Blank: Functions (Curriculum System)
**Location**: [autoload/curriculum_questions.gd:104-108](autoload/curriculum_questions.gd#L104-L108)

**Type**: `curriculum:fillinblank` (Math Q1)

**Question**:
> "A function assigns each _____ to exactly one _____."

**Answers**: `input`, `output`

**Choices**: input, output, domain, range, variable, constant, equation, value

**Educational Concept**: Function definition and terminology

**Timeline Trigger**: [content/timelines/Chapter 2/c2s4.dtl:32](content/timelines/Chapter 2/c2s4.dtl#L32)
```
[signal arg="start_minigame curriculum:fillinblank"]
```

**How it works**:
- The `curriculum:fillinblank` format triggers `MinigameManager._start_curriculum_minigame()`
- The system checks `Dialogic.VAR.selected_subject` (set to "math")
- The system checks `Dialogic.VAR.current_chapter` (set to 2)
- Maps Chapter 2 → Q1 (First Quarter topics)
- Retrieves math Q1 fillinblank question from `CurriculumQuestions`

---

#### 3. Maze: Function Concepts (Curriculum System)
**Location**: [autoload/curriculum_questions.gd:84-92](autoload/curriculum_questions.gd#L84-L92)

**Type**: `curriculum:maze` (Math Q1)

**Questions** (5 total):
1. What is the notation for an inverse function? → `f^-1(x)`
2. Piecewise functions are defined by? → `Multiple rules`
3. What test checks if an inverse is a function? → `Horizontal line`
4. The domain of f^-1 is the ___ of f? → `Range`
5. A relation where each input has one output is a? → `Function`

**Educational Concept**: Function properties, inverse functions, and function notation

**Timeline Trigger**: [content/timelines/Chapter 2/c2s5.dtl:44](content/timelines/Chapter 2/c2s5.dtl#L44)
```
[signal arg="start_minigame curriculum:maze"]
```

**How it works**:
- Same curriculum system as fill-in-the-blank
- Maps Chapter 2 → Q1 math questions
- Randomly selects from 5 maze questions about functions

---

## How the Subject Variant System Works

### For Specific Minigames (dialogue_choice)

1. **Timeline calls**: `[signal arg="start_minigame dialogue_choice_ria_note"]`
2. **MinigameManager receives**: `puzzle_id = "dialogue_choice_ria_note"`
3. **Subject check**: `_get_subject_variant_id()` transforms it based on `PlayerStats.selected_subject`
   - If `"math"` → `"dialogue_choice_ria_note_math"`
   - If `"science"` → `"dialogue_choice_ria_note_science"` (if exists)
   - If `"english"` → `"dialogue_choice_ria_note"` (base version)
4. **Fallback**: If variant doesn't exist, uses base English version

### For Curriculum Minigames

1. **Timeline calls**: `[signal arg="start_minigame curriculum:fillinblank"]`
2. **MinigameManager receives**: Format starts with `"curriculum:"`
3. **Routes to**: `_start_curriculum_minigame(minigame_type)`
4. **CurriculumQuestions system**:
   - Reads `Dialogic.VAR.selected_subject` (e.g., "math")
   - Reads `Dialogic.VAR.current_chapter` (e.g., 2)
   - Maps chapter → quarter (Chapter 2 → Q1)
   - Returns `questions["math"]["Q1"]["fillinblank"]`

---

## Testing the Implementation

To test the math minigames in Chapter 2:

1. **Start new game** and select **"Math (General Mathematics)"** as your subject
2. **Play through Chapter 2** until you reach the three minigame scenes:
   - **c2s3** (Ria's Note scene) → Dialogue Choice with money calculation
   - **c2s4** (Computer Lab scene) → Fill-in-the-blank about functions
   - **c2s5** (Storage Room scene) → Maze with function concepts

3. **Verify**:
   - Math questions appear (not English questions)
   - Questions are relevant to General Mathematics curriculum
   - Completion rewards hints and advances story

---

## Curriculum Alignment

Chapter 2 math content aligns with **Philippine SHS General Mathematics Q1 curriculum**:

**Quarter 1 Topics**:
- Functions and their properties
- Operations on functions
- Inverse functions
- Piecewise functions
- Function composition

**Learning Objectives**:
- Understand function notation and terminology
- Identify domain, range, inputs, and outputs
- Recognize function properties (one-to-one, inverse)
- Apply multi-step arithmetic reasoning

---

## Future Enhancements

To add more subject variants for other minigames in Chapter 2:

1. **For science variants**: Create `dialogue_choice_ria_note_science` in `dialogue_choice_configs`
2. **For additional math minigames**: Add more entries to `curriculum_questions.gd` under `math.Q1`
3. **For custom minigames**: Create new configs with `_math` or `_science` suffix

---

## Related Files

- [autoload/minigame_manager.gd](autoload/minigame_manager.gd) - Minigame configuration and routing
- [autoload/curriculum_questions.gd](autoload/curriculum_questions.gd) - Subject-specific curriculum questions
- [content/timelines/Chapter 2/c2s3.dtl](content/timelines/Chapter 2/c2s3.dtl) - Ria's interrogation scene
- [content/timelines/Chapter 2/c2s4.dtl](content/timelines/Chapter 2/c2s4.dtl) - Computer lab investigation
- [content/timelines/Chapter 2/c2s5.dtl](content/timelines/Chapter 2/c2s5.dtl) - Storage room confrontation
- [MULTI_SUBJECT_SYSTEM.md](MULTI_SUBJECT_SYSTEM.md) - Complete multi-subject system documentation
- [CLAUDE.md](CLAUDE.md) - Project overview and architecture

---

## Success Criteria

✅ **Math students get math-themed minigames in Chapter 2**
✅ **Questions align with General Mathematics Q1 curriculum**
✅ **Automatic subject detection and routing works seamlessly**
✅ **Fallback to English version if math variant missing**
✅ **No code changes needed in timeline files**

---

*Last Updated: 2026-02-06*
