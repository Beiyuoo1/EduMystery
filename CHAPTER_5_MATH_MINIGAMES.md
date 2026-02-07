# Chapter 5 Math Minigames

## Overview

Chapter 5 "B.C. Revelation" now fully supports the **Math (General Mathematics)** subject track with math-themed minigames focused on **Statistics and Probability** (Q4 curriculum).

## Implementation Summary

### Added Minigames

#### 1. Dialogue Choice: B.C. Approach (Math Variant)
**Location**: [autoload/minigame_manager.gd:1881-1891](autoload/minigame_manager.gd#L1881-L1891)

**ID**: `dialogue_choice_bc_approach_math`

**Question**:
> Conrad collected data from all 5 B.C. cards. If the mean time between cards was 8 days with a standard deviation of 2 days, what does this tell him about the pattern?

**Choices**:
1. ✅ **The pattern is consistent with most cards appearing within 6-10 days of each other** (CORRECT)
   - Understanding: Mean ± 1 standard deviation covers most data (8 ± 2 = 6 to 10 days)
2. ❌ The pattern is random with no predictable timing
3. ❌ All cards appeared exactly 8 days apart with no variation
4. ❌ The standard deviation being 2 means the cards were 2 days late on average

**Educational Concept**: Mean, standard deviation, and data spread interpretation

**Timeline Trigger**: [content/timelines/Chapter 5/c5s1.dtl:64](content/timelines/Chapter 5/c5s1.dtl#L64)
```
[signal arg="start_minigame dialogue_choice_bc_approach"]
```

**Story Context**: Conrad prepares to meet B.C. face-to-face after solving four cases and receiving four lesson cards. He analyzes the pattern in their appearance.

---

#### 2. Hear and Fill: Observation Teaching (Math Variant)
**Location**: [autoload/minigame_manager.gd:1745-1751](autoload/minigame_manager.gd#L1745-L1751)

**ID**: `observation_teaching_math`

**Sentence**: "In statistics, the _____ is the middle value when data is arranged in order."

**Blank Word**: `median`

**Choices** (8 options):
- comedian
- medium
- immediate
- media
- remedial
- **median** ✅ (correct, index 5)
- medicinal
- medieval

**Educational Concept**: Median definition (measure of central tendency)

**Timeline Trigger**: [content/timelines/Chapter 5/c5s2.dtl:78](content/timelines/Chapter 5/c5s2.dtl#L78)
```
[signal arg="start_minigame observation_teaching"]
```

**Story Context**: Conrad meets the Principal (revealed as B.C.) and learns about their teaching philosophy. Before the final lesson, he must prove his readiness.

---

#### 3. Fill-in-the-Blank: Curriculum (Automatic)
**Location**: [autoload/curriculum_questions.gd:306-310](autoload/curriculum_questions.gd#L306-L310)

**Type**: `curriculum:fillinblank` (Math Q4)

**Sentence**: "The _____ is the sum of values divided by the _____ of values."

**Answers**: `mean`, `count`

**Choices** (8 options):
- mean ✅
- median
- mode
- count ✅
- range
- sum
- total
- number

**Educational Concept**: Mean definition (average calculation)

**Timeline Trigger**: [content/timelines/Chapter 5/c5s3.dtl:68](content/timelines/Chapter 5/c5s3.dtl#L68)
```
[signal arg="start_minigame curriculum:fillinblank"]
```

**Story Context**: The Principal asks Conrad to reflect on what he's learned. Conrad must demonstrate his understanding before receiving the final lesson.

---

## Curriculum System Integration

Chapter 5 fully utilizes the curriculum system for Q4 (Statistics & Probability).

### Available Curriculum Minigames (Math Q4)

**Topics**: Statistics (Central Tendency, Variability) and Probability (Basic Rules, Distributions)

**Types Available**:
- `curriculum:pacman` - Mean, median, mode, basic probability
- `curriculum:runner` - Standard deviation, variance, probability rules
- `curriculum:maze` - Normal distribution, combinations, permutations, factorials
- `curriculum:platformer` - Central tendency measures, simple probability
- `curriculum:fillinblank` - "The mean is the sum of values divided by the count of values." ✅ **Used in c5s3**
- `curriculum:math` - Mixed statistics and probability problems

**Example Questions** (from Q4):
- The mean of 2, 4, 6 is? → 4
- The median of 1, 3, 5 is? → 3
- Probability ranges from? → 0 to 1
- Standard deviation measures? → Spread
- 5! (factorial) equals? → 120

---

## How the Subject Variant System Works

### For Specific Minigames

1. **Timeline calls**: `[signal arg="start_minigame dialogue_choice_bc_approach"]`
2. **MinigameManager receives**: `puzzle_id = "dialogue_choice_bc_approach"`
3. **Subject check**: `_get_subject_variant_id()` transforms based on `PlayerStats.selected_subject`
   - If `"math"` → `"dialogue_choice_bc_approach_math"`
   - If `"science"` → `"dialogue_choice_bc_approach_science"` (if exists)
   - If `"english"` → `"dialogue_choice_bc_approach"` (base version)
4. **Fallback**: If variant doesn't exist, uses base English version

### For Curriculum Minigames

The `curriculum:fillinblank` in c5s3 automatically:
1. Detects `PlayerStats.selected_subject = "math"`
2. Maps Chapter 5 → Q4
3. Retrieves `questions["math"]["Q4"]["fillinblank"]`
4. Loads the mean/count definition question

---

## Testing the Implementation

To test the math minigames in Chapter 5:

1. **Start new game** and select **"Math (General Mathematics)"** as your subject
2. **Play through to Chapter 5** (The B.C. Revelation chapter)
3. **Test minigame locations**:
   - **c5s1** (Approaching B.C.) → Dialogue Choice about mean and standard deviation
   - **c5s2** (Meeting B.C.) → Hear and Fill about median
   - **c5s3** (Final reflection) → Fill-in-the-blank about mean definition

4. **Verify**:
   - Math questions appear (not English questions)
   - Questions relate to statistics and probability concepts
   - Completion advances the story

---

## Curriculum Alignment

Chapter 5 math content aligns with **Philippine SHS General Mathematics Q4 curriculum**:

**Quarter 4 Topics**:
- Measures of central tendency (mean, median, mode)
- Measures of variability (range, variance, standard deviation)
- Basic probability concepts and rules
- Combinations and permutations
- Normal distribution basics

**Learning Objectives**:
- Calculate and interpret mean, median, and mode
- Understand standard deviation as a measure of spread
- Apply mean ± SD to interpret data patterns
- Recognize probability values (0 to 1 range)
- Use statistical measures to analyze real-world data

---

## Story Integration

### Chapter 5: B.C. Revelation

**Case Summary**: The culmination of Conrad's journey. He discovers:
- **Revelation**: B.C. is the Principal, who has been guiding Conrad through observation
- **Method**: Teaching through natural events, not manipulation
- **Purpose**: Training Conrad to become a guide for others
- **B.C. Card 5**: Choice - "True teaching respects free will. Guide, never control. The chain transforms."

**Math Integration**:
- **Dialogue Choice**: Analyzes pattern in B.C. cards using statistical concepts (mean, SD)
- **Hear and Fill**: Tests understanding of median (middle value concept)
- **Fill-in-the-blank**: Reviews mean definition before final lesson

The math variants frame Conrad's analytical journey in statistical terms - he's collecting data, finding patterns, and drawing conclusions, just as he's been doing throughout the five cases.

---

## Statistical Thinking Theme

Chapter 5's math minigames emphasize **data analysis** and **pattern recognition**:

1. **Mean & Standard Deviation**: Conrad analyzes the timing pattern of B.C. cards
   - Mean = 8 days (central tendency)
   - SD = 2 days (consistency of pattern)
   - Interpretation: Most cards within 6-10 days (± 1 SD)

2. **Median**: Understanding the middle value
   - Represents central position in ordered data
   - Different from mean but also measures "center"

3. **Mean Calculation**: Sum divided by count
   - Fundamental averaging concept
   - Foundation for more advanced statistics

This progression mirrors Conrad's growth from **collecting evidence** (data) to **understanding patterns** (statistical analysis) to **drawing conclusions** (inference).

---

## Adding More Minigames to Chapter 5

If you want to add curriculum minigames to Chapter 5 timelines:

### Example Addition to c5s4.dtl (Final Lesson):

```dtl
join "Diwata Laya" (Half_mirror) center
[signal arg="laya_start"]
"Diwata Laya": One final test of your analytical skills.
[signal arg="start_minigame curriculum:maze"]
"Diwata Laya": Your journey is complete.
[signal arg="laya_end"]
leave "Diwata Laya"
```

This would automatically use Math Q4 maze questions (factorials, combinations, normal distribution) for math students.

---

## Future Enhancements

To add more subject variants:

1. **For science variants**: Create `dialogue_choice_bc_approach_science` and `observation_teaching_science`
2. **For additional curriculum minigames**: Add more `curriculum:TYPE` calls to timeline files
3. **For custom minigames**: Create new configs with `_math` or `_science` suffix

---

## Related Files

- [autoload/minigame_manager.gd](autoload/minigame_manager.gd) - Minigame configuration and routing
- [autoload/curriculum_questions.gd](autoload/curriculum_questions.gd) - Subject-specific curriculum questions (Q4)
- [content/timelines/Chapter 5/c5s1.dtl](content/timelines/Chapter 5/c5s1.dtl) - Approaching B.C.
- [content/timelines/Chapter 5/c5s2.dtl](content/timelines/Chapter 5/c5s2.dtl) - Meeting B.C.
- [content/timelines/Chapter 5/c5s3.dtl](content/timelines/Chapter 5/c5s3.dtl) - Final reflection
- [MULTI_SUBJECT_SYSTEM.md](MULTI_SUBJECT_SYSTEM.md) - Complete multi-subject system documentation
- [CHAPTER_2_MATH_MINIGAMES.md](CHAPTER_2_MATH_MINIGAMES.md) - Chapter 2 math implementation
- [CHAPTER_3_MATH_MINIGAMES.md](CHAPTER_3_MATH_MINIGAMES.md) - Chapter 3 math implementation
- [CHAPTER_4_MATH_MINIGAMES.md](CHAPTER_4_MATH_MINIGAMES.md) - Chapter 4 math implementation
- [CLAUDE.md](CLAUDE.md) - Project overview and architecture

---

## Success Criteria

✅ **Math students get math-themed minigames in Chapter 5**
✅ **Questions align with General Mathematics Q4 curriculum (Statistics & Probability)**
✅ **Automatic subject detection and routing works seamlessly**
✅ **Fallback to English version if math variant missing**
✅ **No code changes needed in timeline files**
✅ **Math concepts integrated naturally into the mystery narrative**
✅ **Statistical thinking reinforces Conrad's analytical journey**

---

## Comparison: English vs Math Variants

### Dialogue Choice (c5s1)

| Aspect | English Version | Math Version |
|--------|----------------|--------------|
| **Focus** | Ethical approach and respect | Statistical pattern analysis |
| **Question** | "How should Conrad approach B.C.?" | "What does mean and SD tell about pattern?" |
| **Answer** | "Enter respectfully and thank them..." | "Pattern is consistent within 6-10 days..." |
| **Concept** | Social wisdom and gratitude | Mean, standard deviation, data interpretation |

### Hear and Fill (c5s2)

| Aspect | English Version | Math Version |
|--------|----------------|--------------|
| **Focus** | Vocabulary (observation) | Statistical measure definition |
| **Sentence** | "B.C. teaches through _____ rather than direct instruction." | "In statistics, the _____ is the middle value..." |
| **Answer** | observation | median |
| **Concept** | Word recognition | Central tendency (median) |

### Fill-in-the-Blank (c5s3)

| Aspect | English Version | Math Version |
|--------|----------------|--------------|
| **Focus** | Teaching philosophy | Mean calculation |
| **Sentence** | "True teaching requires _____ and respects _____..." | "The _____ is the sum of values divided by the _____ of values." |
| **Answers** | wisdom, choice | mean, count |
| **Concept** | Moral philosophy | Average/mean definition |

---

## Complete Math Curriculum Coverage

Chapter 5 completes the **full Philippine SHS General Mathematics curriculum** integration:

| Chapter | Quarter | Topic | Status |
|---------|---------|-------|--------|
| 1 & 2 | Q1 | Functions & Operations | ✅ Complete |
| 3 | Q2 | Exponential & Logarithmic | ✅ Complete |
| 4 | Q3 | Trigonometry | ✅ Complete |
| 5 | Q4 | Statistics & Probability | ✅ Complete |

**All four quarters of the General Mathematics curriculum are now fully integrated into the game!** 🎓📊

---

## Narrative Closure with Statistics

The use of statistics in Chapter 5 provides perfect narrative symmetry:

- **Chapter 1**: Functions (relationships) - Conrad learns to see connections
- **Chapter 2**: Functions cont. (operations) - Conrad learns to solve problems
- **Chapter 3**: Exponentials (patterns) - Conrad recognizes growth and decay
- **Chapter 4**: Trigonometry (navigation) - Conrad finds his path
- **Chapter 5**: Statistics (analysis) - Conrad sees the complete pattern

Conrad's journey from **collecting evidence** to **understanding patterns** to **drawing wisdom** mirrors the mathematical progression from **data** to **analysis** to **inference**.

---

*Last Updated: 2026-02-06*
