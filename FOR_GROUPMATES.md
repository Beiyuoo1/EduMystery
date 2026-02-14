# EduMys - Setup Guide for Groupmates

## 🎮 How to Get the Game

### First Time Setup (Do This Once)

1. **Install Git**
   - Download: https://git-scm.com/download/win
   - Install with default settings
   - Restart your computer

2. **Install Godot 4.5**
   - Download: https://godotengine.org/download
   - Extract and run `Godot_v4.5_stable_win64.exe`

3. **Download Vosk Model (Required for Voice Recognition)**
   - Download: https://alphacephei.com/vosk/models/vosk-model-en-us-0.22.zip (2.7GB)
   - Extract the zip file
   - Place the `vosk-model-en-us-0.22` folder in:
     `Desktop/edu-mys-dev/addons/vosk/models/`

4. **Clone the Project**
   ```bash
   # Open Git Bash (right-click desktop → Git Bash Here)
   cd Desktop
   git clone https://github.com/AmeDesuwa/edu-mys-dev.git
   cd edu-mys-dev
   ```

4. **Open in Godot**
   - Open Godot
   - Click "Import"
   - Navigate to `Desktop/edu-mys-dev/project.godot`
   - Click "Import & Edit"

---

## 🔄 How to Get Updates

When the project lead (AmeDesuwa) tells you there are new updates:

```bash
# Open Git Bash in the project folder
cd Desktop/edu-mys-dev

# Get latest changes
git pull
```

That's it! The game will automatically update.

---

## 🚀 How to Run the Game

1. Open Godot 4.5
2. Select the `edu-mys-dev` project
3. Press **F5** or click the Play button ▶

---

## 🐛 Troubleshooting

### "Merge Conflict" Error
If you accidentally edited files:
```bash
git reset --hard
git pull
```

### "Permission Denied"
Contact AmeDesuwa to be added as a collaborator on GitHub.

### Game Won't Open
Make sure you're using **Godot 4.5** (not 3.x or 4.0-4.4).

---

## ❓ Need Help?

Ask AmeDesuwa (project lead) or check TEAM_WORKFLOW.md for detailed instructions.

---

## 📝 Important Notes

- **DO NOT** edit files unless coordinating with the team
- **DO NOT** commit changes (only AmeDesuwa should push updates)
- **DO** report bugs to AmeDesuwa
- **DO** pull updates regularly to stay in sync
