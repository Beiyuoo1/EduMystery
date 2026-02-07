# Clue/Evidence Analyzer for EduMys

Analyzes converted dialogue transcripts to suggest potential evidence items and clues based on the story content.

## What It Does

The analyzer scans your converted dialogue transcripts (`.txt` files) and:
- 🔍 Identifies mentions of clue-related keywords (objects, locations, suspicious words)
- 💡 Suggests potential evidence items based on dialogue context
- 📊 Shows existing evidence unlocks and minigames
- ✨ Highlights key dialogue moments with high clue density
- 📈 Ranks suggestions by frequency across all scenes

## Usage

### Quick Start (Windows)

1. First, convert your chapter dialogue to TXT:
   ```bash
   # Run this first
   convert_dtl.bat
   # Select option 3, 4, 5, or 6 to convert a chapter
   ```

2. Then analyze the transcripts:
   ```bash
   # Double-click this file
   analyze_clues.bat
   # Select the same chapter to analyze
   ```

### Command Line (Mac/Linux)

```bash
# Step 1: Convert dialogue to TXT
python dtl_to_txt_converter.py
# Choose your chapter (3-6)

# Step 2: Analyze the transcripts
python clue_analyzer.py
# Choose the same chapter
```

## What to Analyze

The analyzer works on **converted transcript files** (`.txt`), not the original `.dtl` files.

**Workflow:**
1. Convert DTL → TXT using `dtl_to_txt_converter.py`
2. Analyze TXT files using `clue_analyzer.py`

**Example:**
```bash
# Convert Chapter 3
python dtl_to_txt_converter.py
# Select option 4

# Analyze Chapter 3 transcripts
python clue_analyzer.py
# Select option 2
```

## Output Report

The analyzer generates a comprehensive report:

### 📊 Summary Section
- Total files analyzed
- Number of clue keyword mentions
- Count of existing evidence items

### ✅ Existing Evidence
Shows evidence already unlocked in the chapter:
```
✅ Existing Evidence Items:
  • cruel_note_c3 (line 145)
  • paint_cloth_c3 (line 289)
  • victor_sketchbook_c3 (line 412)
```

### 🔍 Key Moments
Dialogue lines with multiple clue keywords (high importance):
```
🔍 Key Moments (Clue-Rich Dialogue):
  • [Conrad] I found a strange note hidden under the desk...
    (Line 145, 3 clue keywords)
  • [Mia] The paint-stained cloth was concealed in the cabinet...
    (Line 289, 4 clue keywords)
```

### 💡 Suggested Evidence Items
Potential new clues ranked by frequency:
```
💡 Suggested Evidence Items (by frequency):
  1. "the note" - mentioned 8 time(s)
  2. "a cloth" - mentioned 5 time(s)
  3. "the receipt" - mentioned 4 time(s)
  4. "the sketchbook" - mentioned 3 time(s)
```

### 📁 Per-File Breakdown
Detailed analysis for each scene file:
```
📁 Per-File Breakdown:

  c3s0.txt:
    Clue mentions: 12
    Evidence unlocks: 1
    Minigames: 2
    Top suggestions:
      • "the note" (3x)
      • "a bracelet" (2x)
```

## How It Works

### Clue Keyword Detection

The analyzer looks for these categories of keywords:

**Physical Objects:**
- note, letter, paper, receipt, photo, bracelet, necklace, key, card
- book, notebook, diary, journal, phone, laptop, camera
- bag, backpack, locker, box, cloth, fabric, stain, paint

**Actions/Events:**
- found, discovered, noticed, saw, heard, witnessed
- missing, stolen, lost, hidden, concealed
- evidence, clue, proof, alibi, witness

**Suspicious Words:**
- suspicious, strange, odd, unusual, weird
- lie, secret, hiding, guilty, innocent, suspect

**Locations:**
- scene, room, office, classroom, locker, desk, drawer, cabinet

**Mystery Elements:**
- mystery, investigation, case, crime, incident
- victim, perpetrator, motive, opportunity

### Context Analysis

For each keyword found, the analyzer:
1. Captures surrounding context (3 words before/after)
2. Tracks line numbers for easy reference
3. Identifies patterns like "found [object]" or "discovered [item]"
4. Ranks suggestions by frequency across all scenes

### Smart Filtering

The analyzer filters out:
- Common non-evidence words (it, that, this, something)
- Generic dialogue markers
- Non-specific references

## Use Cases

### 1. Planning New Evidence

**Scenario:** Writing Chapter 4 and need evidence ideas

```bash
# Convert Chapter 4 dialogue
python dtl_to_txt_converter.py  # Option 5

# Analyze for clue suggestions
python clue_analyzer.py  # Option 3
```

**Output:** Get a ranked list of items naturally mentioned in dialogue that would make good evidence.

### 2. Consistency Checking

**Scenario:** Make sure all important items are unlocked as evidence

```bash
# Analyze existing chapter
python clue_analyzer.py  # Select chapter

# Check "Key Moments" section
# If important dialogue mentions items not in "Existing Evidence",
# consider adding them as evidence unlocks
```

### 3. Finding Missing Clues

**Scenario:** Dialogue mentions items that should be evidence

**Example Output:**
```
🔍 Key Moments:
  • [Conrad] The receipt proves Victor was near the school...
    (Line 234, 3 clue keywords)

✅ Existing Evidence Items:
  • paint_cloth_c3
  • victor_sketchbook_c3
  # Missing: receipt!
```

**Action:** Add receipt as evidence in the timeline at the appropriate point.

### 4. Balancing Evidence Distribution

**Scenario:** Check if evidence is evenly distributed across scenes

```
📁 Per-File Breakdown:
  c3s0.txt: Evidence unlocks: 0  # Too few?
  c3s1.txt: Evidence unlocks: 3  # Too many?
  c3s2.txt: Evidence unlocks: 1  # Good
```

## Requirements

- Python 3.6 or higher
- Converted transcript files (`.txt`) from `dtl_to_txt_converter.py`
- No external dependencies (uses Python standard library)

## Workflow Example

**Complete workflow for analyzing Chapter 3:**

```bash
# 1. Convert Chapter 3 dialogue to text
python dtl_to_txt_converter.py
# Press 4 (Chapter 3)
# Output saved to: transcripts/Chapter_3/

# 2. Analyze the transcripts
python clue_analyzer.py
# Press 2 (Chapter 3)

# 3. Review the report
# - Check suggested clues
# - Compare with existing evidence
# - Identify gaps or missing items

# 4. Update your game
# - Add new evidence definitions to EvidenceManager
# - Add unlock signals in timelines
# - Create evidence images
```

## Tips

### Best Practices

✅ **Run analyzer early** - Use it while writing dialogue to identify natural evidence opportunities

✅ **Check frequency** - Items mentioned 3+ times are strong evidence candidates

✅ **Read key moments** - High keyword-density dialogue should usually unlock evidence

✅ **Balance per scene** - Aim for 1-2 evidence items per scene file

✅ **Match dialogue** - If characters talk about an item extensively, it should be evidence

### Common Patterns

**Good evidence candidates:**
- Mentioned multiple times across different scenes
- Associated with "found", "discovered", "noticed" verbs
- Described with specific details (color, location, condition)
- Connected to multiple clue keywords

**Weak evidence candidates:**
- Mentioned only once in passing
- Generic references ("it", "something")
- Background elements without story significance

## Output Files

The analyzer doesn't create files - it prints reports to the console.

**To save a report:**
```bash
# Windows
python clue_analyzer.py > chapter3_analysis.txt

# Mac/Linux
python clue_analyzer.py > chapter3_analysis.txt
```

## Troubleshooting

### "No .txt files found"
- Make sure you converted the chapter first using `dtl_to_txt_converter.py`
- Check that files exist in `transcripts/Chapter_X/`

### "Too many suggestions"
- Focus on items with frequency ≥ 3
- Read the context to determine story relevance
- Not all mentioned items need to be evidence

### "No suggestions found"
- Your dialogue might not use clue keywords
- Add more descriptive language about objects and events
- Use words like "found", "noticed", "discovered" more

## Integration with Game

After getting suggestions, integrate them into the game:

1. **Add to EvidenceManager** ([autoload/evidence_manager.gd](autoload/evidence_manager.gd)):
   ```gdscript
   "suggested_item_c3": {
       "id": "suggested_item_c3",
       "title": "Suggested Item",
       "description": "Description based on dialogue context",
       "image_path": "res://Bg/assets/evidence/suggested_item.png",
       "chapter": 3
   }
   ```

2. **Add unlock signal in timeline**:
   ```
   Conrad: I found the suggested item!
   [signal arg="unlock_evidence suggested_item_c3"]
   ```

3. **Create evidence image** at `Bg/assets/evidence/suggested_item.png`

## License

This tool is part of the EduMys project and follows the same license as the main project.
