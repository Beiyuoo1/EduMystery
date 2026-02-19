extends CanvasLayer

# Set to true to skip Vosk entirely — correct choice click completes the minigame directly.
# Useful for testing layout/logic when Vosk is not working or causes lag.
const VOSK_BYPASS: bool = true

# Node references
@onready var timer_label = $Control/Panel/MainContainer/VBoxContainer/HeaderContainer/TimerLabel
@onready var question_label = $Control/Panel/MainContainer/VBoxContainer/InstructionPanel/MarginContainer/VBoxContainer/QuestionLabel
@onready var choices_container = $Control/Panel/MainContainer/VBoxContainer/ContentRow/RightColumn/ChoicesContainer
@onready var microphone_panel = $Control/Panel/MainContainer/VBoxContainer/ContentRow/RightColumn/MicrophonePanel
@onready var feedback_label = $Control/Panel/MainContainer/VBoxContainer/ContentRow/RightColumn/FeedbackLabel
@onready var sentence_display = $Control/Panel/MainContainer/VBoxContainer/ContentRow/RightColumn/MicrophonePanel/MarginContainer/VBoxContainer/SentenceDisplay
@onready var status_label = $Control/Panel/MainContainer/VBoxContainer/ContentRow/RightColumn/MicrophonePanel/MarginContainer/VBoxContainer/StatusLabel
@onready var transcription_label = $Control/Panel/MainContainer/VBoxContainer/ContentRow/RightColumn/MicrophonePanel/MarginContainer/VBoxContainer/TranscriptionLabel
@onready var progress_label = $Control/Panel/MainContainer/VBoxContainer/ContentRow/RightColumn/MicrophonePanel/MarginContainer/VBoxContainer/ProgressLabel
@onready var character_image = $Control/Panel/MainContainer/VBoxContainer/ContentRow/CharacterPanel/CharacterImage
@onready var chibi_mic_image = $Control/Panel/MainContainer/VBoxContainer/ContentRow/CharacterPanel/ChibiMicImage
@onready var chat_bubble = $Control/Panel/MainContainer/VBoxContainer/ContentRow/CharacterPanel/ChatBubble
@onready var bubble_label = $Control/Panel/MainContainer/VBoxContainer/ContentRow/CharacterPanel/ChatBubble/BubbleMargin/BubbleLabel
@onready var question_mark = $Control/Panel/MainContainer/VBoxContainer/ContentRow/CharacterPanel/QuestionMark
@onready var game_over_overlay = $Control/GameOverOverlay

# Chibi mic sprites (loaded per protagonist)
var chibi_normal_texture: Texture2D = null
var chibi_talking_texture: Texture2D = null
var _is_chibi_talking: bool = false

# Tutorial overlay (built in code)
var tutorial_overlay: Control = null
var tutorial_page1: Control = null
var tutorial_page2: Control = null
var tutorial_help_button: Button = null

# Choice buttons
@onready var choice_buttons = [
	$Control/Panel/MainContainer/VBoxContainer/ContentRow/RightColumn/ChoicesContainer/Choice1,
	$Control/Panel/MainContainer/VBoxContainer/ContentRow/RightColumn/ChoicesContainer/Choice2,
	$Control/Panel/MainContainer/VBoxContainer/ContentRow/RightColumn/ChoicesContainer/Choice3,
	$Control/Panel/MainContainer/VBoxContainer/ContentRow/RightColumn/ChoicesContainer/Choice4
]

# Timer
var time_remaining: float = 180.0  # 3:00 in seconds
var timer_active: bool = false

# Correct answer index (configurable)
var correct_answer: int = 1  # Default to Choice 2 for janitor scenario

# Selected choice
var selected_choice_index: int = -1

# Configurable question and choices (defaults removed - must be configured via configure_puzzle())
var question_text: String = ""
var choice_texts: Array = []  # Will be populated by configure_puzzle()

# Voice recognition using GodotVoskRecognizer
var vosk_recognizer = null
var audio_effect_capture: AudioEffectCapture = null
var audio_bus_index: int = -1
var microphone_player: AudioStreamPlayer = null
var is_listening: bool = false
var audio_buffer: PackedByteArray = PackedByteArray()
var silence_timer: float = 0.0
var has_spoken: bool = false
const SILENCE_THRESHOLD: float = 1.0  # Stop after 1.0 second of silence (reduced for faster feedback)
var partial_check_timer: float = 0.0
const PARTIAL_CHECK_INTERVAL: float = 0.1  # Check Vosk partial results every 100ms, not every frame

# Word-by-word recognition tracking
var current_word_index: int = 0  # Which word we're currently trying to recognize
var last_partial_text: String = ""  # Track changes in partial results
var word_just_recognized: bool = false  # Prevent double-triggering

# Vosk configuration
const MODEL_PATH = "res://addons/vosk/models/vosk-model-en-us-0.22"  # Large model for better accuracy
const SAMPLE_RATE = 16000.0
const PHRASE_MATCH_THRESHOLD = 0.6  # 60% of words must match
const AUDIO_CHUNK_SIZE = 2048  # Smaller chunks = faster processing (was 4096)

# Homophone/variant groups - words that should be treated as equivalent
# To add more: "base_word": ["variant1", "variant2", "variant3"]
# Example: "im": ["im", "i'm", "i am"] means all three are treated as the same
const HOMOPHONE_GROUPS = {
	"im": ["im", "i'm", "i am"],
	"youre": ["youre", "you're", "you are"],
	"theyre": ["theyre", "they're", "they are"],
	"were": ["were", "we're", "we are"],
	"its": ["its", "it's", "it is"],
	"thats": ["thats", "that's", "that is"],
	"whats": ["whats", "what's", "what is"],
	"hes": ["hes", "he's", "he is"],
	"shes": ["shes", "she's", "she is"],
	"ive": ["ive", "i've", "i have"],
	"weve": ["weve", "we've", "we have"],
	"theyve": ["theyve", "they've", "they have"],
	"youve": ["youve", "you've", "you have"],
	"dont": ["dont", "don't", "do not"],
	"doesnt": ["doesnt", "doesn't", "does not"],
	"didnt": ["didnt", "didn't", "did not"],
	"wont": ["wont", "won't", "will not"],
	"wouldnt": ["wouldnt", "wouldn't", "would not"],
	"couldnt": ["couldnt", "couldn't", "could not"],
	"shouldnt": ["shouldnt", "shouldn't", "should not"],
	"isnt": ["isnt", "isn't", "is not"],
	"arent": ["arent", "aren't", "are not"],
	"wasnt": ["wasnt", "wasn't", "was not"],
	"werent": ["werent", "weren't", "were not"],
	"havent": ["havent", "haven't", "have not"],
	"hasnt": ["hasnt", "hasn't", "has not"],
	"hadnt": ["hadnt", "hadn't", "had not"],
	"cant": ["cant", "can't", "cannot", "can not"],

	# Common Vosk misrecognitions
	"afternoon": ["afternoon", "after noon", "after new"],
	"hoping": ["hoping", "hopping", "hope", "hoping"],
	"looking": ["looking", "lock", "look"],
	"could": ["could", "cold", "good", "called"],
	"something": ["something", "some", "somethin"],
	"unusual": ["unusual", "and usual"],
	"sweeping": ["sweeping", "sweep", "sweeping"],
	"come": ["come", "came", "calm"],
	"across": ["across", "a cross"],
	"anything": ["anything", "any"],
	"while": ["while", "well", "wall"],
}

# Full sentence text with punctuation for display (populated by configure_puzzle())
var full_sentence_texts = []

# Full sentence to pronounce (no punctuation, for matching)
var target_sentence: String = ""
var target_words = []

signal minigame_completed(success: bool)

func configure_puzzle(config: Dictionary):
	"""Configure the minigame with custom question and choices"""
	if config.has("question"):
		question_text = config["question"]
	if config.has("choices"):
		choice_texts = config["choices"]
		full_sentence_texts = config["choices"].duplicate()
	if config.has("correct_index"):
		correct_answer = config["correct_index"]

	print("DEBUG: Dialogue choice configured - Question: ", question_text)
	print("DEBUG: Correct answer index: ", correct_answer)

	# Update UI nodes directly if they're already initialized (configure called after _ready)
	_apply_config_to_ui()

func _apply_config_to_ui():
	"""Apply configured question and choices to UI nodes (safe to call before or after _ready)"""
	if not is_inside_tree():
		return  # Nodes not ready yet, _ready() will handle it

	if question_text != "" and question_label:
		question_label.text = question_text
		print("DEBUG: Question label set to: ", question_text)

	if choice_texts.size() > 0:
		for i in range(min(choice_buttons.size(), choice_texts.size())):
			if choice_buttons[i]:
				choice_buttons[i].text = choice_texts[i]
				print("DEBUG: Button ", i, " text set to: ", choice_texts[i])

func _load_protagonist_image():
	"""Load the chibi sprite based on selected protagonist"""
	var protagonist = PlayerStats.selected_character
	if protagonist.is_empty():
		protagonist = "conrad"

	var chibi_path = "res://Sprites/" + protagonist + "_chibi.png"
	if ResourceLoader.exists(chibi_path):
		character_image.texture = load(chibi_path)
		print("DEBUG: Loaded chibi: ", chibi_path)
	else:
		push_warning("DialogueChoice: chibi image not found at: " + chibi_path)

	# Load normal/talking mic chibi textures
	var normal_path = "res://Sprites/" + protagonist + "_chibi_normal.png"
	var talking_path = "res://Sprites/" + protagonist + "_chibi_talking.png"
	if ResourceLoader.exists(normal_path):
		chibi_normal_texture = load(normal_path)
	if ResourceLoader.exists(talking_path):
		chibi_talking_texture = load(talking_path)

func _set_chibi_mic_state(talking: bool):
	"""Switch chibi mic image between normal and talking states"""
	if _is_chibi_talking == talking:
		return
	_is_chibi_talking = talking
	if talking and chibi_talking_texture:
		chibi_mic_image.texture = chibi_talking_texture
	elif chibi_normal_texture:
		chibi_mic_image.texture = chibi_normal_texture

func _ready():
	visible = true

	# Load protagonist chibi image
	_load_protagonist_image()

	# Apply configured text to UI
	_apply_config_to_ui()

	# Start idle question mark animation
	_start_question_mark_idle()

	# Show tutorial on first encounter, otherwise show help button
	_build_tutorial_overlay()
	if not TutorialFlags.has_seen("dialogue_choice"):
		tutorial_overlay.show()
		tutorial_page1.show()
		tutorial_page2.hide()
		timer_active = false  # Pause timer until tutorial is dismissed
	else:
		tutorial_overlay.hide()
		_add_tutorial_help_button()
		timer_active = true  # Already seen — start immediately

	if VOSK_BYPASS:
		# Bypass mode: no Vosk, no microphone — just click-to-answer
		microphone_panel.visible = false
		print("DialogueChoice: VOSK_BYPASS enabled — click correct answer to complete")
	else:
		_initialize_vosk()
		_setup_audio_capture()

func _build_tutorial_overlay() -> void:
	"""Build the tutorial overlay in code using page1.png and page2.png"""
	tutorial_overlay = Control.new()
	tutorial_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	tutorial_overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.82)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	tutorial_overlay.add_child(dim)

	# --- Page 1: Choice selection (shown first) ---
	tutorial_page1 = _build_tutorial_page(
		"HOW TO PLAY — Step 1 of 2",
		"Read the question at the top, then choose the most polite\nand grammatically correct dialogue option.\nWrong choices will be disabled — think carefully before clicking!",
		"res://assets/tutorials/dialougechoice/page2.png",
		false
	)
	tutorial_overlay.add_child(tutorial_page1)

	# --- Page 2: Mic panel (shown second) ---
	tutorial_page2 = _build_tutorial_page(
		"HOW TO PLAY — Step 2 of 2",
		"After choosing the correct line, the mic panel appears.\nSpeak the sentence clearly into your microphone.\nThe chibi reacts when audio is detected — keep speaking until done!",
		"res://assets/tutorials/dialougechoice/page1.png",
		true
	)
	tutorial_overlay.add_child(tutorial_page2)

	add_child(tutorial_overlay)

func _build_tutorial_page(title: String, description: String, image_path: String, is_last: bool) -> Control:
	"""Create a centered tutorial page with title, description, image, and a Next/Done button"""
	var page = Control.new()
	page.set_anchors_preset(Control.PRESET_FULL_RECT)
	page.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Centered panel — compact, not full screen
	var panel = PanelContainer.new()
	panel.anchor_left = 0.2
	panel.anchor_top = 0.12
	panel.anchor_right = 0.8
	panel.anchor_bottom = 0.88
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.06, 0.04, 0.97)
	style.border_color = Color(0.6, 0.45, 0.2, 0.9)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	panel.add_theme_stylebox_override("panel", style)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 18)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)

	# Title label
	var title_lbl = Label.new()
	title_lbl.text = title
	title_lbl.add_theme_font_size_override("font_size", 22)
	title_lbl.add_theme_color_override("font_color", Color(0.95, 0.8, 0.3, 1.0))
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_lbl)

	# Separator line
	var sep = HSeparator.new()
	sep.add_theme_color_override("color", Color(0.6, 0.45, 0.2, 0.6))
	vbox.add_child(sep)

	# Description label
	var desc_lbl = Label.new()
	desc_lbl.text = description
	desc_lbl.add_theme_font_size_override("font_size", 17)
	desc_lbl.add_theme_color_override("font_color", Color(0.88, 0.85, 0.78, 1.0))
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_lbl)

	# Tutorial image — constrained height
	var img = TextureRect.new()
	img.custom_minimum_size = Vector2(0, 40)
	img.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	img.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ResourceLoader.exists(image_path):
		img.texture = load(image_path)
	vbox.add_child(img)

	# Page indicator dots
	var dots_lbl = Label.new()
	dots_lbl.text = "● ○" if not is_last else "○ ●"
	dots_lbl.add_theme_font_size_override("font_size", 14)
	dots_lbl.add_theme_color_override("font_color", Color(0.6, 0.45, 0.2, 0.8))
	dots_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(dots_lbl)

	# Button
	var btn_label = "Start Playing!" if is_last else "Next →"
	var btn = Button.new()
	btn.text = btn_label
	btn.custom_minimum_size = Vector2(180, 46)
	btn.add_theme_font_size_override("font_size", 20)

	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.2, 0.45, 0.75, 1.0)
	btn_style.corner_radius_top_left = 8
	btn_style.corner_radius_top_right = 8
	btn_style.corner_radius_bottom_left = 8
	btn_style.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", btn_style)
	var btn_hover = btn_style.duplicate()
	btn_hover.bg_color = Color(0.3, 0.6, 1.0, 1.0)
	btn.add_theme_stylebox_override("hover", btn_hover)
	btn.add_theme_color_override("font_color", Color.WHITE)

	var btn_row = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 16)

	# Back button — only on the last page
	if is_last:
		var back_btn = Button.new()
		back_btn.text = "← Back"
		back_btn.custom_minimum_size = Vector2(140, 46)
		back_btn.add_theme_font_size_override("font_size", 20)

		var back_style = StyleBoxFlat.new()
		back_style.bg_color = Color(0.25, 0.18, 0.1, 1.0)
		back_style.border_color = Color(0.6, 0.45, 0.2, 0.8)
		back_style.border_width_left = 2
		back_style.border_width_top = 2
		back_style.border_width_right = 2
		back_style.border_width_bottom = 2
		back_style.corner_radius_top_left = 8
		back_style.corner_radius_top_right = 8
		back_style.corner_radius_bottom_left = 8
		back_style.corner_radius_bottom_right = 8
		back_btn.add_theme_stylebox_override("normal", back_style)
		var back_hover = back_style.duplicate()
		back_hover.bg_color = Color(0.4, 0.28, 0.14, 1.0)
		back_btn.add_theme_stylebox_override("hover", back_hover)
		back_btn.add_theme_color_override("font_color", Color(0.95, 0.85, 0.6, 1.0))
		back_btn.pressed.connect(_on_tutorial_back)
		btn_row.add_child(back_btn)

	btn_row.add_child(btn)
	vbox.add_child(btn_row)

	margin.add_child(vbox)
	panel.add_child(margin)
	page.add_child(panel)

	if is_last:
		btn.pressed.connect(_on_tutorial_done)
	else:
		btn.pressed.connect(_on_tutorial_next)

	return page

func _add_tutorial_help_button() -> void:
	"""Small '?' button at top-right to re-open tutorial after first time"""
	tutorial_help_button = Button.new()
	tutorial_help_button.text = "?"
	tutorial_help_button.tooltip_text = "How to Play"
	tutorial_help_button.custom_minimum_size = Vector2(42, 42)
	tutorial_help_button.add_theme_font_size_override("font_size", 22)

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
	tutorial_help_button.add_theme_stylebox_override("normal", style)
	var hover = style.duplicate()
	hover.bg_color = Color(0.3, 0.5, 0.8, 1.0)
	tutorial_help_button.add_theme_stylebox_override("hover", hover)
	tutorial_help_button.add_theme_color_override("font_color", Color.WHITE)

	tutorial_help_button.anchor_left = 1.0
	tutorial_help_button.anchor_right = 1.0
	tutorial_help_button.anchor_top = 0.0
	tutorial_help_button.anchor_bottom = 0.0
	tutorial_help_button.offset_left = -58.0
	tutorial_help_button.offset_right = -16.0
	tutorial_help_button.offset_top = 16.0
	tutorial_help_button.offset_bottom = 58.0
	tutorial_help_button.pressed.connect(_open_tutorial_popup)
	add_child(tutorial_help_button)

func _open_tutorial_popup() -> void:
	"""Re-open tutorial (pauses timer while open)"""
	timer_active = false
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
	if not TutorialFlags.has_seen("dialogue_choice"):
		TutorialFlags.mark_seen("dialogue_choice")
		_add_tutorial_help_button()
	tutorial_overlay.hide()
	timer_active = true  # Start/resume timer after tutorial dismissed

func _start_question_mark_idle():
	"""Continuously bob and sway the question mark above the chibi head"""
	question_mark.visible = true
	question_mark.pivot_offset = Vector2(question_mark.size.x * 0.5, question_mark.size.y)
	question_mark.rotation_degrees = 45.0  # Base tilt to the right
	_question_mark_idle_loop()

func _question_mark_idle_loop():
	if not is_inside_tree():
		return
	var tween = create_tween()
	tween.set_loops(0)  # Loop forever
	# Bob up and down
	tween.tween_property(question_mark, "position:y", -8.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(question_mark, "position:y", 0.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	# Sway around the 45° base rotation
	tween.parallel()
	tween.tween_property(question_mark, "rotation_degrees", 33.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(question_mark, "rotation_degrees", 57.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func _unhandled_input(event):
	# F5 to skip minigame
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F5:
			print("F5 pressed - Skipping dialogue choice minigame")
			_skip_minigame()

func _process(delta):
	if timer_active:
		time_remaining -= delta
		if time_remaining <= 0:
			time_remaining = 0
			timer_active = false
			_on_timer_timeout()
		_update_timer_display()

	# Process audio capture for Vosk (only when actively listening and not bypassed)
	if VOSK_BYPASS or not is_listening or audio_effect_capture == null:
		return

	# Collect audio frames into buffer
	var frames_available = audio_effect_capture.get_frames_available()
	if frames_available > 0:
		var stereo_data = audio_effect_capture.get_buffer(frames_available)
		# Build mono PCM bytes — pre-size a local buffer to avoid per-byte appends
		var mono_bytes = PackedByteArray()
		mono_bytes.resize(stereo_data.size())  # 2 bytes per stereo frame (L+R averaged → 1 int16)
		var byte_idx = 0
		for i in range(0, stereo_data.size(), 2):
			if i + 1 < stereo_data.size():
				var mono_sample = (stereo_data[i].x + stereo_data[i].y) * 0.5
				var int_sample = int(clamp(mono_sample * 32767.0, -32768.0, 32767.0))
				mono_bytes[byte_idx] = int_sample & 0xFF
				mono_bytes[byte_idx + 1] = (int_sample >> 8) & 0xFF
				byte_idx += 2
		mono_bytes.resize(byte_idx)
		audio_buffer.append_array(mono_bytes)

		# Send full chunks to Vosk
		while audio_buffer.size() >= AUDIO_CHUNK_SIZE:
			vosk_recognizer.accept_waveform(audio_buffer.slice(0, AUDIO_CHUNK_SIZE))
			audio_buffer = audio_buffer.slice(AUDIO_CHUNK_SIZE)

	# Throttle partial result polling to every 100ms (not every frame)
	partial_check_timer += delta
	if partial_check_timer < PARTIAL_CHECK_INTERVAL:
		return
	partial_check_timer = 0.0

	if vosk_recognizer == null:
		return

	var partial_json = vosk_recognizer.get_partial_result()
	var partial = JSON.parse_string(partial_json)
	if partial and partial.has("partial") and partial["partial"] != "":
		var partial_text = partial["partial"]
		_process_partial_text(partial_text)
		has_spoken = true
		silence_timer = 0.0
		_set_chibi_mic_state(true)   # Chibi talks when speech detected
	elif has_spoken:
		silence_timer += delta
		_set_chibi_mic_state(false)  # Chibi goes back to normal during silence
		if silence_timer >= SILENCE_THRESHOLD:
			_check_if_sentence_complete()

func _update_timer_display():
	var minutes = int(time_remaining) / 60
	var seconds = int(time_remaining) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

func _on_choice_selected(choice_index: int):
	selected_choice_index = choice_index

	# Disable all choice buttons
	for button in choice_buttons:
		button.disabled = true

	if choice_index == correct_answer:
		if VOSK_BYPASS:
			# Bypass: show mic panel, animate talking chibi, then auto-complete
			_show_microphone_panel()
			# Animate chibi talking for ~1.5s then go back to normal
			_set_chibi_mic_state(true)
			await get_tree().create_timer(1.5).timeout
			_set_chibi_mic_state(false)
			await get_tree().create_timer(0.5).timeout
			_play_sfx("res://assets/audio/sound_effect/correct.wav")
			await get_tree().create_timer(0.6).timeout
			_complete_minigame(true)
		else:
			_show_microphone_panel()
	else:
		_show_wrong_feedback()

func _show_microphone_panel():
	choices_container.visible = false
	microphone_panel.visible = true
	feedback_label.visible = false

	# Swap to chibi mic image, hide original chibi and question mark
	character_image.visible = false
	question_mark.visible = false
	chibi_mic_image.visible = true
	_set_chibi_mic_state(false)

	# Prepare the target sentence
	_prepare_target_sentence()

	# Display the full sentence
	sentence_display.text = full_sentence_texts[correct_answer]
	status_label.text = "Speak the sentence above"
	progress_label.text = "Ready to listen..."
	transcription_label.text = "Waiting for speech..."

	# Start voice recognition
	_start_sentence_recognition()

func _prepare_target_sentence():
	"""Prepare the target sentence for matching"""
	var full_text = full_sentence_texts[correct_answer]

	# Remove punctuation for matching
	target_sentence = full_text.replace(",", "").replace(".", "").replace("?", "").replace("!", "").replace("—", "").replace("'", "").to_lower()
	target_words = target_sentence.split(" ", false)

	print("DEBUG: Target sentence: ", target_sentence)
	print("DEBUG: Target words (", target_words.size(), "): ", target_words)

func _play_sfx(path: String) -> void:
	var player = AudioStreamPlayer.new()
	player.stream = load(path)
	player.bus = "SFX"
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func _show_wrong_feedback():
	_play_sfx("res://assets/audio/sound_effect/wrong.wav")

	# Show fixed feedback message (not the wrong choice text)
	bubble_label.text = "That's not the right way to approach someone politely. Try again!"

	# Animate question mark above chibi head
	_animate_question_mark()

	chat_bubble.modulate.a = 0.0
	chat_bubble.visible = true

	# Fade in
	var tween_in = create_tween()
	tween_in.tween_property(chat_bubble, "modulate:a", 1.0, 0.25)
	await tween_in.finished

	# Hold for 2.5 seconds
	await get_tree().create_timer(2.5).timeout

	# Fade out
	var tween_out = create_tween()
	tween_out.tween_property(chat_bubble, "modulate:a", 0.0, 0.3)
	await tween_out.finished
	chat_bubble.visible = false

	# Re-enable all buttons except the wrong one
	for i in range(choice_buttons.size()):
		if i != selected_choice_index:
			choice_buttons[i].disabled = false

func _animate_question_mark():
	"""Shake the question mark rapidly left-right on wrong answer"""
	# Flash color to red briefly, then rapid shake
	var tween = create_tween()
	tween.tween_property(question_mark, "modulate", Color(1, 0.2, 0.2, 1), 0.1)
	tween.tween_property(question_mark, "rotation_degrees", 15.0, 0.07)
	tween.tween_property(question_mark, "rotation_degrees", 75.0, 0.07)
	tween.tween_property(question_mark, "rotation_degrees", 15.0, 0.07)
	tween.tween_property(question_mark, "rotation_degrees", 75.0, 0.07)
	tween.tween_property(question_mark, "rotation_degrees", 15.0, 0.07)
	tween.tween_property(question_mark, "rotation_degrees", 45.0, 0.1)
	tween.tween_property(question_mark, "modulate", Color(1, 0.85, 0.1, 1), 0.2)
	await tween.finished

func _initialize_vosk():
	"""Initialize Vosk speech recognizer (use preloaded one if available)"""
	# Try to use the preloaded Vosk from MinigameManager
	if MinigameManager.shared_vosk_recognizer != null:
		vosk_recognizer = MinigameManager.shared_vosk_recognizer
		print("Using preloaded Vosk recognizer from MinigameManager ✓")
		return

	# Fallback: Load Vosk now if not preloaded
	print("Vosk not preloaded, loading now...")
	vosk_recognizer = ClassDB.instantiate("GodotVoskRecognizer")
	var absolute_path = ProjectSettings.globalize_path(MODEL_PATH)

	if not vosk_recognizer.initialize(absolute_path, SAMPLE_RATE):
		push_error("Failed to initialize Vosk recognizer")
		print("ERROR: Vosk failed to initialize at path: ", absolute_path)
		vosk_recognizer = null
		return

	print("Vosk initialized successfully")

func _setup_audio_capture():
	"""Setup audio capture for microphone input"""
	if vosk_recognizer == null:
		print("WARNING: Skipping audio capture setup - Vosk not initialized")
		return

	# Check available input devices
	var input_device_count = AudioServer.get_input_device_list().size()
	print("DEBUG: Available input devices: ", AudioServer.get_input_device_list())
	print("DEBUG: Current input device: ", AudioServer.input_device)

	if input_device_count == 0:
		push_error("No microphone input devices found!")
		return

	# Enable microphone capture
	var idx = AudioServer.get_bus_index("Record")
	if idx == -1:
		# Create Record bus if it doesn't exist
		idx = AudioServer.get_bus_count()
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, "Record")

	audio_bus_index = idx

	# Add capture effect to the Record bus
	audio_effect_capture = AudioEffectCapture.new()
	audio_effect_capture.buffer_length = 0.05  # 50ms buffer for faster response (was 100ms)
	AudioServer.add_bus_effect(audio_bus_index, audio_effect_capture)

	# IMPORTANT: Mute the bus so we don't hear ourselves (prevents echo)
	AudioServer.set_bus_mute(audio_bus_index, true)

	# Create an AudioStreamPlayer to start the microphone
	microphone_player = AudioStreamPlayer.new()
	microphone_player.stream = AudioStreamMicrophone.new()
	microphone_player.bus = "Record"
	add_child(microphone_player)
	microphone_player.play()

	print("Audio capture setup complete with microphone input (muted for recording only)")

func _start_sentence_recognition():
	"""Start listening for word-by-word sequential recognition"""
	if vosk_recognizer == null:
		# Fallback: Auto-complete after 3 seconds for testing
		print("WARNING: Vosk not available - auto-completing")
		await get_tree().create_timer(3.0).timeout
		_complete_minigame(true)
		return

	is_listening = true
	has_spoken = false
	silence_timer = 0.0
	partial_check_timer = 0.0
	audio_buffer.clear()
	vosk_recognizer.reset()
	current_word_index = 0
	last_partial_text = ""
	word_just_recognized = false

	# Show initial state
	_update_word_display()
	status_label.text = "Say the highlighted word!"
	transcription_label.text = ""
	progress_label.text = "Word 1 / " + str(target_words.size())

func _process_partial_text(partial_text: String):
	"""Process partial text and check current word OR multiple words in sequence"""
	if partial_text == last_partial_text or partial_text.strip_edges().is_empty():
		return

	if word_just_recognized:
		return

	var spoken_words = partial_text.to_lower().split(" ", false)
	transcription_label.text = "Hearing: " + partial_text

	# Try to match multiple consecutive words first
	var words_matched = _check_multiple_words_match(spoken_words)
	if words_matched > 0:
		for i in range(words_matched):
			_on_word_recognized()
		return

	# Fall back to single word matching (last spoken word)
	if spoken_words.size() > 0:
		var target_word = target_words[current_word_index]
		var last_spoken_word = spoken_words[spoken_words.size() - 1]
		if _words_match(last_spoken_word, target_word):
			_on_word_recognized()
			return

	last_partial_text = partial_text

func _check_multiple_words_match(spoken_words: Array) -> int:
	"""Check if multiple spoken words match consecutive target words starting from current index"""
	if spoken_words.size() == 0:
		return 0

	var matched_count = 0
	var remaining_target_words = target_words.size() - current_word_index

	# Try to match as many words as possible in sequence
	for i in range(min(spoken_words.size(), remaining_target_words)):
		var spoken_word = spoken_words[i]
		var target_word = target_words[current_word_index + i]

		if _words_match(spoken_word, target_word):
			matched_count += 1
		else:
			# Stop at first non-match
			break

	# Only return match if we got at least 2 words (otherwise single word matching handles it)
	return matched_count if matched_count >= 2 else 0

func _on_word_recognized():
	"""Called when current word is successfully recognized"""
	word_just_recognized = true

	# Mark word as recognized
	current_word_index += 1

	# Update display
	_update_word_display()

	# Update progress
	progress_label.text = "Word " + str(current_word_index + 1) + " / " + str(target_words.size())
	progress_label.add_theme_color_override("font_color", Color.GREEN)

	# Check if we've completed all words
	if current_word_index >= target_words.size():
		_on_all_words_complete()
	else:
		# Prepare for next word
		status_label.text = "Great! Say the next word..."
		await get_tree().create_timer(0.5).timeout  # Brief pause

		if is_listening:  # Make sure we haven't stopped
			word_just_recognized = false
			vosk_recognizer.reset()  # Clear Vosk buffer for next word
			last_partial_text = ""
			transcription_label.text = ""
			status_label.text = "Say: " + target_words[current_word_index]
			progress_label.add_theme_color_override("font_color", Color.WHITE)
			print("Waiting for next word: '", target_words[current_word_index], "'")

func _on_all_words_complete():
	"""Called when all words have been recognized"""
	is_listening = false
	print("SUCCESS: All words recognized!")
	_play_sfx("res://assets/audio/sound_effect/correct.wav")

	# Show completion message
	status_label.text = "✓ COMPLETE!"
	status_label.add_theme_color_override("font_color", Color.GREEN)
	transcription_label.text = "Perfect! You said the entire sentence correctly!"
	transcription_label.add_theme_color_override("font_color", Color.GREEN)

	# Highlight all words green
	var all_green = ""
	for word in target_words:
		all_green += "[color=green]" + word + "[/color] "
	sentence_display.text = all_green.strip_edges()

	await get_tree().create_timer(2.0).timeout
	_complete_minigame(true)

func _update_word_display():
	"""Update the sentence display to highlight current word"""
	var highlighted_sentence = ""

	for i in range(target_words.size()):
		var word = target_words[i]

		if i < current_word_index:
			# Already recognized - show in green
			highlighted_sentence += "[color=green]" + word + "[/color] "
		elif i == current_word_index:
			# Current word - highlight in yellow/bright
			highlighted_sentence += "[color=yellow]" + word + "[/color] "
		else:
			# Not yet reached - show in gray
			highlighted_sentence += "[color=gray]" + word + "[/color] "

	sentence_display.text = highlighted_sentence.strip_edges()

func _check_if_sentence_complete():
	"""Called when silence is detected - give feedback to continue"""
	if not is_listening or word_just_recognized:
		return

	# Encourage user to speak
	if has_spoken:
		status_label.text = "Keep going! Say: " + target_words[current_word_index]

	# Reset for next attempt at current word
	silence_timer = 0.0
	has_spoken = false

# Old function - replaced by progressive word-by-word checking
# func _check_sentence_match(recognized_text: String):
# 	"""Check if recognized sentence matches target sentence"""
# 	# This function is no longer used - see _check_sentence_match_progressive() instead

func _words_match(spoken_word: String, target_word: String) -> bool:
	"""Check if two words match, considering homophones and similarity"""
	spoken_word = spoken_word.to_lower().strip_edges()
	target_word = target_word.to_lower().strip_edges()

	# Direct match
	if spoken_word == target_word:
		return true

	# Check homophone groups
	if _are_homophones(spoken_word, target_word):
		return true

	# Fallback to similarity check (lowered threshold for Vosk small model)
	var similarity = _calculate_similarity(spoken_word, target_word)
	return similarity >= 0.5  # 50% similarity (was 70%)

func _are_homophones(word1: String, word2: String) -> bool:
	"""Check if two words are in the same homophone group"""
	word1 = word1.to_lower().strip_edges()
	word2 = word2.to_lower().strip_edges()

	# Check each homophone group
	for group_key in HOMOPHONE_GROUPS:
		var variants = HOMOPHONE_GROUPS[group_key]
		var word1_in_group = word1 in variants
		var word2_in_group = word2 in variants

		if word1_in_group and word2_in_group:
			return true

	return false

func _calculate_similarity(text1: String, text2: String) -> float:
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

func _on_timer_timeout():
	"""Called when timer reaches zero - show game over overlay, do NOT proceed"""
	print("Timer ran out - showing game over screen")
	is_listening = false
	timer_active = false

	# Disable all choice buttons
	for button in choice_buttons:
		button.disabled = true

	# Show game over overlay with fade-in
	game_over_overlay.modulate.a = 0.0
	game_over_overlay.visible = true
	var tween = create_tween()
	tween.tween_property(game_over_overlay, "modulate:a", 1.0, 0.4)

func _on_try_again_pressed():
	"""Reset the minigame so player can try again"""
	print("Try Again pressed - resetting minigame")

	# Hide overlay
	game_over_overlay.visible = false

	# Reset timer
	time_remaining = 180.0
	timer_active = true

	# Restore choice phase UI (hide mic panel, show original chibi + question mark)
	microphone_panel.visible = false
	choices_container.visible = true
	chibi_mic_image.visible = false
	character_image.visible = true
	question_mark.visible = true
	_is_chibi_talking = false

	# Re-enable all choice buttons and clear wrong selections
	selected_choice_index = -1
	for button in choice_buttons:
		button.disabled = false

	# Restart Vosk if not in bypass mode
	if not VOSK_BYPASS and vosk_recognizer != null:
		is_listening = false
		audio_buffer.clear()
		vosk_recognizer.reset()

func _skip_minigame():
	"""Skip the minigame when F5 is pressed"""
	print("Skipping dialogue choice minigame...")
	is_listening = false  # Stop listening for audio
	_complete_minigame(true)  # Complete as success

func _complete_minigame(success: bool):
	minigame_completed.emit(success)
	_cleanup()
	queue_free()

func _cleanup():
	"""Cleanup audio resources"""
	is_listening = false

	# Stop and remove microphone player
	if microphone_player:
		microphone_player.stop()
		microphone_player.queue_free()
		microphone_player = null

	# Note: Don't remove the Record bus as it might be used elsewhere
	audio_bus_index = -1

func _exit_tree():
	_cleanup()
