extends Control

# Signal to notify the main game when the puzzle is done
signal game_finished(success: bool, score: int)

# --- Puzzle Data (now dynamic) ---
# Default puzzle data - can be overridden via configure_puzzle()
var puzzle_data = {
	"sentence_parts": [
		"A function assigns each ", # Part 1
		" to exactly one ",          # Part 2
		"."                          # Part 3
	],
	"answers": ["input", "output"],
	"choices": [
		"input", "output", "domain", "range",
		"variable", "constant", "equation", "value"
	],
	"title": "Complete the Sentence",
	"subtitle": "Drag the correct words into the blanks",
	"context": ""
}

var is_configured = false
var is_ready = false

# --- Node Paths ---
var header_path = "CanvasLayer/TextureRect/CenterContainer/PanelContainer/"
var header_path2 = "AspectRatioContainer/MarginContainer/VBoxContainer/ColorRect/MarginContainer/VBoxContainer/"
var content_path = "CanvasLayer/TextureRect/CenterContainer/PanelContainer/"
var content_path2 = "AspectRatioContainer/MarginContainer/VBoxContainer/"

@onready var sentence_line = get_node(content_path + content_path2 + "HBoxContainer")
@onready var choices_grid = get_node(content_path + content_path2 + "GridContainer")
@onready var drop_zone_1 = get_node(content_path + content_path2 + "HBoxContainer/drop1")
@onready var texture_rect = $CanvasLayer/TextureRect

# Header labels (now configurable)
@onready var timer_label = get_node(header_path + header_path2 + "HBoxContainer/TimerLabel")
@onready var hint_button = get_node(header_path + header_path2 + "HBoxContainer/HintButton")
@onready var hint_label = get_node(header_path + header_path2 + "HBoxContainer/HintLabel")
@onready var title_label = get_node(header_path + header_path2 + "TitleLabel")
@onready var subtitle_label = get_node(header_path + header_path2 + "SubtitleLabel")
@onready var context_label = get_node(header_path + header_path2 + "ContextLabel")

# Timer
var time_remaining: float = 90.0  # 1:30 in seconds
var timer_active: bool = false

# Hint system
var hint_on_cooldown: bool = false
const HINT_COOLDOWN: float = 12.0

# Time tracking for bonus hint
var start_time: float = 0.0
const TIME_BONUS_THRESHOLD: float = 60.0  # Complete within 1 minute for bonus hint

var correct_drops = 0
const TOTAL_DROPS = 1
const TILE_SCRIPT = preload("res://minigames/Drag/scripts/Tile.gd")
const DROP_SCRIPT = preload("res://minigames/Drag/scripts/DropZone.gd")

# Tutorial / countdown nodes
@onready var tutorial_overlay: Control = $CanvasLayer/TutorialOverlay
@onready var tut_start_button: Button = $CanvasLayer/TutorialOverlay/TutPanel/VBox/StartButton
@onready var countdown_overlay: Control = $CanvasLayer/CountdownOverlay
@onready var countdown_label: Label = $CanvasLayer/CountdownOverlay/CountdownLabel

# Countdown sfx paths
const SFX_THREE = "res://assets/audio/sound_effect/timeline_analysis_minigame/three.mp3"
const SFX_TWO   = "res://assets/audio/sound_effect/timeline_analysis_minigame/two.mp3"
const SFX_ONE   = "res://assets/audio/sound_effect/timeline_analysis_minigame/one.mp3"
const SFX_START = "res://assets/audio/sound_effect/timeline_analysis_minigame/start.mp3"

func _ready():
	is_ready = true
	# Quick fade-in for smooth transition
	texture_rect.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(texture_rect, "modulate:a", 1.0, 0.15)

	# Update hint display from PlayerStats
	_update_hint_display()

	# Connect hint button and set icon
	if hint_button:
		hint_button.pressed.connect(_on_hint_button_pressed)
		hint_button.icon = load("res://assets/UI/core/hints.png")
		hint_button.add_theme_constant_override("icon_max_width", 32)
		hint_button.text = ""
		hint_button.add_theme_constant_override("icon_margin_left", 0)
		hint_button.add_theme_constant_override("icon_margin_right", 0)
		hint_button.add_theme_constant_override("icon_margin_top", 0)
		hint_button.add_theme_constant_override("icon_margin_bottom", 0)
		hint_button.add_theme_constant_override("h_separation", 0)

	# Connect tutorial start button
	tut_start_button.pressed.connect(_on_tutorial_done)

	# Hide countdown until needed
	if countdown_overlay:
		countdown_overlay.hide()

	# Show tutorial on first time, otherwise go straight to countdown
	if not TutorialFlags.has_seen("fill_in_blank"):
		tutorial_overlay.show()
	else:
		tutorial_overlay.hide()
		_start_countdown()

	# Initialize puzzle now that nodes are ready
	_initialize_puzzle()

func _on_tutorial_done() -> void:
	TutorialFlags.mark_seen("fill_in_blank")
	tutorial_overlay.hide()
	_start_countdown()

func _start_countdown() -> void:
	if countdown_overlay == null:
		_start_game()
		return
	countdown_overlay.show()
	await _countdown_step("3", SFX_THREE)
	await _countdown_step("2", SFX_TWO)
	await _countdown_step("1", SFX_ONE)
	await _countdown_step("START!", SFX_START)
	countdown_overlay.hide()
	_start_game()

func _countdown_step(text: String, sfx_path: String) -> void:
	if countdown_label:
		countdown_label.text = text
	_play_countdown_sfx(sfx_path)
	await get_tree().create_timer(1.0).timeout

func _play_countdown_sfx(path: String) -> void:
	if OS.get_name() == "Web":
		DialogicSignalHandler.play_web_sfx(path)
		return
	var player = AudioStreamPlayer.new()
	player.stream = load(path)
	player.bus = "SFX"
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func _start_game() -> void:
	start_time = Time.get_ticks_msec() / 1000.0
	timer_active = true

func _unhandled_input(event):
	# F5 to skip minigame
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F5:
			print("F5 pressed - Skipping fill-in-the-blank minigame")
			_skip_minigame()

func _process(delta):
	if timer_active:
		time_remaining -= delta
		_update_timer_display()

		if time_remaining <= 0:
			_on_time_up()

func _update_timer_display():
	if timer_label:
		var minutes = int(time_remaining) / 60
		var seconds = int(time_remaining) % 60
		timer_label.text = "%d:%02d" % [minutes, seconds]

		# Change color when time is running low
		if time_remaining <= 10:
			timer_label.add_theme_color_override("font_color", Color.RED)
		elif time_remaining <= 30:
			timer_label.add_theme_color_override("font_color", Color.YELLOW)

func _update_hint_display():
	if hint_label:
		hint_label.text = "Hints: %d" % PlayerStats.hints

func _on_hint_button_pressed():
	if hint_on_cooldown:
		return

	if not PlayerStats.use_hint():
		if hint_button:
			hint_button.icon = null
			hint_button.text = "No hints!"
			await get_tree().create_timer(1.0).timeout
			hint_button.text = ""
			hint_button.icon = load("res://assets/UI/core/hints.png")
			hint_button.add_theme_constant_override("icon_max_width", 32)
		return

	_update_hint_display()
	_show_hint_overlay()

	# 12-second cooldown between uses
	hint_on_cooldown = true
	if hint_button:
		hint_button.disabled = true
	await get_tree().create_timer(HINT_COOLDOWN).timeout
	hint_on_cooldown = false
	if hint_button and not is_queued_for_deletion():
		hint_button.disabled = false

func _show_hint_overlay():
	var hint_text = puzzle_data.get("hint_text", "Think carefully about the context of the sentence and the meaning of each word choice.")
	var overlay = CanvasLayer.new()
	overlay.set_script(load("res://scenes/ui/hint_overlay.gd"))
	get_tree().root.add_child(overlay)
	overlay.show_hint(hint_text)

func _on_time_up():
	timer_active = false
	if timer_label:
		timer_label.text = "0:00"
		timer_label.add_theme_color_override("font_color", Color.RED)

	print("Time's up! Resetting for retry.")

	# Show time-up feedback briefly, then reset for retry
	if title_label:
		var prev_text = title_label.text
		var prev_color = title_label.get_theme_color("font_color") if title_label.has_theme_color("font_color", "") else Color.WHITE
		title_label.text = "Time's up! Try again!"
		title_label.add_theme_color_override("font_color", Color.ORANGE)
		await get_tree().create_timer(2.0).timeout
		if not is_queued_for_deletion():
			title_label.text = prev_text
			title_label.remove_theme_color_override("font_color")

	if is_queued_for_deletion():
		return

	# Reset timer and restart
	time_remaining = 90.0
	if timer_label:
		timer_label.remove_theme_color_override("font_color")
	timer_active = true

# Configure puzzle with external data from MinigameManager
func configure_puzzle(config: Dictionary) -> void:
	puzzle_data = {
		"sentence_parts": config.get("sentence_parts", []),
		"answers": config.get("answers", []),
		"choices": config.get("choices", []),
		"title": config.get("title", "Complete the Sentence"),
		"subtitle": config.get("subtitle", "Drag the correct words into the blanks"),
		"context": config.get("context", "")
	}
	is_configured = true
	# Only initialize if _ready() has already run, otherwise _ready() will handle it
	if is_ready:
		_initialize_puzzle()

func _initialize_puzzle():
	print("DEBUG: Initializing puzzle with sentence_parts: ", puzzle_data.sentence_parts)
	print("DEBUG: Answers: ", puzzle_data.answers)
	print("DEBUG: Choices: ", puzzle_data.choices)

	# 0. Set header labels if configured
	if puzzle_data.has("title"):
		title_label.text = puzzle_data.title
	if puzzle_data.has("subtitle"):
		subtitle_label.text = puzzle_data.subtitle
	if puzzle_data.has("context"):
		context_label.text = puzzle_data.context

	# 1. Set the sentence labels (supports 1-blank puzzle with 2 sentence parts)
	var labels = sentence_line.get_children().filter(func(c): return c is Label)
	print("DEBUG: Found ", labels.size(), " labels in sentence_line")
	# Make sentence_line expand to full width of its parent
	sentence_line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sentence_line.alignment = BoxContainer.ALIGNMENT_CENTER

	if labels.size() >= 2 and puzzle_data.sentence_parts.size() >= 2:
		print("DEBUG: Setting label 0 to: ", puzzle_data.sentence_parts[0])
		labels[0].text = puzzle_data.sentence_parts[0]
		labels[0].autowrap_mode = TextServer.AUTOWRAP_OFF
		labels[0].size_flags_horizontal = Control.SIZE_SHRINK_END
		print("DEBUG: Setting label 1 to: ", puzzle_data.sentence_parts[1])
		labels[1].text = puzzle_data.sentence_parts[1]
		labels[1].autowrap_mode = TextServer.AUTOWRAP_OFF
		labels[1].size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	else:
		print("ERROR: Label count (", labels.size(), ") or sentence_parts count (", puzzle_data.sentence_parts.size(), ") mismatch!")

	# 2. Attach and initialize Drop Zone scripts
	drop_zone_1.set_script(DROP_SCRIPT)
	drop_zone_1.expected_answer = puzzle_data.answers[0]
	drop_zone_1.minigame_scene = self
	drop_zone_1.name = "DropZone1"


	# 3. Initialize Draggable Tiles
	var choices = puzzle_data.choices.duplicate()
	choices.shuffle()

	for i in range(choices_grid.get_child_count()):
		var tile_rect = choices_grid.get_child(i)
		if i < choices.size():
			tile_rect.set_script(TILE_SCRIPT)
			tile_rect.word_data = choices[i]
			var label = tile_rect.get_node("Label")
			label.text = choices[i]
			# Force center alignment
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		else:
			tile_rect.visible = false

func check_win_condition(correctly_dropped):
	if correctly_dropped:
		correct_drops += 1

	if correct_drops == TOTAL_DROPS:
		_complete_puzzle()

func _skip_minigame():
	"""Skip the minigame when F5 is pressed"""
	print("Skipping fill-in-the-blank minigame...")
	timer_active = false
	_complete_puzzle()

func _complete_puzzle():
	"""Complete the puzzle and show results"""
	# Stop timer
	timer_active = false

	# Check for speed bonus (completed in under 60 seconds)
	var completion_time = (Time.get_ticks_msec() / 1000.0) - start_time
	var earned_bonus = false
	if completion_time < TIME_BONUS_THRESHOLD:
		PlayerStats.add_hints(1)
		earned_bonus = true
		print("⚡ Speed Bonus: +1 Hint! ⚡")

	# Win condition achieved!
	print("Puzzle Solved!")

	# Show bonus message if earned
	if earned_bonus and title_label:
		title_label.text = "Speed Bonus: +1 Hint!"
		title_label.add_theme_color_override("font_color", Color.YELLOW)

	# Brief delay to show bonus message
	if earned_bonus:
		await get_tree().create_timer(1.5).timeout

	# Fade out before emitting signal and closing
	var tween = create_tween()
	tween.tween_property(texture_rect, "modulate:a", 0.0, 0.2)
	await tween.finished
	# Emit signal AFTER fade completes but BEFORE queue_free
	emit_signal("game_finished", true, 100)
	# Small delay to ensure signal is processed
	await get_tree().process_frame
	queue_free()
