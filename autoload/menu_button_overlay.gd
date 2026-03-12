extends CanvasLayer

# Persistent hamburger menu button — visible during gameplay, acts like ESC key.
# Only shows when PauseManager.pause_enabled is true (i.e. during a timeline).

const BUTTON_SIZE := 64
const BUTTON_MARGIN := 12

var _button: TextureButton

func _ready() -> void:
	layer = 90  # Below pause menu (100) but above game

	_button = TextureButton.new()
	_button.custom_minimum_size = Vector2(BUTTON_SIZE, BUTTON_SIZE)
	_button.stretch_mode = TextureButton.STRETCH_SCALE
	_button.ignore_texture_size = true

	# Load normal and hover textures
	var normal_tex = load("res://assets/button/menu.png")
	var hover_tex = load("res://assets/button/menu.png")  # same image, modulate on hover

	_button.texture_normal = normal_tex
	_button.texture_hover = hover_tex
	_button.texture_pressed = normal_tex

	# Anchor to top-left
	_button.anchor_left = 0.0
	_button.anchor_top = 0.0
	_button.offset_left = 90
	_button.offset_top = 50

	# Slight transparency, full on hover
	_button.modulate = Color(1, 1, 1, 0.75)
	_button.mouse_entered.connect(_on_hover.bind(true))
	_button.mouse_exited.connect(_on_hover.bind(false))
	_button.pressed.connect(_on_pressed)

	add_child(_button)

	# Start hidden; show/hide based on PauseManager state
	_button.visible = false

	# Connect to Dialogic timeline events to show/hide button
	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(_on_timeline_ended)

func _on_timeline_started() -> void:
	_button.visible = true

func _on_timeline_ended() -> void:
	_button.visible = false

func _on_hover(hovering: bool) -> void:
	_button.modulate = Color(1, 1, 1, 1.0) if hovering else Color(1, 1, 1, 0.75)

func _on_pressed() -> void:
	if not PauseManager.is_paused and PauseManager.pause_enabled:
		PauseManager._pause_game()
	elif PauseManager.is_paused:
		PauseManager._resume_game()
