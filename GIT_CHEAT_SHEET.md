# Git Cheat Sheet - Quick Reference

## 🚀 Daily Workflow (Copy-Paste These)

### Every Time You Start Working
```bash
cd /c/Projects/edu-mys-dev
git pull origin main
```

### Every 30-60 Minutes While Working
```bash
git add .
git commit -m "[YourName] What you changed"
git push origin main
```

### End of Day
```bash
git add .
git commit -m "[YourName] End of day: summary of work"
git push origin main
```

---

## 📋 Common Commands

| What You Want | Command |
|---------------|---------|
| **Get team's updates** | `git pull origin main` |
| **See what you changed** | `git status` |
| **Add all changes** | `git add .` |
| **Add specific file** | `git add filename.gd` |
| **Save changes with message** | `git commit -m "Your message"` |
| **Share with team** | `git push origin main` |
| **See recent commits** | `git log --oneline -10` |
| **Discard changes to file** | `git checkout -- filename.gd` |
| **Undo last commit (keep changes)** | `git reset HEAD~1` |

---

## ✅ Good Commit Messages

```bash
# ✅ GOOD (Clear and specific)
git commit -m "[John] Add voice narration for Chapter 1 Scene 1 (69 files)"
git commit -m "[Sarah] Fix dialogue typo in c2s3 line 45"
git commit -m "[Mike] Update namebox to fixed width 360px"

# ❌ BAD (Vague and unhelpful)
git commit -m "changes"
git commit -m "update"
git commit -m "fixes"
```

---

## 🔥 Emergency: Merge Conflict

If you see this after `git pull`:
```
CONFLICT (content): Merge conflict in c1s1.dtl
```

**Don't panic! Here's what to do:**

1. **Open the file in VSCode**
2. **Look for these markers:**
   ```
   <<<<<<< HEAD
   Your changes
   =======
   Teammate's changes
   >>>>>>> origin/main
   ```
3. **Delete the markers and keep the version you want**
4. **Save the file**
5. **Run these commands:**
   ```bash
   git add filename.dtl
   git commit -m "Resolved merge conflict in filename"
   git push origin main
   ```

---

## 🎯 Team Coordination

Before starting work each day, post in group chat:

```
📋 [YourName] Today's Work:
- Working on: Chapter 1 voice attachments
- Editing files: c1s1.dtl, c1s2.dtl
- Don't touch: c1s1.dtl until I push (around 3pm)
```

---

## 🛠️ Troubleshooting

### "Your local changes would be overwritten"
```bash
git stash           # Save your changes temporarily
git pull origin main
git stash pop       # Get your changes back
```

### "I want to undo everything and start fresh"
```bash
git reset --hard origin/main   # ⚠️ CAREFUL: Deletes all local changes!
```

### "I committed but forgot to add a file"
```bash
git add forgotten_file.gd
git commit --amend --no-edit
git push origin main
```

### "Voice files not showing up after pull"
```bash
git pull origin main          # Try pulling again
git log --oneline -5          # Check if teammate pushed them
ls "assets/audio/voice/"      # Check if files exist locally
```

---

## 📁 File Locations

| File Type | Location | Who Edits |
|-----------|----------|-----------|
| **Voice files** | `assets/audio/voice/Chapter X/` | Members 2 & 3 |
| **Dialogue** | `content/timelines/Chapter X/*.dtl` | Members 2 & 3 |
| **Code** | `scripts/*.gd`, `autoload/*.gd` | Member 1 (You) |
| **Scenes** | `scenes/**/*.tscn` | Member 1 (You) |
| **Minigames** | `minigames/**/` | Member 1 (You) |

---

## ⚠️ DON'T DO THESE

| ❌ Never Do | ✅ Do Instead |
|------------|--------------|
| `git push --force` | `git pull` first, then `git push` |
| `git reset --hard` (without knowing what it does) | Ask teammate or check guide |
| Edit same file at same time | Coordinate in chat |
| Forget to pull before starting | Always `git pull origin main` first |
| Commit without testing | Test in Godot first |

---

## 🎓 Git Workflow Summary

```
┌─────────────────────────────────────────────┐
│  1. START: git pull origin main            │
│     (Get team's latest changes)             │
└──────────────┬──────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────┐
│  2. WORK: Make your changes                 │
│     (Edit files, attach voice, code, etc.)  │
└──────────────┬──────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────┐
│  3. CHECK: git status                       │
│     (See what files you changed)            │
└──────────────┬──────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────┐
│  4. ADD: git add .                          │
│     (Stage all changes for commit)          │
└──────────────┬──────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────┐
│  5. COMMIT: git commit -m "Message"         │
│     (Save changes with description)         │
└──────────────┬──────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────┐
│  6. PUSH: git push origin main              │
│     (Share with team)                       │
└──────────────┬──────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────┐
│  7. REPEAT: Go back to step 1               │
│     (Every 30-60 minutes or end of day)     │
└─────────────────────────────────────────────┘
```

---

## 💡 Pro Tips

1. **Commit often** - Better to have many small commits than one huge commit
2. **Pull before push** - Avoid conflicts by staying up-to-date
3. **Test before push** - Make sure game still runs
4. **Communicate** - Tell team what you're working on
5. **Use descriptive messages** - Your future self will thank you!

---

## 🆘 When In Doubt

1. **Don't panic** - Git is forgiving
2. **Ask in group chat** - Your teammates can help
3. **Check TEAM_GIT_WORKFLOW.md** - Full detailed guide
4. **Google the error** - Someone else had this problem too
5. **Make a backup** - Copy project folder before trying risky commands

---

## 📞 Quick Help

**If you see an error you don't understand:**

1. Copy the error message
2. Post in group chat: "Help! I got this error: [paste error]"
3. Wait for teammate response
4. **Don't run random commands** without understanding them!

**Common errors and fixes:**

```bash
# Error: "fatal: not a git repository"
# Fix: You're in wrong folder
cd /c/Projects/edu-mys-dev

# Error: "Permission denied (publickey)"
# Fix: Check GitHub login/credentials

# Error: "Your branch is behind 'origin/main'"
# Fix: git pull origin main

# Error: "Your branch is ahead of 'origin/main'"
# Fix: git push origin main
```

---

**Save this file! Print it! Pin it to your wall!** 📌

This is all you need for day-to-day Git work!
