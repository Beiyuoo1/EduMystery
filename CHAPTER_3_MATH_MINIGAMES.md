# Chapter 3 Math Minigames

## Overview

Chapter 3 "Art Week Vandalism Mystery" now fully supports the **Math (General Mathematics)** subject track with math-themed minigames focused on **Exponential & Logarithmic Functions** (Q2 curriculum).

## Implementation Summary

### Added Minigames

#### 1. Dialogue Choice: Cruel Note (Math Variant)
**Location**: [autoload/minigame_manager.gd:1830-1839](autoload/minigame_manager.gd#L1830-L1839)

**ID**: `dialogue_choice_cruel_note_math`

**Question**:
> Conrad finds paint stains on the cloth at different times. If the first stain was made 2 hours ago and each subsequent stain was made in half the time of the previous one, how long ago was the 4th stain made?

**Choices**:
1. ✅ **Divide 2 by 2 three times: 2, 1, 0.5, 0.25 hours (15 minutes ago)** (CORRECT)
   - Solution: Exponential decay pattern - 2 → 1 → 0.5 → 0.25 hours
2. ❌ Multiply 2 by 0.5 four times to get 0.25 hours
3. ❌ Subtract 0.5 from 2 four times
4. ❌ Add 2 plus 1 plus 0.5 to get 3.5 hours

**Educational Concept**: Exponential decay, geometric sequences (each term is half the previous)

**Timeline Trigger**: [content/timelines/Chapter 3/c3s1.dtl:75](content/timelines/Chapter 3/c3s1.dtl#L75)
```
[signal arg="start_minigame dialogue_choice_cruel_note"]
```

**Story Context**: Conrad examines the vandalized sculpture and finds a cruel handwritten note saying "Not everyone deserves to shine." The paint stains on the cloth provide timing evidence.

---

#### 2. Riddle: Receipt (Math Variant)
**Location**: [autoload/minigame_manager.gd:1751-1757](autoload/minigame_manager.gd#L1751-L1757)

**ID**: `receipt_riddle_math`

**Riddle**:
> I grow without bounds, my base stays the same,
> Raised to a power is my claim to fame.
> In growth and decay, I'm the function you'll see,
> What mathematical term could I be?

**Answer**: `EXPONENTIAL` (12 letters)

**Letters**: E, X, P, O, N, E, N, T, I, A, L, R, G, W, H, M (16 total, 12 correct + 4 decoys)

**Educational Concept**: Exponential functions, growth/decay patterns

**Timeline Trigger**: [content/timelines/Chapter 3/c3s3.dtl:61](content/timelines/Chapter 3/c3s3.dtl#L61)
```
[signal arg="start_minigame receipt_riddle"]
```

**Story Context**: Conrad examines Victor's sketchbook and finds a receipt. Diwata Laya suggests sharpening his mind with a riddle before proceeding with the investigation.

---

## Curriculum System Integration

Chapter 3 has access to the curriculum system for additional minigames (though none are currently used in the timeline). If you want to add curriculum minigames, they would automatically pull from Math Q2:

### Available Curriculum Minigames (Math Q2)

**Topics**: Exponential & Logarithmic Functions

**Types Available**:
- `curriculum:pacman` - Logarithm basics and exponential calculations
- `curriculum:runner` - Logarithm properties and exponential rules
- `curriculum:maze` - Exponential growth/decay, inverse functions
- `curriculum:platformer` - Basic exponential and logarithm evaluation
- `curriculum:fillinblank` - "The inverse of an exponential function is a logarithmic function."
- `curriculum:math` - Mixed exponential and logarithm problems

**Example Questions** (from Q2):
- What is log base 10 of 100? → 2
- 2^4 equals? → 16
- Exponential growth has base greater than? → 1
- What is the inverse of y = 10^x? → y = log x
- Half-life problems use which function? → Exponential

---

## How the Subject Variant System Works

### For Specific Minigames

1. **Timeline calls**: `[signal arg="start_minigame dialogue_choice_cruel_note"]`
2. **MinigameManager receives**: `puzzle_id = "dialogue_choice_cruel_note"`
3. **Subject check**: `_get_subject_variant_id()` transforms based on `PlayerStats.selected_subject`
   - If `"math"` → `"dialogue_choice_cruel_note_math"`
   - If `"science"` → `"dialogue_choice_cruel_note_science"` (if exists)
   - If `"english"` → `"dialogue_choice_cruel_note"` (base version)
4. **Fallback**: If variant doesn't exist, uses base English version

Same process applies for `receipt_riddle` → `receipt_riddle_math`.

---

## Testing the Implementation

To test the math minigames in Chapter 3:

1. **Start new game** and select **"Math (General Mathematics)"** as your subject
2. **Play through to Chapter 3** (The Art Week Vandalism case)
3. **Test minigame locations**:
   - **c3s1** (Vandalism scene) → Dialogue Choice about exponential decay
   - **c3s3** (Victor's sketchbook) → Riddle about exponential functions

4. **Verify**:
   - Math questions appear (not English grammar questions)
   - Questions relate to exponential/logarithmic concepts
   - Completion advances the story

---

## Curriculum Alignment

Chapter 3 math content aligns with **Philippine SHS General Mathematics Q2 curriculum**:

**Quarter 2 Topics**:
- Exponential functions and their properties
- Logarithmic functions as inverses of exponentials
- Exponential growth and decay
- Logarithm properties and rules
- Applications (compound interest, half-life, population growth)

**Learning Objectives**:
- Understand exponential growth and decay patterns
- Recognize geometric sequences (halving pattern)
- Apply exponential concepts to real-world scenarios
- Identify exponential functions by their characteristics

---

## Story Integration

### Chapter 3: Art Week Vandalism Mystery

**Case Summary**: During Art Week, Mia's sculpture "The Reader" is vandalized. Conrad investigates and discovers:
- **Evidence**: Cruel handwritten note, paint-stained cloth, Victor's angry sketches, receipt
- **Culprit**: Victor (art student who felt overshadowed)
- **Motive**: Jealousy and resentment of Mia's talent
- **B.C. Card**: Lesson 3 - Creativity

**Math Integration**:
- **Dialogue Choice**: Uses exponential decay to analyze timing of paint stains
- **Riddle**: Focuses on exponential function concepts before examining critical evidence

The math variants maintain the mystery's narrative flow while teaching Q2 math concepts.

---

## Adding More Minigames to Chapter 3

If you want to add curriculum minigames to Chapter 3 timelines:

### Example Addition to c3s2.dtl (Art Room Investigation):

```dtl
join "Diwata Laya" (Half_mirror) center
[signal arg="laya_start"]
"Diwata Laya": Test your knowledge before proceeding.
[signal arg="start_minigame curriculum:maze"]
"Diwata Laya": Your path is clear.
[signal arg="laya_end"]
leave "Diwata Laya"
```

This would automatically use Math Q2 maze questions for math students.

---

## Future Enhancements

To add more subject variants:

1. **For science variants**: Create `dialogue_choice_cruel_note_science` and `receipt_riddle_science`
2. **For additional curriculum minigames**: Add `curriculum:TYPE` calls to timeline files
3. **For custom minigames**: Create new configs with `_math` or `_science` suffix

---

## Related Files

- [autoload/minigame_manager.gd](autoload/minigame_manager.gd) - Minigame configuration and routing
- [autoload/curriculum_questions.gd](autoload/curriculum_questions.gd) - Subject-specific curriculum questions (Q2)
- [content/timelines/Chapter 3/c3s1.dtl](content/timelines/Chapter 3/c3s1.dtl) - Vandalism discovery scene
- [content/timelines/Chapter 3/c3s3.dtl](content/timelines/Chapter 3/c3s3.dtl) - Victor's sketchbook examination
- [MULTI_SUBJECT_SYSTEM.md](MULTI_SUBJECT_SYSTEM.md) - Complete multi-subject system documentation
- [CHAPTER_2_MATH_MINIGAMES.md](CHAPTER_2_MATH_MINIGAMES.md) - Chapter 2 math implementation
- [CLAUDE.md](CLAUDE.md) - Project overview and architecture

---

## Success Criteria

✅ **Math students get math-themed minigames in Chapter 3**
✅ **Questions align with General Mathematics Q2 curriculum (Exponential & Logarithmic Functions)**
✅ **Automatic subject detection and routing works seamlessly**
✅ **Fallback to English version if math variant missing**
✅ **No code changes needed in timeline files**
✅ **Math concepts integrated naturally into the mystery narrative**

---

## Comparison: English vs Math Variants

### Dialogue Choice (c3s1)

| Aspect | English Version | Math Version |
|--------|----------------|--------------|
| **Focus** | Grammar correctness | Exponential decay |
| **Question** | "Which sentence is grammatically correct?" | "How long ago was the 4th stain made?" |
| **Answer** | "They left evidence." | "Divide 2 by 2 three times: 0.25 hours" |
| **Concept** | Subject-verb agreement | Geometric sequences (halving) |

### Riddle (c3s3)

| Aspect | English Version | Math Version |
|--------|----------------|--------------|
| **Focus** | Vocabulary (flipping pages) | Function type identification |
| **Answer** | FLIPPING (8 letters) | EXPONENTIAL (12 letters) |
| **Riddle** | "I am the sound of paper in motion..." | "I grow without bounds, my base stays the same..." |
| **Concept** | Word recognition | Exponential function properties |

---

*Last Updated: 2026-02-06*
