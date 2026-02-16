#!/usr/bin/env python3
"""
Voice Attachment Tool - GUI for attaching voice MP3 files to narrator dialogues.

This tool shows all narrator dialogue lines and lets you:
- Browse and attach MP3 files to each narration line
- Auto-update the timeline .dtl files with voice events
- Preview which lines already have voice attached
- Batch process multiple chapters
"""

import tkinter as tk
from tkinter import ttk, filedialog, messagebox, scrolledtext
import re
from pathlib import Path
import json

class VoiceAttachmentTool:
    def __init__(self, root):
        self.root = root
        self.root.title("Voice Narration Attachment Tool")
        self.root.geometry("1200x800")

        # Data
        self.timeline_dir = Path("content/timelines")
        self.voice_dir = Path("assets/audio/voice")
        self.current_file = None
        self.narration_lines = []
        self.modified = False

        self.setup_ui()

    def setup_ui(self):
        """Setup the UI layout"""
        # Top toolbar
        toolbar = ttk.Frame(self.root)
        toolbar.pack(side=tk.TOP, fill=tk.X, padx=5, pady=5)

        ttk.Label(toolbar, text="Chapter:").pack(side=tk.LEFT, padx=5)

        self.chapter_var = tk.StringVar()
        self.chapter_combo = ttk.Combobox(toolbar, textvariable=self.chapter_var, width=15)
        self.chapter_combo['values'] = ['Chapter 1', 'Chapter 2', 'Chapter 3', 'Chapter 4', 'Chapter 5']
        self.chapter_combo.pack(side=tk.LEFT, padx=5)

        ttk.Label(toolbar, text="Scene:").pack(side=tk.LEFT, padx=5)

        self.scene_var = tk.StringVar()
        self.scene_combo = ttk.Combobox(toolbar, textvariable=self.scene_var, width=15)
        self.scene_combo.pack(side=tk.LEFT, padx=5)

        ttk.Button(toolbar, text="Load Scene", command=self.load_scene).pack(side=tk.LEFT, padx=5)
        ttk.Button(toolbar, text="Save Changes", command=self.save_changes).pack(side=tk.LEFT, padx=5)

        self.status_label = ttk.Label(toolbar, text="Ready", foreground="green")
        self.status_label.pack(side=tk.RIGHT, padx=10)

        # Main content area
        main_frame = ttk.Frame(self.root)
        main_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)

        # Left panel - Narration list
        left_panel = ttk.LabelFrame(main_frame, text="Narration Lines", padding=5)
        left_panel.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        # Scrollable list
        list_frame = ttk.Frame(left_panel)
        list_frame.pack(fill=tk.BOTH, expand=True)

        scrollbar = ttk.Scrollbar(list_frame)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

        self.narration_listbox = tk.Listbox(list_frame, yscrollcommand=scrollbar.set,
                                           font=("Consolas", 10), height=30)
        self.narration_listbox.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.config(command=self.narration_listbox.yview)

        self.narration_listbox.bind('<<ListboxSelect>>', self.on_select_narration)

        # Right panel - Details and attachment
        right_panel = ttk.LabelFrame(main_frame, text="Voice Attachment", padding=5)
        right_panel.pack(side=tk.RIGHT, fill=tk.BOTH, expand=False, padx=(5, 0))
        right_panel.config(width=400)

        # Narration text display
        ttk.Label(right_panel, text="Narration Text:").pack(anchor=tk.W, pady=(0, 5))

        self.text_display = scrolledtext.ScrolledText(right_panel, height=8, width=50,
                                                      wrap=tk.WORD, font=("Arial", 10))
        self.text_display.pack(fill=tk.BOTH, pady=(0, 10))

        # Current voice file
        ttk.Label(right_panel, text="Current Voice File:").pack(anchor=tk.W)

        self.current_voice_label = ttk.Label(right_panel, text="(None)", foreground="gray")
        self.current_voice_label.pack(anchor=tk.W, pady=(0, 10))

        # New voice file selection
        voice_frame = ttk.Frame(right_panel)
        voice_frame.pack(fill=tk.X, pady=(0, 10))

        self.voice_file_var = tk.StringVar()
        self.voice_entry = ttk.Entry(voice_frame, textvariable=self.voice_file_var, width=35)
        self.voice_entry.pack(side=tk.LEFT, fill=tk.X, expand=True)

        ttk.Button(voice_frame, text="Browse...", command=self.browse_voice_file).pack(side=tk.LEFT, padx=(5, 0))

        # Attach button
        self.attach_btn = ttk.Button(right_panel, text="Attach Voice to This Line",
                                     command=self.attach_voice, state=tk.DISABLED)
        self.attach_btn.pack(fill=tk.X, pady=(0, 5))

        # Remove button
        self.remove_btn = ttk.Button(right_panel, text="Remove Voice from This Line",
                                     command=self.remove_voice, state=tk.DISABLED)
        self.remove_btn.pack(fill=tk.X, pady=(0, 10))

        # Statistics
        stats_frame = ttk.LabelFrame(right_panel, text="Statistics", padding=5)
        stats_frame.pack(fill=tk.X, pady=(10, 0))

        self.stats_label = ttk.Label(stats_frame, text="Total: 0\nWith Voice: 0\nWithout Voice: 0")
        self.stats_label.pack()

        # Update scene list when chapter changes
        self.chapter_combo.bind('<<ComboboxSelected>>', self.update_scene_list)

        # Initialize
        if self.chapter_combo['values']:
            self.chapter_combo.current(0)
            self.update_scene_list()

    def update_scene_list(self, event=None):
        """Update the scene list based on selected chapter"""
        chapter = self.chapter_var.get()
        if not chapter:
            return

        chapter_path = self.timeline_dir / chapter
        if not chapter_path.exists():
            return

        scenes = [f.stem for f in chapter_path.glob("*.dtl")]
        scenes.sort()

        self.scene_combo['values'] = scenes
        if scenes:
            self.scene_combo.current(0)

    def load_scene(self):
        """Load narration lines from the selected scene"""
        chapter = self.chapter_var.get()
        scene = self.scene_var.get()

        if not chapter or not scene:
            messagebox.showwarning("Warning", "Please select a chapter and scene first.")
            return

        file_path = self.timeline_dir / chapter / f"{scene}.dtl"

        if not file_path.exists():
            messagebox.showerror("Error", f"File not found: {file_path}")
            return

        self.current_file = file_path
        self.narration_lines = []

        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()

            i = 0
            while i < len(lines):
                line = lines[i]

                # Check if this is a voice event
                voice_match = re.match(r'\[voice path="([^"]+)"\s+volume=(\d+)\s+bus="([^"]+)"\]', line.strip())

                if voice_match:
                    voice_path = voice_match.group(1)
                    # Next line should be the narration
                    if i + 1 < len(lines):
                        narration_line = lines[i + 1].strip()
                        # Skip if it's a command or dialogue
                        if not narration_line.startswith('[') and ':' not in narration_line[:30]:
                            self.narration_lines.append({
                                'line_num': i + 2,  # +2 because narration is next line, 1-indexed
                                'text': narration_line,
                                'voice_path': voice_path,
                                'voice_line_num': i + 1  # 1-indexed
                            })
                            i += 2
                            continue

                # Check if this is narration without voice
                stripped = line.strip()
                if stripped and not stripped.startswith('[') and not stripped.startswith('#'):
                    # Not a dialogue line (no character name: at start)
                    if not re.match(r'^[A-Z][a-z]+(\s+[A-Z][a-z]+)*\s*(\([^)]*\))?\s*:', stripped):
                        # Check if previous line was NOT a voice event
                        if i == 0 or not lines[i-1].strip().startswith('[voice'):
                            # Skip commands and labels
                            if not any(stripped.startswith(cmd) for cmd in ['if ', 'elif ', 'else', 'set ', 'jump ', 'label ', 'join ', 'leave ', 'update ', '-']):
                                self.narration_lines.append({
                                    'line_num': i + 1,  # 1-indexed
                                    'text': stripped,
                                    'voice_path': None,
                                    'voice_line_num': None
                                })

                i += 1

            # Update UI
            self.refresh_narration_list()
            self.update_statistics()
            self.status_label.config(text=f"Loaded: {scene}", foreground="green")
            self.modified = False

        except Exception as e:
            messagebox.showerror("Error", f"Failed to load scene:\n{e}")

    def refresh_narration_list(self):
        """Refresh the narration listbox"""
        self.narration_listbox.delete(0, tk.END)

        for i, item in enumerate(self.narration_lines):
            text_preview = item['text'][:60] + "..." if len(item['text']) > 60 else item['text']
            has_voice = "✓" if item['voice_path'] else "✗"
            display_text = f"[{has_voice}] Line {item['line_num']}: {text_preview}"

            self.narration_listbox.insert(tk.END, display_text)

            # Color code
            if item['voice_path']:
                self.narration_listbox.itemconfig(i, {'fg': 'green'})
            else:
                self.narration_listbox.itemconfig(i, {'fg': 'red'})

    def on_select_narration(self, event):
        """Handle narration selection"""
        selection = self.narration_listbox.curselection()
        if not selection:
            return

        idx = selection[0]
        item = self.narration_lines[idx]

        # Update text display
        self.text_display.delete('1.0', tk.END)
        self.text_display.insert('1.0', item['text'])

        # Update current voice
        if item['voice_path']:
            self.current_voice_label.config(text=item['voice_path'], foreground="blue")
            self.remove_btn.config(state=tk.NORMAL)
        else:
            self.current_voice_label.config(text="(None)", foreground="gray")
            self.remove_btn.config(state=tk.DISABLED)

        self.attach_btn.config(state=tk.NORMAL)

    def browse_voice_file(self):
        """Browse for voice MP3 file"""
        initialdir = self.voice_dir / self.chapter_var.get().replace(' ', ' ')
        if not initialdir.exists():
            initialdir = self.voice_dir

        filename = filedialog.askopenfilename(
            title="Select Voice MP3 File",
            initialdir=initialdir,
            filetypes=[("MP3 files", "*.mp3"), ("All files", "*.*")]
        )

        if filename:
            # Convert to relative path
            try:
                rel_path = Path(filename).relative_to(Path.cwd())
                res_path = "res://" + str(rel_path).replace('\\', '/')
                self.voice_file_var.set(res_path)
            except:
                # If not relative, just use absolute
                self.voice_file_var.set("res://" + filename.replace('\\', '/'))

    def attach_voice(self):
        """Attach voice file to selected narration"""
        selection = self.narration_listbox.curselection()
        if not selection:
            return

        idx = selection[0]
        voice_file = self.voice_file_var.get()

        if not voice_file:
            messagebox.showwarning("Warning", "Please select a voice file first.")
            return

        # Update the item
        self.narration_lines[idx]['voice_path'] = voice_file

        # Refresh UI
        self.refresh_narration_list()
        self.narration_listbox.selection_set(idx)
        self.on_select_narration(None)
        self.update_statistics()

        self.modified = True
        self.status_label.config(text="Modified (unsaved)", foreground="orange")

    def remove_voice(self):
        """Remove voice from selected narration"""
        selection = self.narration_listbox.curselection()
        if not selection:
            return

        idx = selection[0]

        # Update the item
        self.narration_lines[idx]['voice_path'] = None
        self.narration_lines[idx]['voice_line_num'] = None

        # Refresh UI
        self.refresh_narration_list()
        self.narration_listbox.selection_set(idx)
        self.on_select_narration(None)
        self.update_statistics()

        self.modified = True
        self.status_label.config(text="Modified (unsaved)", foreground="orange")

    def update_statistics(self):
        """Update statistics display"""
        total = len(self.narration_lines)
        with_voice = sum(1 for item in self.narration_lines if item['voice_path'])
        without_voice = total - with_voice

        self.stats_label.config(text=f"Total: {total}\nWith Voice: {with_voice}\nWithout Voice: {without_voice}")

    def save_changes(self):
        """Save changes back to the .dtl file"""
        if not self.current_file or not self.modified:
            messagebox.showinfo("Info", "No changes to save.")
            return

        if not messagebox.askyesno("Confirm", "Save changes to timeline file?"):
            return

        try:
            # Read original file
            with open(self.current_file, 'r', encoding='utf-8') as f:
                lines = f.readlines()

            # Build new content
            new_lines = []
            processed_lines = set()

            for i, line in enumerate(lines):
                line_num = i + 1

                # Check if this line is a narration we've modified
                narration_item = None
                for item in self.narration_lines:
                    if item['line_num'] == line_num:
                        narration_item = item
                        break

                if narration_item:
                    # Check if previous line was a voice event
                    prev_was_voice = i > 0 and lines[i-1].strip().startswith('[voice')

                    if narration_item['voice_path']:
                        # Add voice event if not already there
                        if not prev_was_voice:
                            voice_line = f'[voice path="{narration_item["voice_path"]}" volume=25 bus="Voice"]\n'
                            new_lines.append(voice_line)
                        elif prev_was_voice:
                            # Update existing voice event
                            voice_line = f'[voice path="{narration_item["voice_path"]}" volume=25 bus="Voice"]\n'
                            new_lines[-1] = voice_line
                    else:
                        # Remove voice event if it exists
                        if prev_was_voice:
                            new_lines.pop()  # Remove the voice line we just added

                    new_lines.append(line)
                    processed_lines.add(line_num)
                else:
                    new_lines.append(line)

            # Write back
            with open(self.current_file, 'w', encoding='utf-8') as f:
                f.writelines(new_lines)

            self.modified = False
            self.status_label.config(text="Saved successfully!", foreground="green")
            messagebox.showinfo("Success", "Changes saved successfully!")

        except Exception as e:
            messagebox.showerror("Error", f"Failed to save changes:\n{e}")

def main():
    root = tk.Tk()
    app = VoiceAttachmentTool(root)
    root.mainloop()

if __name__ == "__main__":
    main()
