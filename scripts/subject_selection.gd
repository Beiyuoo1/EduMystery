extends Control

@onready var math_button = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/SubjectButtons/MathButton
@onready var science_button = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/SubjectButtons/ScienceButton
@onready var english_button = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/SubjectButtons/EnglishButton
@onready var description_label = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/DescriptionLabel
@onready var back_button = $BackButton
@onready var background = $Background

var selected_subject: String = ""
var subject_buttons: Array = []

# Subject data with icons, colors, and detailed descriptions
var subject_data = {
	"math": {
		"name": "Mathematics",
		"icon": "[ + ]",
		"color": Color(0.3, 0.6, 1.0),  # Blue
		"description": "General Mathematics Curriculum\n\nQ1-Q2: Functions, Inverse Functions, Exponential & Logarithmic Functions\nQ3: Trigonometry - Unit Circle, Identities\nQ4: Statistics & Probability",
		"short_desc": "Functions, Trigonometry, Statistics"
	},
	"science": {
		"name": "Science",
		"icon": "[ @ ]",
		"color": Color(0.3, 0.8, 0.4),  # Green
		"description": "Earth & Physical Science Curriculum\n\nQ1: Earth's Structure, Plate Tectonics\nQ2: Weather, Climate, Natural Hazards\nQ3: Biology, Genetics, DNA\nQ4: Chemistry, Atomic Structure",
		"short_desc": "Earth Science, Biology, Chemistry"
	},
	"english": {
		"name": "English",
		"icon": "[ A ]",
		"color": Color(1.0, 0.6, 0.3),  # Orange
		"description": "Oral Communication Curriculum\n\nQ1: Elements of Communication, Models\nQ2: Communication Strategies, Avoiding Breakdown\nQ3: Speech Context, Speech Acts\nQ4: Presentation Skills, Argumentation",
		"short_desc": "Communication, Speech, Presentations"
	}
}

func _ready() -> void:
	# Set up background image
	_setup_background()

	# Store button references for navigation
	subject_buttons = [math_button, science_button, english_button]

	# Connect button signals
	math_button.pressed.connect(_on_subject_selected.bind("math"))
	science_button.pressed.connect(_on_subject_selected.bind("science"))
	english_button.pressed.connect(_on_subject_selected.bind("english"))
	back_button.pressed.connect(_on_back_pressed)

	# Connect hover signals for descriptions and visual feedback
	for subject in ["math", "science", "english"]:
		var button = _get_button_for_subject(subject)
		button.mouse_entered.connect(_on_button_hover.bind(subject, true))
		button.mouse_exited.connect(_on_button_hover.bind(subject, false))
		button.focus_entered.connect(_on_button_hover.bind(subject, true))
		button.focus_exited.connect(_on_button_hover.bind(subject, false))

	# Style the buttons with icons and colors
	_style_buttons()

	# Set initial focus for keyboard navigation
	math_button.grab_focus()

	# Fade in
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func _setup_background() -> void:
	# Try to load the background image
	var bg_texture = load("res://Pics/choosegradelevelandsubject.png")
	if bg_texture and background:
		# Create TextureRect for background
		var tex_rect = TextureRect.new()
		tex_rect.texture = bg_texture
		tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tex_rect.modulate = Color(0.4, 0.4, 0.5, 1.0)  # Darken for readability

		# Add behind the background ColorRect
		background.add_sibling(tex_rect)
		move_child(tex_rect, 0)

		# Make background ColorRect semi-transparent
		background.color = Color(0.08, 0.06, 0.12, 0.7)

func _style_buttons() -> void:
	for subject in subject_data.keys():
		var button = _get_button_for_subject(subject)
		var data = subject_data[subject]

		# Set button text with icon
		button.text = data.icon + "  " + data.name

		# We'll handle color changes on hover instead of permanent coloring

func _get_button_for_subject(subject: String) -> Button:
	match subject:
		"math": return math_button
		"science": return science_button
		"english": return english_button
	return null

func _on_button_hover(subject: String, is_hovering: bool) -> void:
	var button = _get_button_for_subject(subject)
	var data = subject_data[subject]

	if is_hovering:
		# Show detailed description
		description_label.text = data.description

		# Animate button scale
		var tween = create_tween()
		tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.1)

		# Add glow effect via modulate
		button.modulate = Color(1.2, 1.2, 1.2)
	else:
		# Reset description if no button is focused/hovered
		if not _any_button_focused():
			description_label.text = "Select a subject to see curriculum details\n\nUse arrow keys to navigate, Enter to select"

		# Reset button appearance
		var tween = create_tween()
		tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)
		button.modulate = Color(1.0, 1.0, 1.0)

func _any_button_focused() -> bool:
	for btn in subject_buttons:
		if btn.has_focus():
			return true
	return false

func _on_subject_selected(subject: String) -> void:
	selected_subject = subject

	# Visual feedback - flash the selected button
	var button = _get_button_for_subject(subject)
	var data = subject_data[subject]

	# Disable all buttons during transition
	for btn in subject_buttons:
		btn.disabled = true
	back_button.disabled = true

	# Flash animation
	var tween = create_tween()
	tween.tween_property(button, "modulate", data.color, 0.15)
	tween.tween_property(button, "modulate", Color.WHITE, 0.15)
	tween.tween_property(button, "modulate", data.color, 0.15)

	await tween.finished

	# Set the selected subject in Dialogic AND PlayerStats
	Dialogic.VAR.selected_subject = subject
	Dialogic.VAR.current_chapter = 1

	# IMPORTANT: Also set in PlayerStats so MinigameManager can access it
	if PlayerStats:
		PlayerStats.selected_subject = subject
		PlayerStats.save_stats()

	# Fade out transition
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.5)

	await fade_tween.finished

	# Navigate to character selection
	get_tree().change_scene_to_file("res://scenes/ui/character_selection.tscn")

func _on_back_pressed() -> void:
	# Fade out transition
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished

	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _input(event: InputEvent) -> void:
	# Handle keyboard navigation
	if event.is_action_pressed("ui_up"):
		_navigate_buttons(-1)
	elif event.is_action_pressed("ui_down"):
		_navigate_buttons(1)

func _navigate_buttons(direction: int) -> void:
	var current_index = -1
	for i in range(subject_buttons.size()):
		if subject_buttons[i].has_focus():
			current_index = i
			break

	if current_index == -1:
		subject_buttons[0].grab_focus()
	else:
		var new_index = wrapi(current_index + direction, 0, subject_buttons.size())
		subject_buttons[new_index].grab_focus()
