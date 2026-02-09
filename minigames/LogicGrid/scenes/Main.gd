extends Control

## Logic Grid Puzzle Minigame
## Detective-style deduction grid for systematic reasoning
## Students eliminate possibilities based on clues to find the solution

# UI Nodes
@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var context_label: RichTextLabel = $Panel/VBox/ContextLabel
@onready var clues_container: VBoxContainer = $Panel/VBox/ScrollContainer/CluesContainer
@onready var grid_container: GridContainer = $Panel/VBox/GridPanel/GridContainer
@onready var timer_label: Label = $Panel/VBox/HBox/TimerLabel
@onready var hint_button: Button = $Panel/VBox/HBox/HintButton
@onready var hint_counter: Label = $Panel/VBox/HBox/HintCounter
@onready var submit_button: Button = $Panel/VBox/SubmitButton
@onready var feedback_overlay: ColorRect = $FeedbackOverlay
@onready var feedback_panel: Panel = $FeedbackPanel
@onready var feedback_label: RichTextLabel = $FeedbackPanel/VBox/FeedbackLabel
@onready var continue_button: Button = $FeedbackPanel/VBox/ContinueButton

# Minigame data
var puzzle_config: Dictionary = {}
var grid_data: Dictionary = {}  # Store grid cell states
var start_time: float = 0.0
var time_limit: float = 120.0  # 2 minutes
var hint_used: bool = false
var rows: Array = []  # Category 1 items
var cols: Array = []  # Category 2 items
var solution: Dictionary = {}  # Correct matches

signal minigame_completed(success: bool, time_taken: float)

func _ready() -> void:
	feedback_panel.hide()
	feedback_overlay.hide()
	hint_button.pressed.connect(_on_hint_pressed)
	submit_button.pressed.connect(_on_submit_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	_update_hint_display()

func configure_puzzle(config: Dictionary) -> void:
	"""Configure the logic grid puzzle"""
	puzzle_config = config

	# Set title and context
	title_label.text = config.get("title", "Logic Grid Puzzle")
	context_label.text = config.get("context", "Use the clues to deduce the correct matches.")

	# Get grid dimensions
	rows = config.get("rows", [])  # e.g., ["Greg", "Ben", "Alex"]
	cols = config.get("cols", [])  # e.g., ["Library", "Cafeteria", "Gym"]
	solution = config.get("solution", {})  # e.g., {"Greg": "Cafeteria", "Ben": "Library"}

	# Display clues
	var clues = config.get("clues", [])
	_display_clues(clues)

	# Create grid
	_create_grid()

	# Start timer
	start_time = Time.get_ticks_msec() / 1000.0
	set_process(true)

func _display_clues(clues: Array) -> void:
	"""Display clue list"""
	for clue_text in clues:
		var clue_label = Label.new()
		clue_label.text = "• " + clue_text
		clue_label.add_theme_font_size_override("font_size", 20)
		clue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		clues_container.add_child(clue_label)

func _create_grid() -> void:
	"""Create interactive grid"""
	grid_container.columns = cols.size() + 1

	# Header row
	var corner_label = Label.new()
	corner_label.text = ""
	corner_label.custom_minimum_size = Vector2(120, 50)
	grid_container.add_child(corner_label)

	for col in cols:
		var header = Label.new()
		header.text = col
		header.custom_minimum_size = Vector2(120, 50)
		header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		header.add_theme_font_size_override("font_size", 18)
		header.add_theme_color_override("font_color", Color(0.4, 0.7, 1.0))
		grid_container.add_child(header)

	# Grid cells
	for row in rows:
		# Row label
		var row_label = Label.new()
		row_label.text = row
		row_label.custom_minimum_size = Vector2(120, 50)
		row_label.add_theme_font_size_override("font_size", 18)
		row_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
		grid_container.add_child(row_label)

		# Cells for each column
		for col in cols:
			var cell_button = Button.new()
			cell_button.custom_minimum_size = Vector2(120, 50)
			cell_button.text = "?"
			cell_button.add_theme_font_size_override("font_size", 24)

			# Store cell coordinates in metadata
			cell_button.set_meta("row", row)
			cell_button.set_meta("col", col)

			# Style button
			_style_cell_button(cell_button, "unknown")

			# Connect signal
			cell_button.pressed.connect(_on_cell_pressed.bind(cell_button))

			grid_container.add_child(cell_button)

			# Initialize grid data
			var key = row + ":" + col
			grid_data[key] = "unknown"  # States: unknown, yes, no

func _style_cell_button(button: Button, state: String) -> void:
	"""Apply visual style based on cell state"""
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5

	match state:
		"yes":
			button.text = "✓"
			style.bg_color = Color(0.2, 0.8, 0.3, 0.8)
			button.add_theme_color_override("font_color", Color.WHITE)
		"no":
			button.text = "✗"
			style.bg_color = Color(0.8, 0.2, 0.2, 0.8)
			button.add_theme_color_override("font_color", Color.WHITE)
		_:  # unknown
			button.text = "?"
			style.bg_color = Color(0.3, 0.3, 0.3, 0.8)
			button.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))

	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style.duplicate())
	button.add_theme_stylebox_override("pressed", style.duplicate())

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
	"""Update timer"""
	var elapsed = Time.get_ticks_msec() / 1000.0 - start_time
	var remaining = time_limit - elapsed

	if remaining <= 0:
		remaining = 0
		_on_time_up()

	var minutes = int(remaining) / 60
	var seconds = int(remaining) % 60
	timer_label.text = "Time: %02d:%02d" % [minutes, seconds]

	if remaining <= 10:
		timer_label.add_theme_color_override("font_color", Color.RED)
	elif remaining <= 30:
		timer_label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		timer_label.add_theme_color_override("font_color", Color.WHITE)

func _on_submit_pressed() -> void:
	"""Check if solution is correct"""
	set_process(false)

	var is_correct = _check_solution()
	var elapsed = Time.get_ticks_msec() / 1000.0 - start_time

	_show_feedback(is_correct, elapsed)

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

func _show_feedback(is_correct: bool, time_taken: float) -> void:
	"""Show feedback panel with result"""
	var feedback_text = ""

	if is_correct:
		feedback_text = "[center][color=green][b]✓ CORRECT![/b][/color][/center]\n\n"
		feedback_text += "You successfully deduced all the correct matches using logical reasoning!\n\n"
	else:
		feedback_text = "[center][color=red][b]✗ INCORRECT[/b][/color][/center]\n\n"
		feedback_text += "Some of your deductions don't match the clues. Review the evidence carefully.\n\n"
		feedback_text += "[b]Correct Solution:[/b]\n"
		for row in rows:
			var correct_col = solution.get(row, "")
			feedback_text += "• %s → %s\n" % [row, correct_col]

	if puzzle_config.has("explanation"):
		feedback_text += "\n" + puzzle_config["explanation"]

	feedback_label.text = feedback_text
	feedback_overlay.show()
	feedback_panel.show()

	# Award speed bonus
	if is_correct and time_taken < 60.0 and not hint_used:
		PlayerStats.add_hints(1)
		feedback_label.text += "\n\n[center][color=yellow]⚡ Speed Bonus: +1 Hint! ⚡[/color][/center]"

func _on_continue_pressed() -> void:
	"""Continue to next scene"""
	var is_correct = _check_solution()
	var elapsed = Time.get_ticks_msec() / 1000.0 - start_time

	minigame_completed.emit(is_correct, elapsed)
	queue_free()

func _on_time_up() -> void:
	"""Handle time running out"""
	set_process(false)

	feedback_label.text = "[center][color=red][b]⏱ TIME'S UP![/b][/color][/center]\n\n"
	feedback_label.text += "You ran out of time to complete the deduction.\n\n"
	feedback_label.text += "[b]Correct Solution:[/b]\n"
	for row in rows:
		var correct_col = solution.get(row, "")
		feedback_label.text += "• %s → %s\n" % [row, correct_col]

	if puzzle_config.has("explanation"):
		feedback_label.text += "\n" + puzzle_config["explanation"]

	feedback_overlay.show()
	feedback_panel.show()

func _on_hint_pressed() -> void:
	"""Use hint to reveal one correct match"""
	if PlayerStats.use_hint():
		hint_used = true
		_update_hint_display()

		# Find an unsolved correct match
		for row in rows:
			var correct_col = solution.get(row, "")
			var key = row + ":" + correct_col

			if grid_data.get(key, "unknown") != "yes":
				# Reveal this match
				grid_data[key] = "yes"

				# Update button visually
				for child in grid_container.get_children():
					if child is Button:
						if child.has_meta("row") and child.has_meta("col"):
							if child.get_meta("row") == row and child.get_meta("col") == correct_col:
								_style_cell_button(child, "yes")

								# Flash animation
								var tween = create_tween()
								tween.set_loops(3)
								tween.tween_property(child, "modulate", Color.YELLOW, 0.3)
								tween.tween_property(child, "modulate", Color.WHITE, 0.3)
								break
				break

		hint_button.disabled = true
	else:
		var label = Label.new()
		label.text = "No hints available!"
		label.add_theme_color_override("font_color", Color.RED)
		label.position = hint_button.global_position + Vector2(0, -30)
		add_child(label)

		await get_tree().create_timer(1.5).timeout
		label.queue_free()

func _update_hint_display() -> void:
	"""Update hint counter display"""
	hint_counter.text = "Hints: %d" % PlayerStats.hints

func _unhandled_input(event: InputEvent) -> void:
	"""Handle F5 skip"""
	if InputMap.has_action("skip_minigame") and event.is_action_pressed("skip_minigame"):
		print("Logic Grid: F5 pressed - skipping minigame")
		set_process(false)

		var elapsed = Time.get_ticks_msec() / 1000.0 - start_time
		minigame_completed.emit(true, elapsed)
		queue_free()

		get_viewport().set_input_as_handled()
