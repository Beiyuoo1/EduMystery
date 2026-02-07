# EduMys - Feature List

## 🎮 Gameplay Features

### Core Mystery Mechanics
- ✅ **5 Chapter Story** - Complete detective mystery narrative
- ✅ **Evidence Collection** - Find and analyze clues
- ✅ **Interactive Choices** - Your decisions matter
- ✅ **Multiple Interrogations** - Question suspects
- ✅ **B.C. Card Mystery** - Overarching storyline across all chapters

### Educational Integration
- ✅ **Communication Models** - Learn Aristotle, Shannon-Weaver, Schramm
- ✅ **Grammar Lessons** - Integrated into dialogue choices
- ✅ **Pronunciation Practice** - Voice recognition minigames
- ✅ **Critical Thinking** - Analyze evidence and make deductions

## 📊 Statistics & Progress

### Chapter Results System
- ✅ **Comprehensive Stats** - Track 15+ metrics per chapter
- ✅ **Detective Ranks** - S, A, B, C, D, F grading system
- ✅ **Accuracy Tracking** - Monitor correct vs wrong choices
- ✅ **Time Tracking** - Chapter completion time
- ✅ **Clue Completion** - Track evidence collection percentage

### Achievement System
- 🌟 **Perfect Detective** - Complete chapter with no mistakes
- ⚡ **Speed Demon** - Complete all minigames under 60 seconds
- 🔍 **Eagle Eye** - Find all clues in a chapter
- 🧠 **Hint Master** - Complete without using hints
- 💬 **Smooth Interrogator** - Perfect interrogation sequences

### Progression System
- ✅ **10 Detective Levels** - Unlock abilities as you progress
- ✅ **XP System** - Earn experience from correct choices
- ✅ **Per-Chapter Scoring** - Independent scoring system
- ✅ **Level-Up Rewards** - Unlock new detective skills

## 🎯 Minigame System

### 8 Different Minigame Types

1. **Fill-in-the-Blank** 📝
   - Drag-and-drop word completion
   - 90-second timer with color warnings
   - Hint system with visual highlighting
   - Speed bonus for quick completion

2. **Dialogue Choice** 🎙️
   - Voice recognition based
   - Real-time speech-to-text
   - Multiple choice with pronunciation
   - Retry mechanism for wrong answers

3. **Hear and Fill** 👂
   - Listen to TTS pronunciation
   - Select correct word from 8 options
   - Pronunciation-based learning
   - Speed bonus system

4. **Riddle** 🧩
   - Letter selection puzzle
   - Scrambled letters (16 total)
   - Undo functionality
   - Multiple attempts allowed

5. **Pacman Quiz** 👻
   - Collect correct answers
   - Avoid enemy obstacles
   - Action-based learning

6. **Runner** 🏃
   - Answer while moving
   - Time-based challenges

7. **Platformer** 🎮
   - Collect items while platforming
   - Action-oriented gameplay

8. **Maze** 🌀
   - Navigate while answering
   - Spatial reasoning

### Minigame Features
- ✅ **Hint System** - Use hints to highlight correct answers
- ✅ **Speed Bonuses** - Earn extra hints for fast completion
- ✅ **Configurable** - Easy to add new questions
- ✅ **Visual Feedback** - Clear success/failure indicators

## 🎙️ Voice Recognition

### Vosk Integration
- ✅ **Large English Model** - 2.7GB high-accuracy model
- ✅ **Real-Time Transcription** - See what you're saying live
- ✅ **Silence Detection** - Automatic speech end detection
- ✅ **Sentence Matching** - 60% word match threshold
- ✅ **Levenshtein Distance** - Word similarity algorithm
- ✅ **Preloaded System** - Loads on startup with progress screen
- ✅ **Shared Instance** - Efficient resource usage

### Voice Minigames
- ✅ **Dialogue Choice** - Speak the correct response
- ✅ **Pronunciation** - Practice word pronunciation
- ✅ **TTS Playback** - Hear correct pronunciation

## 💾 Save/Load System

### Save Features
- ✅ **10 Manual Slots** - Player-controlled saves
- ✅ **3 Auto-Save Slots** - Rotating automatic backups
- ✅ **Quick Save/Load** - F5/F9 hotkeys
- ✅ **Save Thumbnails** - Screenshot of game state
- ✅ **Detailed Metadata** - Timestamp, chapter, scene, level, score

### Save Data
- ✅ **Per-Slot Stats** - Independent progress per save
- ✅ **Evidence Tracking** - Per-slot evidence collection
- ✅ **Dialogic State** - All variables and timeline position
- ✅ **Player Stats** - Level, XP, score, hints

### UI Features
- ✅ **Renpy-Style Interface** - Familiar save/load UI
- ✅ **Grid Layout** - Easy slot selection
- ✅ **Continue Button** - Quick access to latest save
- ✅ **New Game** - Fresh start with stats reset

## 🔍 Evidence System

### Evidence Collection
- ✅ **Per-Chapter Evidence** - Organized by chapter
- ✅ **Animated Unlocks** - "🔍 CLUE FOUND! 🔍" popup
- ✅ **Evidence Panel** - View collected clues anytime
- ✅ **Evidence Button** - Persistent top-right UI button
- ✅ **Image & Description** - Visual reference for each clue

### B.C. Card System
- ✅ **4 B.C. Cards** - One per chapter (1-4)
- ✅ **Lesson System** - Truth, Responsibility, Creativity, Wisdom
- ✅ **Overarching Mystery** - Ties all chapters together
- ✅ **Chapter 5 Revelation** - Final B.C. encounter

### Evidence Types
- 📋 **Documents** - Notes, receipts, logs
- 🎨 **Physical Objects** - Bracelets, cloths, envelopes
- 📱 **Digital Evidence** - WiFi logs, messages
- 🗂️ **Records** - Maintenance logs, statements

## 🎨 Visual & Audio

### Character System
- ✅ **Animated Portraits** - Mouth animation for Conrad and Mark
- ✅ **Multiple Poses** - Half, full, mirror variants
- ✅ **Auto-Animation** - Responds to dialogue automatically
- ✅ **DialogicPortrait Integration** - Seamless with Dialogic 2.x
- ✅ **Mystery Character** - Special vignette-style character ("???")

### Visual Effects
- ✅ **Fade Transitions** - Smooth scene changes
- ✅ **Animated Popups** - Evidence unlocks, level-ups
- ✅ **Pulsing Animations** - UI highlights and attention grabbers
- ✅ **Color Coding** - Rank colors, stat indicators

### UI/UX
- ✅ **Main Menu** - New Game, Continue, Settings
- ✅ **Pause Menu** - Save, Load, Settings, Main Menu
- ✅ **Chapter Title Cards** - Animated chapter introductions
- ✅ **Results Screen** - Comprehensive chapter statistics
- ✅ **Settings Menu** - Audio, display customization

## 🛠️ Developer Tools

### Content Creation
- ✅ **DTL to TXT Converter** - Convert timelines to readable text
- ✅ **Clue Analyzer** - Analyze transcripts for evidence suggestions
- ✅ **Batch Conversion** - Convert entire chapters at once
- ✅ **Transcript System** - Export dialogue for review

### Development Features
- ✅ **Modular Architecture** - Autoload singletons for systems
- ✅ **Signal-Based** - Event-driven communication
- ✅ **Easy Configuration** - Minigames via dictionaries
- ✅ **Debug Output** - Console logging for tracking

### Documentation
- ✅ **CLAUDE.md** - Complete architecture guide
- ✅ **Usage Guides** - Step-by-step implementation docs
- ✅ **Code Comments** - Inline documentation
- ✅ **Example Files** - Reference implementations

## 🎓 Educational Content

### Chapter 1: The Faculty Room Leak
- **Topic**: Initial investigation skills
- **Evidence**: 7 clues (bracelet, WiFi logs, envelope, etc.)
- **Lesson**: Truth and evidence-based reasoning

### Chapter 2: The Missing Fund
- **Topic**: Responsibility and trust
- **Evidence**: 2 clues (lockbox, threatening note)
- **Lesson**: Actions have consequences

### Chapter 3: Art Week Vandalism
- **Topic**: Creativity and expression
- **Evidence**: 4 clues (note, cloth, sketchbook, receipt)
- **Lesson**: Art expresses, not competes

### Chapter 4: Anonymous Notes
- **Topic**: Wisdom and knowledge
- **Evidence**: 1+ clues (anonymous note)
- **Lesson**: Knowledge vs wisdom

### Chapter 5: The B.C. Revelation
- **Topic**: Choice and free will
- **Evidence**: B.C. cards review
- **Lesson**: Guide, never control

## 🔮 Future Enhancements (Potential)

### Planned Features
- 📊 **Chapter Comparison** - Compare stats across chapters
- 🏆 **Global Leaderboard** - High scores tracking
- 🎯 **More Achievements** - Additional badge types
- 🔁 **Chapter Replay** - Replay from results screen
- 📸 **Share Results** - Screenshot results to share
- 🎭 **More Character Animations** - Additional animated portraits
- 🌐 **Localization** - Multi-language support

### Expandability
- ➕ **New Chapters** - Easy to add via Dialogic
- 🎮 **New Minigames** - Modular minigame system
- 🔍 **New Evidence Types** - Extensible evidence system
- 🎨 **Custom Themes** - UI theming support

---

**Total Features Implemented**: 100+ features across 10 major systems
**Development Status**: Production-ready for Chapters 1-4, Chapter 5 in progress
**Last Updated**: 2026-02-05
