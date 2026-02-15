# VoskPronunciationGame.gd
# A ready-to-use node for pronunciation minigames
extends Control

# Signals
signal word_recognized(recognized_text: String, similarity: float)
signal recording_started()
signal recording_stopped()
signal pronunciation_correct(word: String)
signal pronunciation_incorrect(word: String, recognized: String)

# Configuration
@export var model_path: String = "res://addons/vosk/models/vosk-model-small-en-us-0.15"
@export var sample_rate: float = 16000.0
@export var similarity_threshold: float = 0.8  # 0.0 to 1.0
@export var show_debug_ui: bool = true

# Internal variables
var vosk = null
var audio_effect_capture: AudioEffectCapture
var audio_bus_index: int
var is_recording: bool = false
var target_word: String = ""
var audio_buffer: PackedByteArray = PackedByteArray()

# UI References
@onready var target_label: Label = $VBoxContainer/TargetLabel
@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var record_button: Button = $VBoxContainer/RecordButton
@onready var result_label: Label = $VBoxContainer/ResultLabel
@onready var partial_label: Label = $VBoxContainer/PartialLabel

func _ready():
	_setup_vosk()
	_setup_audio_capture()
	_setup_ui()

func _setup_vosk():
	vosk = ClassDB.instantiate("GodotVoskRecognizer")
	var absolute_path = ProjectSettings.globalize_path(model_path)
	
	if not vosk.initialize(absolute_path, sample_rate):
		push_error("Failed to initialize Vosk recognizer")
		status_label.text = "ERROR: Vosk failed to initialize"
		status_label.add_theme_color_override("font_color", Color.RED)
		return
	
	print("Vosk initialized successfully")
	status_label.text = "Ready"
	status_label.add_theme_color_override("font_color", Color.GREEN)

func _setup_audio_capture():
	# Create audio bus for microphone capture
	audio_bus_index = AudioServer.get_bus_count()
	AudioServer.add_bus(audio_bus_index)
	AudioServer.set_bus_name(audio_bus_index, "VoskCapture")
	
	# Add capture effect
	audio_effect_capture = AudioEffectCapture.new()
	audio_effect_capture.buffer_length = 0.1  # 100ms buffer
	AudioServer.add_bus_effect(audio_bus_index, audio_effect_capture)
	
	# Setup microphone
	var idx = AudioServer.get_bus_index("VoskCapture")
	AudioServer.set_bus_mute(idx, false)

func _setup_ui():
	if not show_debug_ui:
		return
	
	# Create UI if it doesn't exist in the scene
	if not has_node("VBoxContainer"):
		var vbox = VBoxContainer.new()
		vbox.name = "VBoxContainer"
		add_child(vbox)
		
		target_label = Label.new()
		target_label.name = "TargetLabel"
		target_label.text = "Say a word to start"
		target_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		target_label.add_theme_font_size_override("font_size", 24)
		vbox.add_child(target_label)
		
		status_label = Label.new()
		status_label.name = "StatusLabel"
		status_label.text = "Initializing..."
		status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(status_label)
		
		record_button = Button.new()
		record_button.name = "RecordButton"
		record_button.text = "Start Recording"
		record_button.pressed.connect(_on_record_button_pressed)
		vbox.add_child(record_button)
		
		partial_label = Label.new()
		partial_label.name = "PartialLabel"
		partial_label.text = ""
		partial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		partial_label.add_theme_color_override("font_color", Color.GRAY)
		vbox.add_child(partial_label)
		
		result_label = Label.new()
		result_label.name = "ResultLabel"
		result_label.text = ""
		result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		result_label.add_theme_font_size_override("font_size", 20)
		vbox.add_child(result_label)
	
	record_button.pressed.connect(_on_record_button_pressed)

func set_target_word(word: String):
	"""Set the word the player should pronounce"""
	target_word = word.to_lower().strip_edges()
	target_label.text = "Say: " + word
	result_label.text = ""
	partial_label.text = ""

func start_recording():
	"""Start recording audio for recognition"""
	if is_recording:
		return
	
	is_recording = true
	audio_buffer.clear()
	vosk.reset()
	
	# Start microphone capture
	AudioServer.set_bus_mute(audio_bus_index, false)
	
	status_label.text = "Listening..."
	status_label.add_theme_color_override("font_color", Color.YELLOW)
	record_button.text = "Stop Recording"
	result_label.text = ""
	partial_label.text = ""
	
	recording_started.emit()

func stop_recording():
	"""Stop recording and process the audio"""
	if not is_recording:
		return
	
	is_recording = false
	AudioServer.set_bus_mute(audio_bus_index, true)
	
	status_label.text = "Processing..."
	record_button.text = "Start Recording"
	
	# Get final result
	var result_json = vosk.get_final_result()
	var result = JSON.parse_string(result_json)
	
	if result and result.has("text"):
		var recognized_text = result["text"].strip_edges()
		_process_result(recognized_text)
	else:
		result_label.text = "No speech detected"
		result_label.add_theme_color_override("font_color", Color.ORANGE)
		status_label.text = "Ready"
		status_label.add_theme_color_override("font_color", Color.GREEN)
	
	recording_stopped.emit()

func _process_result(recognized_text: String):
	"""Process the recognized text and check against target"""
	recognized_text = recognized_text.to_lower().strip_edges()
	
	if target_word.is_empty():
		# No target word, just emit the recognition
		result_label.text = "You said: " + recognized_text
		word_recognized.emit(recognized_text, 1.0)
		status_label.text = "Ready"
		status_label.add_theme_color_override("font_color", Color.GREEN)
		return
	
	# Calculate similarity
	var similarity = calculate_similarity(recognized_text, target_word)
	
	result_label.text = "You said: " + recognized_text
	
	if similarity >= similarity_threshold:
		result_label.add_theme_color_override("font_color", Color.GREEN)
		status_label.text = "Correct! ✓"
		status_label.add_theme_color_override("font_color", Color.GREEN)
		pronunciation_correct.emit(target_word)
	else:
		result_label.add_theme_color_override("font_color", Color.RED)
		status_label.text = "Try again (%.0f%% match)" % (similarity * 100)
		status_label.add_theme_color_override("font_color", Color.ORANGE)
		pronunciation_incorrect.emit(target_word, recognized_text)
	
	word_recognized.emit(recognized_text, similarity)

func calculate_similarity(text1: String, text2: String) -> float:
	"""Calculate Levenshtein distance-based similarity"""
	if text1 == text2:
		return 1.0
	
	if text1.is_empty() or text2.is_empty():
		return 0.0
	
	var len1 = text1.length()
	var len2 = text2.length()
	var matrix = []
	
	# Initialize matrix
	for i in range(len1 + 1):
		matrix.append([])
		for j in range(len2 + 1):
			matrix[i].append(0)
	
	# Fill first row and column
	for i in range(len1 + 1):
		matrix[i][0] = i
	for j in range(len2 + 1):
		matrix[0][j] = j
	
	# Calculate Levenshtein distance
	for i in range(1, len1 + 1):
		for j in range(1, len2 + 1):
			var cost = 0 if text1[i-1] == text2[j-1] else 1
			matrix[i][j] = min(
				matrix[i-1][j] + 1,      # deletion
				matrix[i][j-1] + 1,      # insertion
				matrix[i-1][j-1] + cost  # substitution
			)
	
	var distance = matrix[len1][len2]
	var max_len = max(len1, len2)
	return 1.0 - (float(distance) / float(max_len))

func _process(_delta):
	if not is_recording:
		return
	
	# Capture audio data
	var frames_available = audio_effect_capture.get_frames_available()
	if frames_available > 0:
		var stereo_data = audio_effect_capture.get_buffer(frames_available)
		
		# Convert stereo float to mono PCM 16-bit
		for i in range(0, stereo_data.size(), 2):
			# Average left and right channels
			var mono_sample = (stereo_data[i].x + stereo_data[i].y) / 2.0
			# Convert to 16-bit PCM
			var int_sample = int(clamp(mono_sample * 32767.0, -32768, 32767))
			# Append as little-endian bytes
			audio_buffer.append(int_sample & 0xFF)
			audio_buffer.append((int_sample >> 8) & 0xFF)
		
		# Send to Vosk every 4096 bytes
		if audio_buffer.size() >= 4096:
			var chunk = audio_buffer.slice(0, 4096)
			audio_buffer = audio_buffer.slice(4096)
			
			vosk.accept_waveform(chunk)
			
			# Get partial result for live feedback
			var partial_json = vosk.get_partial_result()
			var partial = JSON.parse_string(partial_json)
			if partial and partial.has("partial") and partial["partial"] != "":
				partial_label.text = "Hearing: " + partial["partial"]

func _on_record_button_pressed():
	if is_recording:
		stop_recording()
	else:
		start_recording()

func _exit_tree():
	# Cleanup
	if audio_bus_index >= 0:
		AudioServer.remove_bus(audio_bus_index)
