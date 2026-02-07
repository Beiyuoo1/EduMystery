# Chapter 4 Math Minigames

## Overview

Chapter 4 "Anonymous Notes Mystery" now fully supports the **Math (General Mathematics)** subject track with math-themed minigames focused on **Trigonometry - Unit Circle and Identities** (Q3 curriculum).

## Implementation Summary

### Added Minigames

#### 1. Hear and Fill: Anonymous Notes (Math Variant)
**Location**: [autoload/minigame_manager.gd:1728-1734](autoload/minigame_manager.gd#L1728-L1734)

**ID**: `anonymous_notes_math`

**Sentence**: "The angle that measures exactly 90 degrees is called a _____ angle."

**Blank Word**: `right`

**Choices** (8 options):
- write
- bite
- sight
- **right** ✅ (correct, index 3)
- flight
- bright
- tight
- night

**Educational Concept**: Angle classification (right angles = 90°)

**Timeline Trigger**: [content/timelines/Chapter 4/c4s1.dtl:59](content/timelines/Chapter 4/c4s1.dtl#L59)
```
[signal arg="start_minigame anonymous_notes"]
```

**Story Context**: Students are receiving anonymous notes that expose their moral failings. Conrad investigates to find out who is behind these confrontational messages.

---

#### 2. Fill-in-the-Blank: Pedagogy Methods (Math Variant)
**Location**: [autoload/minigame_manager.gd:143-149](autoload/minigame_manager.gd#L143-L149)

**ID**: `pedagogy_methods_math`

**Sentence**: "In trigonometry, _____ is opposite over _____."

**Answers**: `sine`, `hypotenuse`

**Choices** (8 options):
- sine ✅
- cosine
- tangent
- adjacent
- hypotenuse ✅
- opposite
- secant
- angle

**Educational Concept**: Trigonometric ratio definition (SOH-CAH-TOA: Sine = Opposite / Hypotenuse)

**Timeline Trigger**: [content/timelines/Chapter 4/c4s3.dtl:27](content/timelines/Chapter 4/c4s3.dtl#L27)
```
[signal arg="start_minigame pedagogy_methods"]
```

**Story Context**: Conrad discovers Alex found an educator's journal in the archive containing experimental pedagogy methods. She's been implementing these teaching techniques without proper training or wisdom.

---

#### 3. Dialogue Choice: Approach Suspect (Math Variant)
**Location**: [autoload/minigame_manager.gd:1867-1878](autoload/minigame_manager.gd#L1867-L1878)

**ID**: `dialogue_choice_approach_suspect_math`

**Question**:
> Conrad notices a pattern in when the anonymous notes were delivered. If the angle between the library and the archive on a map is 45 degrees, and Conrad walks along the hypotenuse of this right triangle, which trigonometric ratio should he use to calculate the shortest path?

**Choices**:
1. ❌ Use sine to find the opposite side divided by the hypotenuse
2. ✅ **Use cosine to find the adjacent side divided by the hypotenuse, then apply the Pythagorean theorem** (CORRECT)
3. ❌ Use tangent to find the ratio of opposite to adjacent sides
4. ❌ Multiply the angle by pi and divide by 180 to convert to radians first

**Educational Concept**: Trigonometric ratio application (cosine for adjacent side calculation), navigation with right triangles

**Timeline Trigger**: [content/timelines/Chapter 4/c4s2.dtl:66](content/timelines/Chapter 4/c4s2.dtl#L66)
```
[signal arg="start_minigame dialogue_choice_approach_suspect"]
```

**Story Context**: Conrad investigates the archive and discovers Alex has been accessing it repeatedly. He must decide how to approach her as a suspect.

---

## Curriculum System Integration

Chapter 4 has access to the curriculum system for additional minigames. If you want to add curriculum minigames, they automatically pull from Math Q3 (Trigonometry).

### Available Curriculum Minigames (Math Q3)

**Topics**: Trigonometry - Unit Circle, Identities, Angle Conversions

**Types Available**:
- `curriculum:pacman` - Basic trig values (sin, cos, tan at key angles)
- `curriculum:runner` - Angle conversions, identities, reciprocal functions
- `curriculum:maze` - Quadrant analysis, unit circle properties
- `curriculum:platformer` - Degree/radian conversions, special angles
- `curriculum:fillinblank` - "The sine function relates an angle to the ratio of opposite over hypotenuse."
- `curriculum:math` - Mixed trigonometry problems

**Example Questions** (from Q3):
- sin(90°) equals? → 1
- tan(45°) equals? → 1
- Pi radians equals how many degrees? → 180
- In Quadrant II, sin is positive and cos is? → Negative
- sin²θ + cos²θ equals? → 1

---

## How the Subject Variant System Works

### For Specific Minigames

1. **Timeline calls**: `[signal arg="start_minigame anonymous_notes"]`
2. **MinigameManager receives**: `puzzle_id = "anonymous_notes"`
3. **Subject check**: `_get_subject_variant_id()` transforms based on `PlayerStats.selected_subject`
   - If `"math"` → `"anonymous_notes_math"`
   - If `"science"` → `"anonymous_notes_science"` (if exists)
   - If `"english"` → `"anonymous_notes"` (base version)
4. **Fallback**: If variant doesn't exist, uses base English version

Same process applies for all three minigames in Chapter 4.

---

## Testing the Implementation

To test the math minigames in Chapter 4:

1. **Start new game** and select **"Math (General Mathematics)"** as your subject
2. **Play through to Chapter 4** (The Anonymous Notes case)
3. **Test minigame locations**:
   - **c4s1** (Investigation begins) → Hear and Fill about right angles
   - **c4s2** (Library investigation) → Dialogue Choice about trigonometric navigation
   - **c4s3** (Archive discovery) → Fill-in-the-blank about sine ratio

4. **Verify**:
   - Math questions appear (not English questions)
   - Questions relate to trigonometry concepts
   - Completion advances the story

---

## Curriculum Alignment

Chapter 4 math content aligns with **Philippine SHS General Mathematics Q3 curriculum**:

**Quarter 3 Topics**:
- Trigonometric ratios (sine, cosine, tangent)
- Unit circle and angle measurement
- Angle conversions (degrees/radians)
- Trigonometric identities
- Special angles (30°, 45°, 60°, 90°)
- Quadrant analysis

**Learning Objectives**:
- Identify and classify angles (right, acute, obtuse)
- Apply trigonometric ratios to solve problems
- Understand SOH-CAH-TOA relationships
- Use trigonometry for navigation and distance calculation
- Recognize special angle values

---

## Story Integration

### Chapter 4: Anonymous Notes Mystery

**Case Summary**: Students receive anonymous notes exposing their moral failings. Conrad investigates and discovers:
- **Evidence**: Anonymous notes, archive access log, missing educator's journal
- **Culprit**: Alex (well-intentioned student who found experimental pedagogy journal)
- **Motive**: Belief she could help others improve through moral challenges
- **B.C. Card**: Lesson 4 - Wisdom (knowledge without wisdom is dangerous)

**Math Integration**:
- **Hear and Fill**: Right angle classification (fundamental trigonometry concept)
- **Fill-in-the-blank**: Sine ratio definition (SOH-CAH-TOA mnemonic)
- **Dialogue Choice**: Trigonometric navigation using cosine for pathfinding

The math variants maintain the mystery's narrative flow while teaching Q3 trigonometry concepts.

---

## Adding More Minigames to Chapter 4

If you want to add curriculum minigames to Chapter 4 timelines:

### Example Addition to c4s4.dtl (Confrontation Scene):

```dtl
join "Diwata Laya" (Half_mirror) center
[signal arg="laya_start"]
"Diwata Laya": Test your understanding before the final confrontation.
[signal arg="start_minigame curriculum:maze"]
"Diwata Laya": Your mind is sharp.
[signal arg="laya_end"]
leave "Diwata Laya"
```

This would automatically use Math Q3 maze questions (quadrant analysis, unit circle) for math students.

---

## Future Enhancements

To add more subject variants:

1. **For science variants**: Create `anonymous_notes_science`, `pedagogy_methods_science`, and `dialogue_choice_approach_suspect_science`
2. **For additional curriculum minigames**: Add `curriculum:TYPE` calls to timeline files
3. **For custom minigames**: Create new configs with `_math` or `_science` suffix

---

## Related Files

- [autoload/minigame_manager.gd](autoload/minigame_manager.gd) - Minigame configuration and routing
- [autoload/curriculum_questions.gd](autoload/curriculum_questions.gd) - Subject-specific curriculum questions (Q3)
- [content/timelines/Chapter 4/c4s1.dtl](content/timelines/Chapter 4/c4s1.dtl) - Investigation begins
- [content/timelines/Chapter 4/c4s2.dtl](content/timelines/Chapter 4/c4s2.dtl) - Library investigation
- [content/timelines/Chapter 4/c4s3.dtl](content/timelines/Chapter 4/c4s3.dtl) - Archive discovery
- [MULTI_SUBJECT_SYSTEM.md](MULTI_SUBJECT_SYSTEM.md) - Complete multi-subject system documentation
- [CHAPTER_2_MATH_MINIGAMES.md](CHAPTER_2_MATH_MINIGAMES.md) - Chapter 2 math implementation
- [CHAPTER_3_MATH_MINIGAMES.md](CHAPTER_3_MATH_MINIGAMES.md) - Chapter 3 math implementation
- [CLAUDE.md](CLAUDE.md) - Project overview and architecture

---

## Success Criteria

✅ **Math students get math-themed minigames in Chapter 4**
✅ **Questions align with General Mathematics Q3 curriculum (Trigonometry)**
✅ **Automatic subject detection and routing works seamlessly**
✅ **Fallback to English version if math variant missing**
✅ **No code changes needed in timeline files**
✅ **Math concepts integrated naturally into the mystery narrative**

---

## Comparison: English vs Math Variants

### Hear and Fill (c4s1)

| Aspect | English Version | Math Version |
|--------|----------------|--------------|
| **Focus** | Vocabulary (anonymous) | Angle classification |
| **Sentence** | "The students are receiving _____ notes..." | "The angle that measures exactly 90 degrees is called a _____ angle." |
| **Answer** | anonymous | right |
| **Concept** | Word recognition with similar-sounding words | Right angle identification (90°) |

### Fill-in-the-Blank (c4s3)

| Aspect | English Version | Math Version |
|--------|----------------|--------------|
| **Focus** | Educational terminology | Trigonometric ratios |
| **Sentence** | "Experimental _____ teaches through _____ rather than lectures." | "In trigonometry, _____ is opposite over _____." |
| **Answers** | pedagogy, experience | sine, hypotenuse |
| **Concept** | Teaching methods | SOH-CAH-TOA (Sine = Opposite / Hypotenuse) |

### Dialogue Choice (c4s2)

| Aspect | English Version | Math Version |
|--------|----------------|--------------|
| **Focus** | Critical thinking about approach | Trigonometric navigation |
| **Question** | "How should Conrad approach Alex?" | "Which trigonometric ratio for shortest path calculation?" |
| **Answer** | "Observe her behavior carefully..." | "Use cosine to find adjacent side..." |
| **Concept** | Social wisdom and judgment | Cosine application, Pythagorean theorem |

---

## Trigonometry Integration Strategy

The Chapter 4 math minigames progressively introduce trigonometry concepts:

1. **c4s1 (Right Angles)**: Foundation - introduces 90° angles
2. **c4s2 (Trigonometric Ratios)**: Application - uses cosine for navigation
3. **c4s3 (Sine Definition)**: Core Concept - defines sine as opposite/hypotenuse

This scaffolded approach helps students build understanding from basic angle classification to practical trigonometric applications.

---

*Last Updated: 2026-02-06*
