extends Control

## Logic Grid Puzzle Minigame
## Detective-style deduction grid for systematic reasoning
## Students eliminate possibilities based on clues to find the solution

# UI Nodes
@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var context_label: RichTextLabel = $Panel/VBox/ContextLabel
@onready var clues_container: VBoxContainer = $CluesPopup/PopupPanel/VBox/ScrollContainer/CluesContainer
@onready var chibi_sprite: TextureRect = $Panel/VBox/MainHBox/ChibiSection/ChibiSprite
@onready var grid_container: GridContainer = $Panel/VBox/MainHBox/GridSection/GridPanel/MarginContainer/GridContainer
@onready var timer_label: Label = $Panel/VBox/HBox/TimerLabel
@onready var hint_button: Button = $Panel/VBox/HBox/HintButton
@onready var hint_counter: Label = $Panel/VBox/HBox/HintCounter
@onready var submit_button: Button = $Panel/VBox/SubmitButton
@onready var feedback_overlay: ColorRect = $FeedbackOverlay
@onready var feedback_panel: NinePatchRect = $FeedbackPanel
@onready var feedback_label: RichTextLabel = $FeedbackPanel/VBox/FeedbackLabel
@onready var continue_button: Button = $FeedbackPanel/VBox/ContinueButton
@onready var tutorial_overlay: Control = $TutorialOverlay
@onready var tutorial_page1: Control = $TutorialOverlay/Page1
@onready var tutorial_page2: Control = $TutorialOverlay/Page2
@onready var tut_next_button: Button = $TutorialOverlay/Page1/VBox/NextButton
@onready var tut_back_button: Button = $TutorialOverlay/Page2/VBox/ButtonsRow/BackButton
@onready var tut_done_button: Button = $TutorialOverlay/Page2/VBox/ButtonsRow/DoneButton
@onready var clues_button: Button = $Panel/VBox/HBox/CluesButton
@onready var clues_popup: Control = $CluesPopup
@onready var clues_close_button: Button = $CluesPopup/PopupPanel/VBox/CloseButton

# Minigame data
var puzzle_config: Dictionary = {}
var grid_data: Dictionary = {}  # Store grid cell states
var start_time: float = 0.0
var time_limit: float = 120.0  # 2 minutes
var hint_used: bool = false  # tracks if hint was ever used (for speed bonus)
var hint_cooldown: float = 0.0  # seconds remaining before next hint allowed
const HINT_COOLDOWN_TIME: float = 12.0
var rows: Array = []  # Category 1 items
var cols: Array = []  # Category 2 items
var solution: Dictionary = {}  # Correct matches
var attempts: int = 0
var help_button: Button = null  # Top-right "?" button shown after tutorial seen once

# Chibi blink system
var chibi_normal_tex: Texture2D = null
var chibi_blink_tex: Texture2D = null
var _blink_timer: float = 0.0
var _next_blink: float = 0.0
var _is_blinking: bool = false
var _blink_close_duration: float = 0.12   # seconds eyes stay closed
var _blink_elapsed: float = 0.0

signal minigame_completed(success: bool, time_taken: float)


func _ready() -> void:
	set_process(false)  # Don't run _process until timer is started
	feedback_panel.hide()
	feedback_overlay.hide()
	clues_popup.hide()
	hint_button.pressed.connect(_on_hint_pressed)
	hint_button.icon = load("res://assets/UI/core/hints.png")
	hint_button.add_theme_constant_override("icon_max_width", 32)
	hint_button.text = ""
	submit_button.pressed.connect(_on_submit_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	tut_next_button.pressed.connect(_on_tutorial_next)
	tut_back_button.pressed.connect(_on_tutorial_back)
	tut_done_button.pressed.connect(_on_tutorial_done)
	clues_button.pressed.connect(_on_clues_button_pressed)
	clues_close_button.pressed.connect(_on_clues_close_pressed)
	_style_clues_button()
	_update_hint_display()
	_style_submit_button()

	if not TutorialFlags.has_seen("logic_grid"):
		# First time — show tutorial, timer starts after dismissal
		tutorial_overlay.show()
		tutorial_page1.show()
		tutorial_page2.hide()
	else:
		# Already seen — hide tutorial and show the "?" help button
		tutorial_overlay.hide()
		_add_help_button()

func _style_clues_button() -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.28, 0.55, 0.95)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_color = Color(0.4, 0.65, 1.0)
	clues_button.add_theme_stylebox_override("normal", style)
	var hover = style.duplicate()
	hover.bg_color = Color(0.2, 0.45, 0.85, 1.0)
	clues_button.add_theme_stylebox_override("hover", hover)
	clues_button.add_theme_stylebox_override("pressed", hover.duplicate())
	clues_button.add_theme_color_override("font_color", Color.WHITE)
	clues_button.add_theme_font_size_override("font_size", 18)

func _on_clues_button_pressed() -> void:
	clues_popup.show()

func _on_clues_close_pressed() -> void:
	clues_popup.hide()

func _add_help_button() -> void:
	"""Add a small '?' button at the top-right to re-open tutorial"""
	help_button = Button.new()
	help_button.text = "?"
	help_button.tooltip_text = "How to Play"
	help_button.custom_minimum_size = Vector2(42, 42)
	help_button.add_theme_font_size_override("font_size", 22)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.35, 0.55, 0.9)
	style.corner_radius_top_left = 21
	style.corner_radius_top_right = 21
	style.corner_radius_bottom_left = 21
	style.corner_radius_bottom_right = 21
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_color = Color(0.4, 0.65, 1.0)
	help_button.add_theme_stylebox_override("normal", style)

	var hover = style.duplicate()
	hover.bg_color = Color(0.3, 0.5, 0.8, 1.0)
	help_button.add_theme_stylebox_override("hover", hover)
	help_button.add_theme_color_override("font_color", Color.WHITE)

	# Anchor to top-right corner
	help_button.anchor_left = 1.0
	help_button.anchor_right = 1.0
	help_button.anchor_top = 0.0
	help_button.anchor_bottom = 0.0
	help_button.offset_left = -58.0
	help_button.offset_right = -16.0
	help_button.offset_top = 16.0
	help_button.offset_bottom = 58.0

	help_button.pressed.connect(_open_tutorial_popup)
	add_child(help_button)

func _open_tutorial_popup() -> void:
	"""Re-open the tutorial overlay (pauses timer while open)"""
	set_process(false)
	tutorial_overlay.show()
	tutorial_page1.show()
	tutorial_page2.hide()

func _on_tutorial_next() -> void:
	tutorial_page1.hide()
	tutorial_page2.show()

func _on_tutorial_back() -> void:
	tutorial_page2.hide()
	tutorial_page1.show()

func _on_tutorial_done() -> void:
	if not TutorialFlags.has_seen("logic_grid"):
		TutorialFlags.mark_seen("logic_grid")
		_add_help_button()

	tutorial_overlay.hide()
	# Start/resume timer after tutorial dismissed
	start_time = Time.get_ticks_msec() / 1000.0
	set_process(true)

func configure_puzzle(config: Dictionary) -> void:
	"""Configure the logic grid puzzle"""
	puzzle_config = config

	# Set title and context
	title_label.text = config.get("title", "Logic Grid Puzzle")
	context_label.text = config.get("context", "Use the clues to deduce the correct matches.")

	# Load protagonist chibi — shown at right side of grid
	var protagonist = PlayerStats.selected_character if PlayerStats.selected_character != "" else "conrad"
	var normal_path = "res://Sprites/%s_chibi_clues.png" % protagonist
	var blink_path  = "res://Sprites/%s_chibi_clues_eyes_close.png" % protagonist
	# Fallback to conrad if character not set
	if not ResourceLoader.exists(normal_path):
		normal_path = "res://Sprites/conrad_chibi_clues.png"
		blink_path  = "res://Sprites/conrad_chibi_clues_eyes_close.png"
	chibi_normal_tex = load(normal_path)
	if ResourceLoader.exists(blink_path):
		chibi_blink_tex = load(blink_path)
	else:
		chibi_blink_tex = chibi_normal_tex
	chibi_sprite.texture = chibi_normal_tex
	chibi_sprite.flip_h = false  # Face inward (toward grid = left, so no flip)
	chibi_sprite.show()
	_next_blink = randf_range(3.0, 6.0)

	# Get grid dimensions
	rows = config.get("rows", []).duplicate()
	cols = config.get("cols", [])
	solution = config.get("solution", {})

	# Shuffle rows so order is different each playthrough
	rows.shuffle()

	# Display clues
	var clues = config.get("clues", [])
	_display_clues(clues)

	# Create grid
	_create_grid()

	# Only start timer if tutorial is NOT currently showing
	# (tutorial_overlay visible means player is still reading - don't start yet)
	if not tutorial_overlay.visible:
		start_time = Time.get_ticks_msec() / 1000.0
		set_process(true)
	# else: timer starts after tutorial is dismissed in _on_tutorial_done()

func _display_clues(clues: Array) -> void:
	"""Display clue list"""
	for clue_text in clues:
		var clue_label = Label.new()
		clue_label.text = "• " + clue_text
		clue_label.add_theme_font_size_override("font_size", 20)
		clue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		clue_label.add_theme_color_override("font_color", Color(0.15, 0.08, 0.03))
		clues_container.add_child(clue_label)

func _create_grid() -> void:
	"""Create interactive grid that fills its container"""
	grid_container.columns = cols.size() + 1

	# Corner cell (empty top-left)
	var corner_label = Label.new()
	corner_label.text = ""
	corner_label.custom_minimum_size = Vector2(20, 60)
	corner_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	corner_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid_container.add_child(corner_label)

	# Column headers — white text on dark blue bg for readability
	for col in cols:
		var header = Label.new()
		header.text = col
		header.custom_minimum_size = Vector2(80, 64)
		header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		header.size_flags_vertical = Control.SIZE_EXPAND_FILL
		header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		header.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		header.add_theme_font_size_override("font_size", 24)
		header.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
		var header_bg = StyleBoxFlat.new()
		header_bg.bg_color = Color(0.15, 0.30, 0.60, 0.95)
		header_bg.corner_radius_top_left = 8
		header_bg.corner_radius_top_right = 8
		header_bg.corner_radius_bottom_left = 8
		header_bg.corner_radius_bottom_right = 8
		header_bg.border_width_top = 2
		header_bg.border_width_bottom = 2
		header_bg.border_width_left = 2
		header_bg.border_width_right = 2
		header_bg.border_color = Color(0.5, 0.7, 1.0, 0.8)
		header.add_theme_stylebox_override("normal", header_bg)
		grid_container.add_child(header)

	# Row labels + cells
	for row in rows:
		var row_label = Label.new()
		row_label.text = row
		row_label.custom_minimum_size = Vector2(20, 88)
		row_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		row_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		row_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row_label.add_theme_font_size_override("font_size", 28)
		row_label.add_theme_color_override("font_color", Color(0.22, 0.10, 0.03))
		grid_container.add_child(row_label)

		for col in cols:
			var cell_button = Button.new()
			cell_button.custom_minimum_size = Vector2(80, 80)
			cell_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			cell_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
			cell_button.text = "?"
			cell_button.add_theme_font_size_override("font_size", 36)
			cell_button.set_meta("row", row)
			cell_button.set_meta("col", col)
			_style_cell_button(cell_button, "unknown")
			cell_button.pressed.connect(_on_cell_pressed.bind(cell_button))
			grid_container.add_child(cell_button)

			var key = row + ":" + col
			grid_data[key] = "unknown"

func _style_cell_button(button: Button, state: String) -> void:
	"""Apply visual style based on cell state"""
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_width_left = 3
	style.border_width_right = 3

	var hover_style = style.duplicate()

	match state:
		"yes":
			button.text = ""
			button.icon = load("res://assets/UI/core/correct.png")
			button.add_theme_constant_override("icon_max_width", 40)
			style.bg_color = Color(0.12, 0.62, 0.25, 0.97)
			style.border_color = Color(0.25, 0.95, 0.45, 1.0)
			hover_style.bg_color = Color(0.18, 0.78, 0.35, 1.0)
			hover_style.border_color = Color(0.35, 1.0, 0.55, 1.0)
		"no":
			button.text = ""
			button.icon = load("res://assets/UI/core/incorrect.png")
			button.add_theme_constant_override("icon_max_width", 40)
			style.bg_color = Color(0.65, 0.12, 0.12, 0.97)
			style.border_color = Color(1.0, 0.3, 0.3, 1.0)
			hover_style.bg_color = Color(0.80, 0.18, 0.18, 1.0)
			hover_style.border_color = Color(1.0, 0.5, 0.5, 1.0)
		_:  # unknown
			button.text = "?"
			button.icon = null
			style.bg_color = Color(0.18, 0.18, 0.22, 0.95)
			style.border_color = Color(0.4, 0.4, 0.5, 0.8)
			hover_style.bg_color = Color(0.28, 0.28, 0.35, 1.0)
			hover_style.border_color = Color(0.55, 0.55, 0.7, 1.0)
			button.add_theme_color_override("font_color", Color(0.75, 0.75, 0.85))
			button.add_theme_font_size_override("font_size", 38)

	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", style.duplicate())

func _style_submit_button() -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.45, 0.85)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_color = Color(0.4, 0.65, 1.0)
	submit_button.add_theme_stylebox_override("normal", style)

	var hover = style.duplicate()
	hover.bg_color = Color(0.3, 0.58, 1.0)
	submit_button.add_theme_stylebox_override("hover", hover)
	submit_button.add_theme_color_override("font_color", Color.WHITE)
	submit_button.add_theme_font_size_override("font_size", 22)

func _on_cell_pressed(button: Button) -> void:
	"""Cycle cell state: unknown -> no -> yes -> unknown"""
	var row = button.get_meta("row")
	var col = button.get_meta("col")
	var key = row + ":" + col

	var current_state = grid_data[key]
	var new_state = ""

	match current_state:
		"unknown":
			new_state = "no"
		"no":
			new_state = "yes"
		"yes":
			new_state = "unknown"

	grid_data[key] = new_state
	_style_cell_button(button, new_state)

func _process(delta: float) -> void:
	"""Update timer, hint cooldown, and chibi blink"""
	# Chibi blink logic
	if chibi_normal_tex != null:
		if _is_blinking:
			_blink_elapsed += delta
			if _blink_elapsed >= _blink_close_duration:
				chibi_sprite.texture = chibi_normal_tex
				_is_blinking = false
				_blink_timer = 0.0
				_next_blink = randf_range(3.0, 6.0)
		else:
			_blink_timer += delta
			if _blink_timer >= _next_blink:
				chibi_sprite.texture = chibi_blink_tex
				_is_blinking = true
				_blink_elapsed = 0.0

	var elapsed = Time.get_ticks_msec() / 1000.0 - start_time
	var remaining = time_limit - elapsed

	if remaining <= 0:
		remaining = 0
		set_process(false)
		_on_time_up()

	var minutes = int(remaining) / 60
	var seconds = int(remaining) % 60
	timer_label.text = "Time: %02d:%02d" % [minutes, seconds]

	if remaining <= 10:
		timer_label.add_theme_color_override("font_color", Color.RED)
	elif remaining <= 30:
		timer_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	else:
		timer_label.add_theme_color_override("font_color", Color(0.2, 0.1, 0.05))

	# Hint cooldown countdown
	if hint_cooldown > 0.0:
		hint_cooldown -= delta
		if hint_cooldown <= 0.0:
			hint_cooldown = 0.0
			hint_button.disabled = false
			hint_button.icon = load("res://assets/UI/core/hints.png")
			hint_button.add_theme_constant_override("icon_max_width", 32)
			hint_button.text = ""
		else:
			hint_button.icon = null
			hint_button.text = "Hint (%ds)" % ceil(hint_cooldown)

func _on_submit_pressed() -> void:
	"""Check if solution is correct"""
	set_process(false)
	attempts += 1

	var is_correct = _check_solution()
	var elapsed = Time.get_ticks_msec() / 1000.0 - start_time

	if is_correct:
		_show_feedback(true, elapsed)
	else:
		_show_wrong_feedback()

func _show_wrong_feedback() -> void:
	"""Show a brief incorrect message and let player retry"""
	_play_sfx("res://assets/audio/sound_effect/wrong.wav")
	feedback_overlay.show()
	feedback_panel.show()
	feedback_label.text = "[center][img=64x64]res://assets/UI/core/incorrect.png[/img][/center]\n"
	feedback_label.text += "[center][color=#ff5555][font_size=80][b]Not Quite Right[/b][/font_size][/color][/center]\n\n"
	feedback_label.text += "[center][font_size=24]Some deductions are incorrect.\nReview the clues carefully and try again.[/font_size][/center]"
	continue_button.text = "Try Again"

	# Disconnect old signal and connect retry handler
	if continue_button.pressed.is_connected(_on_continue_pressed):
		continue_button.pressed.disconnect(_on_continue_pressed)
	if not continue_button.pressed.is_connected(_on_retry_pressed):
		continue_button.pressed.connect(_on_retry_pressed)

func _on_retry_pressed() -> void:
	"""Reset grid and let player try again"""
	feedback_overlay.hide()
	feedback_panel.hide()
	continue_button.text = "Continue"

	# Reconnect to normal continue
	if continue_button.pressed.is_connected(_on_retry_pressed):
		continue_button.pressed.disconnect(_on_retry_pressed)
	if not continue_button.pressed.is_connected(_on_continue_pressed):
		continue_button.pressed.connect(_on_continue_pressed)

	# Reset all cells to unknown
	for child in grid_container.get_children():
		if child is Button and child.has_meta("row") and child.has_meta("col"):
			var key = child.get_meta("row") + ":" + child.get_meta("col")
			grid_data[key] = "unknown"
			_style_cell_button(child, "unknown")

	# Resume timer
	start_time = Time.get_ticks_msec() / 1000.0 - (time_limit - _get_remaining_time())
	set_process(true)

func _get_remaining_time() -> float:
	# After retry we give them fresh time
	return time_limit

func _check_solution() -> bool:
	"""Verify if all matches are correct"""
	for row in rows:
		var found_match = false
		var correct_col = solution.get(row, "")

		for col in cols:
			var key = row + ":" + col
			var state = grid_data.get(key, "unknown")

			if state == "yes":
				if col == correct_col:
					found_match = true
				else:
					return false  # Wrong match marked as yes

		if not found_match:
			return false  # Correct match not found

	return true

func _play_sfx(path: String) -> void:
	if OS.get_name() == "Web":
		DialogicSignalHandler.play_web_sfx(path)
		return
	var player = AudioStreamPlayer.new()
	player.stream = load(path)
	player.bus = "SFX"
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func _show_feedback(is_correct: bool, time_taken: float) -> void:
	"""Show success feedback panel"""
	_play_sfx("res://assets/audio/sound_effect/correct.wav")
	var feedback_text = "[center][img=64x64]res://assets/UI/core/correct.png[/img][/center]\n"
	feedback_text += "[center][color=#55ff88][font_size=80][b]CORRECT![/b][/font_size][/color][/center]\n\n"
	feedback_text += "[center][font_size=24]Excellent detective work!\nYou successfully deduced all matches.[/font_size][/center]"

	if puzzle_config.has("explanation"):
		feedback_text += "\n\n" + puzzle_config["explanation"]

	if time_taken < 60.0 and not hint_used:
		PlayerStats.add_hints(1)
		feedback_text += "\n\n[center][color=yellow][img=28x28]res://assets/UI/core/speed_bonus.png[/img] Speed Bonus: +1 Hint![/color][/center]"

	feedback_label.text = feedback_text
	continue_button.text = "Continue"
	feedback_overlay.show()
	feedback_panel.show()

func _on_continue_pressed() -> void:
	"""Only called after correct solution"""
	var elapsed = Time.get_ticks_msec() / 1000.0 - start_time
	minigame_completed.emit(true, elapsed)
	queue_free()

func _on_time_up() -> void:
	"""Handle time running out - show solution and allow retry"""
	feedback_label.text = "[center][font_size=80][color=#ff5555][b]TIME'S UP![/b][/color][/font_size][/center]\n\n"
	feedback_label.text += "[center][font_size=22][b]Correct Solution:[/b][/font_size][/center]\n"
	for row in rows:
		var correct_col = solution.get(row, "")
		feedback_label.text += "[center][font_size=20]• %s → %s[/font_size][/center]\n" % [row, correct_col]

	if puzzle_config.has("explanation"):
		feedback_label.text += "\n" + puzzle_config["explanation"]

	continue_button.text = "Try Again"
	feedback_overlay.show()
	feedback_panel.show()

	if continue_button.pressed.is_connected(_on_continue_pressed):
		continue_button.pressed.disconnect(_on_continue_pressed)
	if not continue_button.pressed.is_connected(_on_retry_pressed):
		continue_button.pressed.connect(_on_retry_pressed)

func _on_hint_pressed() -> void:
	"""Reveal the correct match for one unsolved row"""
	if not PlayerStats.use_hint():
		var label = Label.new()
		label.text = "No hints available!"
		label.add_theme_color_override("font_color", Color.RED)
		label.add_theme_font_size_override("font_size", 18)
		label.position = hint_button.global_position + Vector2(0, -35)
		add_child(label)
		await get_tree().create_timer(1.5).timeout
		label.queue_free()
		return

	# Find the first unsolved row (correct cell not yet YES)
	var target_row: String = ""
	for row in rows:
		var correct_col = solution.get(row, "")
		var key = row + ":" + correct_col
		if grid_data.get(key, "unknown") != "yes":
			target_row = row
			break

	if target_row == "":
		# All rows already solved — no hint needed
		return

	hint_used = true
	_update_hint_display()
	hint_cooldown = HINT_COOLDOWN_TIME
	hint_button.disabled = true
	hint_button.icon = null
	hint_button.text = "Hint (%ds)" % ceil(hint_cooldown)

	var correct_col = solution.get(target_row, "")

	# Apply the correct answer to all cells in the target row
	for child in grid_container.get_children():
		if child is Button and child.has_meta("row") and child.get_meta("row") == target_row:
			var col = child.get_meta("col")
			var key = target_row + ":" + col
			if col == correct_col:
				grid_data[key] = "yes"
				_style_cell_button(child, "yes")
				# Flash yellow to draw attention
				child.modulate = Color(1.2, 1.1, 0.3, 1.0)
				await get_tree().create_timer(0.25).timeout
				child.modulate = Color(1, 1, 1, 1)
			else:
				grid_data[key] = "no"
				_style_cell_button(child, "no")

func _update_hint_display() -> void:
	hint_counter.text = "Hints: %d" % PlayerStats.hints

func _unhandled_input(event: InputEvent) -> void:
	if InputMap.has_action("skip_minigame") and event.is_action_pressed("skip_minigame"):
		set_process(false)
		var elapsed = Time.get_ticks_msec() / 1000.0 - start_time
		minigame_completed.emit(true, elapsed)
		queue_free()
		get_viewport().set_input_as_handled()
