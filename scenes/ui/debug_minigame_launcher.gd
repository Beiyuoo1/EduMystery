extends Control

# Debug Minigame Launcher
# A full debug scene to test every minigame across all subjects and characters.
# Access: Add to main menu or launch directly via Godot editor (F6 on this scene).

const SUBJECT_COLORS = {
	"english": Color(0.2, 0.6, 1.0),
	"math":    Color(0.2, 0.8, 0.3),
	"science": Color(1.0, 0.5, 0.1),
}

const CATEGORY_COLORS = {
	"Fill-in-the-Blank":         Color(0.4, 0.7, 1.0),
	"Hear & Fill":                Color(0.5, 0.9, 0.6),
	"Riddle":                     Color(1.0, 0.8, 0.3),
	"Dialogue Choice":            Color(1.0, 0.5, 0.7),
	"Detective Analysis":         Color(0.9, 0.4, 0.4),
	"Logic Grid":                 Color(0.6, 0.4, 1.0),
	"Timeline Reconstruction":    Color(0.4, 0.9, 0.9),
	"Curriculum (Pacman/Runner/etc.)": Color(0.8, 0.8, 0.4),
}

# ── Minigame catalogue ─────────────────────────────────────────────────────────
# Each entry: [display_label, base_puzzle_id, has_subject_variants]
# has_subject_variants = true  → launcher auto-appends _math / _science based on selection
#                         false → launches exactly as-is

const MINIGAMES = {
	"Fill-in-the-Blank": [
		["Locker Examination",          "locker_examination",           true],
		["Pedagogy Methods",            "pedagogy_methods",             true],
		["WiFi Router (FIB)",           "wifi_router",                  false],  # covered by Hear&Fill variants
		["Budget Basics",               "budget_basics",                false],
		["Library Logic",               "library_logic",                false],
		["Lesson Reflection",           "lesson_reflection",            false],
		["Comm Model (linear)",         "english_m2_linear",            false],
		["Comm Model (schramm)",        "english_m2_schramm",           false],
		["Comm Model (transactional)",  "english_m2_transactional",     false],
		["Comm: Encoding",              "english_m1_encoding",          false],
		["Comm: Feedback",              "english_m1_feedback",          false],
		["Comm: Channel",               "english_m1_channel",           false],
		["Comm: Decoding",              "english_m1_decoding",          false],
	],
	"Hear & Fill": [
		["WiFi Router",           "wifi_router",           true],
		["Anonymous Notes",       "anonymous_notes",       true],
		["Observation Teaching",  "observation_teaching",  true],
	],
	"Riddle": [
		["Bracelet Riddle",  "bracelet_riddle",  true],
		["Receipt Riddle",   "receipt_riddle",   true],
	],
	"Dialogue Choice": [
		["Approach Janitor",      "dialogue_choice_janitor",         true],
		["Ria's Note",            "dialogue_choice_ria_note",        true],
		["Cruel Note",            "dialogue_choice_cruel_note",      true],
		["Approach Suspect",      "dialogue_choice_approach_suspect",true],
		["B.C. Approach",         "dialogue_choice_bc_approach",     true],
	],
	"Detective Analysis": [
		["Timeline Analysis (Greg Math)",     "timeline_analysis_greg_math",   false],
		["Evaporation Analysis (Science)",    "evaporation_analysis_science",  false],
		["Fund Analysis (Math)",              "fund_analysis_math",            false],
		["Fingerprint Analysis (Science)",    "fingerprint_analysis_science",  false],
		["Paint Area (Math)",                 "paint_area_math",               false],
		["Energy Analysis (Science)",         "energy_analysis_science",       false],
		["Probability Analysis (Math)",       "probability_analysis_math",     false],
		["Electricity Analysis (Science)",    "electricity_analysis_science",  false],
		["Teaching Power Analysis (Science)", "teaching_power_analysis_science",false],
		["Pattern Recognition (Math)",        "pattern_recognition_math",      false],
		["Light Analysis (Science)",          "light_analysis_science",        false],
	],
	"Logic Grid": [
		["Alibi Grid (Math)",             "logic_grid_alibi_math",              false],
		["WiFi Grid (Math)",              "logic_grid_wifi_math",               false],
		["WiFi Grid (Science)",           "logic_grid_wifi_science",            false],
		["Blackmail Grid (Math)",         "logic_grid_blackmail_math",          false],
		["Blackmail Grid (Science)",      "logic_grid_blackmail_science",       false],
		["Evidence Grid (Math)",          "logic_grid_evidence_math",           false],
		["Evidence Grid (Science)",       "logic_grid_evidence_science",        false],
		["Funds Grid (Science)",          "logic_grid_funds_science",           false],
		["Info Circuit Grid (Science)",   "logic_grid_information_circuit_science", false],
		["Suspect Behavior (Math)",       "logic_grid_suspect_behavior_math",   false],
		["Pedagogy Grid (Math)",          "logic_grid_pedagogy_math",           false],
		["Teaching Principles (Math)",    "logic_grid_teaching_principles_math",  false],
		["Teaching Principles (Science)", "logic_grid_teaching_principles_science",false],
		["Four Lessons (Math)",           "logic_grid_four_lessons_math",       false],
		["Four Lessons (Science)",        "logic_grid_four_lessons_science",    false],
	],
	"Timeline Reconstruction": [
		["Footprints (Math)",         "timeline_footprints_math",          false],
		["Theft (Math)",              "timeline_theft_math",               false],
		["Greg Alibi (Math)",         "timeline_analysis_greg_math",       false],
		["Threat Note (Math)",        "timeline_threat_note_math",         false],
		["Threat Note (Science)",     "timeline_threat_note_science",      false],
		["Vandalism (Science)",       "timeline_vandalism_science",        false],
		["Receipt Analysis (Math)",   "timeline_receipt_analysis_math",    false],
		["Receipt Analysis (Science)","timeline_receipt_analysis_science", false],
		["Notes Pattern (Math)",      "timeline_notes_pattern_math",       false],
		["Notes Distribution (Sci)",  "timeline_notes_distribution_science",false],
		["Lessons Synthesis (Math)",  "timeline_lessons_synthesis_math",   false],
		["Lessons Synthesis (Sci)",   "timeline_lessons_synthesis_science",false],
		["Alibi (Science)",           "timeline_alibi_science",            false],
	],
	"Curriculum (Pacman/Runner/etc.)": [
		["Curriculum Pacman",     "curriculum:pacman",     false],
		["Curriculum Runner",     "curriculum:runner",     false],
		["Curriculum Platformer", "curriculum:platformer", false],
		["Curriculum Maze",       "curriculum:maze",       false],
	],
}

# ── UI nodes ───────────────────────────────────────────────────────────────────
@onready var subject_btns:   HBoxContainer = $MainVBox/TopBar/SubjectRow/SubjectBtns
@onready var character_btns: HBoxContainer = $MainVBox/TopBar/CharacterRow/CharacterBtns
@onready var status_label:   Label         = $MainVBox/TopBar/StatusLabel
@onready var scroll:         ScrollContainer = $MainVBox/ScrollContainer
@onready var category_vbox:  VBoxContainer = $MainVBox/ScrollContainer/CategoryVBox
@onready var back_btn:       Button        = $MainVBox/BottomBar/BackButton

var _current_subject:   String = "english"
var _current_character: String = "conrad"
var _subject_btn_map:   Dictionary = {}
var _character_btn_map: Dictionary = {}

# ── Lifecycle ─────────────────────────────────────────────────────────────────
func _ready() -> void:
	_build_subject_buttons()
	_build_character_buttons()
	_build_minigame_list()
	_apply_selection()
	MinigameManager.minigame_completed.connect(_on_minigame_completed)
	back_btn.pressed.connect(_on_back_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
		get_viewport().set_input_as_handled()

# ── Builder helpers ───────────────────────────────────────────────────────────
func _build_subject_buttons() -> void:
	for subject in ["english", "math", "science"]:
		var btn := Button.new()
		btn.text = subject.capitalize()
		btn.custom_minimum_size = Vector2(120, 44)
		btn.pressed.connect(_select_subject.bind(subject))
		subject_btns.add_child(btn)
		_subject_btn_map[subject] = btn

func _build_character_buttons() -> void:
	for char_id in ["conrad", "celestine"]:
		var btn := Button.new()
		btn.text = char_id.capitalize()
		btn.custom_minimum_size = Vector2(120, 44)
		btn.pressed.connect(_select_character.bind(char_id))
		character_btns.add_child(btn)
		_character_btn_map[char_id] = btn

func _build_minigame_list() -> void:
	for category in MINIGAMES.keys():
		var cat_col: Color = CATEGORY_COLORS.get(category, Color.WHITE)

		# ── Category header ──
		var header := Label.new()
		header.text = "  " + category.to_upper()
		header.add_theme_color_override("font_color", cat_col)
		header.add_theme_font_size_override("font_size", 18)
		var sep := HSeparator.new()
		sep.add_theme_color_override("color", cat_col)
		category_vbox.add_child(header)
		category_vbox.add_child(sep)

		# ── Button grid ──
		var grid := GridContainer.new()
		grid.columns = 3
		grid.add_theme_constant_override("h_separation", 8)
		grid.add_theme_constant_override("v_separation", 6)
		category_vbox.add_child(grid)

		for entry in MINIGAMES[category]:
			var label: String  = entry[0]
			var puzzle_id: String = entry[1]
			var has_variants: bool = entry[2]

			var btn := Button.new()
			btn.text = label
			btn.custom_minimum_size = Vector2(280, 38)
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.tooltip_text = puzzle_id
			btn.pressed.connect(_launch_minigame.bind(puzzle_id, has_variants))
			grid.add_child(btn)

		# Spacer between categories
		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(0, 10)
		category_vbox.add_child(spacer)

# ── Selection logic ───────────────────────────────────────────────────────────
func _select_subject(subject: String) -> void:
	_current_subject = subject
	_apply_selection()

func _select_character(char_id: String) -> void:
	_current_character = char_id
	_apply_selection()

func _apply_selection() -> void:
	# Subject buttons: highlight active
	for s in _subject_btn_map:
		var btn: Button = _subject_btn_map[s]
		var col: Color = SUBJECT_COLORS.get(s, Color.WHITE)
		if s == _current_subject:
			btn.modulate = col
		else:
			btn.modulate = Color(0.5, 0.5, 0.5)

	# Character buttons
	for c in _character_btn_map:
		var btn: Button = _character_btn_map[c]
		if c == _current_character:
			btn.modulate = Color.WHITE
		else:
			btn.modulate = Color(0.5, 0.5, 0.5)

	# Push to game state
	PlayerStats.selected_subject   = _current_subject
	PlayerStats.selected_character = _current_character
	Dialogic.VAR.selected_subject   = _current_subject
	Dialogic.VAR.selected_character = _current_character

	_update_status("Ready — Subject: %s | Character: %s" % [
		_current_subject.capitalize(),
		_current_character.capitalize()
	])

# ── Launch ────────────────────────────────────────────────────────────────────
func _launch_minigame(puzzle_id: String, has_variants: bool) -> void:
	if MinigameManager.current_minigame:
		_update_status("A minigame is already running!")
		return

	# For variant-aware entries, let MinigameManager._get_subject_variant_id handle it.
	# For explicit IDs (no variants), launch exactly as-is.
	# Either way we call start_minigame() — the manager resolves variants internally.
	var launch_id := puzzle_id

	# Special handling: if this is an explicit per-subject ID, bypass variant lookup by
	# temporarily forcing subject to "english" so no _math/_science is appended.
	# (Has_variants=false means the ID already encodes the subject.)
	if not has_variants and (puzzle_id.ends_with("_math") or puzzle_id.ends_with("_science")):
		var saved_subject = PlayerStats.selected_subject
		PlayerStats.selected_subject = "english"
		Dialogic.VAR.selected_subject = "english"
		MinigameManager.start_minigame(launch_id)
		# Restore immediately after (manager reads subject synchronously at start)
		PlayerStats.selected_subject   = saved_subject
		Dialogic.VAR.selected_subject  = saved_subject
	else:
		MinigameManager.start_minigame(launch_id)

	_update_status("Launched: %s  [%s / %s]" % [
		puzzle_id,
		_current_subject.capitalize(),
		_current_character.capitalize()
	])

# ── Completion callback ───────────────────────────────────────────────────────
func _on_minigame_completed(puzzle_id: String, success: bool) -> void:
	var result_text := "✓ SUCCESS" if success else "✗ FAILED"
	_update_status("%s → %s" % [puzzle_id, result_text])

# ── Helpers ───────────────────────────────────────────────────────────────────
func _update_status(msg: String) -> void:
	if status_label:
		status_label.text = msg

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
