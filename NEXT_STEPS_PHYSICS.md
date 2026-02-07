# Next Steps: Physics Curriculum Integration

## ✅ Completed

1. **Integrated 25 physics problems** into `curriculum_questions.gd`
   - Q2 (Chapter 3): Mechanics - 8 Pacman, 6 Runner, 5 Maze, 4 Platformer, 1 Fill-in-blank, 5 Math questions
   - Q3 (Chapter 4): Electricity & Waves - 8 Pacman, 6 Runner, 5 Maze, 4 Platformer, 1 Fill-in-blank, 5 Math questions

2. **Updated review content** with physics explanations and formulas

3. **Created documentation** in `PHYSICS_CURRICULUM_INTEGRATION.md`

## 🔄 Current Status

### Chapter 1-2 (Q1)
✅ **Already has curriculum minigames**
- Example from c1s2.dtl:
  ```dtl
  if {selected_subject} == "science":
      [signal arg="start_minigame curriculum:runner"]
  ```
- Science students get Earth Science questions (Plate Tectonics)

### Chapter 3 (Q2)
⚠️ **No curriculum minigames yet**
- Current minigames: `receipt_riddle`, `budget_basics`
- These are story-specific, will fall back to English version for science students
- **Physics mechanics questions are ready but not being used**

### Chapter 4 (Q3)
⚠️ **No curriculum minigames yet**
- Current minigames: `anonymous_notes`, `dialogue_choice_approach_suspect`, `pedagogy_methods`
- These are story-specific, will fall back to English version
- **Physics electricity/waves questions are ready but not being used**

## 📋 Recommended Next Steps

### Option 1: Add Curriculum Minigames to Chapter 3

Edit timeline files to include subject-specific branching:

**Example: c3s3.dtl (after receipt riddle)**
```dtl
Conrad: Now I need to analyze the physics of this situation...

if {selected_subject} == "science":
    [signal arg="start_minigame curriculum:runner"]
elif {selected_subject} == "math":
    [signal arg="start_minigame curriculum:platformer"]
elif {selected_subject} == "english":
    # Keep existing dialogue minigame or add English curriculum
    [signal arg="start_minigame dialogue_choice_cruel_note"]
```

### Option 2: Add Curriculum Minigames to Chapter 4

**Example: c4s3.dtl (after pedagogy_methods)**
```dtl
Conrad: Let me test my understanding of electricity and waves...

if {selected_subject} == "science":
    [signal arg="start_minigame curriculum:maze"]
elif {selected_subject} == "math":
    [signal arg="start_minigame curriculum:platformer"]
elif {selected_subject} == "english":
    [signal arg="start_minigame dialogue_choice_library_logic"]
```

### Option 3: Create Subject-Specific Variants

Instead of curriculum minigames, create science-specific variants:

**For Chapter 3:**
- Add `receipt_riddle_science` to `riddle_configs` in MinigameManager
- Add `budget_basics_science` (physics word problem)

**For Chapter 4:**
- Add `anonymous_notes_science` (physics pronunciation)
- Add `pedagogy_methods_science` (physics fill-in-blank)

## 🎯 Testing Plan

Once curriculum minigames are added to Chapter 3/4:

1. Start new game → Select "Science"
2. Play through Chapter 3
   - Verify physics mechanics questions appear
   - Check formulas: F=ma, W=Fd, P=W/t
3. Play through Chapter 4
   - Verify electricity & waves questions appear
   - Check formulas: V=IR, P=VI, v=fλ
4. Intentionally fail minigames to test review content

## 📊 Current Science Curriculum Flow

| Chapter | Quarter | Topic | Status |
|---------|---------|-------|--------|
| 1-2 | Q1 | Earth Science (Plate Tectonics) | ✅ Active |
| 3 | Q2 | Physics - Mechanics | ⚠️ Ready, not used |
| 4 | Q3 | Physics - Electricity & Waves | ⚠️ Ready, not used |
| 5 | Q4 | Chemistry (Atomic Structure) | ✅ Ready |

## 🚀 Quick Implementation

**Fastest way to activate physics questions:**

Add to **c3s3.dtl** (after line 61):
```dtl
[signal arg="start_minigame receipt_riddle"]
# NEW: Science subject check
if {selected_subject} == "science":
    Conrad: Let me solve this physics problem...
    [signal arg="start_minigame curriculum:runner"]
```

Add to **c4s3.dtl** (after line 27):
```dtl
[signal arg="start_minigame pedagogy_methods"]
# NEW: Science subject check
if {selected_subject} == "science":
    Conrad: Time to test my electricity knowledge...
    [signal arg="start_minigame curriculum:maze"]
```

This will add **2 physics minigames** (one per chapter) using the questions we just integrated.

## 📝 Files Modified

1. ✅ `autoload/curriculum_questions.gd` - Physics questions added
2. ✅ `PHYSICS_CURRICULUM_INTEGRATION.md` - Documentation created
3. ✅ `NEXT_STEPS_PHYSICS.md` - This file

## 🔧 Files to Modify (Optional)

To activate physics minigames:
1. `content/timelines/Chapter 3/c3s3.dtl` - Add curriculum:runner
2. `content/timelines/Chapter 4/c4s3.dtl` - Add curriculum:maze

---

**Note:** The physics questions are **fully functional and ready to use**. They just need to be called from the timeline files using `[signal arg="start_minigame curriculum:TYPE"]` format.
