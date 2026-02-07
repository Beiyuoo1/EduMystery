# EduMys - Educational Mystery Visual Novel

A detective mystery educational game built in Godot 4.5, featuring interactive dialogue, minigames, and voice recognition capabilities.

## Project Structure

```
edu-mys/
├── addons/              # Third-party addons
│   ├── dialogic/       # Narrative system
│   └── vosk/           # Speech recognition
│
├── assets/             # Game assets
│   ├── audio/          # Audio files and test samples
│   ├── backgrounds/    # Background images
│   ├── pictures/       # UI pictures and evidence images
│   └── sprites/        # Character sprites
│
├── autoload/           # Global autoload scripts
│   └── level_up_manager.gd
│
├── content/            # Game narrative content
│   ├── characters/     # Dialogic character definitions (.dch)
│   └── timelines/      # Dialogic dialogue timelines (.dtl)
│       ├── Chapter 1/
│       └── Chapter 2/
│
├── minigames/          # Interactive minigames
│   ├── Drag/          # Fill-in-the-blank drag puzzle
│   └── Pacman/        # Quiz game with enemies
│
├── scenes/             # Game scenes
│   ├── effects/       # Visual effects (DialogicEffectsManager)
│   └── ui/            # UI scenes (level_up_scene, etc.)
│
├── scripts/            # Game scripts
│   └── dialogic_signal_handler.gd
│
└── src/                # Core game code
	├── core/          # Core systems (PlayerStats)
	├── vosk/          # Vosk integration (VoskPronunciationGame, VoskAudioFileTester)
	└── ui/            # UI components (future)
```

## Key Systems

### 🎮 Core Gameplay
- **Detective Mystery Visual Novel** with 5 chapters
- **Dialogic 2.x Integration** for narrative and choices
- **Evidence Collection System** with animated unlock popups
- **Multiple Endings** based on player choices

### 📊 Chapter Results System
- **Comprehensive Statistics Tracking** for each chapter
- **Detective Rankings** (S, A, B, C, D, F grades)
- **Achievement System** (Perfect Detective, Speed Demon, Eagle Eye, etc.)
- **Performance Metrics**: Score, accuracy, clues, choices, time, XP
- See [CHAPTER_RESULTS_USAGE.md](CHAPTER_RESULTS_USAGE.md) for details

### 🎓 Level-Up System
- **10 Detective Levels** with unlockable abilities
- **XP and Progression** system
- **Flashy Level-Up UI** with ability reveals
- Managed by `autoload/level_up_manager.gd`

### 🎙️ Voice Recognition (Vosk Integration)
- **Dialogue Choice Minigames** with speech-to-text
- **Pronunciation Minigames** (Hear and Fill)
- **Large English Model** (vosk-model-en-us-0.22, 2.7GB)
- **Preloaded on Startup** with loading screen
- Real-time transcription and silence detection

### 🎯 Minigame System
- **Fill-in-the-Blank** - Drag-and-drop word completion (1:30 timer, hints)
- **Dialogue Choice** - Voice recognition based choices
- **Hear and Fill** - Pronunciation with TTS playback
- **Riddle** - Letter selection puzzle with scrambled letters
- **Speed Bonus System** - Complete under 60s = +1 hint
- **Hint System** - Global hint pool shared across minigames

### 💾 Save/Load System
- **10 Manual Save Slots** with thumbnails
- **3 Auto-Save Slots** (rotating, triggers after minigames/chapters)
- **Quick Save/Load** (F5/F9 hotkeys)
- **Per-Slot Data** - Independent stats and evidence
- **Renpy-Style UI** with detailed slot information

### 🔍 Evidence System
- **Per-Chapter Evidence** with images and descriptions
- **Evidence Panel UI** accessible during gameplay
- **Animated Unlock Popups** when discovering clues
- **B.C. Card Collection** - Overarching mystery across chapters

### 🎨 Animated Character Portraits
- **Conrad** - Mouth animation when speaking
- **Mark** - Mouth animation when speaking
- **Automatic Animation** - Responds to dialogue automatically
- Built with `AnimatedSprite2D` and Dialogic 2.x integration

### 📈 Player Progression
- **XP and Leveling** system with per-chapter scoring
- **Hint Management** - Earn through speed bonuses, use in minigames
- **Per-Chapter Scores** tracked independently
- Persists to `user://player_stats.sav`

## Development Status

**✅ Completed:**
- Chapters 1-4 complete with evidence and minigames
- Chapter 5 in development (B.C. revelation)
- Level-up system with 10 levels
- 8+ minigame types implemented
- Vosk voice recognition fully integrated
- Save/load system with 10 slots + auto-save + quick save
- Evidence collection with animated popups
- Chapter results screen with statistics
- Animated character portraits (Conrad, Mark)
- B.C. Card overarching mystery system

**🚧 In Progress:**
- Chapter 5 finale content
- Additional character animations
- Polishing existing chapters

## Technical Details

- **Engine:** Godot 4.5
- **Resolution:** 1920x1080
- **Renderer:** GL Compatibility
- **Main Scene:** `scenes/ui/main_menu.tscn`
- **Target Platform:** Windows (primary), cross-platform compatible

## Documentation

- **[CLAUDE.md](CLAUDE.md)** - Complete project architecture and development guide
- **[SAVE_SYSTEM.md](SAVE_SYSTEM.md)** - Save/load system documentation
- **[CHAPTER_RESULTS_USAGE.md](CHAPTER_RESULTS_USAGE.md)** - Chapter results implementation guide
- **[DTL_CONVERTER_README.md](DTL_CONVERTER_README.md)** - Dialogue to text converter tool
- **[CLUE_ANALYZER_README.md](CLUE_ANALYZER_README.md)** - Evidence analysis tool

## Quick Start

1. **Open Project** in Godot 4.5
2. **Run** (F5) - Starts at main menu
3. **New Game** - Begins Chapter 1
4. **Controls**:
   - **ESC** - Pause menu / Save-Load
   - **F5** - Quick save
   - **F9** - Quick load
   - **Evidence Button** - View collected clues (top-right during gameplay)

## For Developers

See [CLAUDE.md](CLAUDE.md) for:
- Architecture overview
- Timeline syntax guide
- Minigame system
- Signal handling
- Adding new chapters
- Creating evidence items
- Implementing minigames
