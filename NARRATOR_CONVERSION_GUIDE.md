# Narrator Dialogue Conversion Guide

## ✅ What Was Done

The narrator dialogues across all 5 chapters have been **partially converted** from 3rd person (Conrad/Celestine) to 2nd person (you).

- **Files processed:** 33 timeline files
- **Changes made:** 214 individual line modifications
- **Conversion type:** Conservative (only changed possessives and some pronouns)

## 📋 Review Process

### Step 1: Review the Change Report

Open `NARRATION_CHANGES_REPORT.txt` to see all 139 documented changes with before/after comparisons.

**For each change:**
1. ✅ Check if the grammar is correct
2. ✅ Check if the meaning is preserved
3. ✅ Mark any issues that need manual fixing
4. ✅ Note which lines need voice re-recording

### Step 2: Common Issues to Fix

Based on the automatic conversion, here are **common errors** you'll find:

#### ❌ **Issue 1: Incomplete pronoun conversion**
```
WRONG: "Unlike most of your classmates, she felt something..."
RIGHT: "Unlike most of your classmates, you felt something..."
```
**Fix:** Change remaining "he/she" to "you" in the same sentence.

#### ❌ **Issue 2: Possessive errors**
```
WRONG: "The Janitor brings in your cleaning equipment"
RIGHT: "The Janitor brings in his cleaning equipment"
```
**Fix:** Keep "his/her" when it refers to OTHER characters, not the protagonist.

#### ❌ **Issue 3: Verb conjugation errors**
```
WRONG: "Mysteries had always fascinated your"
RIGHT: "Mysteries had always fascinated you"
```
**Fix:** "your" is possessive, "you" is pronoun. Check context.

#### ❌ **Issue 4: Mixed pronouns in same sentence**
```
WRONG: "visible only to your. Only she can see..."
RIGHT: "visible only to you. Only you can see..."
```
**Fix:** Convert ALL pronouns in narration about the protagonist.

### Step 3: Manual Editing Workflow

**Recommended approach:**

1. **Open the timeline file** (e.g., `content/timelines/Chapter 1/c1s1.dtl`)
2. **Search for the BEFORE text** from the report
3. **Manually edit** the line to fix grammar/meaning
4. **Check in-game** to see how it reads
5. **Mark as reviewed** in the report

**Example fix:**

**Report shows:**
```
BEFORE: Unlike most of her classmates, she felt something strange
AFTER:  Unlike most of your classmates, she felt something strange
```

**You manually change to:**
```
FINAL:  Unlike most of your classmates, you felt something strange
```

### Step 4: Voice Re-recording

After fixing all text issues:

1. **Export narration text** from each chapter
2. **Re-record voice files** with 2nd person narration
3. **Replace old MP3 files** in `assets/audio/voice/`
4. **Test in-game** to ensure voice matches text

**Voice files location:**
- `assets/audio/voice/Chapter 1/c1s1/` etc.

## 🔧 Quick Fix Script (Optional)

If you find many similar errors, you can create a batch fix:

```python
# Example: Fix "fascinated your" → "fascinated you"
import re
from pathlib import Path

for file in Path("content/timelines").rglob("*.dtl"):
    content = file.read_text(encoding='utf-8')
    content = re.sub(r'fascinated your(?!\s+\w+)', 'fascinated you', content)
    file.write_text(content, encoding='utf-8')
```

## 📊 Progress Tracking

Use the checkboxes in `NARRATION_CHANGES_REPORT.txt`:

```
[ ] Reviewed  [ ] Needs Fix  [ ] Voice Re-record Needed
[X] Reviewed  [ ] Needs Fix  [X] Voice Re-record Needed  ← Example: Reviewed, needs voice
[X] Reviewed  [X] Needs Fix  [ ] Voice Re-record Needed  ← Example: Needs manual edit
```

## 🎯 Priority Order

**Recommended order of review:**

1. **Chapter 1** (14 changes) - Test here first
2. **Chapter 2** (69 changes) - Most changes
3. **Chapter 3** (61 changes)
4. **Chapter 4** (42 changes)
5. **Chapter 5** (28 changes)

## 🚀 Testing

After fixing issues in Chapter 1:

1. Run the game
2. Start Chapter 1 with both Conrad and Celestine
3. Read narration lines aloud
4. Check for:
   - ✅ Grammar correctness
   - ✅ Natural flow
   - ✅ Immersion (does "you" feel natural?)
5. If good, proceed to other chapters

## 📝 Reverting Changes (If Needed)

If you want to start over:

```bash
# Revert all timeline changes
git restore content/timelines/

# Then manually edit or use a different approach
```

## 🎬 Next Steps

1. ✅ **Review** `NARRATION_CHANGES_REPORT.txt` (all 139 changes)
2. ✅ **Fix** grammatical errors in timeline files
3. ✅ **Test** Chapter 1 in-game
4. ✅ **Export** narration text for voice recording
5. ✅ **Re-record** voice files with 2nd person perspective
6. ✅ **Replace** old voice MP3s with new recordings
7. ✅ **Final test** all 5 chapters

---

**Good luck with the conversion!** The bulk of the work is done - now it's just polishing and re-recording. 🎙️
