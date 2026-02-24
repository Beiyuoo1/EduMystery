extends CanvasLayer

# Node references
@onready var timer_label = $Control/MainContainer/VBoxContainer/HeaderContainer/TimerLabel
@onready var hint_button = $Control/MainContainer/VBoxContainer/HeaderContainer/HintButton
@onready var hint_label = $Control/MainContainer/VBoxContainer/HeaderContainer/HintLabel
@onready var title_label = $Control/MainContainer/VBoxContainer/InstructionPanel/MarginContainer/VBoxContainer/TitleLabel
@onready var instruction_label = $Control/MainContainer/VBoxContainer/InstructionPanel/MarginContainer/VBoxContainer/InstructionLabel
@onready var sentence_container = $Control/MainContainer/VBoxContainer/SentenceContainer
@onready var sentence_label = $Control/MainContainer/VBoxContainer/SentenceContainer/SentenceLabel
@onready var speaker_button = $Control/MainContainer/VBoxContainer/SentenceContainer/SpeakerButton
@onready var choices_container = $Control/MainContainer/VBoxContainer/ChoicesContainer
@onready var feedback_label = $Control/MainContainer/VBoxContainer/FeedbackLabel
@onready var countdown_overlay = $Control/CountdownOverlay
@onready var countdown_label = $Control/CountdownOverlay/CountdownLabel
@onready var tutorial_overlay = $Control/TutorialOverlay
@onready var tutorial_label = $Control/TutorialOverlay/MarginContainer/VBoxContainer/TutorialLabel
@onready var tutorial_ok_button = $Control/TutorialOverlay/MarginContainer/VBoxContainer/OkButton

# Choice buttons (8 buttons in 2 rows of 4)
@onready var choice_buttons = [
	$Control/MainContainer/VBoxContainer/ChoicesContainer/Row1/Choice1,
	$Control/MainContainer/VBoxContainer/ChoicesContainer/Row1/Choice2,
	$Control/MainContainer/VBoxContainer/ChoicesContainer/Row1/Choice3,
	$Control/MainContainer/VBoxContainer/ChoicesContainer/Row1/Choice4,
	$Control/MainContainer/VBoxContainer/ChoicesContainer/Row2/Choice5,
	$Control/MainContainer/VBoxContainer/ChoicesContainer/Row2/Choice6,
	$Control/MainContainer/VBoxContainer/ChoicesContainer/Row2/Choice7,
	$Control/MainContainer/VBoxContainer/ChoicesContainer/Row2/Choice8
]

# Timer
var time_remaining: float = 90.0  # 1:30 in seconds
var timer_active: bool = false

# Puzzle configuration
var puzzle_config: Dictionary = {}
var sentence_text: String = "Sir, does this room have a dedicated ____ router?"
var blank_word: String = "WiFi"
var correct_answer_index: int = 2  # "WiFi" is at index 2
var choices: Array = ["Hi-fi", "Sci-fi", "WiFi", "Bye-bye", "Fly high", "Sky high", "Pie-fry", "Why try"]

# Hint system
var hint_on_cooldown: bool = false  # 12-second cooldown between uses
const HINT_COOLDOWN: float = 12.0
# Tracks buttons permanently eliminated by hint — never re-enabled
var hint_eliminated_indices: Array = []

# Time tracking for bonus hint
var start_time: float = 0.0
const TIME_BONUS_THRESHOLD: float = 60.0  # Complete within 1 minute for bonus hint

# Audio system
var tts_player: AudioStreamPlayer = null

# Countdown sfx paths
const SFX_THREE = "res://assets/audio/sound_effect/timeline_analysis_minigame/three.mp3"
const SFX_TWO   = "res://assets/audio/sound_effect/timeline_analysis_minigame/two.mp3"
const SFX_ONE   = "res://assets/audio/sound_effect/timeline_analysis_minigame/one.mp3"
const SFX_START = "res://assets/audio/sound_effect/timeline_analysis_minigame/start.mp3"

signal minigame_completed(success: bool)

func _ready():
	print("DEBUG: HearAndFill minigame _ready() called")
	visible = true
	_verify_nodes()
	_setup_ui()
	_connect_buttons()
	_setup_tts()

	# Block input during tutorial/countdown
	_set_choices_interactable(false)
	hint_button.disabled = true

	# Show tutorial first, then countdown
	_show_tutorial()

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F5:
			print("F5 pressed - Skipping hear and fill minigame")
			_skip_minigame()

func _verify_nodes():
	if timer_label == null: push_error("HearAndFill: timer_label is null!")
	if hint_button == null: push_error("HearAndFill: hint_button is null!")
	if hint_label == null: push_error("HearAndFill: hint_label is null!")
	if title_label == null: push_error("HearAndFill: title_label is null!")
	if instruction_label == null: push_error("HearAndFill: instruction_label is null!")
	if sentence_label == null: push_error("HearAndFill: sentence_label is null!")
	if speaker_button == null: push_error("HearAndFill: speaker_button is null!")

func _setup_ui():
	if title_label:
		title_label.text = "\"Hear and Fill!\""
	if instruction_label:
		instruction_label.text = "Listen to the audio clip\nChoose the correct word based on proper pronunciation."
	if sentence_label:
		sentence_label.text = sentence_text

	_update_hint_display()

	# Shuffle choices so the correct answer lands in a random position each run
	var correct_word = choices[correct_answer_index]
	choices.shuffle()
	correct_answer_index = choices.find(correct_word)

	for i in range(choice_buttons.size()):
		if choice_buttons[i] == null:
			push_error("HearAndFill: choice_buttons[" + str(i) + "] is null!")
			continue
		if i < choices.size():
			choice_buttons[i].text = choices[i]
			choice_buttons[i].visible = true
		else:
			choice_buttons[i].visible = false

	if feedback_label:
		feedback_label.visible = false

func _connect_buttons():
	for i in range(choice_buttons.size()):
		if choice_buttons[i]:
			choice_buttons[i].pressed.connect(_on_choice_selected.bind(i))

	if tutorial_ok_button:
		tutorial_ok_button.pressed.connect(_on_tutorial_ok)

	if hint_button:
		hint_button.pressed.connect(_on_hint_pressed)
		hint_button.icon = load("res://assets/UI/core/hints.png")
		hint_button.add_theme_constant_override("icon_max_width", 40)
		hint_button.text = ""
		hint_button.add_theme_constant_override("icon_margin_left", 0)
		hint_button.add_theme_constant_override("icon_margin_right", 0)
		hint_button.add_theme_constant_override("icon_margin_top", 0)
		hint_button.add_theme_constant_override("icon_margin_bottom", 0)
		hint_button.add_theme_constant_override("h_separation", 0)

	if speaker_button:
		speaker_button.pressed.connect(_on_speaker_pressed)
		speaker_button.icon = load("res://assets/UI/core/speaker.png")
		speaker_button.add_theme_constant_override("icon_max_width", 40)
		speaker_button.text = ""
		speaker_button.add_theme_constant_override("icon_margin_left", 0)
		speaker_button.add_theme_constant_override("icon_margin_right", 0)
		speaker_button.add_theme_constant_override("icon_margin_top", 0)
		speaker_button.add_theme_constant_override("icon_margin_bottom", 0)
		speaker_button.add_theme_constant_override("h_separation", 0)

# ─── Tutorial ────────────────────────────────────────────────────────────────

func _show_tutorial():
	if tutorial_overlay == null:
		# No tutorial node in scene — go straight to countdown
		_start_countdown()
		return
	tutorial_overlay.visible = true

func _on_tutorial_ok():
	tutorial_overlay.visible = false
	_start_countdown()

# ─── Countdown ───────────────────────────────────────────────────────────────

func _start_countdown():
	if countdown_overlay == null:
		# No countdown node — start directly
		_begin_game()
		return
	countdown_overlay.visible = true
	await _play_countdown_step("3", SFX_THREE)
	await _play_countdown_step("2", SFX_TWO)
	await _play_countdown_step("1", SFX_ONE)
	await _play_countdown_step("START!", SFX_START)
	countdown_overlay.visible = false
	_begin_game()

func _play_countdown_step(text: String, sfx_path: String) -> void:
	if countdown_label:
		countdown_label.text = text
	_play_sfx(sfx_path)
	await get_tree().create_timer(1.0).timeout

func _begin_game():
	start_time = Time.get_ticks_msec() / 1000.0
	_set_choices_interactable(true)
	if hint_button:
		hint_button.disabled = false
	timer_active = true

# ─── Helpers ─────────────────────────────────────────────────────────────────

func _set_choices_interactable(enabled: bool):
	for i in range(choice_buttons.size()):
		if choice_buttons[i] == null:
			continue
		# Never re-enable buttons that hint eliminated
		if not enabled:
			choice_buttons[i].disabled = true
		elif i in hint_eliminated_indices:
			# Keep eliminated buttons disabled
			pass
		else:
			choice_buttons[i].disabled = false

# ─── Process ─────────────────────────────────────────────────────────────────

func _process(delta):
	if timer_active:
		time_remaining -= delta
		if time_remaining <= 0:
			time_remaining = 0
			timer_active = false
			_on_time_up()
		_update_timer_display()

func _update_timer_display():
	var minutes = int(time_remaining) / 60
	var seconds = int(time_remaining) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

func _on_time_up():
	feedback_label.text = "Time's up! Try again."
	feedback_label.add_theme_color_override("font_color", Color.ORANGE)
	feedback_label.visible = true

	_set_choices_interactable(false)

	await get_tree().create_timer(2.0).timeout

	# Reset timer and re-enable non-eliminated buttons
	time_remaining = 90.0
	feedback_label.visible = false

	# Restore color overrides on non-eliminated buttons only
	for i in range(choice_buttons.size()):
		if i not in hint_eliminated_indices:
			choice_buttons[i].remove_theme_color_override("font_color")

	_set_choices_interactable(true)
	timer_active = true

# ─── Choice selection ─────────────────────────────────────────────────────────

func _on_choice_selected(choice_index: int):
	print("DEBUG: Choice selected: ", choice_index, " (", choices[choice_index], ")")
	_set_choices_interactable(false)
	timer_active = false

	if choice_index == correct_answer_index:
		_show_correct_feedback()
	else:
		_show_wrong_feedback(choice_index)

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

func _show_correct_feedback():
	_play_sfx("res://assets/audio/sound_effect/correct.wav")
	var completion_time = (Time.get_ticks_msec() / 1000.0) - start_time

	var bonus_hint_earned = completion_time <= TIME_BONUS_THRESHOLD
	if bonus_hint_earned:
		PlayerStats.add_hints(1)
		feedback_label.text = "Correct! Well done!\nSpeed Bonus: +1 Hint!"
	else:
		feedback_label.text = "Correct! Well done!"

	feedback_label.add_theme_color_override("font_color", Color.GREEN)
	feedback_label.visible = true
	choice_buttons[correct_answer_index].add_theme_color_override("font_color", Color.GREEN)

	await get_tree().create_timer(2.5).timeout
	_complete_minigame(true)

func _show_wrong_feedback(selected_index: int):
	_play_sfx("res://assets/audio/sound_effect/wrong.wav")
	feedback_label.text = "Incorrect! Try again."
	feedback_label.add_theme_color_override("font_color", Color.RED)
	feedback_label.visible = true
	choice_buttons[selected_index].add_theme_color_override("font_color", Color.RED)

	await get_tree().create_timer(1.5).timeout

	# Reset colors on non-eliminated buttons, keep eliminated ones gray
	for i in range(choice_buttons.size()):
		if i not in hint_eliminated_indices:
			choice_buttons[i].remove_theme_color_override("font_color")

	feedback_label.visible = false
	_set_choices_interactable(true)
	timer_active = true

# ─── Hint ────────────────────────────────────────────────────────────────────

func _update_hint_display():
	if hint_label and PlayerStats:
		hint_label.text = "Hints: " + str(PlayerStats.hints)

func _on_hint_pressed():
	if hint_on_cooldown:
		return

	if not PlayerStats.use_hint():
		hint_button.icon = null
		hint_button.text = "No hints!"
		await get_tree().create_timer(1.0).timeout
		hint_button.text = ""
		hint_button.icon = load("res://assets/UI/core/hints.png")
		hint_button.add_theme_constant_override("icon_max_width", 40)
		return

	_update_hint_display()
	_eliminate_one_wrong_button()

	var hint_text = puzzle_config.get("hint_text", "Think about how the word sounds when spoken aloud. Use the speaker button to hear it again.")
	var overlay = CanvasLayer.new()
	overlay.set_script(load("res://scenes/ui/hint_overlay.gd"))
	get_tree().root.add_child(overlay)
	overlay.show_hint(hint_text)

	# Start cooldown — button disabled for 12 seconds
	hint_on_cooldown = true
	hint_button.disabled = true
	await get_tree().create_timer(HINT_COOLDOWN).timeout
	hint_on_cooldown = false
	if not is_queued_for_deletion():
		hint_button.disabled = false

func _eliminate_one_wrong_button() -> void:
	var wrong_indices: Array = []
	for i in range(choice_buttons.size()):
		if i != correct_answer_index and i not in hint_eliminated_indices and not choice_buttons[i].disabled:
			wrong_indices.append(i)
	if wrong_indices.is_empty():
		return
	wrong_indices.shuffle()
	var target = wrong_indices[0]
	hint_eliminated_indices.append(target)
	choice_buttons[target].disabled = true
	choice_buttons[target].add_theme_color_override("font_color", Color(0.45, 0.45, 0.45, 0.6))

# ─── TTS ─────────────────────────────────────────────────────────────────────

func _setup_tts():
	tts_player = AudioStreamPlayer.new()
	add_child(tts_player)
	tts_player.finished.connect(_on_tts_finished)
	_generate_tts_audio(blank_word)

func _generate_tts_audio(text: String):
	if DisplayServer.tts_is_speaking():
		DisplayServer.tts_stop()
	DisplayServer.tts_speak(text, "")

func _on_speaker_pressed():
	_generate_tts_audio(blank_word)

func _on_tts_finished():
	pass

# ─── Skip / Complete / Cleanup ────────────────────────────────────────────────

func _skip_minigame():
	print("Skipping hear and fill minigame...")
	_complete_minigame(true)

func _complete_minigame(success: bool):
	if DisplayServer.tts_is_speaking():
		DisplayServer.tts_stop()
	minigame_completed.emit(success)
	_cleanup()
	queue_free()

func _cleanup():
	if tts_player:
		tts_player.queue_free()
		tts_player = null

func _exit_tree():
	_cleanup()

# ─── Configuration ────────────────────────────────────────────────────────────

func configure_puzzle(config: Dictionary):
	puzzle_config = config
	if config.has("sentence"):
		sentence_text = config["sentence"]
	if config.has("blank_word"):
		blank_word = config["blank_word"]
	if config.has("correct_index"):
		correct_answer_index = config["correct_index"]
	if config.has("choices"):
		choices = config["choices"]

	if is_node_ready():
		_setup_ui()
		_setup_tts()
