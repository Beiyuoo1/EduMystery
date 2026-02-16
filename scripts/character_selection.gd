extends Control

@onready var conrad_button = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/CharacterContainer/ConradPanel/VBoxContainer/ConradButton
@onready var thebe_button = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/CharacterContainer/ThebePanel/VBoxContainer/ThebeButton
@onready var conrad_portrait = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/CharacterContainer/ConradPanel/VBoxContainer/PortraitContainer/ConradPortrait
@onready var thebe_portrait = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/CharacterContainer/ThebePanel/VBoxContainer/PortraitContainer/ThebePortrait
@onready var conrad_name_label = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/CharacterContainer/ConradPanel/VBoxContainer/ConradName
@onready var thebe_name_label = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/CharacterContainer/ThebePanel/VBoxContainer/ThebeName
@onready var description_label = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/DescriptionLabel
@onready var back_button = $BackButton
@onready var background = $Background

var selected_character: String = ""
var character_buttons: Array = []

# Character data
var character_data = {
	"conrad": {
		"name": "Conrad",
		"description": "A keen observer with a sharp mind.\nConrad approaches mysteries with logic and careful deduction.\n\nPronoun: He/Him",
		"portrait": "res://Sprites/Conrad_full.png",
		"color": Color(0.4, 0.6, 1.0)  # Blue
	},
	"celestine": {
		"name": "Celestine",
		"description": "An intuitive thinker with a creative perspective.\nCelestine solves cases through empathy and understanding.\n\nPronoun: She/Her",
		"portrait": "res://Sprites/Celestine.png",
		"color": Color(1.0, 0.5, 0.7)  # Pink
	}
}

func _ready() -> void:
	# Set up background
	_setup_background()

	# Store button references
	character_buttons = [conrad_button, thebe_button]

	# Load character portraits
	_load_portraits()

	# Connect button signals
	conrad_button.pressed.connect(_on_character_selected.bind("conrad"))
	thebe_button.pressed.connect(_on_character_selected.bind("celestine"))
	back_button.pressed.connect(_on_back_pressed)

	# Connect hover signals
	conrad_button.mouse_entered.connect(_on_button_hover.bind("conrad", true))
	conrad_button.mouse_exited.connect(_on_button_hover.bind("conrad", false))
	thebe_button.mouse_entered.connect(_on_button_hover.bind("celestine", true))
	thebe_button.mouse_exited.connect(_on_button_hover.bind("celestine", false))

	# Connect focus signals for better visual feedback
	conrad_button.focus_entered.connect(_on_button_hover.bind("conrad", true))
	conrad_button.focus_exited.connect(_on_button_hover.bind("conrad", false))
	thebe_button.focus_entered.connect(_on_button_hover.bind("celestine", true))
	thebe_button.focus_exited.connect(_on_button_hover.bind("celestine", false))

	# Set initial focus
	conrad_button.grab_focus()

	# Show debug hint
	_add_debug_label()

	# Fade in
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func _setup_background() -> void:
	# Similar to subject selection
	var bg_texture = load("res://Pics/choosegradelevelandsubject.png")
	if bg_texture and background:
		var tex_rect = TextureRect.new()
		tex_rect.texture = bg_texture
		tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tex_rect.modulate = Color(0.4, 0.4, 0.5, 1.0)

		background.add_sibling(tex_rect)
		move_child(tex_rect, 0)
		background.color = Color(0.08, 0.06, 0.12, 0.7)

func _load_portraits() -> void:
	# Load Conrad portrait
	var conrad_tex = load(character_data.conrad.portrait)
	if conrad_tex and conrad_portrait:
		conrad_portrait.texture = conrad_tex
		conrad_portrait.visible = true
		print("DEBUG: Loaded Conrad portrait: ", character_data.conrad.portrait)
	else:
		print("ERROR: Failed to load Conrad portrait or portrait node not found")

	# Load Celestine portrait
	var celestine_tex = load(character_data.celestine.portrait)
	if celestine_tex and thebe_portrait:
		thebe_portrait.texture = celestine_tex
		thebe_portrait.visible = true
		print("DEBUG: Loaded Celestine portrait: ", character_data.celestine.portrait)
	else:
		print("ERROR: Failed to load Celestine portrait or portrait node not found")

func _on_button_hover(character: String, is_hovering: bool) -> void:
	var data = character_data[character]
	var button = conrad_button if character == "conrad" else thebe_button
	var portrait = conrad_portrait if character == "conrad" else thebe_portrait

	if is_hovering:
		# Show description
		description_label.text = data.description

		# Animate portrait scale
		var tween = create_tween()
		tween.tween_property(portrait, "scale", Vector2(1.05, 1.05), 0.2)

		# Add glow effect
		portrait.modulate = Color(1.2, 1.2, 1.2)
	else:
		# Reset description
		if not _any_button_focused():
			description_label.text = "Choose your character\n\nUse arrow keys to navigate, Enter to select"

		# Reset portrait
		var tween = create_tween()
		tween.tween_property(portrait, "scale", Vector2(1.0, 1.0), 0.2)
		portrait.modulate = Color(1.0, 1.0, 1.0)

func _any_button_focused() -> bool:
	for btn in character_buttons:
		if btn.has_focus():
			return true
	return false

func _on_character_selected(character: String) -> void:
	selected_character = character

	# Disable all buttons
	for btn in character_buttons:
		btn.disabled = true
	back_button.disabled = true

	# Flash animation
	var portrait = conrad_portrait if character == "conrad" else thebe_portrait
	var data = character_data[character]

	var tween = create_tween()
	tween.tween_property(portrait, "modulate", data.color, 0.15)
	tween.tween_property(portrait, "modulate", Color.WHITE, 0.15)
	tween.tween_property(portrait, "modulate", data.color, 0.15)

	await tween.finished

	# Set the selected character in PlayerStats
	if PlayerStats:
		PlayerStats.selected_character = character
		PlayerStats.save_stats()

	# Dialogic variable will be initialized when timeline starts (c1s1.dtl)

	# Fade out transition
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.5)

	await fade_tween.finished

	# Start the game
	get_tree().change_scene_to_file("res://node_2d.tscn")

func _on_back_pressed() -> void:
	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished

	get_tree().change_scene_to_file("res://scenes/ui/subject_selection.tscn")

func _input(event: InputEvent) -> void:
	# Debug: Press 1-5 to skip to specific chapter (after selecting character)
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				_debug_skip_to_chapter(1)
				return
			KEY_2:
				_debug_skip_to_chapter(2)
				return
			KEY_3:
				_debug_skip_to_chapter(3)
				return
			KEY_4:
				_debug_skip_to_chapter(4)
				return
			KEY_5:
				_debug_skip_to_chapter(5)
				return

	# Handle keyboard navigation (left/right)
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
		_toggle_character_focus()

func _toggle_character_focus() -> void:
	if conrad_button.has_focus():
		thebe_button.grab_focus()
	elif thebe_button.has_focus():
		conrad_button.grab_focus()
	else:
		conrad_button.grab_focus()

func _add_debug_label() -> void:
	"""Add a small debug label showing chapter skip keys"""
	var debug_label = Label.new()
	debug_label.text = "DEBUG: First select character, then press 1-5 to skip to chapter"
	debug_label.add_theme_font_size_override("font_size", 16)
	debug_label.add_theme_color_override("font_color", Color(1, 1, 0, 0.7))  # Semi-transparent yellow
	debug_label.position = Vector2(10, 10)  # Top-left corner
	add_child(debug_label)

func _debug_skip_to_chapter(chapter: int) -> void:
	"""Debug function to skip directly to a specific chapter with selected character"""
	# Must select a character first (either by clicking or pressing number keys)
	var character_to_use = ""

	# Debug info to help troubleshoot
	print("DEBUG: selected_character = ", selected_character)
	print("DEBUG: conrad_button.has_focus() = ", conrad_button.has_focus())
	print("DEBUG: thebe_button.has_focus() = ", thebe_button.has_focus())

	# Check which button has focus or if one was already selected
	if selected_character != "":
		character_to_use = selected_character
		print("DEBUG: Using selected_character: ", character_to_use)
	elif thebe_button.has_focus():
		character_to_use = "celestine"
		print("DEBUG: Using thebe_button focus: celestine")
	elif conrad_button.has_focus():
		character_to_use = "conrad"
		print("DEBUG: Using conrad_button focus: conrad")
	else:
		# Default to Conrad if no selection/focus
		character_to_use = "conrad"
		print("DEBUG: Using default: conrad")

	print("DEBUG: Skipping to Chapter ", chapter, " with character: ", character_to_use)

	# IMPORTANT: Set character and subject FIRST before reset
	if PlayerStats:
		PlayerStats.selected_character = character_to_use
		print("DEBUG: Set PlayerStats.selected_character to: ", PlayerStats.selected_character)
		# Also preserve the subject from subject selection screen
		# For debug skip, default to Math (change to "science" or "english" if needed for testing)
		if PlayerStats.selected_subject == "":
			PlayerStats.selected_subject = "math"  # Debug default: Math
			print("DEBUG: No subject set, defaulting to MATH for debug skip")

	# Reset player stats for fresh chapter start (but character/subject are preserved)
	PlayerStats.score = 0
	PlayerStats.xp = 0
	PlayerStats.level = 1
	PlayerStats.hints = 10
	PlayerStats.save_stats()
	print("DEBUG: After save_stats, PlayerStats.selected_character = ", PlayerStats.selected_character)

	EvidenceManager.reset_evidence()

	# Set flag to prevent node_2d from auto-starting c1s1
	var node_2d_script = load("res://node_2d.gd")
	node_2d_script.timeline_already_started = true

	# Start the chapter timeline directly
	var chapter_timeline = "res://content/timelines/Chapter " + str(chapter) + "/c" + str(chapter) + "s0.dtl"
	Dialogic.start(chapter_timeline)

	# Wait a frame for Dialogic to initialize
	await get_tree().process_frame

	# CRITICAL: Set selected_character IMMEDIATELY before timeline processes conditionals
	# This must happen synchronously before any character checks in the timeline
	Dialogic.current_state_info['variables']['selected_character'] = character_to_use
	print("DEBUG: Set Dialogic.VAR.selected_character to: ", character_to_use)
	print("DEBUG: Verification - Dialogic.VAR.selected_character = ", Dialogic.VAR.selected_character)

	# Initialize other Dialogic variables
	Dialogic.paused = false
	Dialogic.VAR.conrad_level = chapter  # Set level based on chapter
	Dialogic.VAR.chapter1_score = 0
	Dialogic.VAR.chapter2_score = 0
	Dialogic.VAR.chapter3_score = 0
	Dialogic.VAR.chapter4_score = 0
	Dialogic.VAR.chapter5_score = 0
	Dialogic.VAR.minigames_completed = 0
	Dialogic.VAR.selected_subject = PlayerStats.selected_subject
	Dialogic.VAR.current_chapter = chapter

	print("DEBUG: Started timeline: ", chapter_timeline, " with character: ", character_to_use)
