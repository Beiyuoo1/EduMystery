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

- **[DEVGUIDE.md](DEVGUIDE.md)** - Complete project architecture and development guide
- **[SAVE_SYSTEM.md](SAVE_SYSTEM.md)** - Save/load system documentation
- **[CHAPTER_RESULTS_USAGE.md](CHAPTER_RESULTS_USAGE.md)** - Chapter results implementation guide
- **[DTL_CONVERTER_README.md](DTL_CONVERTER_README.md)** - Dialogue to text converter tool
- **[CLUE_ANALYZER_README.md](CLUE_ANALYZER_README.md)** - Evidence analysis tool

## Setup: Missing Large Files

Several large files are **not included** in the repository due to size limits. You must obtain these separately before the project will run fully.

### Vosk Speech Recognition Model (~2.7GB)
Required for voice recognition minigames.

1. Download `vosk-model-en-us-0.22` from [alphacephei.com/vosk/models](https://alphacephei.com/vosk/models)
2. Extract and place at: `addons/vosk/models/vosk-model-en-us-0.22/`

### Vosk Android Plugin (`.aar` files, ~41MB each)
Required for Android builds with voice recognition.

1. Download the Vosk Android plugin from [github.com/alphacep/vosk-android-demo](https://github.com/alphacep/vosk-android-demo)
2. Place the `.aar` files at:
   - `addons/vosk_speech/VoskSpeechRecognition.aar`
   - `addons/vosk_speech/bin/debug/VoskSpeechRecognition.aar`
   - `addons/vosk_speech/bin/release/VoskSpeechRecognition.aar`

### Web Export Binary (`EduMys.wasm`, ~36MB)
Only needed if you are hosting the web build. Re-export the project via **Project → Export → Web** to regenerate this file.

> Without the Vosk model and `.aar` files, voice recognition minigames will not work, but the rest of the game functions normally.

## Quick Start

1. **Open Project** in Godot 4.5
2. **Run** (F5) - Starts at main menu
3. **New Game** - Begins Chapter 1
4. **Controls**:
   - **ESC** - Pause menu / Save-Load
   - **F5** - Quick save
   - **F9** - Quick load
   - **Evidence Button** - View collected clues (top-right during gameplay)

## Exporting the Project

### Windows (.exe)

1. Go to **Project → Export**
2. Click **Add...** and select **Windows Desktop**
3. Set export path (e.g. `build/EduMystery.exe`)
4. Click **Export Project**

> Install export templates first via **Editor → Manage Export Templates**

### Android (.apk)

#### One-time Setup

1. Install **Android Studio** to get the Android SDK
2. Go to **Editor → Editor Settings → Export → Android** and set:
   - **Android SDK Path** (e.g. `C:/Users/YourName/AppData/Local/Android/Sdk`)
   - **Java SDK Path** (e.g. your JDK installation folder)
3. Create a keystore for signing:
   ```
   keytool -genkey -v -keystore edumystery.keystore -alias edumystery -keyalg RSA -keysize 2048 -validity 10000
   ```
4. In **Project → Export → Android**, set the keystore path, user, and password

#### Exporting

1. Go to **Project → Export**
2. Select the **Android** preset
3. Click **Export Project** and save as `.apk`

> Enable USB debugging on your phone for **One Click Deploy** directly from Godot

### Web (HTML5)

1. Go to **Project → Export**
2. Click **Add...** and select **Web**
3. Set export path to `web/index.html`
4. Click **Export Project**
5. Host the `web/` folder on a web server (browsers block local file access)

## For Developers

See [DEVGUIDE.md](DEVGUIDE.md) for:
- Architecture overview
- Timeline syntax guide
- Minigame system
- Signal handling
- Adding new chapters
- Creating evidence items
- Implementing minigames
