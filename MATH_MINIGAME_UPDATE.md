# Math Minigame Update - Locker Examination

## What Changed

The `locker_examination` fill-in-the-blank minigame now has a **math-focused variant** that appears when the player selects **Math** as their subject.

---

## Before vs After

### English Version (Default)
```
Conrad [examines] the envelope closely.
```
Choices: examines, studies, ignores, watches, inspects, reads, opens, holds

### Math Version (NEW) ✅
```
If Conrad finds [8] clues total and has already examined [3], how many [clues] remain?
```
Choices: 8, 5, 3, 2, clues, items, objects, pieces, evidence, suspects, answers, questions

**Answer:** 8 total - 3 examined = **5 clues** remaining

---

## How It Works

### Subject Detection

When the timeline calls `start_minigame("locker_examination")`:

1. **If player selected English:**
   - Shows: "Conrad [examines] the envelope closely."

2. **If player selected Math:**
   - Automatically loads `locker_examination_math`
   - Shows: "If Conrad finds [8] clues total and has already examined [3], how many [clues] remain?"

3. **If player selected Science:**
   - Automatically loads `locker_examination_science`
   - Shows science-related content

### Technical Implementation

**File:** `autoload/minigame_manager.gd`

**Lines 163-167:**
```gdscript
"locker_examination_math": {
	"sentence_parts": ["If Conrad finds ", " clues total and has already examined ", ", how many ", " remain?"],
	"answers": ["8", "3", "clues"],
	"choices": ["8", "5", "3", "2", "clues", "items", "objects", "pieces", "evidence", "suspects", "answers", "questions"]
},
```

**Subject Variant Detection:** (Lines 2838-2888)
```gdscript
func _get_subject_variant_id(base_id: String) -> String:
	var subject = PlayerStats.selected_subject

	if subject == "english":
		return base_id  # Use base English version

	# Try math/science variant
	var variant_id = base_id + "_" + subject  # e.g., "locker_examination_math"

	if fillinTheblank_configs.has(variant_id):
		return variant_id  # Use math/science version

	# No variant found, fallback to English
	return base_id
```

---

## Educational Value (Math Version)

### Concepts Covered
- **Subtraction**: 8 - 3 = 5
- **Word problems**: Reading and understanding mathematical scenarios
- **Context clues**: Using story context to solve math problems
- **Logical reasoning**: Total - examined = remaining

### Why This Works Better
✅ **Story-integrated**: Uses detective story context (clues, evidence)
✅ **Authentic learning**: Math applied to real problem-solving
✅ **Age-appropriate**: Simple subtraction for Grade 11/12
✅ **Engaging**: More interesting than abstract equations
✅ **Multiple blanks**: Tests comprehension of problem structure (3 blanks to fill)

---

## Testing

### To Verify Math Version Appears

1. **Start a new game**
2. **Select Conrad or Celestine**
3. **Select "Math" as subject** on subject selection screen
4. **Skip to Chapter 1** (or play through)
5. **Reach Chapter 1 Scene 5** (locker examination)
6. **Verify minigame shows:**
   - "If Conrad finds [8] clues total and has already examined [3], how many [clues] remain?"
   - NOT "Conrad [examines] the envelope closely."

### Debug Console Output

When math version loads, you should see:
```
DEBUG: MinigameManager.start_minigame called with: locker_examination
DEBUG: PlayerStats.selected_subject = math
DEBUG: Looking for variant: locker_examination_math
DEBUG: Found in fillinTheblank_configs!
DEBUG: Using minigame variant: locker_examination_math
```

---

## For Other Subjects

### Science Version
Already exists in `minigame_manager.gd`:
```gdscript
"locker_examination_science": {
	// Physics-related fill-in-the-blank
}
```

### English Version (Default)
```gdscript
"locker_examination": {
	"sentence_parts": ["Conrad ", " the envelope closely."],
	"answers": ["examines"],
	"choices": ["examines", "studies", "ignores", "watches", "inspects", "reads", "opens", "holds"]
}
```

---

## Common Issues

### Issue: Math version not appearing

**Possible causes:**
1. Subject not set to "math" in subject selection
2. `PlayerStats.selected_subject` not persisting
3. Using old save file with different subject

**Solution:**
- Start a **new game** (not load save)
- Make sure to **select "Math"** on subject selection screen
- Check debug console for subject detection messages

### Issue: Wrong choices appearing

**Note:** The choices list has 12 items, but the UI only shows 8 at a time. This is intentional to provide variety and make the puzzle challenging.

---

## Future Improvements (Optional)

### More Math Word Problems

Could add similar story-integrated math problems:
- **Time calculations**: "If class ends at 3:00 PM and Conrad spent 45 minutes investigating..."
- **Percentages**: "If 30% of 20 students saw the culprit..."
- **Patterns**: "The locker combination follows the pattern: 2, 4, 8, [16]..."

### Difficulty Scaling

Could add harder problems for later chapters:
- Chapter 1: Simple subtraction (8 - 3)
- Chapter 2: Multiplication/division
- Chapter 3: Fractions/percentages
- Chapter 4: Ratios/proportions
- Chapter 5: Complex word problems

---

## Files Modified

- ✅ `autoload/minigame_manager.gd` - Updated `locker_examination_math` config

---

## Summary

The math variant is now **story-integrated** and **contextually relevant** instead of showing abstract equations. This provides:
- ✅ Better engagement (detective story context)
- ✅ Authentic learning (applying math to solve mysteries)
- ✅ Age-appropriate challenge (Grade 11/12 level)
- ✅ Multiple skill practice (reading, comprehension, calculation)

**Test it out by selecting Math subject and playing Chapter 1!** 🎓🔢
