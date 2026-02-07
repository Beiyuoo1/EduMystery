# Physics Curriculum Integration

## Overview

Successfully integrated 25 physics problems into the science curriculum system for Chapters 3-4 (Q2-Q3).

## Changes Made

### 1. Updated `curriculum_questions.gd`

#### **Q2: Physics - Mechanics (Chapter 3)**
Topics: Motion, Forces, Energy, Work, Power

**Minigame Types:**
- **Pacman** (8 questions): Speed, work, acceleration, force, friction, power, potential energy
- **Runner** (6 questions): Distance calculation, spring force, normal force, friction, frictionless vs rough surfaces, pulley dynamics
- **Maze** (5 questions): Formula-based (F=ma, W=Fd, P=W/t, KE=½mv², PE=mgh)
- **Platformer** (4 questions): Conceptual understanding of friction, spring force, PE, acceleration
- **Fill-in-blank**: "Average **speed** uses total distance divided by total **time**."
- **Math minigame** (5 questions): Calculation-heavy problems with timed answers

**Sample Questions:**
- "A car travels 120m in 5s, then 180m in 10s. Average speed?" → **20 m/s**
- "4 kg box accelerates at 2.5 m/s². Net force?" → **10 N**
- "Machine does 600J work in 5s. Power?" → **120 W**

#### **Q3: Physics - Electricity, Magnetism, Waves (Chapter 4)**
Topics: Circuits, Electric Power, Waves, Doppler Effect, Magnetism

**Minigame Types:**
- **Pacman** (8 questions): Resistance, wave speed, photoelectric effect, power, current, magnetic force
- **Runner** (6 questions): Doppler effect, Bernoulli's principle, de Broglie wavelength, photons
- **Maze** (5 questions): Formula-based (V=IR, P=VI, v=fλ, I=Q/t, F=qvB)
- **Platformer** (4 questions): Perpendicular motion, frequency shift, pressure-velocity relationship
- **Fill-in-blank**: "Wave **speed** depends on frequency times **wavelength**."
- **Math minigame** (5 questions): Circuit and wave calculations

**Sample Questions:**
- "4Ω and 6Ω resistors in series. Equivalent resistance?" → **10 Ω**
- "Wave frequency 5Hz, wavelength 3m. Speed?" → **15 m/s**
- "Sound source moves toward observer. Observed frequency?" → **Higher**

### 2. Updated Review Content

Added comprehensive review explanations for students who struggle with minigames:

**Q2 Review - Mechanics:**
- Key formulas with explanations
- Example: PE = mgh calculation
- Tip: Average speed uses TOTAL distance ÷ TOTAL time

**Q3 Review - Electricity & Waves:**
- Circuit formulas (Ohm's Law, Power)
- Wave properties and Doppler Effect
- Example: Wave speed = frequency × wavelength
- Tip: Moving source → frequency shift (compression/expansion)

## Problem Mapping

### Mechanics Problems (Q2)
- Problem 1 → Average speed (300m ÷ 15s = 20 m/s)
- Problem 2 → Work (20N × 5m = 100 J)
- Problem 6 → Acceleration (v = 0 + 3×8 = 24 m/s)
- Problem 7 → Force (F = 4×2.5 = 10 N)
- Problem 8 → Friction (0.2 × 100N = 20 N)
- Problem 9 → Work (50N × 6m = 300 J)
- Problem 10 → Power (600J ÷ 5s = 120 W)
- Problem 11 → Potential Energy (2×10×8 = 160 J)
- Problem 13 → Horizontal distance (15×2 = 30 m)
- Problem 14 → Spring force (200×0.05 = 10 N)
- Problem 15 → Normal force on incline (100×cos30° = 86.6 N)
- Problem 16 → Friction (0.3 × 200N = 60 N)
- Problem 24 → Pulley dynamics (solid vs hollow)
- Problem 25 → Energy conservation (frictionless vs rough)

### Electricity & Waves Problems (Q3)
- Problem 3 → Series resistance (4Ω + 6Ω = 10Ω)
- Problem 4 → Wave speed (5Hz × 3m = 15 m/s)
- Problem 5 → Photoelectric effect (particle nature of light)
- Problem 12 → Electric power (24V × 10A = 240 W)
- Problem 17 → Magnetic force (2C × 3m/s × 0.5T = 3 N)
- Problem 18 → Wave speed (12Hz × 2.5m = 30 m/s)
- Problem 19 → Doppler effect (moving source → higher frequency)
- Problem 20 → Current (12C ÷ 3s = 4 A)
- Problem 21 → Power (12V × 2A = 24 W)
- Problem 22 → Bernoulli's principle (faster flow → lower pressure)
- Problem 23 → de Broglie wavelength (higher momentum → smaller λ)

## Chapter Integration

### Chapter 3 (Q2 - Mechanics)
Science students will encounter:
- Runner minigame: Mechanics concepts (forces, motion)
- Pacman: Speed and energy calculations
- Maze: Formula recognition
- Platformer: Conceptual understanding

### Chapter 4 (Q3 - Electricity & Waves)
Science students will encounter:
- Runner minigame: Wave and circuit concepts
- Pacman: Electricity calculations
- Maze: Circuit formulas
- Platformer: Wave properties

## Testing Recommendations

1. **Start new game** → Select "Science" subject
2. **Chapter 3** → Verify physics mechanics questions appear
3. **Chapter 4** → Verify electricity & waves questions appear
4. **Test each minigame type** (Pacman, Runner, Maze, Platformer)
5. **Verify review content** shows when failing minigames

## Philippine SHS Curriculum Alignment

The physics content aligns with **General Physics 1 & 2** curriculum for Senior High School:

**General Physics 1 (Q2 equivalent):**
- Kinematics (motion, velocity, acceleration)
- Dynamics (forces, Newton's Laws)
- Work, Energy, and Power
- Friction and Inclined Planes

**General Physics 2 (Q3 equivalent):**
- Electricity and Magnetism
- Circuits and Ohm's Law
- Waves and Wave Properties
- Doppler Effect

## Formula Reference

### Mechanics (Q2)
```
Average Speed: v_avg = total distance / total time
Work: W = F × d
Power: P = W / t
Force: F = m × a
Kinetic Energy: KE = ½mv²
Potential Energy: PE = mgh
Friction: F_f = μN
Spring Force: F = kx
```

### Electricity & Waves (Q3)
```
Ohm's Law: V = IR
Power: P = VI
Current: I = Q / t
Wave Speed: v = fλ
Magnetic Force: F = qvB
Series Resistance: R_eq = R1 + R2
```

## Summary

✅ **25 physics problems** integrated into curriculum system
✅ **All minigame types** supported (Pacman, Runner, Maze, Platformer, Fill-in-blank, Math)
✅ **Educational review content** added for struggling students
✅ **Philippine SHS curriculum aligned** (General Physics 1 & 2)
✅ **Chapters 3-4** now feature physics content for science students

Students selecting the "Science" subject will now receive comprehensive physics education through engaging minigames while solving detective mysteries.
