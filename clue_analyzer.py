#!/usr/bin/env python3
"""
Clue/Evidence Analyzer for EduMys
Analyzes converted dialogue transcripts to suggest potential clues and evidence items

Usage:
    python clue_analyzer.py
"""

import os
import re
from pathlib import Path
from collections import Counter

class ClueAnalyzer:
    """Analyzes dialogue transcripts to find potential evidence and clues"""

    # Keywords that often indicate important clues
    CLUE_KEYWORDS = [
        # Physical objects
        'note', 'letter', 'paper', 'document', 'receipt', 'photo', 'picture',
        'bracelet', 'necklace', 'ring', 'jewelry', 'key', 'card', 'badge',
        'book', 'notebook', 'diary', 'journal', 'file', 'folder',
        'phone', 'laptop', 'computer', 'camera', 'recording', 'video',
        'bag', 'backpack', 'locker', 'box', 'container',
        'cloth', 'fabric', 'stain', 'mark', 'paint',

        # Actions/Events
        'found', 'discovered', 'noticed', 'saw', 'heard', 'witnessed',
        'missing', 'stolen', 'lost', 'hidden', 'concealed',
        'evidence', 'clue', 'proof', 'alibi', 'witness',

        # Suspicious words
        'suspicious', 'strange', 'odd', 'unusual', 'weird',
        'lie', 'lying', 'secret', 'hiding', 'concealing',
        'guilty', 'innocent', 'suspect', 'accused',

        # Locations
        'scene', 'room', 'office', 'classroom', 'locker',
        'desk', 'table', 'drawer', 'shelf', 'cabinet',

        # Mystery elements
        'mystery', 'investigation', 'case', 'crime', 'incident',
        'victim', 'perpetrator', 'culprit', 'motive', 'opportunity'
    ]

    def __init__(self):
        self.chapter_data = {}

    def analyze_file(self, txt_path):
        """Analyze a single transcript file"""
        txt_path = Path(txt_path)

        if not txt_path.exists() or txt_path.suffix != '.txt':
            return None

        with open(txt_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Extract chapter info from path
        chapter_match = re.search(r'Chapter[_\s](\d+)', str(txt_path))
        chapter_num = chapter_match.group(1) if chapter_match else 'Unknown'

        analysis = {
            'file': txt_path.name,
            'chapter': chapter_num,
            'clue_mentions': self._find_clue_mentions(content),
            'evidence_unlocks': self._find_evidence_unlocks(content),
            'minigames': self._find_minigames(content),
            'key_phrases': self._find_key_phrases(content),
            'potential_clues': self._suggest_clues(content)
        }

        return analysis

    def _find_clue_mentions(self, content):
        """Find mentions of clue-related keywords"""
        mentions = []
        content_lower = content.lower()

        for keyword in self.CLUE_KEYWORDS:
            # Find keyword with context (3 words before and after)
            pattern = r'(\w+\s+\w+\s+\w+\s+)?' + re.escape(keyword) + r'(\s+\w+\s+\w+\s+\w+)?'
            matches = re.finditer(pattern, content_lower, re.IGNORECASE)

            for match in matches:
                context = match.group(0).strip()
                # Get line number
                line_num = content[:match.start()].count('\n') + 1
                mentions.append({
                    'keyword': keyword,
                    'context': context,
                    'line': line_num
                })

        return mentions

    def _find_evidence_unlocks(self, content):
        """Find existing evidence unlocks in the transcript"""
        evidence = []
        pattern = r'\[EVIDENCE UNLOCKED: ([^\]]+)\]'
        matches = re.finditer(pattern, content)

        for match in matches:
            evidence_id = match.group(1)
            line_num = content[:match.start()].count('\n') + 1
            evidence.append({
                'id': evidence_id,
                'line': line_num
            })

        return evidence

    def _find_minigames(self, content):
        """Find minigame triggers in the transcript"""
        minigames = []
        pattern = r'\[MINIGAME: ([^\]]+)\]'
        matches = re.finditer(pattern, content)

        for match in matches:
            game_id = match.group(1)
            line_num = content[:match.start()].count('\n') + 1
            minigames.append({
                'id': game_id,
                'line': line_num
            })

        return minigames

    def _find_key_phrases(self, content):
        """Extract important dialogue phrases"""
        key_phrases = []

        # Find dialogue lines with multiple clue keywords
        lines = content.split('\n')
        for i, line in enumerate(lines, 1):
            # Skip non-dialogue lines
            if not ':' in line or line.startswith('['):
                continue

            line_lower = line.lower()
            keyword_count = sum(1 for kw in self.CLUE_KEYWORDS if kw in line_lower)

            # If line has 2+ clue keywords, it's probably important
            if keyword_count >= 2:
                # Extract character name and dialogue
                match = re.match(r'^([^:]+):\s*(.+)$', line)
                if match:
                    character = match.group(1).strip()
                    dialogue = match.group(2).strip()
                    key_phrases.append({
                        'line': i,
                        'character': character,
                        'dialogue': dialogue,
                        'keyword_count': keyword_count
                    })

        return key_phrases

    def _suggest_clues(self, content):
        """Suggest potential clue items based on content analysis"""
        suggestions = []
        content_lower = content.lower()

        # Noun phrases that could be evidence items
        # Pattern: (article) (adjective) noun
        noun_pattern = r'\b(a|an|the)\s+(\w+\s+)?(\w+)\b'

        # Look for nouns near clue keywords
        for keyword in ['found', 'discovered', 'noticed', 'saw', 'evidence', 'clue']:
            keyword_positions = [m.start() for m in re.finditer(r'\b' + keyword + r'\b', content_lower)]

            for pos in keyword_positions:
                # Check 50 characters after the keyword
                snippet = content_lower[pos:pos+100]
                noun_matches = re.finditer(noun_pattern, snippet)

                for noun_match in noun_matches:
                    full_match = noun_match.group(0)
                    noun = noun_match.group(3)

                    # Filter out common non-evidence words
                    if noun not in ['it', 'that', 'this', 'there', 'what', 'something', 'anything']:
                        # Get context
                        context_start = max(0, pos - 50)
                        context_end = min(len(content), pos + 100)
                        context = content[context_start:context_end].strip()

                        suggestions.append({
                            'item': full_match,
                            'trigger_word': keyword,
                            'context': context
                        })

        # Deduplicate and rank by frequency
        item_counter = Counter([s['item'] for s in suggestions])
        ranked_suggestions = []

        for item, count in item_counter.most_common(10):
            # Find best context for this item
            best_context = next(s['context'] for s in suggestions if s['item'] == item)
            ranked_suggestions.append({
                'item': item,
                'frequency': count,
                'context': best_context
            })

        return ranked_suggestions

    def analyze_chapter(self, chapter_folder):
        """Analyze all transcript files in a chapter folder"""
        chapter_folder = Path(chapter_folder)

        if not chapter_folder.exists():
            print(f"❌ Folder not found: {chapter_folder}")
            return None

        txt_files = list(chapter_folder.glob('*.txt'))

        if not txt_files:
            print(f"❌ No .txt files found in: {chapter_folder}")
            return None

        chapter_analysis = {
            'folder': str(chapter_folder),
            'files': [],
            'total_clue_mentions': 0,
            'existing_evidence': [],
            'suggested_clues': [],
            'key_moments': []
        }

        print(f"\n📂 Analyzing {len(txt_files)} file(s) in {chapter_folder.name}...")
        print("-" * 80)

        for txt_file in sorted(txt_files):
            print(f"  📄 {txt_file.name}")
            analysis = self.analyze_file(txt_file)

            if analysis:
                chapter_analysis['files'].append(analysis)
                chapter_analysis['total_clue_mentions'] += len(analysis['clue_mentions'])
                chapter_analysis['existing_evidence'].extend(analysis['evidence_unlocks'])
                chapter_analysis['key_moments'].extend(analysis['key_phrases'])

        # Compile suggested clues from all files
        all_suggestions = []
        for file_analysis in chapter_analysis['files']:
            all_suggestions.extend(file_analysis['potential_clues'])

        # Rank by frequency across all files
        item_counter = Counter([s['item'] for s in all_suggestions])
        chapter_analysis['suggested_clues'] = [
            {'item': item, 'frequency': count}
            for item, count in item_counter.most_common(15)
        ]

        return chapter_analysis

    def print_report(self, chapter_analysis):
        """Print a formatted analysis report"""
        if not chapter_analysis:
            return

        print("\n" + "=" * 80)
        print(f"  CLUE ANALYSIS REPORT: {Path(chapter_analysis['folder']).name}")
        print("=" * 80)

        # Summary
        print(f"\n📊 Summary:")
        print(f"  Files analyzed: {len(chapter_analysis['files'])}")
        print(f"  Clue keyword mentions: {chapter_analysis['total_clue_mentions']}")
        print(f"  Existing evidence items: {len(chapter_analysis['existing_evidence'])}")

        # Existing evidence
        if chapter_analysis['existing_evidence']:
            print(f"\n✅ Existing Evidence Items:")
            for evidence in chapter_analysis['existing_evidence']:
                print(f"  • {evidence['id']} (line {evidence['line']})")

        # Top key moments (dialogue with multiple clue keywords)
        if chapter_analysis['key_moments']:
            print(f"\n🔍 Key Moments (Clue-Rich Dialogue):")
            sorted_moments = sorted(chapter_analysis['key_moments'],
                                   key=lambda x: x['keyword_count'], reverse=True)[:10]
            for moment in sorted_moments:
                print(f"  • [{moment['character']}] {moment['dialogue'][:80]}...")
                print(f"    (Line {moment['line']}, {moment['keyword_count']} clue keywords)")

        # Suggested new clues
        if chapter_analysis['suggested_clues']:
            print(f"\n💡 Suggested Evidence Items (by frequency):")
            for i, suggestion in enumerate(chapter_analysis['suggested_clues'][:10], 1):
                print(f"  {i}. \"{suggestion['item']}\" - mentioned {suggestion['frequency']} time(s)")

        # Per-file breakdown
        print(f"\n📁 Per-File Breakdown:")
        for file_analysis in chapter_analysis['files']:
            print(f"\n  {file_analysis['file']}:")
            print(f"    Clue mentions: {len(file_analysis['clue_mentions'])}")
            print(f"    Evidence unlocks: {len(file_analysis['evidence_unlocks'])}")
            print(f"    Minigames: {len(file_analysis['minigames'])}")

            # Show top 3 potential clues for this file
            if file_analysis['potential_clues']:
                print(f"    Top suggestions:")
                for suggestion in file_analysis['potential_clues'][:3]:
                    print(f"      • \"{suggestion['item']}\" ({suggestion['frequency']}x)")

        print("\n" + "=" * 80)


def main():
    print("\n" + "=" * 80)
    print("  CLUE/EVIDENCE ANALYZER FOR EDUMYS")
    print("  Analyze dialogue transcripts to find potential clues")
    print("=" * 80)

    analyzer = ClueAnalyzer()

    print("\nOptions:")
    print("  1. Analyze Chapter 2 transcripts")
    print("  2. Analyze Chapter 3 transcripts")
    print("  3. Analyze Chapter 4 transcripts")
    print("  4. Analyze Chapter 5 transcripts")
    print("  5. Analyze custom folder")
    print("  6. Exit")

    choice = input("\nEnter your choice (1-6): ").strip()

    transcripts_base = Path(__file__).parent / "transcripts"

    if choice == '1':
        folder = transcripts_base / "Chapter_2"
        analysis = analyzer.analyze_chapter(folder)
        if analysis:
            analyzer.print_report(analysis)

    elif choice == '2':
        folder = transcripts_base / "Chapter_3"
        analysis = analyzer.analyze_chapter(folder)
        if analysis:
            analyzer.print_report(analysis)

    elif choice == '3':
        folder = transcripts_base / "Chapter_4"
        analysis = analyzer.analyze_chapter(folder)
        if analysis:
            analyzer.print_report(analysis)

    elif choice == '4':
        folder = transcripts_base / "Chapter_5"
        analysis = analyzer.analyze_chapter(folder)
        if analysis:
            analyzer.print_report(analysis)

    elif choice == '5':
        folder_path = input("\nEnter the path to the folder: ").strip().strip('"')
        analysis = analyzer.analyze_chapter(folder_path)
        if analysis:
            analyzer.print_report(analysis)

    elif choice == '6':
        print("\n👋 Goodbye!")
        return

    else:
        print("\n❌ Invalid choice!")

    input("\nPress Enter to exit...")


if __name__ == "__main__":
    main()
