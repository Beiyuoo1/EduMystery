# Pronunciation Minigame
# Player must pronounce a sentence correctly with sufficient confidence
extends Control

signal game_finished(success: bool, score: int)

# Vosk settings
var vosk  # GodotVoskRecognizer - type hint removed to allow loading when extension unavailable
var model_path: String = "res://addons/vosk/models/vosk-model-small-en-us-0.15"
var sample_rate: float = 16000.0

# Audio capture
var audio_effect_capture: AudioEffectCapture
var audio_bus_index: int = -1
var mic_player: AudioStreamPlayer  # AudioStreamPlayer with microphone input
var is_recording: bool = false
var audio_buffer: PackedByteArray = PackedByteArray()

# Audio feedback
var sfx_player: AudioStreamPlayer
var sfx_start_recording: AudioStream
var sfx_stop_recording: AudioStream
var sfx_success: AudioStream
var sfx_failure: AudioStream
var sfx_retry: AudioStream

# Audio paths (placeholder - add your own audio files)
const SFX_START_PATH = "res://assets/audio/sfx/record_start.wav"
const SFX_STOP_PATH = "res://assets/audio/sfx/record_stop.wav"
const SFX_SUCCESS_PATH = "res://assets/audio/sfx/success.wav"
const SFX_FAILURE_PATH = "res://assets/audio/sfx/failure.wav"
const SFX_RETRY_PATH = "res://assets/audio/sfx/retry.wav"

# Puzzle configuration
var target_sentence: String = ""
var min_confidence: float = 0.6  # Minimum confidence to pass (60%)
var max_attempts: int = 3
var current_attempt: int = 0

# Scoring thresholds
const SCORE_EXCELLENT = 85  # Green, immediate pass
const SCORE_GOOD = 70       # Yellow-green, pass
const SCORE_FAIR = 50       # Orange, retry
const SCORE_POOR = 0        # Red, needs improvement

# State
var is_configured: bool = false
var is_ready: bool = false
var vosk_initialized: bool = false

# UI nodes (will be created dynamically)
var background: ColorRect
var panel: PanelContainer
var title_label: Label
var sentence_label: Label
var instruction_label: Label
var status_label: Label
var confidence_label: Label
var record_button: Button
var attempts_label: Label
var result_container: VBoxContainer

func _ready():
	print("DEBUG: Pronunciation minigame _ready() called")
	is_ready = true
	_setup_ui()
	print("DEBUG: UI setup complete")
	_setup_audio_feedback()
	print("DEBUG: Audio feedback setup complete")
	_setup_vosk()
	print("DEBUG: Vosk setup complete")
	_setup_audio_capture()
	print("DEBUG: Audio capture setup complete")

	if is_configured:
		_display_puzzle()
	print("DEBUG: Pronunciation minigame _ready() finished")

func _setup_audio_feedback():
	# Create audio player for sound effects
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "Master"
	add_child(sfx_player)

	# Load audio files (gracefully handle missing files)
	sfx_start_recording = _load_audio_safe(SFX_START_PATH)
	sfx_stop_recording = _load_audio_safe(SFX_STOP_PATH)
	sfx_success = _load_audio_safe(SFX_SUCCESS_PATH)
	sfx_failure = _load_audio_safe(SFX_FAILURE_PATH)
	sfx_retry = _load_audio_safe(SFX_RETRY_PATH)

func _load_audio_safe(path: String) -> AudioStream:
	if ResourceLoader.exists(path):
		return load(path)
	print("DEBUG: Audio file not found: ", path)
	return null

func _play_sfx(stream: AudioStream) -> void:
	if stream and sfx_player:
		sfx_player.stream = stream
		sfx_player.play()

func configure_puzzle(config: Dictionary) -> void:
	target_sentence = config.get("sentence", "Hello world").to_lower().strip_edges()
	min_confidence = config.get("min_confidence", 0.6)
	max_attempts = config.get("max_attempts", 3)
	current_attempt = 0
	is_configured = true

	if is_ready:
		_display_puzzle()

func _setup_ui():
	# Create a CanvasLayer to render on top of everything (including Dialogic)
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # High layer to be on top of Dialogic
	add_child(canvas_layer)

	# Dark semi-transparent background
	background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.85)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas_layer.add_child(background)

	# Center container
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas_layer.add_child(center)

	# Main panel
	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(700, 500)
	center.add_child(panel)

	# Style the panel
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2, 1)
	style.border_color = Color(0.4, 0.6, 0.9, 1)
	style.set_border_width_all(3)
	style.set_corner_radius_all(15)
	style.set_content_margin_all(30)
	panel.add_theme_stylebox_override("panel", style)

	# VBox for content
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	panel.add_child(vbox)

	# Title
	title_label = Label.new()
	title_label.text = "Pronunciation Challenge"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.3))
	vbox.add_child(title_label)

	# Instruction
	instruction_label = Label.new()
	instruction_label.text = "Read the sentence below clearly into your microphone:"
	instruction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instruction_label.add_theme_font_size_override("font_size", 16)
	instruction_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(instruction_label)

	# Sentence to pronounce (in a styled container)
	var sentence_panel = PanelContainer.new()
	var sentence_style = StyleBoxFlat.new()
	sentence_style.bg_color = Color(0.1, 0.1, 0.15, 1)
	sentence_style.set_corner_radius_all(10)
	sentence_style.set_content_margin_all(20)
	sentence_panel.add_theme_stylebox_override("panel", sentence_style)
	vbox.add_child(sentence_panel)

	sentence_label = Label.new()
	sentence_label.text = "Loading..."
	sentence_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sentence_label.add_theme_font_size_override("font_size", 24)
	sentence_label.add_theme_color_override("font_color", Color(1, 1, 1))
	sentence_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sentence_panel.add_child(sentence_label)

	# Status label
	status_label = Label.new()
	status_label.text = "Initializing..."
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(status_label)

	# Confidence display
	confidence_label = Label.new()
	confidence_label.text = ""
	confidence_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	confidence_label.add_theme_font_size_override("font_size", 20)
	vbox.add_child(confidence_label)

	# Record button
	record_button = Button.new()
	record_button.icon = load("res://assets/UI/core/mic_off.png")
	record_button.icon_max_width = 32
	record_button.text = "Hold to Record"
	record_button.custom_minimum_size = Vector2(250, 60)
	record_button.add_theme_font_size_override("font_size", 20)
	record_button.disabled = true
	record_button.button_down.connect(_on_record_pressed)
	record_button.button_up.connect(_on_record_released)

	var button_container = CenterContainer.new()
	button_container.add_child(record_button)
	vbox.add_child(button_container)

	# Attempts counter
	attempts_label = Label.new()
	attempts_label.text = ""
	attempts_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	attempts_label.add_theme_font_size_override("font_size", 14)
	attempts_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	vbox.add_child(attempts_label)

	# Fade in - fade the background which contains all UI
	background.modulate.a = 0.0
	panel.modulate.a = 0.0
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(background, "modulate:a", 1.0, 0.3)
	tween.tween_property(panel, "modulate:a", 1.0, 0.3)

func _setup_vosk():
	# Check if GodotVoskRecognizer class exists (GDExtension loaded)
	if not ClassDB.class_exists("GodotVoskRecognizer"):
		push_error("GodotVoskRecognizer class not found - Vosk GDExtension not loaded")
		status_label.text = "ERROR: Speech recognition not available"
		status_label.add_theme_color_override("font_color", Color.RED)
		# Allow skipping by clicking anywhere after a delay
		_setup_skip_fallback()
		return

	vosk = ClassDB.instantiate("GodotVoskRecognizer")
	var absolute_path = ProjectSettings.globalize_path(model_path)
	print("DEBUG: Vosk model path: ", absolute_path)

	if not vosk.initialize(absolute_path, sample_rate):
		push_error("Failed to initialize Vosk recognizer")
		status_label.text = "ERROR: Speech recognition failed to initialize"
		status_label.add_theme_color_override("font_color", Color.RED)
		_setup_skip_fallback()
		return

	# Enable word-level confidence scores
	vosk.set_words(true)
	vosk_initialized = true
	print("Vosk initialized for pronunciation minigame")

func _setup_skip_fallback():
	# When Vosk fails, allow user to skip after 2 seconds
	await get_tree().create_timer(2.0).timeout
	status_label.text += "\n\nClick anywhere to skip..."
	# Connect a one-shot click handler
	var click_handler = func(event):
		if event is InputEventMouseButton and event.pressed:
			_finish_game(true, 50)  # Give partial credit for skipping
	set_process_input(true)
	# Store handler for _input
	set_meta("skip_handler", click_handler)

func _unhandled_input(event):
	if has_meta("skip_handler"):
		var handler = get_meta("skip_handler")
		handler.call(event)

func _setup_audio_capture():
	# Create dedicated audio bus for microphone capture
	audio_bus_index = AudioServer.get_bus_count()
	AudioServer.add_bus(audio_bus_index)
	AudioServer.set_bus_name(audio_bus_index, "PronunciationCapture")

	# Add capture effect to this bus
	audio_effect_capture = AudioEffectCapture.new()
	audio_effect_capture.buffer_length = 10.0  # 10 second buffer
	AudioServer.add_bus_effect(audio_bus_index, audio_effect_capture)

	# Mute output (we don't want to hear the mic playback)
	AudioServer.set_bus_mute(audio_bus_index, true)

	# Create AudioStreamPlayer with microphone input
	mic_player = AudioStreamPlayer.new()
	mic_player.stream = AudioStreamMicrophone.new()
	mic_player.bus = "PronunciationCapture"
	add_child(mic_player)

	print("Audio capture setup complete - microphone ready")

func _display_puzzle():
	sentence_label.text = "\"" + target_sentence.capitalize() + "\""
	attempts_label.text = "Attempts: %d / %d" % [current_attempt, max_attempts]

	if vosk_initialized:
		status_label.text = "Ready - Hold the button and speak"
		status_label.add_theme_color_override("font_color", Color.GREEN)
		record_button.disabled = false
	else:
		status_label.text = "Waiting for speech recognition..."
		status_label.add_theme_color_override("font_color", Color.YELLOW)

func _on_record_pressed():
	if not vosk_initialized or is_recording:
		return

	_start_recording()

func _on_record_released():
	if is_recording:
		_stop_recording()

func _start_recording():
	is_recording = true
	audio_buffer.clear()
	vosk.reset()

	# Play start recording sound
	_play_sfx(sfx_start_recording)

	# Clear capture buffer
	audio_effect_capture.clear_buffer()

	# Start microphone capture by playing the mic stream
	mic_player.play()

	status_label.text = "Listening... Speak now!"
	status_label.add_theme_color_override("font_color", Color.YELLOW)
	record_button.icon = load("res://assets/UI/core/mic_active.png")
	record_button.icon_max_width = 32
	record_button.text = "Recording..."
	record_button.add_theme_color_override("font_color", Color.RED)
	confidence_label.text = ""

func _stop_recording():
	is_recording = false
	# Stop the microphone
	mic_player.stop()

	# Play stop recording sound
	_play_sfx(sfx_stop_recording)

	status_label.text = "Processing..."
	record_button.icon = load("res://assets/UI/core/mic_off.png")
	record_button.icon_max_width = 32
	record_button.text = "Processing..."
	record_button.remove_theme_color_override("font_color")
	record_button.disabled = true

	current_attempt += 1
	attempts_label.text = "Attempts: %d / %d" % [current_attempt, max_attempts]

	# Process the recorded audio
	await _process_recording()

func _process_recording():
	# Wait a frame to ensure all audio is captured
	await get_tree().process_frame

	# Send any remaining buffer to Vosk
	if audio_buffer.size() > 0:
		vosk.accept_waveform(audio_buffer)

	# Get final result with word confidence
	var result_json = vosk.get_final_result()
	print("Vosk result: ", result_json)

	var result = JSON.parse_string(result_json)

	if result and result.has("text") and result["text"].strip_edges() != "":
		_evaluate_result(result)
	else:
		_handle_no_speech()

func _evaluate_result(result: Dictionary):
	var recognized_text = result.get("text", "").to_lower().strip_edges()

	# Calculate word match score
	var target_words = target_sentence.split(" ", false)
	var recognized_words = recognized_text.split(" ", false)

	var word_match_score = _calculate_word_match(target_words, recognized_words)

	# Calculate confidence score from Vosk
	var confidence_score = 0.0
	var word_count = 0

	if result.has("result") and result["result"] is Array:
		for word_data in result["result"]:
			if word_data is Dictionary and word_data.has("conf"):
				confidence_score += word_data.get("conf", 0.0)
				word_count += 1

		if word_count > 0:
			confidence_score = confidence_score / word_count
	else:
		# Fallback if no detailed confidence data
		confidence_score = 0.7 if word_match_score > 0.8 else 0.5

	# Combined score (weighted: 40% word match, 60% confidence)
	var final_score = (word_match_score * 0.4) + (confidence_score * 0.6)

	# Display results
	_display_evaluation(recognized_text, word_match_score, confidence_score, final_score)

func _calculate_word_match(target: PackedStringArray, recognized: PackedStringArray) -> float:
	if target.size() == 0:
		return 0.0

	var total_score = 0.0

	for target_word in target:
		var best_match = 0.0

		for rec_word in recognized:
			# Exact match
			if target_word == rec_word:
				best_match = 1.0
				break

			# Partial match using similarity
			var similarity = _word_similarity(target_word, rec_word)
			if similarity > best_match:
				best_match = similarity

		total_score += best_match

	return total_score / float(target.size())

func _word_similarity(word1: String, word2: String) -> float:
	# Simple similarity based on common characters and length
	if word1.is_empty() or word2.is_empty():
		return 0.0

	# Check if one contains the other (handles partial recognition)
	if word1 in word2 or word2 in word1:
		var shorter = min(word1.length(), word2.length())
		var longer = max(word1.length(), word2.length())
		return float(shorter) / float(longer) * 0.8  # 80% credit for partial match

	# Levenshtein-like similarity (simplified)
	var common_chars = 0
	var word2_chars = word2.split("")

	for c in word1.split(""):
		var idx = word2_chars.find(c)
		if idx >= 0:
			common_chars += 1
			word2_chars.remove_at(idx)

	var max_len = max(word1.length(), word2.length())
	return float(common_chars) / float(max_len) * 0.6  # 60% max for fuzzy match

func _display_evaluation(recognized: String, word_match: float, confidence: float, final: float):
	var score_percent = int(final * 100)
	var word_percent = int(word_match * 100)
	var clarity_percent = int(confidence * 100)

	# Determine success based on combined criteria
	var _success = score_percent >= SCORE_GOOD and word_percent >= 60

	# Show what was recognized
	status_label.text = "You said: \"" + recognized + "\""

	# Show detailed score breakdown
	confidence_label.text = "Score: %d%% (Words: %d%%, Clarity: %d%%)" % [
		score_percent, word_percent, clarity_percent
	]

	# Color and feedback based on score tier
	var bright_green = Color(0.2, 1.0, 0.2)
	var yellow_green = Color(0.6, 1.0, 0.3)
	var orange = Color(1.0, 0.7, 0.2)
	var red = Color(1.0, 0.3, 0.3)

	if score_percent >= SCORE_EXCELLENT:
		confidence_label.add_theme_color_override("font_color", bright_green)
		status_label.add_theme_color_override("font_color", bright_green)
		status_label.text = "✨ Excellent! \"" + recognized + "\""
		_play_sfx(sfx_success)
		_finish_game(true, score_percent)
	elif score_percent >= SCORE_GOOD:
		confidence_label.add_theme_color_override("font_color", yellow_green)
		status_label.add_theme_color_override("font_color", yellow_green)
		status_label.text = "✓ Good! \"" + recognized + "\""
		_play_sfx(sfx_success)
		_finish_game(true, score_percent)
	elif score_percent >= SCORE_FAIR:
		confidence_label.add_theme_color_override("font_color", orange)
		if current_attempt >= max_attempts:
			status_label.add_theme_color_override("font_color", orange)
			status_label.text = "Almost there! \"" + recognized + "\""
			_play_sfx(sfx_failure)
			_finish_game(false, score_percent)
		else:
			status_label.add_theme_color_override("font_color", orange)
			var tip = _get_improvement_tip(word_percent, clarity_percent)
			status_label.text = "You said: \"" + recognized + "\"\n" + tip
			_play_sfx(sfx_retry)
			record_button.icon = load("res://assets/UI/core/mic_off.png")
			record_button.icon_max_width = 32
			record_button.text = "Hold to Record"
			record_button.disabled = false
	else:
		confidence_label.add_theme_color_override("font_color", red)
		if current_attempt >= max_attempts:
			status_label.add_theme_color_override("font_color", red)
			status_label.text = "Keep practicing! \"" + recognized + "\""
			_play_sfx(sfx_failure)
			_finish_game(false, score_percent)
		else:
			status_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.3))
			var tip = _get_improvement_tip(word_percent, clarity_percent)
			status_label.text = "You said: \"" + recognized + "\"\n" + tip
			_play_sfx(sfx_retry)
			record_button.icon = load("res://assets/UI/core/mic_off.png")
			record_button.icon_max_width = 32
			record_button.text = "Hold to Record"
			record_button.disabled = false

func _get_improvement_tip(word_percent: int, clarity_percent: int) -> String:
	if word_percent < 50:
		return "Try to say each word clearly and completely."
	if clarity_percent < 50:
		return "Speak a bit louder and more clearly."
	if word_percent < 70:
		return "Good effort! Focus on pronouncing each word."
	return "Almost perfect! Just a bit more clarity needed."

func _handle_no_speech():
	status_label.text = "No speech detected. Try again."
	status_label.add_theme_color_override("font_color", Color.ORANGE)
	confidence_label.text = ""
	_play_sfx(sfx_retry)

	if current_attempt >= max_attempts:
		_play_sfx(sfx_failure)
		_finish_game(false, 0)
	else:
		record_button.icon = load("res://assets/UI/core/mic_off.png")
		record_button.icon_max_width = 32
		record_button.text = "Hold to Record"
		record_button.disabled = false

func _finish_game(success: bool, score: int):
	record_button.disabled = true

	await get_tree().create_timer(2.0).timeout

	# Fade out, emit signal, then cleanup
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(background, "modulate:a", 0.0, 0.3)
	tween.tween_property(panel, "modulate:a", 0.0, 0.3)
	await tween.finished
	emit_signal("game_finished", success, score)
	# Wait a frame to ensure signal is processed before cleanup
	await get_tree().process_frame
	queue_free()

func _process(_delta):
	if not is_recording:
		return

	# Capture audio from microphone
	var frames_available = audio_effect_capture.get_frames_available()
	if frames_available > 0:
		var stereo_data = audio_effect_capture.get_buffer(frames_available)

		# Convert stereo float to mono PCM 16-bit
		for frame in stereo_data:
			# Average left and right channels
			var mono_sample = (frame.x + frame.y) / 2.0
			# Convert to 16-bit PCM
			var int_sample = int(clamp(mono_sample * 32767.0, -32768, 32767))
			# Append as little-endian bytes
			audio_buffer.append(int_sample & 0xFF)
			audio_buffer.append((int_sample >> 8) & 0xFF)

		# Send chunks to Vosk for streaming recognition
		while audio_buffer.size() >= 4096:
			var chunk = audio_buffer.slice(0, 4096)
			audio_buffer = audio_buffer.slice(4096)
			vosk.accept_waveform(chunk)

func _exit_tree():
	# Cleanup audio bus
	if audio_bus_index >= 0 and audio_bus_index < AudioServer.get_bus_count():
		AudioServer.remove_bus(audio_bus_index)
