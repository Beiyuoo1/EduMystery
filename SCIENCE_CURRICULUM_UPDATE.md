# Science Curriculum Update Summary

## Overview
The Science subject has been completely reorganized to focus on **Physics** across all chapters (Q1-Q4). All story-specific minigames now have Science variants with Physics-based questions.

---

## ✅ Complete Physics Curriculum (Q1-Q4)

### **Q1: Motion and Forces (Chapters 1-2)**
**Topics:** Kinematics, Newton's Laws, Momentum

**Minigame Coverage:**
- ✅ Pacman: 8 questions (speed, force, acceleration, inertia)
- ✅ Runner: 6 questions (F=ma calculations, friction, terminal velocity)
- ✅ Maze: 5 questions (formulas: F=ma, v=d/t, momentum)
- ✅ Platformer: 4 questions (equilibrium, inertia, free fall)
- ✅ Fill-in-blank: Newton's second law
- ✅ Math: 5 calculation problems

**Key Formulas:**
- `F = ma` (Newton's 2nd Law)
- `v = d/t` (Velocity)
- `a = Δv/t` (Acceleration)
- `p = mv` (Momentum)

---

### **Q2: Work, Energy, and Power (Chapter 3)**
**Topics:** Work, Kinetic Energy, Potential Energy, Conservation

**Minigame Coverage:**
- ✅ Pacman: 8 questions (work, power, energy types, SI units)
- ✅ Runner: 6 questions (energy transformation, efficiency, springs)
- ✅ Maze: 5 questions (formulas: W=Fd, P=W/t, KE, PE)
- ✅ Platformer: 4 questions (springs, height vs PE, doubling speed)
- ✅ Fill-in-blank: Conservation of energy
- ✅ Math: 5 calculation problems

**Key Formulas:**
- `W = Fd` (Work)
- `P = W/t` (Power)
- `KE = ½mv²` (Kinetic Energy)
- `PE = mgh` (Potential Energy)

---

### **Q3: Electricity and Magnetism (Chapter 4)**
**Topics:** Circuits, Ohm's Law, Power, Magnetic Forces

**Minigame Coverage:**
- ✅ Pacman: 8 questions (resistance, power, current, photoelectric effect)
- ✅ Runner: 6 questions (Doppler effect, photons, circuit behavior)
- ✅ Maze: 5 questions (formulas: V=IR, P=VI, wave speed)
- ✅ Platformer: 4 questions (magnetic force, frequency, pressure)
- ✅ Fill-in-blank: Wave speed formula
- ✅ Math: 5 calculation problems

**Key Formulas:**
- `V = IR` (Ohm's Law)
- `P = VI` (Electric Power)
- `I = Q/t` (Current)
- `F = qvB` (Magnetic Force)
- `v = fλ` (Wave Speed)

---

### **Q4: Waves, Light, and Modern Physics (Chapter 5)**
**Topics:** Wave Properties, Refraction, Wave-Particle Duality, Photons

**Minigame Coverage:**
- ✅ Pacman: 8 questions (wave types, light speed, refraction, photons)
- ✅ Runner: 6 questions (energy-frequency, photoelectric effect, interference)
- ✅ Maze: 5 questions (formulas: v=fλ, E=hf, Snell's law)
- ✅ Platformer: 4 questions (spectrum, lenses, mirrors, de Broglie)
- ✅ Fill-in-blank: Wave-particle duality
- ✅ Math: 5 calculation problems

**Key Formulas:**
- `v = fλ` (Wave Speed)
- `E = hf` (Photon Energy)
- `n = c/v` (Refractive Index)

---

## ✅ Story-Specific Science Variants

All 13 story-specific minigames now have Science variants:

### **Fill-in-the-Blank (Hear & Fill Type):**
1. ✅ `wifi_router_science` - Law of inertia (Ch 1)
2. ✅ `anonymous_notes_science` - Ohm's law current (Ch 4)
3. ✅ `observation_teaching_science` - Wave-particle duality (Ch 5)

### **Fill-in-the-Blank (Drag & Drop Type):**
4. ✅ `locker_examination_science` - F = ma (Ch 1)
5. ✅ `pedagogy_methods_science` - Series circuits (Ch 4)

### **Riddles:**
6. ✅ `bracelet_riddle_science` - INERTIA (Ch 1)
7. ✅ `receipt_riddle_science` - ENERGY (Ch 3)

### **Dialogue Choice (Voice Recognition):**
8. ✅ `dialogue_choice_janitor_science` - Free fall acceleration (Ch 1)
9. ✅ `dialogue_choice_ria_note_science` - F=ma calculation (Ch 2)
10. ✅ `dialogue_choice_cruel_note_science` - PE=mgh calculation (Ch 3)
11. ✅ `dialogue_choice_approach_suspect_science` - P=VI calculation (Ch 4)
12. ✅ `dialogue_choice_bc_approach_science` - v=fλ calculation (Ch 5)

### **Platformer:**
13. ✅ `platformer_science` - Physics quiz questions

---

## ✅ Pacman 3-Lives System

The Pacman minigame now features a lives system:

**Features:**
- 🎯 Player starts with **3 lives**
- ❤️ Lives displayed in **red text** at top-left
- 💥 When hit: loses 1 life, **respawns at center**
- 🛡️ **2 seconds of invincibility** after respawn (semi-transparent)
- 📍 Game over only after **all 3 lives used**

**Visual Feedback:**
- Red screen flash when hit
- Screen shake effect
- Floating "-1 Life" text
- "Respawned!" message
- Semi-transparent player during invincibility

**Files Modified:**
- `minigames/Pacman/scripts/Main.gd` - Added lives logic
- `minigames/Pacman/scenes/Main.tscn` - Added LivesLabel UI

---

## Files Modified

### Curriculum Questions:
- ✅ `autoload/curriculum_questions.gd` - Complete Physics Q1-Q4

### Story Minigames:
- ✅ `autoload/minigame_manager.gd` - All 13 science variants added

### Pacman Minigame:
- ✅ `minigames/Pacman/scripts/Main.gd` - 3-lives system
- ✅ `minigames/Pacman/scenes/Main.tscn` - Lives UI

### Documentation:
- ✅ `CLAUDE.md` - Updated with science curriculum and Pacman lives info
- ✅ `SCIENCE_CURRICULUM_UPDATE.md` - This summary document

---

## Testing Checklist

### ✅ Curriculum Minigames (Science Subject):
- [ ] Chapter 1-2: Pacman (Motion & Forces questions)
- [ ] Chapter 1-2: Runner (Motion & Forces questions)
- [ ] Chapter 3: Pacman (Work, Energy, Power questions)
- [ ] Chapter 4: Maze (Electricity & Magnetism questions)
- [ ] Chapter 5: Platformer (Waves, Light questions)

### ✅ Story-Specific Minigames (Science Subject):
- [ ] Chapter 1: `locker_examination_science` (F = ma)
- [ ] Chapter 1: `wifi_router_science` (inertia)
- [ ] Chapter 1: `bracelet_riddle_science` (INERTIA)
- [ ] Chapter 1: `dialogue_choice_janitor_science` (free fall)
- [ ] Chapter 2: `dialogue_choice_ria_note_science` (F=ma calc)
- [ ] Chapter 3: `receipt_riddle_science` (ENERGY)
- [ ] Chapter 3: `dialogue_choice_cruel_note_science` (PE=mgh)
- [ ] Chapter 4: `pedagogy_methods_science` (circuits)
- [ ] Chapter 4: `anonymous_notes_science` (current)
- [ ] Chapter 4: `dialogue_choice_approach_suspect_science` (P=VI)
- [ ] Chapter 4: `platformer_science` (physics quiz)
- [ ] Chapter 5: `observation_teaching_science` (duality)
- [ ] Chapter 5: `dialogue_choice_bc_approach_science` (v=fλ)

### ✅ Pacman Lives System:
- [ ] Lives counter displays correctly (3 at start)
- [ ] Player respawns at center when hit
- [ ] Invincibility works after respawn (2 seconds)
- [ ] Game over triggers after 3 hits
- [ ] Visual feedback (flash, shake, text) works

---

## Known Issues / To Fix

If you're still experiencing drag-and-drop errors with Science subject:

1. **Check MinigameManager variant lookup** - The `_get_subject_variant_id()` function should find science variants
2. **Verify fill-in-blank configs exist** - All science variants should be in `fillinTheblank_configs` dictionary
3. **Check console for missing variant warnings** - Look for "No variant found" messages

---

## Next Steps

1. ✅ Test all Science curriculum minigames (Chapters 1-5)
2. ✅ Test all Science story-specific variants
3. ✅ Verify Pacman lives system works correctly
4. 🔄 Fix any remaining drag-and-drop errors (if any)
5. 📝 Update player-facing documentation (if needed)

---

**Last Updated:** 2026-02-06
**Status:** Science curriculum complete, testing in progress
