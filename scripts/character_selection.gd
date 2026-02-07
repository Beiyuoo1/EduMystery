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

	# Set initial focus
	conrad_button.grab_focus()

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
