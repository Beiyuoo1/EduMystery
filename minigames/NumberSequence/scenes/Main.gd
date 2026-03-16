extends Control

## Number Sequence Decoder Minigame
## Player identifies the pattern in a number sequence and fills in the missing values.
## Used for math curriculum: arithmetic sequences, geometric sequences, quadratic patterns.

signal minigame_completed(success: bool, time_taken: float)

# UI Nodes
@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var context_label: RichTextLabel = $Panel/VBox/ContextLabel
@onready var sequence_container: HBoxContainer = $Panel/VBox/SequenceContainer
@onready var pattern_hint_label: Label = $Panel/VBox/PatternHintLabel
@onready var number_pad: GridContainer = $Panel/VBox/NumberPad
@onready var clear_button: Button = $Panel/VBox/ActionRow/ClearButton
@onready var submit_button: Button = $Panel/VBox/ActionRow/SubmitButton
@onready var timer_label: Label = $Panel/VBox/TopRow/TimerLabel
@onready var hint_button: Button = $Panel/VBox/TopRow/HintButton
@onready var hint_counter: Label = $Panel/VBox/TopRow/HintCounter
@onready var feedback_overlay: ColorRect = $FeedbackOverlay
@onready var feedback_panel: PanelContainer = $FeedbackPanel
@onready var feedback_label: RichTextLabel = $FeedbackPanel/VBox/FeedbackLabel
@onready var continue_button: Button = $FeedbackPanel/VBox/ContinueButton

# Puzzle data
var puzzle_config: Dictionary = {}
var sequence: Array = []        # Full sequence (mix of ints and nulls for blanks)
var answers: Array = []         # Correct values for each blank
var blank_indices: Array = []   # Which indices in sequence are blanks
var current_blank: int = 0      # Which blank is currently selected
var player_inputs: Array = []   # Player's entered values (null = not filled)
var blank_buttons: Array = []   # The blank slot buttons in the sequence display
var number_display: String = "" # Current number being typed into active blank

var start_time: float = 0.0
var time_limit: float = 90.0   # 1:30
var hint_used: bool = false

func _ready() -> void:
	set_process(false)
	feedback_panel.hide()
	feedback_overlay.hide()
	submit_button.pressed.connect(_on_submit_pressed)
	clear_button.pressed.connect(_on_clear_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	hint_button.pressed.connect(_on_hint_pressed)
	hint_button.icon = load("res://assets/UI/core/hints.png")
	hint_button.add_theme_constant_override("icon_max_width", 32)
	hint_button.text = ""
	_build_number_pad()
	_update_hint_display()
	_style_submit_button()

func _style_submit_button() -> void:
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(0.15, 0.5, 0.25, 1.0)
	normal.border_color = Color(0.3, 0.85, 0.45)
	normal.border_width_top = 2
	normal.border_width_bottom = 2
	normal.border_width_left = 2
	normal.border_width_right = 2
	normal.corner_radius_top_left = 8
	normal.corner_radius_top_right = 8
	normal.corner_radius_bottom_left = 8
	normal.corner_radius_bottom_right = 8
	submit_button.add_theme_stylebox_override("normal", normal)
	submit_button.add_theme_color_override("font_color", Color.WHITE)

	var hover = normal.duplicate()
	hover.bg_color = Color(0.2, 0.7, 0.35, 1.0)
	hover.border_color = Color(0.4, 1.0, 0.55)
	submit_button.add_theme_stylebox_override("hover", hover)

	var pressed_style = normal.duplicate()
	pressed_style.bg_color = Color(0.1, 0.38, 0.18, 1.0)
	submit_button.add_theme_stylebox_override("pressed", pressed_style)

func configure_puzzle(config: Dictionary) -> void:
	puzzle_config = config
	title_label.text = config.get("title", "Number Sequence Decoder")

	var context_text = config.get("context", "")
	context_label.text = context_text

	sequence = config.get("sequence", [])
	answers = config.get("answers", [])

	var hint_text = config.get("pattern_hint", "")
	pattern_hint_label.text = hint_text
	pattern_hint_label.visible = hint_text != ""

	# Build blank tracking
	blank_indices = []
	player_inputs = []
	for i in range(sequence.size()):
		if sequence[i] == null:
			blank_indices.append(i)
			player_inputs.append(null)

	_build_sequence_display()
	_select_blank(0)

	start_time = Time.get_ticks_msec() / 1000.0
	set_process(true)

func _build_sequence_display() -> void:
	# Clear old nodes
	for child in sequence_container.get_children():
		child.queue_free()
	blank_buttons.clear()

	var blank_idx = 0
	for i in range(sequence.size()):
		if sequence[i] != null:
			# Known number — show as label
			var lbl = Label.new()
			lbl.text = str(int(sequence[i]))
			lbl.add_theme_font_size_override("font_size", 42)
			lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.custom_minimum_size = Vector2(80, 70)
			sequence_container.add_child(lbl)
		else:
			# Blank — show as clickable button
			var btn = Button.new()
			btn.text = "?"
			btn.custom_minimum_size = Vector2(90, 70)
			btn.add_theme_font_size_override("font_size", 38)
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0.15, 0.25, 0.45, 1.0)
			style.border_color = Color(0.4, 0.65, 1.0)
			style.border_width_top = 2
			style.border_width_bottom = 2
			style.border_width_left = 2
			style.border_width_right = 2
			style.corner_radius_top_left = 8
			style.corner_radius_top_right = 8
			style.corner_radius_bottom_left = 8
			style.corner_radius_bottom_right = 8
			btn.add_theme_stylebox_override("normal", style)
			btn.add_theme_color_override("font_color", Color.WHITE)
			var captured_idx = blank_idx
			btn.pressed.connect(func(): _select_blank(captured_idx))
			sequence_container.add_child(btn)
			blank_buttons.append(btn)
			blank_idx += 1

		# Add arrow separator (except after last)
		if i < sequence.size() - 1:
			var arrow = Label.new()
			arrow.text = "→"
			arrow.add_theme_font_size_override("font_size", 28)
			arrow.add_theme_color_override("font_color", Color.WHITE)
			arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			arrow.custom_minimum_size = Vector2(36, 70)
			sequence_container.add_child(arrow)

func _build_number_pad() -> void:
	# Clear existing
	for child in number_pad.get_children():
		child.queue_free()

	number_pad.columns = 5

	# Number buttons: -9 to 9 (covers most sequence answers)
	# Layout: negative row then 0-9 row
	var pad_numbers: Array[String] = ["7", "8", "9", "0", "⌫",
					   "4", "5", "6", "-", " ",
					   "1", "2", "3", " ", " "]

	for val in pad_numbers:
		var btn = Button.new()
		if val == " ":
			btn.visible = false
			btn.custom_minimum_size = Vector2(70, 60)
			number_pad.add_child(btn)
			continue

		btn.text = val
		btn.custom_minimum_size = Vector2(70, 60)
		btn.add_theme_font_size_override("font_size", 26)

		var style = StyleBoxFlat.new()
		if val == "⌫":
			style.bg_color = Color(0.5, 0.2, 0.2, 1.0)
		elif val == "-":
			style.bg_color = Color(0.25, 0.25, 0.45, 1.0)
		else:
			style.bg_color = Color(0.2, 0.3, 0.5, 1.0)
		style.corner_radius_top_left = 6
		style.corner_radius_top_right = 6
		style.corner_radius_bottom_left = 6
		style.corner_radius_bottom_right = 6
		style.border_color = Color(0.35, 0.55, 0.85)
		style.border_width_top = 1
		style.border_width_bottom = 1
		style.border_width_left = 1
		style.border_width_right = 1
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_color_override("font_color", Color.WHITE)

		var hover = style.duplicate()
		hover.bg_color = style.bg_color.lightened(0.15)
		btn.add_theme_stylebox_override("hover", hover)

		if val == "⌫":
			btn.pressed.connect(_on_backspace)
		elif val == "-":
			btn.pressed.connect(_on_minus)
		else:
			btn.pressed.connect(func(): _on_digit_pressed(val))
		number_pad.add_child(btn)

func _select_blank(idx: int) -> void:
	current_blank = idx
	number_display = ""
	if player_inputs[idx] != null:
		number_display = str(int(player_inputs[idx]))
	_refresh_blank_buttons()

func _on_digit_pressed(digit: String) -> void:
	if number_display == "0":
		number_display = digit
	elif number_display == "-0":
		number_display = "-" + digit
	else:
		if number_display.length() < 6:
			number_display += digit
	_apply_current_input()

func _on_minus() -> void:
	if number_display == "" or number_display == "0":
		number_display = "-"
	elif number_display.begins_with("-"):
		number_display = number_display.substr(1)
	else:
		number_display = "-" + number_display
	_apply_current_input()

func _on_backspace() -> void:
	if number_display.length() > 0:
		number_display = number_display.substr(0, number_display.length() - 1)
	_apply_current_input()

func _apply_current_input() -> void:
	if number_display == "" or number_display == "-":
		player_inputs[current_blank] = null
	else:
		player_inputs[current_blank] = int(number_display)
	_refresh_blank_buttons()

	# Auto-advance to next blank if this one is filled and not "-" only
	if player_inputs[current_blank] != null and current_blank < blank_buttons.size() - 1:
		# Small delay before auto-advancing so user sees what they typed
		pass  # User can click next blank manually or stay

func _refresh_blank_buttons() -> void:
	for i in range(blank_buttons.size()):
		var btn = blank_buttons[i]
		if i == current_blank:
			# Selected blank — highlight in bright blue
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0.2, 0.45, 0.85, 1.0)
			style.border_color = Color(0.6, 0.9, 1.0)
			style.border_width_top = 3
			style.border_width_bottom = 3
			style.border_width_left = 3
			style.border_width_right = 3
			style.corner_radius_top_left = 8
			style.corner_radius_top_right = 8
			style.corner_radius_bottom_left = 8
			style.corner_radius_bottom_right = 8
			btn.add_theme_stylebox_override("normal", style)
			if player_inputs[i] != null:
				btn.text = str(int(player_inputs[i]))
				btn.add_theme_color_override("font_color", Color.WHITE)
			elif number_display == "-":
				btn.text = "-"
				btn.add_theme_color_override("font_color", Color.WHITE)
			else:
				btn.text = "?"
				btn.add_theme_color_override("font_color", Color.WHITE)
		else:
			# Other blanks
			var style = StyleBoxFlat.new()
			if player_inputs[i] != null:
				style.bg_color = Color(0.15, 0.4, 0.2, 1.0)
				style.border_color = Color(0.4, 0.9, 0.5)
				btn.add_theme_color_override("font_color", Color.WHITE)
				btn.text = str(int(player_inputs[i]))
			else:
				style.bg_color = Color(0.15, 0.25, 0.45, 1.0)
				style.border_color = Color(0.4, 0.65, 1.0)
				btn.add_theme_color_override("font_color", Color.WHITE)
				btn.text = "?"
			style.border_width_top = 2
			style.border_width_bottom = 2
			style.border_width_left = 2
			style.border_width_right = 2
			style.corner_radius_top_left = 8
			style.corner_radius_top_right = 8
			style.corner_radius_bottom_left = 8
			style.corner_radius_bottom_right = 8
			btn.add_theme_stylebox_override("normal", style)

func _on_clear_pressed() -> void:
	number_display = ""
	player_inputs[current_blank] = null
	_refresh_blank_buttons()

func _on_submit_pressed() -> void:
	# Check all blanks are filled
	for i in range(player_inputs.size()):
		if player_inputs[i] == null:
			_show_feedback("[color=red][b]Fill in all blanks before submitting![/b][/color]", false, true)
			return

	# Check answers
	var all_correct = true
	for i in range(player_inputs.size()):
		if player_inputs[i] != answers[i]:
			all_correct = false
			break

	var elapsed = Time.get_ticks_msec() / 1000.0 - start_time

	if all_correct:
		set_process(false)
		PlayerStats.add_xp(20)
		PlayerStats.add_score(100)

		# Speed bonus
		if elapsed < 60.0 and not hint_used:
			PlayerStats.add_hints(1)
			var bonus_text = "[color=white][b][img=28x28]res://assets/UI/core/speed_bonus.png[/img] Speed Bonus: +1 Hint![/b][/color]\n\n"
			var explanation = puzzle_config.get("explanation", "")
			_show_feedback(bonus_text + "[color=green][b][img=28x28]res://assets/UI/core/correct.png[/img] Correct![/b][/color]\n\n" + explanation, true, false)
		else:
			var explanation = puzzle_config.get("explanation", "")
			_show_feedback("[color=green][b][img=28x28]res://assets/UI/core/correct.png[/img] Correct! Pattern identified![/b][/color]\n\n" + explanation, true, false)

		ChapterStatsTracker.record_minigame_completed(elapsed < 60.0)
		emit_signal("minigame_completed", true, elapsed)
	else:
		# Highlight wrong answers in red, keep going
		_flash_wrong_blanks()
		_show_feedback("[color=red][b]Not quite. Check your pattern and try again.[/b][/color]", false, true)

func _flash_wrong_blanks() -> void:
	for i in range(player_inputs.size()):
		if player_inputs[i] != answers[i]:
			var btn = blank_buttons[i]
			var tween = create_tween()
			tween.tween_property(btn, "modulate", Color.RED, 0.15)
			tween.tween_property(btn, "modulate", Color.WHITE, 0.15)
			tween.tween_property(btn, "modulate", Color.RED, 0.15)
			tween.tween_property(btn, "modulate", Color.WHITE, 0.15)

func _show_feedback(text: String, success: bool, retry: bool) -> void:
	feedback_label.text = text
	feedback_overlay.show()
	feedback_panel.show()

	if continue_button.pressed.is_connected(_on_continue_pressed):
		continue_button.pressed.disconnect(_on_continue_pressed)

	if retry:
		continue_button.text = "Try Again"
		continue_button.pressed.connect(_on_retry_pressed)
	else:
		continue_button.text = "Continue"
		continue_button.pressed.connect(_on_continue_pressed)

func _on_retry_pressed() -> void:
	feedback_overlay.hide()
	feedback_panel.hide()
	if continue_button.pressed.is_connected(_on_retry_pressed):
		continue_button.pressed.disconnect(_on_retry_pressed)
	# Resume timer
	start_time = Time.get_ticks_msec() / 1000.0 - (time_limit - _get_remaining())
	set_process(true)

var _last_remaining: float = 0.0

func _get_remaining() -> float:
	return _last_remaining

func _on_continue_pressed() -> void:
	set_process(false)
	var elapsed = Time.get_ticks_msec() / 1000.0 - start_time
	emit_signal("minigame_completed", true, elapsed)
	queue_free()

func _on_hint_pressed() -> void:
	if not PlayerStats.use_hint():
		var lbl = Label.new()
		lbl.text = "No hints available!"
		lbl.add_theme_color_override("font_color", Color.RED)
		lbl.add_theme_font_size_override("font_size", 18)
		lbl.position = hint_button.global_position + Vector2(0, -35)
		add_child(lbl)
		await get_tree().create_timer(1.5).timeout
		if is_instance_valid(lbl):
			lbl.queue_free()
		return

	hint_used = true
	_update_hint_display()
	hint_button.disabled = true
	var hint_text = puzzle_config.get("hint_text", "Look at how each number changes from one step to the next. Is it adding, subtracting, multiplying, or something else? Find the pattern first, then apply it.")
	var overlay = CanvasLayer.new()
	overlay.set_script(load("res://scenes/ui/hint_overlay.gd"))
	get_tree().root.add_child(overlay)
	overlay.show_hint(hint_text)

func _update_hint_display() -> void:
	hint_counter.text = "Hints: %d" % PlayerStats.hints

func _process(delta: float) -> void:
	var elapsed = Time.get_ticks_msec() / 1000.0 - start_time
	var remaining = time_limit - elapsed
	_last_remaining = remaining

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
		timer_label.add_theme_color_override("font_color", Color.WHITE)
	else:
		timer_label.add_theme_color_override("font_color", Color.WHITE)

func _on_time_up() -> void:
	ChapterStatsTracker.record_minigame_failed()
	_show_feedback("[color=red][b]⏰ Time's Up![/b][/color]\n\nThe pattern was:\n" + _format_full_sequence(), false, false)
	emit_signal("minigame_completed", false, time_limit)

func _format_full_sequence() -> String:
	var result = ""
	var blank_idx = 0
	for i in range(sequence.size()):
		if i > 0:
			result += " → "
		if sequence[i] != null:
			result += str(int(sequence[i]))
		else:
			result += "[color=white]" + str(answers[blank_idx]) + "[/color]"
			blank_idx += 1
	return result

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F5:
		set_process(false)
		var elapsed = Time.get_ticks_msec() / 1000.0 - start_time
		ChapterStatsTracker.record_minigame_completed(elapsed < 60.0)
		emit_signal("minigame_completed", true, elapsed)
		queue_free()
