# Chapter Results System - Usage Guide

## Overview

The Chapter Results system tracks player performance throughout each chapter and displays a comprehensive results screen at the end with stats, rankings, and achievements.

## Automatic Tracking

The following stats are tracked **automatically** without any timeline changes needed:

✅ **Clues Collected** - Tracked via `[signal arg="unlock_evidence ..."]`
✅ **Minigames Completed** - Tracked when minigames finish
✅ **Speed Bonuses** - Tracked when minigames complete under 60 seconds
✅ **Level Progress** - Tracked via PlayerStats and Dialogic variables
✅ **Completion Time** - Tracked from chapter start to end
✅ **XP Earned** - Tracked via PlayerStats

## Manual Tracking (Timeline Signals)

For **choice tracking** (correct/wrong answers), add these signals in your timeline files:

### 1. Tracking Choices

```dtl
label choice_question
Conrad: Who took the bracelet?
- Greg (CORRECT)
    [signal arg="track_correct_choice"]
    Conrad: That's right!
    set {chapter1_score} += 10
- Ben (WRONG)
    [signal arg="track_wrong_choice"]
    Conrad: That's not correct.
    set {chapter1_score} -= 5
    jump choice_question
```

### 2. Tracking Interrogation Sequences

For "perfect interrogation" tracking (sequences without mistakes):

```dtl
[signal arg="start_interrogation"]
label interrogation_start
Conrad: Let's question the suspect...

(Multiple choice questions here)

[signal arg="end_interrogation"]
Conrad: I have all the information I need.
```

### 3. Showing Results Screen

At the **end of each chapter** (typically the last scene like c1s5, c2s6, etc.):

```dtl
Conrad: Another case solved.
[signal arg="show_chapter_results"]
jump c2s0/  # Jump to next chapter
```

## Complete Example - Chapter End

Here's how to set up a chapter ending with results:

```dtl
# c1s5.dtl - Final scene of Chapter 1

Conrad: The case is closed. Justice has been served.
Mark: Great work, Conrad!

# Show the chapter results screen
[signal arg="show_chapter_results"]

# After results dismissed, jump to next chapter
jump c2s0/
```

## Stats Displayed

### 📊 Performance Section
- **Chapter Score** - Total points from choices (+10 correct, -5 wrong)
- **Investigation Accuracy** - Percentage of correct choices
- **Clues Collected** - X / Y clues found

### 🎯 Choices Section
- **Correct Choices** - Number of right answers
- **Wrong Choices** - Number of mistakes
- **Perfect Interrogations** - Sequences completed without errors

### ⏱️ Efficiency Section
- **Completion Time** - MM:SS format
- **Minigames Completed** - Total minigames finished
- **Speed Bonuses** - Minigames under 60 seconds
- **Hints Used** - How many hints consumed

### 📈 Progress Section
- **Detective Level** - Start → End level
- **XP Earned** - Total XP gained this chapter

### 🏆 Achievements
- **Perfect Detective** 🌟 - No wrong choices
- **Speed Demon** ⚡ - All minigames under 60 seconds
- **Eagle Eye** 🔍 - All clues collected
- **Hint Master** 🧠 - Completed without using hints
- **Smooth Interrogator** 💬 - Perfect interrogation sequences

## Detective Ranks

Based on accuracy + clue collection average:

- **S Rank** (95%+ avg, no wrong choices) - Gold
- **A Rank** (90%+) - Cyan
- **B Rank** (80%+) - Green
- **C Rank** (70%+) - Yellow
- **D Rank** (60%+) - Orange
- **F Rank** (<60%) - Red

## Implementation Checklist

For each chapter's **final scene** (e.g., c1s5):

- [ ] Add `[signal arg="show_chapter_results"]` before jumping to next chapter
- [ ] Ensure all choice branches have `track_correct_choice` or `track_wrong_choice`
- [ ] Add `start_interrogation` and `end_interrogation` for perfect tracking
- [ ] Test that all evidence unlocks are triggered
- [ ] Verify minigames complete and report speed bonuses

## Testing

1. Play through a chapter completely
2. Make some correct and wrong choices
3. Collect all clues
4. Complete minigames (some fast, some slow)
5. View results screen at chapter end
6. Verify all stats are accurate

## Notes

- Stats reset automatically when a new chapter starts
- Results screen pauses Dialogic until dismissed
- Continue button resumes the timeline
- Chapter score comes from Dialogic variables (`chapter1_score`, etc.)
- The system integrates with existing save/load system
