extends Control

# Debug Minigame Launcher
# Tabs: All | English | Math | Science
# Each tab has two sections:
#   1. BY CHAPTER  – minigames actually used in story, grouped by chapter
#   2. ALL MINIGAMES OF THIS TYPE – full catalogue grouped by minigame type

# ── Colors ────────────────────────────────────────────────────────────────────
const SUBJECT_COLORS = {
	"all":     Color(0.85, 0.85, 0.85),
	"english": Color(0.2,  0.6,  1.0),
	"math":    Color(0.2,  0.8,  0.3),
	"science": Color(1.0,  0.5,  0.1),
}

const CHAPTER_COLORS = [
	Color(1.0, 0.85, 0.2),   # Ch1 – gold
	Color(0.4, 0.8,  1.0),   # Ch2 – sky blue
	Color(0.5, 1.0,  0.5),   # Ch3 – green
	Color(1.0, 0.55, 0.2),   # Ch4 – orange
	Color(0.8, 0.4,  1.0),   # Ch5 – purple
]

const TYPE_COLORS = {
	"Fill-in-the-Blank":               Color(0.4, 0.7, 1.0),
	"Hear & Fill":                     Color(0.5, 0.9, 0.6),
	"Riddle":                          Color(1.0, 0.8, 0.3),
	"Dialogue Choice":                 Color(1.0, 0.5, 0.7),
	"Detective Analysis":              Color(0.9, 0.4, 0.4),
	"Logic Grid":                      Color(0.6, 0.4, 1.0),
	"Timeline Reconstruction":         Color(0.4, 0.9, 0.9),
	"Curriculum (Pacman/Runner/etc.)": Color(0.8, 0.8, 0.4),
	"Number Sequence":                 Color(0.9, 0.7, 0.3),
}

# ── Chapter minigame map ───────────────────────────────────────────────────────
# Format per entry: [display_label, puzzle_id, subjects_array]
# subjects_array controls which subject tabs show this entry.
# "english" entries are variant-aware (manager auto-picks _math/_science).
# "math" / "science" entries are explicit IDs – launched exactly as-is.

const CHAPTER_MINIGAMES = {
	1: {
		"title": "Chapter 1: The Stolen Exam Papers",
		"entries": [
			# label                          puzzle_id                        subjects
			["Approach Janitor",             "dialogue_choice_janitor",       ["english","math","science"]],
			["Footprints Timeline",          "timeline_footprints_math",      ["math"]],
			["Footprints / Evaporation",     "evaporation_analysis_science",  ["science"]],
			["WiFi Router (Hear & Fill)",    "wifi_router",                   ["english","math","science"]],
			["WiFi Logic Grid",              "logic_grid_wifi_math",          ["math"]],
			["WiFi Logic Grid",              "logic_grid_wifi_science",       ["science"]],
			["Bracelet Riddle",              "bracelet_riddle",               ["english","math","science"]],
			["Alibi Logic Grid",             "logic_grid_alibi_math",         ["math"]],
			["Alibi Timeline",               "timeline_alibi_science",        ["science"]],
			["Greg Alibi Timeline",          "timeline_analysis_greg_math",   ["math"]],
			["Locker Examination (FIB)",     "locker_examination",            ["english","math","science"]],
		],
	},
	2: {
		"title": "Chapter 2: The Student Council Mystery",
		"entries": [
			["Ria's Note Dialogue",          "dialogue_choice_ria_note",      ["english","math","science"]],
			["Threat Note Timeline",         "timeline_threat_note_math",     ["math"]],
			["Threat Note Timeline",         "timeline_threat_note_science",  ["science"]],
			["Blackmail Logic Grid",         "logic_grid_blackmail_math",     ["math"]],
			["Blackmail Logic Grid",         "logic_grid_blackmail_science",  ["science"]],
		],
	},
	3: {
		"title": "Chapter 3: Art Week Vandalism",
		"entries": [
			["Cruel Note Dialogue",          "dialogue_choice_cruel_note",           ["english","math","science"]],
			["Evidence Logic Grid",          "logic_grid_evidence_math",             ["math"]],
			["Evidence Logic Grid",          "logic_grid_evidence_science",          ["science"]],
			["Receipt Riddle",               "receipt_riddle",                       ["english","math","science"]],
			["Receipt Timeline",             "timeline_receipt_analysis_math",       ["math"]],
			["Receipt Timeline",             "timeline_receipt_analysis_science",    ["science"]],
		],
	},
	4: {
		"title": "Chapter 4: Anonymous Notes",
		"entries": [
			["Anonymous Notes (Hear & Fill)","anonymous_notes",                      ["english","math","science"]],
			["Notes Pattern Timeline",       "timeline_notes_pattern_math",          ["math"]],
			["Notes Distribution Timeline",  "timeline_notes_distribution_science",  ["science"]],
			["Approach Suspect Dialogue",    "dialogue_choice_approach_suspect",     ["english","math","science"]],
			["Suspect Behavior Grid",        "logic_grid_suspect_behavior_math",     ["math"]],
			["Info Circuit Grid",            "logic_grid_information_circuit_science",["science"]],
			["Pedagogy Methods (FIB)",       "pedagogy_methods",                     ["english","math","science"]],
			["Teaching Power Analysis",      "teaching_power_analysis_science",      ["science"]],
		],
	},
	5: {
		"title": "Chapter 5: B.C. Revelation",
		"entries": [
			["B.C. Approach Dialogue",       "dialogue_choice_bc_approach",              ["english","math","science"]],
			["Lessons Synthesis Timeline",   "timeline_lessons_synthesis_math",          ["math"]],
			["Lessons Synthesis Timeline",   "timeline_lessons_synthesis_science",       ["science"]],
			["Observation Teaching (H&F)",   "observation_teaching",                     ["english","math","science"]],
			["Teaching Principles Grid",     "logic_grid_teaching_principles_math",      ["math"]],
			["Teaching Principles Grid",     "logic_grid_teaching_principles_science",   ["science"]],
			["Four Lessons Grid",            "logic_grid_four_lessons_math",             ["math"]],
			["Four Lessons Grid",            "logic_grid_four_lessons_science",          ["science"]],
		],
	},
}

# ── Full-catalogue (type-grouped) entries ─────────────────────────────────────
# Format: [display_label, puzzle_id, subjects_array, has_variants]
# has_variants = true  → base ID, manager appends _math or _science
# has_variants = false → exact ID, launched as-is

const ALL_MINIGAMES = {
	"Fill-in-the-Blank": [
		["Locker Examination",         "locker_examination",          ["english","math","science"], true],
		["Pedagogy Methods",           "pedagogy_methods",            ["english","math","science"], true],
		["WiFi Router (FIB)",          "wifi_router",                 ["english"],                  false],
		["Budget Basics",              "budget_basics",               ["english"],                  false],
		["Library Logic",              "library_logic",               ["english"],                  false],
		["Lesson Reflection",          "lesson_reflection",           ["english"],                  false],
		["Comm Model (linear)",        "english_m2_linear",           ["english"],                  false],
		["Comm Model (schramm)",       "english_m2_schramm",          ["english"],                  false],
		["Comm Model (transactional)", "english_m2_transactional",    ["english"],                  false],
		["Comm: Encoding",             "english_m1_encoding",         ["english"],                  false],
		["Comm: Feedback",             "english_m1_feedback",         ["english"],                  false],
		["Comm: Channel",              "english_m1_channel",          ["english"],                  false],
		["Comm: Decoding",             "english_m1_decoding",         ["english"],                  false],
	],
	"Hear & Fill": [
		["WiFi Router",          "wifi_router",          ["english","math","science"], true],
		["Anonymous Notes",      "anonymous_notes",      ["english","math","science"], true],
		["Observation Teaching", "observation_teaching", ["english","math","science"], true],
	],
	"Riddle": [
		["Bracelet Riddle", "bracelet_riddle", ["english","math","science"], true],
		["Receipt Riddle",  "receipt_riddle",  ["english","math","science"], true],
	],
	"Dialogue Choice": [
		["Approach Janitor", "dialogue_choice_janitor",          ["english","math","science"], true],
		["Ria's Note",       "dialogue_choice_ria_note",         ["english","math","science"], true],
		["Cruel Note",       "dialogue_choice_cruel_note",       ["english","math","science"], true],
		["Approach Suspect", "dialogue_choice_approach_suspect", ["english","math","science"], true],
		["B.C. Approach",    "dialogue_choice_bc_approach",      ["english","math","science"], true],
	],
	"Detective Analysis": [
		["Timeline Analysis (Greg)", "timeline_analysis_greg_math",    ["math"],    false],
		["Evaporation Analysis",     "evaporation_analysis_science",   ["science"], false],
		["Fund Analysis",            "fund_analysis_math",             ["math"],    false],
		["Fingerprint Analysis",     "fingerprint_analysis_science",   ["science"], false],
		["Paint Area",               "paint_area_math",                ["math"],    false],
		["Energy Analysis",          "energy_analysis_science",        ["science"], false],
		["Probability Analysis",     "probability_analysis_math",      ["math"],    false],
		["Electricity Analysis",     "electricity_analysis_science",   ["science"], false],
		["Teaching Power Analysis",  "teaching_power_analysis_science",["science"], false],
		["Pattern Recognition",      "pattern_recognition_math",       ["math"],    false],
		["Light Analysis",           "light_analysis_science",         ["science"], false],
	],
	"Logic Grid": [
		["Alibi Grid",            "logic_grid_alibi_math",                   ["math"],    false],
		["WiFi Grid",             "logic_grid_wifi_math",                    ["math"],    false],
		["WiFi Grid",             "logic_grid_wifi_science",                 ["science"], false],
		["Blackmail Grid",        "logic_grid_blackmail_math",               ["math"],    false],
		["Blackmail Grid",        "logic_grid_blackmail_science",            ["science"], false],
		["Evidence Grid",         "logic_grid_evidence_math",                ["math"],    false],
		["Evidence Grid",         "logic_grid_evidence_science",             ["science"], false],
		["Funds Grid",            "logic_grid_funds_science",                ["science"], false],
		["Info Circuit Grid",     "logic_grid_information_circuit_science",  ["science"], false],
		["Suspect Behavior Grid", "logic_grid_suspect_behavior_math",        ["math"],    false],
		["Pedagogy Grid",         "logic_grid_pedagogy_math",                ["math"],    false],
		["Teaching Principles",   "logic_grid_teaching_principles_math",     ["math"],    false],
		["Teaching Principles",   "logic_grid_teaching_principles_science",  ["science"], false],
		["Four Lessons",          "logic_grid_four_lessons_math",            ["math"],    false],
		["Four Lessons",          "logic_grid_four_lessons_science",         ["science"], false],
	],
	"Timeline Reconstruction": [
		["Footprints",         "timeline_footprints_math",           ["math"],    false],
		["Theft",              "timeline_theft_math",                ["math"],    false],
		["Greg Alibi",         "timeline_analysis_greg_math",        ["math"],    false],
		["Threat Note",        "timeline_threat_note_math",          ["math"],    false],
		["Threat Note",        "timeline_threat_note_science",       ["science"], false],
		["Vandalism",          "timeline_vandalism_science",         ["science"], false],
		["Receipt Analysis",   "timeline_receipt_analysis_math",     ["math"],    false],
		["Receipt Analysis",   "timeline_receipt_analysis_science",  ["science"], false],
		["Notes Pattern",      "timeline_notes_pattern_math",        ["math"],    false],
		["Notes Distribution", "timeline_notes_distribution_science",["science"], false],
		["Lessons Synthesis",  "timeline_lessons_synthesis_math",    ["math"],    false],
		["Lessons Synthesis",  "timeline_lessons_synthesis_science", ["science"], false],
		["Alibi",              "timeline_alibi_science",             ["science"], false],
	],
	"Curriculum (Pacman/Runner/etc.)": [
		["Curriculum Pacman",     "curriculum:pacman",     ["english","math","science"], false],
		["Curriculum Runner",     "curriculum:runner",     ["english","math","science"], false],
		["Curriculum Platformer", "curriculum:platformer", ["english","math","science"], false],
		["Curriculum Maze",       "curriculum:maze",       ["english","math","science"], false],
	],
}

# ── UI nodes ──────────────────────────────────────────────────────────────────
@onready var subject_btns:  HBoxContainer  = $MainVBox/TopBar/SubjectRow/SubjectBtns
@onready var char_btns:     HBoxContainer  = $MainVBox/TopBar/CharacterRow/CharacterBtns
@onready var status_label:  Label          = $MainVBox/TopBar/StatusLabel
@onready var category_vbox: VBoxContainer  = $MainVBox/ScrollContainer/CategoryVBox
@onready var back_btn:      Button         = $MainVBox/BottomBar/BackButton

var _current_filter:    String = "all"
var _current_subject:   String = "english"
var _current_character: String = "conrad"
var _subject_btn_map:   Dictionary = {}
var _char_btn_map:      Dictionary = {}

# ── Lifecycle ─────────────────────────────────────────────────────────────────
func _ready() -> void:
	_build_top_buttons()
	_rebuild_list()
	_apply_highlight()
	MinigameManager.minigame_completed.connect(_on_minigame_completed)
	back_btn.pressed.connect(_on_back_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
		get_viewport().set_input_as_handled()

# ── Top-bar buttons ───────────────────────────────────────────────────────────
func _build_top_buttons() -> void:
	for key in ["all", "english", "math", "science"]:
		var btn := Button.new()
		btn.text = "All" if key == "all" else key.capitalize()
		btn.custom_minimum_size = Vector2(110, 44)
		btn.pressed.connect(_select_filter.bind(key))
		subject_btns.add_child(btn)
		_subject_btn_map[key] = btn

	for char_id in ["conrad", "celestine"]:
		var btn := Button.new()
		btn.text = char_id.capitalize()
		btn.custom_minimum_size = Vector2(120, 44)
		btn.pressed.connect(_select_character.bind(char_id))
		char_btns.add_child(btn)
		_char_btn_map[char_id] = btn

# ── List builder ──────────────────────────────────────────────────────────────
func _rebuild_list() -> void:
	for child in category_vbox.get_children():
		child.queue_free()

	# ── SECTION 1: BY CHAPTER ─────────────────────────────────────────────────
	_add_section_header("📖  BY CHAPTER", Color(1, 0.85, 0.2))

	for ch_num in [1, 2, 3, 4, 5]:
		var ch_data: Dictionary = CHAPTER_MINIGAMES[ch_num]
		var ch_col:  Color      = CHAPTER_COLORS[ch_num - 1]

		# Filter entries for current subject
		var filtered: Array = []
		for entry in ch_data["entries"]:
			var subs: Array = entry[2]
			if _current_filter == "all" or subs.has(_current_filter):
				filtered.append(entry)

		if filtered.is_empty():
			continue

		# Chapter sub-header
		_add_category_header("  Ch%d — %s" % [ch_num, ch_data["title"]], ch_col)

		var grid := _make_grid()
		category_vbox.add_child(grid)

		for entry in filtered:
			var label:     String = entry[0]
			var puzzle_id: String = entry[1]
			# Chapter entries: has_variants = true only if puzzle_id has NO _math/_science suffix
			var has_variants: bool = not (puzzle_id.ends_with("_math") or puzzle_id.ends_with("_science") or puzzle_id.begins_with("curriculum:"))
			_add_button(grid, label, puzzle_id, has_variants, ch_col)

		_add_spacer(8)

	_add_spacer(20)

	# ── SECTION 2: ALL MINIGAMES BY TYPE ──────────────────────────────────────
	_add_section_header("🎮  ALL MINIGAMES BY TYPE", Color(0.7, 0.7, 0.7))

	for type_name in ALL_MINIGAMES.keys():
		var type_col: Color = TYPE_COLORS.get(type_name, Color.WHITE)
		var filtered: Array = []
		for entry in ALL_MINIGAMES[type_name]:
			var subs: Array = entry[2]
			if _current_filter == "all" or subs.has(_current_filter):
				filtered.append(entry)

		if filtered.is_empty():
			continue

		_add_category_header("  " + type_name.to_upper(), type_col)

		var grid := _make_grid()
		category_vbox.add_child(grid)

		for entry in filtered:
			var label:        String = entry[0]
			var puzzle_id:    String = entry[1]
			var has_variants: bool   = entry[3]
			_add_button(grid, label, puzzle_id, has_variants, type_col)

		_add_spacer(8)

# ── Widget helpers ────────────────────────────────────────────────────────────
func _add_section_header(text: String, col: Color) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_color_override("font_color", col)
	lbl.add_theme_font_size_override("font_size", 22)
	var sep := HSeparator.new()
	sep.add_theme_color_override("color", col)
	category_vbox.add_child(lbl)
	category_vbox.add_child(sep)
	_add_spacer(4)

func _add_category_header(text: String, col: Color) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_color_override("font_color", col)
	lbl.add_theme_font_size_override("font_size", 16)
	category_vbox.add_child(lbl)

func _make_grid() -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 5)
	return grid

func _add_button(grid: GridContainer, label: String, puzzle_id: String,
		has_variants: bool, tint: Color) -> void:
	var btn := Button.new()
	btn.text = label
	btn.custom_minimum_size = Vector2(280, 36)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.tooltip_text = puzzle_id
	btn.modulate = tint.lerp(Color.WHITE, 0.55)
	btn.pressed.connect(_launch_minigame.bind(puzzle_id, has_variants))
	grid.add_child(btn)

func _add_spacer(height: int) -> void:
	var s := Control.new()
	s.custom_minimum_size = Vector2(0, height)
	category_vbox.add_child(s)

# ── Selection ─────────────────────────────────────────────────────────────────
func _select_filter(key: String) -> void:
	_current_filter = key
	if key != "all":
		_current_subject = key
	_rebuild_list()
	_apply_highlight()
	_push_state()
	_update_status("Showing: %s  |  Subject: %s  |  Character: %s" % [
		("All" if key == "all" else key.capitalize()),
		_current_subject.capitalize(),
		_current_character.capitalize(),
	])

func _select_character(char_id: String) -> void:
	_current_character = char_id
	_apply_highlight()
	_push_state()
	_update_status("Character: %s  |  Subject: %s" % [
		_current_character.capitalize(),
		_current_subject.capitalize(),
	])

func _apply_highlight() -> void:
	for key in _subject_btn_map:
		var btn: Button = _subject_btn_map[key]
		btn.modulate = SUBJECT_COLORS.get(key, Color.WHITE) if key == _current_filter else Color(0.4, 0.4, 0.4)
	for c in _char_btn_map:
		_char_btn_map[c].modulate = Color.WHITE if c == _current_character else Color(0.4, 0.4, 0.4)

func _push_state() -> void:
	PlayerStats.selected_subject    = _current_subject
	PlayerStats.selected_character  = _current_character
	Dialogic.VAR.selected_subject   = _current_subject
	Dialogic.VAR.selected_character = _current_character

# ── Launch ────────────────────────────────────────────────────────────────────
func _launch_minigame(puzzle_id: String, has_variants: bool) -> void:
	if MinigameManager.current_minigame:
		_update_status("A minigame is already running!")
		return

	# Explicit IDs ending in _math/_science: temporarily set subject to "english"
	# so MinigameManager doesn't double-append a suffix.
	if not has_variants and (puzzle_id.ends_with("_math") or puzzle_id.ends_with("_science")):
		var saved := PlayerStats.selected_subject
		PlayerStats.selected_subject  = "english"
		Dialogic.VAR.selected_subject = "english"
		MinigameManager.start_minigame(puzzle_id)
		PlayerStats.selected_subject  = saved
		Dialogic.VAR.selected_subject = saved
	else:
		MinigameManager.start_minigame(puzzle_id)

	_update_status("▶ Launched: %s  [%s / %s]" % [
		puzzle_id,
		_current_subject.capitalize(),
		_current_character.capitalize(),
	])

# ── Callbacks ─────────────────────────────────────────────────────────────────
func _on_minigame_completed(puzzle_id: String, success: bool) -> void:
	_update_status("%s → %s" % [puzzle_id, "✓ SUCCESS" if success else "✗ FAILED"])

func _update_status(msg: String) -> void:
	if status_label:
		status_label.text = msg

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
