# Main.gd - Math Quiz Minigame
# A dedicated math problem-solving minigame with a clean educational interface
extends Control

signal game_finished(success: bool, score: int)

# Default questions (can be overridden via configure_puzzle)
var questions = [
	{
		"question": "Evaluate f(x) = 2x + 3 when x = 4",
		"correct": "11",
		"wrong": ["8", "14", "7"]
	},
	{
		"question": "What is log₁₀(100)?",
		"correct": "2",
		"wrong": ["1", "10", "100"]
	},
	{
		"question": "Simplify: 3² + 4²",
		"correct": "25",
		"wrong": ["12", "14", "49"]
	}
]

# Game state
var current_question = 0
var score = 0
var total_correct = 0
var game_over = false
var is_configured = false
var time_per_question = 15.0  # seconds per question
var time_remaining = 0.0
var timer_active = false

# UI Colors
const COLOR_CORRECT = Color(0.2, 0.7, 0.3)
const COLOR_INCORRECT = Color(0.8, 0.2, 0.2)
const COLOR_NORMAL = Color(0.25, 0.35, 0.55)
const COLOR_HOVER = Color(0.35, 0.45, 0.65)
const COLOR_CHALKBOARD = Color(0.15, 0.25, 0.2)
const COLOR_CHALK = Color(0.95, 0.95, 0.9)

# UI References
var question_label: Label
var progress_label: Label
var score_label: Label
var timer_label: Label
var timer_bar: ProgressBar
var answer_buttons: Array[Button] = []
var feedback_label: Label
var chalkboard: Panel

func _ready():
	_setup_ui()
	if not is_configured:
		start_game()

func configure_puzzle(config: Dictionary) -> void:
	if config.has("questions"):
		questions = config.questions
	if config.has("time_per_question"):
		time_per_question = config.time_per_question
	is_configured = true
	start_game()

func _setup_ui():
	# Main container - full screen
	set_anchors_preset(Control.PRESET_FULL_RECT)

	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.15, 0.2)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Main VBox container
	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 20)
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 50)
	margin.add_theme_constant_override("margin_right", 50)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	add_child(margin)
	margin.add_child(main_vbox)

	# Header section with title and stats
	var header = _create_header()
	main_vbox.add_child(header)

	# Chalkboard for question display
	chalkboard = _create_chalkboard()
	main_vbox.add_child(chalkboard)

	# Timer section
	var timer_section = _create_timer_section()
	main_vbox.add_child(timer_section)

	# Answer buttons grid
	var answers_section = _create_answers_section()
	main_vbox.add_child(answers_section)

	# Feedback label (hidden initially)
	feedback_label = Label.new()
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.add_theme_font_size_override("font_size", 32)
	feedback_label.visible = false
	main_vbox.add_child(feedback_label)

func _create_header() -> HBoxContainer:
	var header = HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 60)

	# Title
	var title = Label.new()
	title.text = "Math Challenge"
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", COLOR_CHALK)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	# Spacer
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)

	# Progress label
	progress_label = Label.new()
	progress_label.add_theme_font_size_override("font_size", 24)
	progress_label.add_theme_color_override("font_color", COLOR_CHALK)
	header.add_child(progress_label)

	# Score label
	score_label = Label.new()
	score_label.add_theme_font_size_override("font_size", 24)
	score_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	score_label.custom_minimum_size = Vector2(150, 0)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(score_label)

	return header

func _create_chalkboard() -> Panel:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(0, 200)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# Chalkboard style
	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_CHALKBOARD
	style.border_color = Color(0.4, 0.3, 0.2)
	style.set_border_width_all(8)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", style)

	# Center container for question
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(center)

	# Question label
	question_label = Label.new()
	question_label.add_theme_font_size_override("font_size", 32)
	question_label.add_theme_color_override("font_color", COLOR_CHALK)
	question_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	question_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	question_label.custom_minimum_size = Vector2(800, 0)
	center.add_child(question_label)

	return panel

func _create_timer_section() -> VBoxContainer:
	var section = VBoxContainer.new()
	section.add_theme_constant_override("separation", 5)

	# Timer label
	timer_label = Label.new()
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.add_theme_font_size_override("font_size", 20)
	timer_label.add_theme_color_override("font_color", COLOR_CHALK)
	section.add_child(timer_label)

	# Timer progress bar
	timer_bar = ProgressBar.new()
	timer_bar.custom_minimum_size = Vector2(0, 20)
	timer_bar.max_value = 100
	timer_bar.value = 100
	timer_bar.show_percentage = false

	# Style the progress bar
	var bar_bg = StyleBoxFlat.new()
	bar_bg.bg_color = Color(0.2, 0.2, 0.2)
	bar_bg.corner_radius_top_left = 4
	bar_bg.corner_radius_top_right = 4
	bar_bg.corner_radius_bottom_left = 4
	bar_bg.corner_radius_bottom_right = 4
	timer_bar.add_theme_stylebox_override("background", bar_bg)

	var bar_fill = StyleBoxFlat.new()
	bar_fill.bg_color = Color(0.3, 0.7, 0.4)
	bar_fill.corner_radius_top_left = 4
	bar_fill.corner_radius_top_right = 4
	bar_fill.corner_radius_bottom_left = 4
	bar_fill.corner_radius_bottom_right = 4
	timer_bar.add_theme_stylebox_override("fill", bar_fill)

	section.add_child(timer_bar)

	return section

func _create_answers_section() -> GridContainer:
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 15)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Create 4 answer buttons
	for i in range(4):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(400, 70)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 22)

		# Button style
		var normal_style = StyleBoxFlat.new()
		normal_style.bg_color = COLOR_NORMAL
		normal_style.corner_radius_top_left = 8
		normal_style.corner_radius_top_right = 8
		normal_style.corner_radius_bottom_left = 8
		normal_style.corner_radius_bottom_right = 8
		btn.add_theme_stylebox_override("normal", normal_style)

		var hover_style = StyleBoxFlat.new()
		hover_style.bg_color = COLOR_HOVER
		hover_style.corner_radius_top_left = 8
		hover_style.corner_radius_top_right = 8
		hover_style.corner_radius_bottom_left = 8
		hover_style.corner_radius_bottom_right = 8
		btn.add_theme_stylebox_override("hover", hover_style)

		var pressed_style = StyleBoxFlat.new()
		pressed_style.bg_color = COLOR_HOVER.darkened(0.2)
		pressed_style.corner_radius_top_left = 8
		pressed_style.corner_radius_top_right = 8
		pressed_style.corner_radius_bottom_left = 8
		pressed_style.corner_radius_bottom_right = 8
		btn.add_theme_stylebox_override("pressed", pressed_style)

		btn.pressed.connect(_on_answer_selected.bind(i))
		grid.add_child(btn)
		answer_buttons.append(btn)

	return grid

func start_game():
	game_over = false
	current_question = 0
	score = 0
	total_correct = 0
	_update_ui()
	load_question()

func load_question():
	if current_question >= questions.size():
		show_victory()
		return

	var q = questions[current_question]
	question_label.text = q.question

	# Prepare answers
	var all_answers = q.wrong.duplicate()
	all_answers.append(q.correct)
	all_answers.shuffle()

	# Set button text and store correct answer index
	for i in range(answer_buttons.size()):
		if i < all_answers.size():
			answer_buttons[i].text = all_answers[i]
			answer_buttons[i].visible = true
			answer_buttons[i].disabled = false
			# Reset button color
			_reset_button_style(answer_buttons[i])
			# Store whether this is correct
			answer_buttons[i].set_meta("is_correct", all_answers[i] == q.correct)
			answer_buttons[i].set_meta("answer_text", all_answers[i])
		else:
			answer_buttons[i].visible = false

	# Reset and start timer
	time_remaining = time_per_question
	timer_active = true
	feedback_label.visible = false

	_update_ui()

func _on_answer_selected(button_index: int):
	if game_over or not timer_active:
		return

	timer_active = false
	var btn = answer_buttons[button_index]
	var is_correct = btn.get_meta("is_correct")

	# Disable all buttons
	for b in answer_buttons:
		b.disabled = true

	if is_correct:
		_handle_correct_answer(btn)
	else:
		_handle_wrong_answer(btn)

func _handle_correct_answer(btn: Button):
	total_correct += 1
	# Bonus points based on time remaining
	var time_bonus = int(time_remaining / time_per_question * 50)
	var question_score = 100 + time_bonus
	score += question_score

	# Visual feedback
	_set_button_color(btn, COLOR_CORRECT)
	feedback_label.text = "Correct! +" + str(question_score) + " points"
	feedback_label.add_theme_color_override("font_color", COLOR_CORRECT)
	feedback_label.visible = true

	# Show correct answer highlight on all buttons
	for b in answer_buttons:
		if b.get_meta("is_correct"):
			_set_button_color(b, COLOR_CORRECT)

	_update_ui()

	# Move to next question after delay
	await get_tree().create_timer(1.5).timeout
	current_question += 1
	load_question()

func _handle_wrong_answer(btn: Button):
	# Visual feedback
	_set_button_color(btn, COLOR_INCORRECT)
	feedback_label.text = "Incorrect!"
	feedback_label.add_theme_color_override("font_color", COLOR_INCORRECT)
	feedback_label.visible = true

	# Show correct answer
	for b in answer_buttons:
		if b.get_meta("is_correct"):
			_set_button_color(b, COLOR_CORRECT)

	_update_ui()

	# Move to next question after delay
	await get_tree().create_timer(2.0).timeout
	current_question += 1
	load_question()

func _handle_timeout():
	timer_active = false

	# Disable all buttons
	for b in answer_buttons:
		b.disabled = true

	feedback_label.text = "Time's up!"
	feedback_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	feedback_label.visible = true

	# Show correct answer
	for b in answer_buttons:
		if b.get_meta("is_correct"):
			_set_button_color(b, COLOR_CORRECT)

	# Move to next question after delay
	await get_tree().create_timer(2.0).timeout
	current_question += 1
	load_question()

func _set_button_color(btn: Button, color: Color):
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_stylebox_override("disabled", style)

func _reset_button_style(btn: Button):
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = COLOR_NORMAL
	normal_style.corner_radius_top_left = 8
	normal_style.corner_radius_top_right = 8
	normal_style.corner_radius_bottom_left = 8
	normal_style.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", normal_style)

	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = COLOR_HOVER
	hover_style.corner_radius_top_left = 8
	hover_style.corner_radius_top_right = 8
	hover_style.corner_radius_bottom_left = 8
	hover_style.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("hover", hover_style)

func _update_ui():
	progress_label.text = "Question " + str(current_question + 1) + " / " + str(questions.size())
	score_label.text = "Score: " + str(score)

func _process(delta):
	if timer_active and not game_over:
		time_remaining -= delta

		# Update timer display
		timer_label.text = "Time: " + str(int(time_remaining)) + "s"
		timer_bar.value = (time_remaining / time_per_question) * 100

		# Change timer bar color based on time remaining
		var fill_style = timer_bar.get_theme_stylebox("fill").duplicate()
		if fill_style is StyleBoxFlat:
			if time_remaining > time_per_question * 0.5:
				fill_style.bg_color = Color(0.3, 0.7, 0.4)
			elif time_remaining > time_per_question * 0.25:
				fill_style.bg_color = Color(0.9, 0.7, 0.2)
			else:
				fill_style.bg_color = Color(0.8, 0.3, 0.2)
			timer_bar.add_theme_stylebox_override("fill", fill_style)

		if time_remaining <= 0:
			_handle_timeout()

func show_victory():
	game_over = true
	timer_active = false

	# Calculate final score and success
	var success = total_correct >= questions.size() / 2  # Pass if at least 50% correct
	var percentage = int((float(total_correct) / questions.size()) * 100)

	# Update display
	question_label.text = "Quiz Complete!\n\nCorrect: " + str(total_correct) + "/" + str(questions.size()) + " (" + str(percentage) + "%)\nFinal Score: " + str(score)

	# Hide answer buttons
	for btn in answer_buttons:
		btn.visible = false

	# Show result feedback
	if success:
		feedback_label.text = "Great job!"
		feedback_label.add_theme_color_override("font_color", COLOR_CORRECT)
	else:
		feedback_label.text = "Keep practicing!"
		feedback_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	feedback_label.visible = true

	# Hide timer
	timer_label.visible = false
	timer_bar.visible = false

	# Wait and then emit signal
	await get_tree().create_timer(3.0).timeout
	game_finished.emit(success, score)
	await get_tree().process_frame
	queue_free()
