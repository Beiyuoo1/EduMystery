# Team Git Workflow Guide

## Team Setup

**3 Team Members:**
- **Member 1 (You):** Functions, features, code changes
- **Member 2:** Voice attachments and dialogue changes
- **Member 3:** Voice attachments and dialogue changes

---

## Quick Reference Commands

### Daily Workflow (Do This Every Time)

```bash
# 1. Pull latest changes from team
git pull origin main

# 2. Work on your changes
# (Edit files, attach voice, write code, etc.)

# 3. Check what you changed
git status

# 4. Add your changes
git add .

# 5. Commit with a message
git commit -m "Your description of changes"

# 6. Push to share with team
git push origin main
```

---

## Detailed Step-by-Step Workflow

### Step 1: Start Your Work Session

**ALWAYS pull first** to get your teammates' latest changes:

```bash
cd /c/Projects/edu-mys-dev
git pull origin main
```

**What this does:**
- Downloads all changes your teammates pushed
- Merges their work with your local files
- Updates voice files, dialogue changes, code changes, etc.

### Step 2: Make Your Changes

**Member 1 (You):**
- Edit code files (`.gd`, `.tscn`)
- Add new features
- Fix bugs
- Test changes in Godot

**Members 2 & 3:**
- Use `voice_attachment_tool.py` to attach voice files
- Edit dialogue in `.dtl` timeline files
- Add/update voice MP3 files in `assets/audio/voice/`
- Test in-game

### Step 3: Check What Changed

```bash
git status
```

**Example output:**
```
Modified files:
  M scripts/minigame_manager.gd
  M content/timelines/Chapter 1/c1s1.dtl
  ?? assets/audio/voice/Chapter 1/c1s1/new_voice.mp3
```

### Step 4: Add Your Changes

**Option A: Add everything (recommended for team)**
```bash
git add .
```

**Option B: Add specific files**
```bash
git add scripts/minigame_manager.gd
git add "content/timelines/Chapter 1/c1s1.dtl"
git add "assets/audio/voice/Chapter 1/"
```

### Step 5: Commit Your Changes

Write a **clear message** explaining what you changed:

```bash
# Member 1 (You) examples:
git commit -m "Add local config system to disable Vosk"
git commit -m "Fix Chapter 5 ending to return to character selection"
git commit -m "Add fixed-width namebox with centered text"

# Member 2 & 3 examples:
git commit -m "Add voice narration for Chapter 1 Scene 1 (69 files)"
git commit -m "Update c1s2 dialogue and attach voice files"
git commit -m "Fix typos in Chapter 3 dialogue"
```

**Tip:** Use this format for clarity:
```bash
git commit -m "[Your Name] Brief description of changes"
# Examples:
git commit -m "[John] Add voice files for c2s3"
git commit -m "[Sarah] Fix minigame bug in Detective Analysis"
```

### Step 6: Push to Share With Team

```bash
git push origin main
```

**What this does:**
- Uploads your changes to GitHub
- Makes them available for teammates to pull
- Everyone gets your updates when they do `git pull`

---

## Handling Conflicts (When 2+ People Edit Same File)

### What is a Merge Conflict?

When you and a teammate **both edit the same file**, Git might not know which version to keep.

### Example Scenario

1. **You** edit `c1s1.dtl` and add a voice tag
2. **Teammate** also edits `c1s1.dtl` and changes dialogue
3. You both push at different times
4. Git says: "CONFLICT! I don't know which version to keep!"

### How to Resolve Conflicts

When you run `git pull` and see a conflict:

```bash
$ git pull origin main
Auto-merging content/timelines/Chapter 1/c1s1.dtl
CONFLICT (content): Merge conflict in content/timelines/Chapter 1/c1s1.dtl
Automatic merge failed; fix conflicts and then commit the result.
```

**Step 1: Open the conflicted file in VSCode**

The file will look like this:

```dtl
Conrad: Hello, Mark.
<<<<<<< HEAD
[voice path="res://assets/audio/voice/Chapter 1/c1s1/hello.mp3" volume=25 bus="Voice"]
=======
Conrad: Hey there, partner!
>>>>>>> origin/main
Mark: What's up?
```

**What this means:**
- `<<<<<<< HEAD` = Your local changes
- `=======` = Separator
- `>>>>>>> origin/main` = Teammate's changes from GitHub

**Step 2: Decide which version to keep**

**Option A: Keep your version**
```dtl
Conrad: Hello, Mark.
[voice path="res://assets/audio/voice/Chapter 1/c1s1/hello.mp3" volume=25 bus="Voice"]
Mark: What's up?
```

**Option B: Keep teammate's version**
```dtl
Conrad: Hey there, partner!
Mark: What's up?
```

**Option C: Combine both (recommended)**
```dtl
Conrad: Hey there, partner!
[voice path="res://assets/audio/voice/Chapter 1/c1s1/hello.mp3" volume=25 bus="Voice"]
Mark: What's up?
```

**Step 3: Remove conflict markers**

Delete these lines:
- `<<<<<<< HEAD`
- `=======`
- `>>>>>>> origin/main`

**Step 4: Save, add, commit, push**

```bash
git add content/timelines/Chapter\ 1/c1s1.dtl
git commit -m "Merge conflict resolved: kept both dialogue and voice"
git push origin main
```

---

## Avoiding Conflicts (Best Practices)

### 1. Communicate Before Starting

Use Discord/Messenger to coordinate:

```
Member 2: "I'm working on Chapter 1 voice files today"
Member 3: "Okay, I'll work on Chapter 2 dialogue"
Member 1: "I'm fixing the ending bug, won't touch timelines"
```

### 2. Pull Before You Start

**ALWAYS** do this first:
```bash
git pull origin main
```

### 3. Push Often

Don't wait until end of day - push every 30-60 minutes:

```bash
git add .
git commit -m "WIP: Added 10 voice files to c1s1"
git push origin main
```

### 4. Divide Work by Chapter

**Recommended division:**
- **Member 2:** Chapters 1-2 voice/dialogue
- **Member 3:** Chapters 3-5 voice/dialogue
- **Member 1:** Code changes across all chapters

### 5. Use Descriptive Commit Messages

**Bad:**
```bash
git commit -m "changes"
git commit -m "update"
git commit -m "fixes"
```

**Good:**
```bash
git commit -m "Add voice narration for c1s1 (69 files)"
git commit -m "Fix dialogue typo in c2s3 line 45"
git commit -m "Update voice volume from 15dB to 25dB"
```

---

## Special Cases

### Voice Files (.mp3)

Voice files are **binary files** that Git handles differently:

✅ **Git WILL track them** - They'll be in the repository
✅ **No merge conflicts** - Can't have conflicts with binary files
✅ **Large files** - GitHub has 100MB per-file limit

**If voice files are too large:**

Consider using **Git LFS (Large File Storage)**:

```bash
# Install Git LFS (one-time setup)
git lfs install

# Track MP3 files with LFS
git lfs track "*.mp3"

# Commit the .gitattributes file
git add .gitattributes
git commit -m "Enable Git LFS for MP3 files"
git push origin main
```

**After this, all teammates need to:**
```bash
git lfs install
git pull origin main
```

### Timeline Files (.dtl)

Timeline files are **text files** that can have merge conflicts.

**Best practice:**
- Only one person edits a specific scene at a time
- Communicate in chat: "I'm editing c1s1.dtl now"
- Pull before you start, push when done

### Local Configuration

Your `local_config.json` is **git-ignored** and won't affect teammates:

✅ **You keep:** `local_config.json` with Vosk disabled
✅ **Teammates keep:** No local config (or their own settings)
✅ **No conflicts:** File is never committed

---

## Daily Workflow Example

### Morning (Start of Work)

```bash
# 1. Open terminal
cd /c/Projects/edu-mys-dev

# 2. Pull teammates' changes from last night
git pull origin main

# 3. Check what changed
git log --oneline -5
# Shows last 5 commits from team

# 4. Open Godot and start working
```

### During Work (Every 30-60 minutes)

```bash
# 1. Check what you changed
git status

# 2. Add and commit
git add .
git commit -m "[YourName] Description of what you did"

# 3. Push to team
git push origin main

# 4. Continue working
```

### Evening (End of Work)

```bash
# 1. Final commit
git add .
git commit -m "[YourName] End of day: finished c1s1 voice attachments"

# 2. Push to team
git push origin main

# 3. Optional: Check team's recent work
git log --oneline --all --graph -10
```

---

## Useful Git Commands

### Check Status
```bash
git status                    # What files changed
git log --oneline -10         # Last 10 commits
git diff                      # See exact changes
```

### Undo Changes
```bash
git checkout -- filename.gd   # Discard changes to one file
git reset --hard             # Discard ALL local changes (CAREFUL!)
git reset HEAD~1             # Undo last commit (keep changes)
```

### See Team's Work
```bash
git log --oneline --author="Member2"  # See what Member2 did
git log --since="2 days ago"          # Commits from last 2 days
git log --all --graph                 # Visual commit tree
```

### Fix Mistakes
```bash
# Forgot to add a file to last commit
git add forgotten_file.gd
git commit --amend --no-edit

# Wrong commit message
git commit --amend -m "Correct message"

# Pushed bad code, want to undo (DANGEROUS!)
git revert HEAD                # Creates new commit that undoes last one
```

---

## Team Communication Checklist

Use this template in your group chat:

```
📋 Daily Standup Template:

🔧 [YourName] - What I'm working on today:
- [ ] Chapter 1 voice attachments (c1s1-c1s3)
- [ ] Fix dialogue typos in c2s0

⚠️ Files I'm editing:
- content/timelines/Chapter 1/c1s1.dtl
- content/timelines/Chapter 1/c1s2.dtl
- assets/audio/voice/Chapter 1/

✅ What I finished yesterday:
- Attached 69 voice files to Chapter 1 Scene 1
- Fixed namebox width issue

🚫 Don't edit these files today (I'm using them):
- c1s1.dtl, c1s2.dtl, c1s3.dtl
```

---

## Troubleshooting

### "Your local changes would be overwritten by merge"

```bash
# Save your changes first
git stash

# Pull teammate's changes
git pull origin main

# Re-apply your changes
git stash pop

# If conflict, resolve it and commit
```

### "Repository not found" or "Permission denied"

Check your GitHub credentials:
```bash
git remote -v
# Should show: origin https://github.com/YourUsername/edu-mys-dev.git
```

### "Merge conflict" and you don't know what to do

**Safe option:** Ask in group chat!

```
"Hey team, I have a merge conflict in c1s1.dtl.
Can someone help me resolve it?"
```

### Voice files not appearing after pull

```bash
# Make sure you pulled correctly
git pull origin main

# Check if files exist
ls "assets/audio/voice/Chapter 1/c1s1/"

# If missing, check if teammate actually pushed them
git log --oneline -10  # Look for their commit
```

---

## Summary: The Golden Rules

1. ✅ **ALWAYS `git pull` before you start working**
2. ✅ **Commit and push often** (every 30-60 minutes)
3. ✅ **Write clear commit messages** (include your name)
4. ✅ **Communicate in group chat** about what files you're editing
5. ✅ **Don't force push** (`git push --force` is dangerous!)
6. ✅ **Test before you push** (make sure game still runs)
7. ✅ **Ask for help** when you see conflicts or errors

Follow these rules and you'll have smooth team collaboration! 🎉
