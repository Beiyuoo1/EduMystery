extends Control

## Detective Analysis Minigame
## Context-integrated minigame for Math and Science reasoning
## Shows evidence, presents problem, asks for analytical solution

# UI Nodes
@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var context_label: RichTextLabel = $Panel/VBox/ContextLabel
@onready var evidence_panel: Panel = $Panel/VBox/EvidencePanel
@onready var evidence_image: TextureRect = $Panel/VBox/EvidencePanel/EvidenceImage
@onready var evidence_caption: Label = $Panel/VBox/EvidencePanel/CaptionLabel
@onready var question_label: RichTextLabel = $Panel/VBox/QuestionLabel
@onready var choices_container: VBoxContainer = $Panel/VBox/ChoicesContainer
@onready var timer_label: Label = $Panel/VBox/HBox/TimerLabel
@onready var hint_button: Button = $Panel/VBox/HBox/HintButton
@onready var hint_counter: Label = $Panel/VBox/HBox/HintCounter
@onready var feedback_panel: NinePatchRect = $FeedbackPanel
@onready var feedback_label: RichTextLabel = $FeedbackPanel/VBox/FeedbackLabel
@onready var continue_button: Button = $FeedbackPanel/VBox/ContinueButton

# Minigame data
var puzzle_config: Dictionary = {}
var correct_answer_index: int = -1
var selected_answer: int = -1
var start_time: float = 0.0
var time_limit: float = 90.0  # 1:30 timer
var hint_used: bool = false

# Choice buttons
var choice_buttons: Array[Button] = []

# Countdown overlay
var countdown_overlay: ColorRect
var countdown_label: Label

const SFX_PATH := "res://assets/audio/sound_effect/timeline_analysis_minigame/"

signal minigame_completed(success: bool, time_taken: float)


func _ready() -> void:
	set_process(false)  # Timer must NOT start until after countdown

	# Hide feedback panel initially
	feedback_panel.hide()

	# Connect hint button
	hint_button.pressed.connect(_on_hint_pressed)

	# Connect continue button
	continue_button.pressed.connect(_on_continue_pressed)

	# Update hint counter
	_update_hint_display()

	# Create countdown overlay
	_create_countdown_overlay()


func _create_countdown_overlay() -> void:
	countdown_overlay = ColorRect.new()
	countdown_overlay.color = Color(0, 0, 0, 0.6)
	countdown_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	countdown_overlay.z_index = 150
	countdown_overlay.hide()
	add_child(countdown_overlay)

	countdown_label = Label.new()
	countdown_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	countdown_label.add_theme_font_size_override("font_size", 120)
	countdown_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	countdown_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	countdown_label.add_theme_constant_override("outline_size", 8)
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	countdown_overlay.add_child(countdown_label)

	await get_tree().process_frame
	countdown_label.pivot_offset = countdown_label.size / 2.0


func _play_countdown() -> void:
	countdown_overlay.show()

	var steps = [["3", Color(0.9, 0.3, 0.3, 1)], ["2", Color(0.9, 0.7, 0.2, 1)], ["1", Color(0.3, 0.85, 0.4, 1)], ["START!", Color(1, 1, 1, 1)]]

	countdown_label.pivot_offset = countdown_label.size / 2.0

	for step in steps:
		var text = step[0]
		var color = step[1]
		countdown_label.text = text
		countdown_label.add_theme_color_override("font_color", color)
		countdown_label.scale = Vector2(1.5, 1.5)
		countdown_label.modulate.a = 1.0

		match text:
			"3": _play_sfx(SFX_PATH + "three.mp3")
			"2": _play_sfx(SFX_PATH + "two.mp3")
			"1": _play_sfx(SFX_PATH + "one.mp3")
			"START!":
				_play_sfx(SFX_PATH + "start.mp3")
				_play_sfx(SFX_PATH + "Whistle.mp3")

		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(countdown_label, "scale", Vector2(1.0, 1.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		if text == "START!":
			tween.tween_property(countdown_label, "modulate:a", 0.0, 0.6).set_delay(0.4)
		await get_tree().create_timer(0.8).timeout

	countdown_overlay.hide()


func configure_puzzle(config: Dictionary) -> void:
	"""Configure the puzzle with provided data structure"""
	puzzle_config = config

	# Set title
	title_label.text = config.get("title", "Detective Analysis")

	# Set context story
	context_label.text = config.get("context", "Analyze the evidence and solve the problem.")

	# Set evidence image if provided
	if config.has("evidence_image"):
		var img_path = config["evidence_image"]
		if ResourceLoader.exists(img_path):
			evidence_image.texture = load(img_path)
			evidence_panel.show()
	else:
		evidence_panel.hide()

	# Set evidence caption
	if config.has("evidence_caption"):
		evidence_caption.text = config["evidence_caption"]

	# Set question
	question_label.text = config.get("question", "What is the answer?")

	# Set correct answer index
	correct_answer_index = config.get("correct_index", 0)

	# Create choice buttons
	var choices = config.get("choices", [])
	_create_choice_buttons(choices)

	# Play countdown then start timer
	await _play_countdown()
	start_time = Time.get_ticks_msec() / 1000.0
	set_process(true)


func _create_choice_buttons(choices: Array) -> void:
	"""Create choice buttons dynamically"""
	# Clear existing buttons
	for button in choice_buttons:
		button.queue_free()
	choice_buttons.clear()

	# Create new buttons
	for i in range(choices.size()):
		var button = Button.new()
		button.text = choices[i]
		button.custom_minimum_size = Vector2(800, 60)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT

		# Style button
		var style_normal = StyleBoxFlat.new()
		style_normal.bg_color = Color(0.2, 0.25, 0.35, 0.9)
		style_normal.border_width_left = 3
		style_normal.border_width_top = 3
		style_normal.border_width_right = 3
		style_normal.border_width_bottom = 3
		style_normal.border_color = Color(0.4, 0.5, 0.6, 1.0)
		style_normal.corner_radius_top_left = 8
		style_normal.corner_radius_top_right = 8
		style_normal.corner_radius_bottom_left = 8
		style_normal.corner_radius_bottom_right = 8
		button.add_theme_stylebox_override("normal", style_normal)

		var style_hover = style_normal.duplicate()
		style_hover.bg_color = Color(0.3, 0.4, 0.5, 1.0)
		style_hover.border_color = Color(0.6, 0.7, 0.8, 1.0)
		button.add_theme_stylebox_override("hover", style_hover)

		# Connect signal with closure
		var index = i
		button.pressed.connect(func(): _on_choice_selected(index))

		choices_container.add_child(button)
		choice_buttons.append(button)


func _process(delta: float) -> void:
	"""Update timer every frame"""
	var elapsed = Time.get_ticks_msec() / 1000.0 - start_time
	var remaining = time_limit - elapsed

	if remaining <= 0:
		remaining = 0
		_on_time_up()

	# Format timer (MM:SS)
	var minutes = int(remaining) / 60
	var seconds = int(remaining) % 60
	timer_label.text = "Time: %02d:%02d" % [minutes, seconds]

	# Color warnings
	if remaining <= 10:
		timer_label.add_theme_color_override("font_color", Color.RED)
	elif remaining <= 30:
		timer_label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		timer_label.add_theme_color_override("font_color", Color.WHITE)


func _on_choice_selected(index: int) -> void:
	"""Handle choice selection"""
	if selected_answer != -1:
		return  # Already answered

	selected_answer = index
	set_process(false)  # Stop timer

	# Calculate time taken
	var elapsed = Time.get_ticks_msec() / 1000.0 - start_time

	# Check if correct
	var is_correct = (index == correct_answer_index)

	# Show feedback
	_show_feedback(is_correct, elapsed)


func _play_sfx(path: String) -> void:
	var player = AudioStreamPlayer.new()
	player.stream = load(path)
	player.bus = "SFX"
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func _show_feedback(is_correct: bool, time_taken: float) -> void:
	"""Show feedback panel with result"""
	if is_correct:
		_play_sfx("res://assets/audio/sound_effect/correct.wav")
	else:
		_play_sfx("res://assets/audio/sound_effect/wrong.wav")
	# Highlight correct/wrong answer
	if is_correct:
		choice_buttons[selected_answer].add_theme_color_override("font_color", Color.GREEN)
	else:
		choice_buttons[selected_answer].add_theme_color_override("font_color", Color.RED)
		# Also highlight the correct answer
		choice_buttons[correct_answer_index].add_theme_color_override("font_color", Color.GREEN)

	# Build feedback message
	var feedback_text = ""
	if is_correct:
		feedback_text = "[center][color=green][b]✓ CORRECT![/b][/color][/center]\n\n"
	else:
		feedback_text = "[center][color=red][b]✗ INCORRECT[/b][/color][/center]\n\n"

	# Add explanation
	if puzzle_config.has("explanation"):
		feedback_text += puzzle_config["explanation"]

	feedback_label.text = feedback_text

	# Show feedback panel
	feedback_panel.show()

	# Award speed bonus if correct and fast
	if is_correct and time_taken < 60.0 and not hint_used:
		PlayerStats.add_hints(1)
		feedback_label.text += "\n\n[center][color=yellow]⚡ Speed Bonus: +1 Hint! ⚡[/color][/center]"


func _on_continue_pressed() -> void:
	"""Continue to next scene"""
	var is_correct = (selected_answer == correct_answer_index)
	var elapsed = Time.get_ticks_msec() / 1000.0 - start_time

	minigame_completed.emit(is_correct, elapsed)

	# Close minigame
	queue_free()


func _on_time_up() -> void:
	"""Handle time running out"""
	set_process(false)

	# Auto-select wrong answer (time out = failure)
	selected_answer = -1

	feedback_label.text = "[center][color=red][b]⏱ TIME'S UP![/b][/color][/center]\n\n"
	feedback_label.text += "You ran out of time to analyze the evidence.\n\n"
	feedback_label.text += "[b]Correct Answer:[/b] " + puzzle_config["choices"][correct_answer_index]

	if puzzle_config.has("explanation"):
		feedback_label.text += "\n\n" + puzzle_config["explanation"]

	feedback_panel.show()

	# Highlight correct answer
	choice_buttons[correct_answer_index].add_theme_color_override("font_color", Color.GREEN)


func _on_hint_pressed() -> void:
	"""Use hint to highlight correct answer"""
	if PlayerStats.use_hint():
		hint_used = true
		_update_hint_display()

		# Highlight correct answer with yellow pulsing animation
		var correct_button = choice_buttons[correct_answer_index]
		var tween = create_tween()
		tween.set_loops(3)
		tween.tween_property(correct_button, "modulate", Color.YELLOW, 0.3)
		tween.tween_property(correct_button, "modulate", Color.WHITE, 0.3)

		# Disable hint button
		hint_button.disabled = true
	else:
		# Show "no hints" message
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
	"""Handle F5 skip and ESC pause"""
	# Check if action exists before using it (defensive programming)
	if InputMap.has_action("skip_minigame") and event.is_action_pressed("skip_minigame"):  # F5
		print("Detective Analysis: F5 pressed - skipping minigame")
		# Auto-complete with correct answer
		selected_answer = correct_answer_index
		set_process(false)

		var elapsed = Time.get_ticks_msec() / 1000.0 - start_time
		minigame_completed.emit(true, elapsed)
		queue_free()

		get_viewport().set_input_as_handled()
