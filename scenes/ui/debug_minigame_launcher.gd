extends Control

# Debug Minigame Launcher
# Access: Main Menu → 🎮 DEBUG MINIGAMES
# Select a subject tab to show only that subject's minigames, or "All" to see everything.

const SUBJECT_COLORS = {
	"all":     Color(0.85, 0.85, 0.85),
	"english": Color(0.2,  0.6,  1.0),
	"math":    Color(0.2,  0.8,  0.3),
	"science": Color(1.0,  0.5,  0.1),
}

const CATEGORY_COLORS = {
	"Fill-in-the-Blank":              Color(0.4, 0.7, 1.0),
	"Hear & Fill":                    Color(0.5, 0.9, 0.6),
	"Riddle":                         Color(1.0, 0.8, 0.3),
	"Dialogue Choice":                Color(1.0, 0.5, 0.7),
	"Detective Analysis":             Color(0.9, 0.4, 0.4),
	"Logic Grid":                     Color(0.6, 0.4, 1.0),
	"Timeline Reconstruction":        Color(0.4, 0.9, 0.9),
	"Curriculum (Pacman/Runner/etc.)":Color(0.8, 0.8, 0.4),
}

# ── Minigame catalogue ─────────────────────────────────────────────────────────
# Each entry: [display_label, puzzle_id, subjects_array, has_variants]
#
# subjects_array  - which subject tabs this entry appears under (plus always "all")
#                   ["english"]        → English-only
#                   ["math"]           → Math-only
#                   ["science"]        → Science-only
#                   ["math","science"] → Both Math and Science tabs
#                   ["english","math","science"] → all three subject tabs
#
# has_variants    - true  → MinigameManager auto-appends _math/_science based on selected_subject
#                   false → puzzle_id is launched exactly as written

const MINIGAMES = {
	"Fill-in-the-Blank": [
		# variant-aware: one entry covers english/math/science
		["Locker Examination",         "locker_examination",          ["english","math","science"], true],
		["Pedagogy Methods",           "pedagogy_methods",            ["english","math","science"], true],
		# English-only fill-in-the-blank entries
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
		["Timeline Analysis (Greg)",  "timeline_analysis_greg_math",    ["math"],    false],
		["Evaporation Analysis",      "evaporation_analysis_science",   ["science"], false],
		["Fund Analysis",             "fund_analysis_math",             ["math"],    false],
		["Fingerprint Analysis",      "fingerprint_analysis_science",   ["science"], false],
		["Paint Area",                "paint_area_math",                ["math"],    false],
		["Energy Analysis",           "energy_analysis_science",        ["science"], false],
		["Probability Analysis",      "probability_analysis_math",      ["math"],    false],
		["Electricity Analysis",      "electricity_analysis_science",   ["science"], false],
		["Teaching Power Analysis",   "teaching_power_analysis_science",["science"], false],
		["Pattern Recognition",       "pattern_recognition_math",       ["math"],    false],
		["Light Analysis",            "light_analysis_science",         ["science"], false],
	],
	"Logic Grid": [
		["Alibi Grid",             "logic_grid_alibi_math",                   ["math"],    false],
		["WiFi Grid",              "logic_grid_wifi_math",                    ["math"],    false],
		["WiFi Grid",              "logic_grid_wifi_science",                 ["science"], false],
		["Blackmail Grid",         "logic_grid_blackmail_math",               ["math"],    false],
		["Blackmail Grid",         "logic_grid_blackmail_science",            ["science"], false],
		["Evidence Grid",          "logic_grid_evidence_math",                ["math"],    false],
		["Evidence Grid",          "logic_grid_evidence_science",             ["science"], false],
		["Funds Grid",             "logic_grid_funds_science",                ["science"], false],
		["Info Circuit Grid",      "logic_grid_information_circuit_science",  ["science"], false],
		["Suspect Behavior Grid",  "logic_grid_suspect_behavior_math",        ["math"],    false],
		["Pedagogy Grid",          "logic_grid_pedagogy_math",                ["math"],    false],
		["Teaching Principles",    "logic_grid_teaching_principles_math",     ["math"],    false],
		["Teaching Principles",    "logic_grid_teaching_principles_science",  ["science"], false],
		["Four Lessons",           "logic_grid_four_lessons_math",            ["math"],    false],
		["Four Lessons",           "logic_grid_four_lessons_science",         ["science"], false],
	],
	"Timeline Reconstruction": [
		["Footprints",          "timeline_footprints_math",           ["math"],    false],
		["Theft",               "timeline_theft_math",                ["math"],    false],
		["Greg Alibi",          "timeline_analysis_greg_math",        ["math"],    false],
		["Threat Note",         "timeline_threat_note_math",          ["math"],    false],
		["Threat Note",         "timeline_threat_note_science",       ["science"], false],
		["Vandalism",           "timeline_vandalism_science",         ["science"], false],
		["Receipt Analysis",    "timeline_receipt_analysis_math",     ["math"],    false],
		["Receipt Analysis",    "timeline_receipt_analysis_science",  ["science"], false],
		["Notes Pattern",       "timeline_notes_pattern_math",        ["math"],    false],
		["Notes Distribution",  "timeline_notes_distribution_science",["science"], false],
		["Lessons Synthesis",   "timeline_lessons_synthesis_math",    ["math"],    false],
		["Lessons Synthesis",   "timeline_lessons_synthesis_science", ["science"], false],
		["Alibi",               "timeline_alibi_science",             ["science"], false],
	],
	"Curriculum (Pacman/Runner/etc.)": [
		["Curriculum Pacman",     "curriculum:pacman",     ["english","math","science"], false],
		["Curriculum Runner",     "curriculum:runner",     ["english","math","science"], false],
		["Curriculum Platformer", "curriculum:platformer", ["english","math","science"], false],
		["Curriculum Maze",       "curriculum:maze",       ["english","math","science"], false],
	],
}

# ── UI nodes ───────────────────────────────────────────────────────────────────
@onready var subject_btns:   HBoxContainer  = $MainVBox/TopBar/SubjectRow/SubjectBtns
@onready var character_btns: HBoxContainer  = $MainVBox/TopBar/CharacterRow/CharacterBtns
@onready var status_label:   Label          = $MainVBox/TopBar/StatusLabel
@onready var category_vbox:  VBoxContainer  = $MainVBox/ScrollContainer/CategoryVBox
@onready var back_btn:       Button         = $MainVBox/BottomBar/BackButton

# "all" shows everything; "english"/"math"/"science" filter by subjects array
var _current_filter:    String = "all"
var _current_subject:   String = "english"
var _current_character: String = "conrad"
var _subject_btn_map:   Dictionary = {}
var _character_btn_map: Dictionary = {}

# ── Lifecycle ─────────────────────────────────────────────────────────────────
func _ready() -> void:
	_build_subject_buttons()
	_build_character_buttons()
	_rebuild_minigame_list()
	_apply_highlight()
	MinigameManager.minigame_completed.connect(_on_minigame_completed)
	back_btn.pressed.connect(_on_back_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
		get_viewport().set_input_as_handled()

# ── Build top-bar buttons ─────────────────────────────────────────────────────
func _build_subject_buttons() -> void:
	# "All" tab first, then the three subjects
	for key in ["all", "english", "math", "science"]:
		var btn := Button.new()
		btn.text = "All" if key == "all" else key.capitalize()
		btn.custom_minimum_size = Vector2(110, 44)
		btn.pressed.connect(_select_filter.bind(key))
		subject_btns.add_child(btn)
		_subject_btn_map[key] = btn

func _build_character_buttons() -> void:
	for char_id in ["conrad", "celestine"]:
		var btn := Button.new()
		btn.text = char_id.capitalize()
		btn.custom_minimum_size = Vector2(120, 44)
		btn.pressed.connect(_select_character.bind(char_id))
		character_btns.add_child(btn)
		_character_btn_map[char_id] = btn

# ── Minigame list (rebuilt on every filter change) ────────────────────────────
func _rebuild_minigame_list() -> void:
	# Clear old content
	for child in category_vbox.get_children():
		child.queue_free()

	var any_visible := false

	for category in MINIGAMES.keys():
		# Collect entries that match the current filter
		var filtered: Array = []
		for entry in MINIGAMES[category]:
			var entry_subjects: Array = entry[2]
			if _current_filter == "all" or entry_subjects.has(_current_filter):
				filtered.append(entry)

		if filtered.is_empty():
			continue

		any_visible = true
		var cat_col: Color = CATEGORY_COLORS.get(category, Color.WHITE)

		# Category header
		var header := Label.new()
		header.text = "  " + category.to_upper()
		header.add_theme_color_override("font_color", cat_col)
		header.add_theme_font_size_override("font_size", 18)
		var sep := HSeparator.new()
		sep.add_theme_color_override("color", cat_col)
		category_vbox.add_child(header)
		category_vbox.add_child(sep)

		# Button grid (3 columns)
		var grid := GridContainer.new()
		grid.columns = 3
		grid.add_theme_constant_override("h_separation", 8)
		grid.add_theme_constant_override("v_separation", 6)
		category_vbox.add_child(grid)

		for entry in filtered:
			var label:     String = entry[0]
			var puzzle_id: String = entry[1]
			var has_variants: bool = entry[3]

			var btn := Button.new()
			btn.text = label
			btn.custom_minimum_size = Vector2(280, 38)
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.tooltip_text = puzzle_id
			btn.pressed.connect(_launch_minigame.bind(puzzle_id, has_variants))
			grid.add_child(btn)

		# Spacer
		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(0, 10)
		category_vbox.add_child(spacer)

	if not any_visible:
		var empty_lbl := Label.new()
		empty_lbl.text = "No minigames for this subject."
		empty_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		category_vbox.add_child(empty_lbl)

# ── Selection logic ───────────────────────────────────────────────────────────
func _select_filter(key: String) -> void:
	_current_filter = key
	# When a specific subject tab is chosen, also set it as the active subject
	# (so variant-aware minigames launch the correct variant)
	if key != "all":
		_current_subject = key
	_rebuild_minigame_list()
	_apply_highlight()
	_push_game_state()
	_update_status("Showing: %s  |  Subject: %s  |  Character: %s" % [
		("All" if key == "all" else key.capitalize()),
		_current_subject.capitalize(),
		_current_character.capitalize(),
	])

func _select_character(char_id: String) -> void:
	_current_character = char_id
	_apply_highlight()
	_push_game_state()
	_update_status("Ready — Subject: %s | Character: %s" % [
		_current_subject.capitalize(),
		_current_character.capitalize(),
	])

func _apply_highlight() -> void:
	for key in _subject_btn_map:
		var btn: Button = _subject_btn_map[key]
		var col: Color  = SUBJECT_COLORS.get(key, Color.WHITE)
		btn.modulate = col if key == _current_filter else Color(0.45, 0.45, 0.45)

	for c in _character_btn_map:
		var btn: Button = _character_btn_map[c]
		btn.modulate = Color.WHITE if c == _current_character else Color(0.45, 0.45, 0.45)

func _push_game_state() -> void:
	PlayerStats.selected_subject    = _current_subject
	PlayerStats.selected_character  = _current_character
	Dialogic.VAR.selected_subject   = _current_subject
	Dialogic.VAR.selected_character = _current_character

# ── Launch ────────────────────────────────────────────────────────────────────
func _launch_minigame(puzzle_id: String, has_variants: bool) -> void:
	if MinigameManager.current_minigame:
		_update_status("A minigame is already running!")
		return

	# Explicit per-subject IDs (has_variants=false, already end in _math/_science):
	# temporarily set subject to "english" so MinigameManager doesn't append another suffix.
	if not has_variants and (puzzle_id.ends_with("_math") or puzzle_id.ends_with("_science")):
		var saved = PlayerStats.selected_subject
		PlayerStats.selected_subject  = "english"
		Dialogic.VAR.selected_subject = "english"
		MinigameManager.start_minigame(puzzle_id)
		PlayerStats.selected_subject  = saved
		Dialogic.VAR.selected_subject = saved
	else:
		MinigameManager.start_minigame(puzzle_id)

	_update_status("Launched: %s  [%s / %s]" % [
		puzzle_id,
		_current_subject.capitalize(),
		_current_character.capitalize(),
	])

# ── Completion callback ───────────────────────────────────────────────────────
func _on_minigame_completed(puzzle_id: String, success: bool) -> void:
	_update_status("%s → %s" % [puzzle_id, "✓ SUCCESS" if success else "✗ FAILED"])

# ── Helpers ───────────────────────────────────────────────────────────────────
func _update_status(msg: String) -> void:
	if status_label:
		status_label.text = msg

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
