# Detective Analysis Minigame Usage Guide

## Overview

The **Detective Analysis** minigame is a context-integrated educational minigame that presents math/science problems within the story context. Unlike generic curriculum questions, these problems are directly relevant to solving the mystery.

## How It Works

1. **Story Context** - The timeline presents a mystery problem
2. **Detective Reasoning** - Conrad/Celestine explains why math/science is needed
3. **Minigame Trigger** - `[signal arg="start_minigame detective_analysis_id"]`
4. **Visual Analysis** - Student sees evidence and applies mathematical/scientific reasoning
5. **Solution & Explanation** - Correct answer is explained with formulas/principles

## Available Minigames

### Chapter 1: The Stolen Exam Papers

**Math - Timeline Analysis:**
- ID: `timeline_analysis_greg_math`
- Concept: Speed, Distance, Time calculation
- Context: Verify Greg's alibi by calculating travel time

**Science - Evaporation Analysis:**
- ID: `evaporation_analysis_science`
- Concept: Evaporation rates, forensic analysis
- Context: Determine when footprints were made based on moisture

### Chapter 2: Student Council Mystery

**Math - Fund Analysis:**
- ID: `fund_analysis_math`
- Concept: Percentages, ratio calculation
- Context: Calculate how much money should be in emergency fund

**Science - Fingerprint Analysis:**
- ID: `fingerprint_analysis_science`
- Concept: Biological classification, pattern recognition
- Context: Classify fingerprint type found on lockbox

### Chapter 3: Art Week Vandalism

**Math - Paint Area:**
- ID: `paint_area_math`
- Concept: Area calculation (length × width), percentages
- Context: Calculate paint coverage on vandalized sculpture

**Science - Energy Analysis:**
- ID: `energy_analysis_science`
- Concept: Potential energy (PE = mgh)
- Context: Determine if sculpture fell or was pushed

### Chapter 4: Anonymous Notes Mystery

**Math - Probability:**
- ID: `probability_analysis_math`
- Concept: Probability, statistical reasoning
- Context: Calculate likelihood sender also received note

**Science - Electricity:**
- ID: `electricity_analysis_science`
- Concept: Electrical power (P=VI), energy consumption
- Context: Track printer usage via power consumption

### Chapter 5: B.C. Revelation

**Math - Pattern Recognition:**
- ID: `pattern_recognition_math`
- Concept: Arithmetic sequences, sum formulas
- Context: Understand B.C.'s long-term pattern

**Science - Light & Optics:**
- ID: `light_analysis_science`
- Concept: Dispersion, refraction, wavelengths
- Context: B.C.'s metaphor using prism

## Timeline Integration Example

### Current Approach (Problematic):
```
# Chapter 1, Scene 1 - After talking to janitor
if {selected_subject} == "math":
    [signal arg="start_minigame curriculum:pacman"]
```
**Problem:** Pacman with random math questions has NO connection to the story.

### Improved Approach (Context-Integrated):
```
# Chapter 1, Scene 1 - After Greg's interrogation
if {selected_subject} == "english":
    Conrad: How should I phrase this question tactfully?
    [signal arg="start_minigame dialogue_choice_janitor"]

elif {selected_subject} == "math":
    Conrad: Wait... Greg said he left at 3:15 PM and walked home.
    Conrad: His house is 2.5 kilometers away. He claims he walks at 5 km/h.
    Conrad: If I calculate the travel time, I can verify his alibi.
    Mark: Math can help us check if his timeline makes sense!
    [signal arg="start_minigame timeline_analysis_greg_math"]
    if {minigames_completed} > 0:
        Conrad: The math checks out. Greg arrived home at 3:45 PM.
        Conrad: He couldn't have returned to steal the exams before 4:00 PM.

elif {selected_subject} == "science":
    Conrad: The janitor mopped the floor at 3:00 PM, but these footprints look fresh.
    Conrad: If I apply scientific principles about evaporation rates...
    Mark: Science can help us determine when these prints were made!
    [signal arg="start_minigame evaporation_analysis_science"]
    if {minigames_completed} > 0:
        Conrad: Based on the evaporation rate, these prints were made at 3:30 PM.
        Conrad: Someone entered after the janitor left!
```

## Benefits for Capstone Defense

1. **Contextualized Learning** - Students apply math/science to solve real problems
2. **Authentic Assessment** - Knowledge tested through application, not memorization
3. **Narrative Engagement** - Story motivates learning
4. **Real-World Relevance** - Shows how subjects are useful
5. **Research Support** - Aligns with situated learning theory

## Pedagogical Justification

**Cite these principles:**
- **Situated Learning** (Lave & Wenger) - Learning occurs best in authentic contexts
- **Problem-Based Learning** - Students learn by solving real problems
- **Transfer of Knowledge** - Application improves retention and understanding
- **Cognitive Load Theory** - Story context provides meaningful scaffolding

## Next Steps

1. Replace 2-3 generic minigames per chapter with Detective Analysis
2. Add 3-5 lines of context dialogue before curriculum minigames
3. Test with actual Grade 12 students
4. Gather feedback on engagement and learning outcomes
5. Document results for capstone paper

## Example Implementation Order

**Phase 1 - Chapter 1 (Pilot):**
- Add `timeline_analysis_greg_math` to c1s2 (Greg interrogation)
- Add `evaporation_analysis_science` to c1s1 (Janitor scene)
- Keep existing curriculum minigames but add context dialogue

**Phase 2 - Chapter 2:**
- Add `fund_analysis_math` to c2s3 (Lockbox investigation)
- Add `fingerprint_analysis_science` to c2s2 (Evidence analysis)

**Phase 3 - Chapters 3-5:**
- Integrate remaining Detective Analysis minigames
- Test full system with focus group

**Phase 4 - Data Collection:**
- Pre-test and post-test assessments
- Student engagement surveys
- Learning outcome analysis
