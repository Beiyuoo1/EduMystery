# EduMys Team Workflow Guide

## Setup (One-Time Only)

### For You (Project Lead)

1. Create a GitHub account (if you don't have one): https://github.com
2. Create a new repository called `edu-mys-dev`
3. Push your code:
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/edu-mys-dev.git
   git branch -M main
   git push -u origin main
   ```

### For Groupmates

1. Install Git: https://git-scm.com/download/win
2. Install Godot 4.5
3. Clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/edu-mys-dev.git
   cd edu-mys-dev
   ```

## Daily Workflow

### When You Make Changes (Project Lead)

```bash
# 1. Check what changed
git status

# 2. Add your changes
git add .

# 3. Commit with a clear message
git commit -m "Fix: Curriculum fill-in-blank layout bug"

# 4. Push to GitHub (everyone can now download)
git push
```

### When Groupmates Want Updates

```bash
# 1. Go to project folder
cd edu-mys-dev

# 2. Download latest changes
git pull

# 3. Open in Godot and test
```

## Common Commands

### Check Status
```bash
git status                    # See what changed
git log --oneline -5         # See last 5 commits
```

### Undo Mistakes
```bash
git restore <file>           # Undo changes to a file
git reset --hard             # Undo ALL local changes (careful!)
```

### Groupmates Testing Changes
```bash
# If they made local test changes and want to discard:
git reset --hard
git pull

# If they want to keep their changes:
git stash                    # Save changes temporarily
git pull                     # Get updates
git stash pop               # Restore their changes
```

## Tips

1. **Commit Often**: Make small commits with clear messages
   - ✅ "Fix: Dropzone text rendering bug"
   - ✅ "Add: Voice narration for Chapter 3"
   - ❌ "Updates" (too vague)

2. **Pull Before Push**: Always `git pull` before `git push`

3. **Don't Commit These Files**:
   - `.godot/imported/` (auto-generated)
   - `user://` save files
   - Large test files

4. **Coordinate Big Changes**: Let team know before major refactoring

## Alternative: If No GitHub Access

Use a shared Google Drive folder:

1. You create a "bare" repository:
   ```bash
   git init --bare "G:/Shared/edu-mys-dev.git"
   git remote add shared "G:/Shared/edu-mys-dev.git"
   git push shared main
   ```

2. Groupmates clone from shared drive:
   ```bash
   git clone "G:/Shared/edu-mys-dev.git"
   ```

## Troubleshooting

### "Merge Conflict" Error
If groupmates accidentally edited the same file:
```bash
# They should discard their local changes:
git reset --hard
git pull
```

### "Permission Denied" on Push
- Make sure groupmates have access to the GitHub repo
- Or use Personal Access Token for authentication

### Missing Files After Pull
```bash
# Reset everything to remote state
git fetch --all
git reset --hard origin/main
```

## Questions?

Ask the project lead (you) for help!
