extends CanvasLayer

# Set to true to skip Vosk entirely — correct choice click completes the minigame directly.
# Useful for testing layout/logic when Vosk is not working or causes lag.
# On Web, this is overridden — Web Speech API is used instead.
const VOSK_BYPASS: bool = false

# Web Speech API state (web-only)
var _web_speech_active: bool = false
var _web_speech_poll_timer: float = 0.0
const WEB_SPEECH_POLL_INTERVAL: float = 0.1

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

# Countdown overlay
var countdown_overlay: ColorRect = null
var countdown_label: Label = null

const SFX_PATH := "res://assets/audio/sound_effect/timeline_analysis_minigame/"

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

# Tracks indices of wrong choices that should stay permanently disabled
var disabled_wrong_indices: Array = []

# Configurable question and choices (defaults removed - must be configured via configure_puzzle())
var question_text: String = ""
var choice_texts: Array = []  # Will be populated by configure_puzzle()

# Voice recognition using GodotVoskRecognizer (PC) or AndroidSpeechRecognition (Android)
var vosk_recognizer = null
var android_speech = null  # AndroidSpeechRecognition autoload reference (Android only)
var audio_effect_capture: AudioEffectCapture = null
var audio_bus_index: int = -1
var microphone_player: AudioStreamPlayer = null
var is_listening: bool = false
var audio_buffer: PackedByteArray = PackedByteArray()
var silence_timer: float = 0.0
var has_spoken: bool = false
const SILENCE_THRESHOLD: float = 1.2  # Wait 1.2s of silence before checking next word
var partial_check_timer: float = 0.0
const PARTIAL_CHECK_INTERVAL: float = 0.1  # Check Vosk partial results every 100ms, not every frame

# Android-specific silence detection (since the Java plugin may not fire final result)
var _android_silence_timer: float = 0.0
var _android_last_partial: String = ""
var _android_is_listening: bool = false
var _android_prev_input_device: String = ""  # Godot input device before we released it
const ANDROID_SILENCE_TIMEOUT: float = 2.5  # Force-evaluate after 2.5s of no new partials

# Word-by-word recognition tracking
var current_word_index: int = 0  # Which word we're currently trying to recognize
var last_partial_text: String = ""  # Track changes in partial results
var word_just_recognized: bool = false  # Prevent double-triggering

# Short/filler words that Vosk often drops — auto-skip these
const AUTO_SKIP_WORDS = ["a", "an", "the", "i", "to", "of", "in", "is", "it", "be", "as", "at", "so", "we", "he", "by", "or", "on", "do", "if", "me", "my", "up", "an", "go", "no", "us", "am"]

# Vosk configuration
const MODEL_PATH = "res://addons/vosk/models/vosk-model-en-us-0.22"  # Large model for better accuracy
const SAMPLE_RATE = 16000.0
const PHRASE_MATCH_THRESHOLD = 0.35  # 35% of words must match (lenient for non-native speakers)
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

# Sentence-by-sentence reading state
var target_sub_sentences: Array = []   # e.g. ["Good afternoon, sir.", "Have you seen any unusual item while cleaning this room?"]
var current_sub_sentence_index: int = 0  # Which sub-sentence we're on

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

	# Create countdown overlay first
	_create_countdown_overlay()

	# Show tutorial on first encounter, otherwise show help button
	_build_tutorial_overlay()
	if not TutorialFlags.has_seen("dialogue_choice"):
		tutorial_overlay.show()
		tutorial_page1.show()
		tutorial_page2.hide()
		timer_active = false  # Pause timer until tutorial + countdown done
	else:
		tutorial_overlay.hide()
		_add_tutorial_help_button()
		# Play countdown then start timer
		_play_countdown_then_start()

	if OS.get_name() == "Web":
		# Web: microphone panel stays hidden until correct answer selected.
		# Web Speech API will be started then.
		microphone_panel.visible = false
		print("DialogueChoice: Web mode — will use Web Speech API for pronunciation")
	elif OS.get_name() == "Android":
		# Android: use Java plugin singleton directly (bypasses GDScript autoload re-emit chain)
		if Engine.has_singleton("AndroidSpeechRecognition"):
			android_speech = Engine.get_singleton("AndroidSpeechRecognition")
			print("DialogueChoice: Android mode — Java plugin singleton found directly")
		else:
			print("DialogueChoice: Android mode — plugin not found, will auto-complete")
	elif VOSK_BYPASS:
		# Bypass mode: no Vosk, no microphone — just click-to-answer
		microphone_panel.visible = false
		print("DialogueChoice: VOSK_BYPASS enabled — click correct answer to complete")
	else:
		_initialize_vosk()
		_setup_audio_capture()

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


func _play_countdown_then_start() -> void:
	"""Play 3-2-1-START! countdown then activate the timer"""
	countdown_overlay.show()
	countdown_label.pivot_offset = countdown_label.size / 2.0

	var steps = [["3", Color(0.9, 0.3, 0.3, 1)], ["2", Color(0.9, 0.7, 0.2, 1)], ["1", Color(0.3, 0.85, 0.4, 1)], ["START!", Color(1, 1, 1, 1)]]

	for step in steps:
		var text = step[0]
		var color = step[1]
		countdown_label.text = text
		countdown_label.add_theme_color_override("font_color", color)
		countdown_label.scale = Vector2(1.5, 1.5)
		countdown_label.modulate.a = 1.0

		match text:
			"3": _play_countdown_sfx(SFX_PATH + "three.mp3")
			"2": _play_countdown_sfx(SFX_PATH + "two.mp3")
			"1": _play_countdown_sfx(SFX_PATH + "one.mp3")
			"START!":
				_play_countdown_sfx(SFX_PATH + "start.mp3")
				_play_countdown_sfx(SFX_PATH + "Whistle.mp3")

		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(countdown_label, "scale", Vector2(1.0, 1.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		if text == "START!":
			tween.tween_property(countdown_label, "modulate:a", 0.0, 0.6).set_delay(0.4)
		await get_tree().create_timer(0.8).timeout

	countdown_overlay.hide()
	timer_active = true


func _play_countdown_sfx(path: String) -> void:
	var player = AudioStreamPlayer.new()
	if ResourceLoader.exists(path):
		player.stream = load(path)
		player.bus = "SFX"
		add_child(player)
		player.play()
		player.finished.connect(player.queue_free)


func _build_tutorial_overlay() -> void:
	"""Build the tutorial overlay in code using protagonist-specific images"""
	# Determine protagonist suffix
	var protagonist = "conrad"
	if PlayerStats and PlayerStats.get("selected_character") != null:
		protagonist = PlayerStats.selected_character
	var suffix = "_" + protagonist  # e.g. "_conrad" or "_celestine"

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
		"res://assets/tutorials/dialougechoice/page2" + suffix + ".png",
		false
	)
	tutorial_overlay.add_child(tutorial_page1)

	# --- Page 2: Mic panel (shown second) ---
	var mic_description: String
	if OS.get_name() == "Web":
		mic_description = "After choosing the correct line, the mic panel appears.\nSpeak the sentence clearly — your browser will listen.\nAllow microphone access when prompted. Speak naturally!"
	else:
		mic_description = "After choosing the correct line, the mic panel appears.\nSpeak the sentence clearly into your microphone.\nThe chibi reacts when audio is detected — keep speaking until done!"
	tutorial_page2 = _build_tutorial_page(
		"HOW TO PLAY — Step 2 of 2",
		mic_description,
		"res://assets/tutorials/dialougechoice/page1" + suffix + ".png",
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
	"""Re-open tutorial (pauses timer while open, resumes after done)"""
	timer_active = false
	tutorial_overlay.show()
	tutorial_page1.show()
	tutorial_page2.hide()
	# Note: _on_tutorial_done() will resume the timer (no countdown on re-open)
	# Override: resume timer directly when done button pressed from popup
	# Done via _on_tutorial_done() which calls _play_countdown_then_start()

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
	# Play countdown then start timer
	_play_countdown_then_start()

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

	# Poll Web Speech API results (web-only)
	if _web_speech_active:
		_web_speech_poll_timer += delta
		if _web_speech_poll_timer >= WEB_SPEECH_POLL_INTERVAL:
			_web_speech_poll_timer = 0.0
			_poll_web_speech()

	# Android silence detection — fire result if partial text stops changing for 2.5s
	# Do NOT restart on no-speech: Vosk needs to run uninterrupted to produce output.
	# onTimeout() (error 6) from Java will fire naturally after prolonged silence.
	if _android_is_listening:
		_android_silence_timer += delta
		if _android_last_partial != "" and _android_silence_timer >= ANDROID_SILENCE_TIMEOUT:
			print("DialogueChoice: Android silence timeout — evaluating partial: ", _android_last_partial)
			_android_is_listening = false
			_on_android_speech_result(_android_last_partial)
			return

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
			_check_if_word_timed_out()

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
		if OS.get_name() == "Web":
			# Web: show mic panel and start Web Speech API recognition
			_show_microphone_panel()
		elif VOSK_BYPASS:
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

	# Prepare sub-sentences (splits on . , ? !)
	_prepare_target_sentence()

	# Display the full sentence with first sub-sentence highlighted
	_update_sub_sentence_display()
	status_label.text = "Read part 1 of %d" % target_sub_sentences.size()
	progress_label.text = "Ready to listen..."
	transcription_label.text = "Waiting for speech..."

	# Start voice recognition
	_start_sentence_recognition()

func _prepare_target_sentence():
	"""Split the full sentence into sub-sentences at punctuation boundaries"""
	var full_text = full_sentence_texts[correct_answer]

	# Split on sentence-ending or clause punctuation: . , ? !
	# Keep the delimiter attached to the preceding chunk so display looks natural
	target_sub_sentences = []
	var current_chunk := ""
	for ch in full_text:
		current_chunk += ch
		if ch in [".", ",", "?", "!"]:
			var trimmed = current_chunk.strip_edges()
			if trimmed != "" and trimmed != "." and trimmed != "," and trimmed != "?" and trimmed != "!":
				target_sub_sentences.append(trimmed)
			current_chunk = ""
	# Any trailing text without punctuation
	var leftover = current_chunk.strip_edges()
	if leftover != "":
		target_sub_sentences.append(leftover)

	# If nothing was split (no punctuation), treat the whole sentence as one chunk
	if target_sub_sentences.is_empty():
		target_sub_sentences = [full_text.strip_edges()]

	current_sub_sentence_index = 0
	print("DEBUG: Sub-sentences: ", target_sub_sentences)
	_prepare_sub_sentence(current_sub_sentence_index)

func _prepare_sub_sentence(idx: int):
	"""Prepare target_words for sub-sentence at idx"""
	var chunk = target_sub_sentences[idx]
	target_sentence = chunk.replace(",", "").replace(".", "").replace("?", "").replace("!", "").replace("—", "").replace("'", "").to_lower()
	target_words = target_sentence.split(" ", false)
	print("DEBUG: Sub-sentence %d: '%s'" % [idx, chunk])
	print("DEBUG: Target words (%d): %s" % [target_words.size(), target_words])

func _update_sub_sentence_display():
	"""Show full sentence: done parts in green, current part in yellow, future parts in gray"""
	var display := ""
	for i in range(target_sub_sentences.size()):
		var part = target_sub_sentences[i]
		if i < current_sub_sentence_index:
			display += "[color=green]" + part + "[/color] "
		elif i == current_sub_sentence_index:
			display += "[color=yellow]" + part + "[/color] "
		else:
			display += "[color=gray]" + part + "[/color] "
	sentence_display.text = display.strip_edges()

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

func _show_wrong_feedback():
	_play_sfx("res://assets/audio/sound_effect/wrong.wav")

	# Permanently record this wrong choice so it stays disabled
	if selected_choice_index not in disabled_wrong_indices:
		disabled_wrong_indices.append(selected_choice_index)

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

	# Re-enable buttons that haven't been selected wrongly before
	for i in range(choice_buttons.size()):
		if i not in disabled_wrong_indices:
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
	# Android uses its own AAR-based plugin — skip Windows Vosk entirely
	if OS.get_name() == "Android":
		return

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
	if OS.get_name() == "Web":
		_start_web_speech_recognition()
		return

	if OS.get_name() == "Android":
		_start_android_speech_recognition()
		return

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

	# Auto-skip leading short words Vosk commonly misses
	_skip_auto_words()

	# Show initial state
	_update_word_display()
	status_label.text = "Say: " + target_words[current_word_index]
	transcription_label.text = ""
	progress_label.text = "Word " + str(current_word_index + 1) + " / " + str(target_words.size())

func _start_web_speech_recognition() -> void:
	"""Start Web Speech API recognition (Chrome/Edge only)"""
	_web_speech_active = true
	_web_speech_poll_timer = 0.0

	var part_num = current_sub_sentence_index + 1
	var total = target_sub_sentences.size()
	status_label.text = "READ PART %d OF %d OUT LOUD" % [part_num, total]
	transcription_label.text = "Waiting for speech..."
	progress_label.text = "Listening — speak now!"
	_set_chibi_mic_state(true)

	# Inject Web Speech API listener into the browser.
	# Results are stored in window._speechResult (dict with 'transcript' and 'done' keys).
	# Interim results update window._speechResult.transcript in real-time.
	JavaScriptBridge.eval("""
		(function() {
			window._speechResult = { transcript: '', done: false, error: '' };
			var SR = window.SpeechRecognition || window.webkitSpeechRecognition;
			if (!SR) {
				window._speechResult.error = 'not_supported';
				window._speechResult.done = true;
				return;
			}
			var recog = new SR();
			recog.lang = 'en-US';
			recog.interimResults = true;
			recog.continuous = false;
			recog.maxAlternatives = 1;
			recog.onresult = function(e) {
				var interim = '';
				var final_t = '';
				for (var i = e.resultIndex; i < e.results.length; i++) {
					var t = e.results[i][0].transcript;
					if (e.results[i].isFinal) { final_t += t; }
					else { interim += t; }
				}
				window._speechResult.transcript = (final_t || interim).trim();
				if (final_t) {
					window._speechResult.done = true;
				}
			};
			recog.onerror = function(e) {
				window._speechResult.error = e.error;
				window._speechResult.done = true;
			};
			recog.onend = function() {
				window._speechResult.done = true;
			};
			window._godotSpeechRecog = recog;
			recog.start();
			console.log('[SpeechAPI] Started listening');
		})();
	""")
	print("DialogueChoice: Web Speech API started")

func _start_android_speech_recognition() -> void:
	"""Start Android Vosk AAR speech recognition"""
	if android_speech == null:
		print("WARNING: Android speech not available - auto-completing")
		await get_tree().create_timer(3.0).timeout
		_complete_minigame(true)
		return

	is_listening = true
	has_spoken = false
	status_label.text = "Waiting for speech..."
	transcription_label.text = ""

	# Connect signals if not already connected (direct Java plugin signals)
	if not android_speech.speech_recognized.is_connected(_on_android_speech_result):
		android_speech.speech_recognized.connect(_on_android_speech_result)
	if not android_speech.speech_partial_result.is_connected(_on_android_speech_partial):
		android_speech.speech_partial_result.connect(_on_android_speech_partial)
	if not android_speech.speech_end.is_connected(_on_android_speech_end):
		android_speech.speech_end.connect(_on_android_speech_end)
	if not android_speech.speech_error.is_connected(_on_android_speech_error):
		android_speech.speech_error.connect(_on_android_speech_error)
	if not android_speech.speech_begin.is_connected(_on_android_speech_begin):
		android_speech.speech_begin.connect(_on_android_speech_begin)
	if not android_speech.speech_ready_for_speech.is_connected(_on_android_ready_for_speech):
		android_speech.speech_ready_for_speech.connect(_on_android_ready_for_speech)

	# Ensure microphone permission is granted (Android 6+)
	var permissions = OS.get_granted_permissions()
	print("DialogueChoice: Granted permissions: ", permissions)
	if "android.permission.RECORD_AUDIO" not in permissions:
		print("DialogueChoice: RECORD_AUDIO not granted — requesting...")
		status_label.text = "Microphone permission needed..."
		OS.request_permissions()
		# Wait up to 8s for user to grant
		var waited_perm := 0
		while waited_perm < 8:
			await get_tree().create_timer(1.0).timeout
			permissions = OS.get_granted_permissions()
			if "android.permission.RECORD_AUDIO" in permissions:
				print("DialogueChoice: RECORD_AUDIO granted after ", waited_perm + 1, "s")
				break
			waited_perm += 1
		if "android.permission.RECORD_AUDIO" not in permissions:
			print("DialogueChoice: RECORD_AUDIO DENIED — auto-completing")
			status_label.text = "Mic permission denied — skipping"
			await get_tree().create_timer(2.0).timeout
			_complete_minigame(true)
			return
	else:
		print("DialogueChoice: RECORD_AUDIO permission already granted ✓")

	# Ensure Vosk model is initialized before calling startListening.
	# isAvailable() returns true only after initModelFromAssets() completes.
	var model_ready: bool = android_speech.call("isAvailable")
	if not model_ready:
		print("DialogueChoice: Vosk model not ready — calling initModelFromAssets()")
		status_label.text = "Loading speech model..."
		# Connect model_initialized signal once to know when it's done
		if not android_speech.model_initialized.is_connected(_on_android_model_initialized):
			android_speech.model_initialized.connect(_on_android_model_initialized, CONNECT_ONE_SHOT)
		android_speech.call("initModelFromAssets")
		# Poll until available (up to 30s) as backup if signal doesn't fire
		var waited := 0
		while waited < 30 and not android_speech.call("isAvailable"):
			await get_tree().create_timer(1.0).timeout
			waited += 1
			if waited % 5 == 0:
				print("DialogueChoice: Still waiting for Vosk model... (", waited, "s)")
		model_ready = android_speech.call("isAvailable")
		if not model_ready:
			print("DialogueChoice: Vosk model FAILED to initialize — auto-completing")
			status_label.text = "Speech model unavailable"
			await get_tree().create_timer(2.0).timeout
			_complete_minigame(true)
			return
		print("DialogueChoice: Vosk model ready after waiting")
		status_label.text = "Waiting for speech..."

	_android_is_listening = true
	_android_silence_timer = 0.0
	_android_last_partial = ""

	# Release Godot's hold on the audio input device so the Java SpeechService
	# can get exclusive mic access (Android only allows one consumer at a time).
	# Without this, the Java VAD receives silence even though the mic appears open.
	if AudioServer.input_device != "Disabled":
		_android_prev_input_device = AudioServer.input_device
		print("DialogueChoice: Releasing Godot audio input (was: '", _android_prev_input_device, "')")
		AudioServer.input_device = "Disabled"
		await get_tree().create_timer(0.2).timeout
		if not is_instance_valid(self) or not timer_active:
			AudioServer.input_device = _android_prev_input_device
			return

	# Reset any stale Java listener state before starting fresh
	android_speech.call("stopListening")
	await get_tree().create_timer(0.15).timeout
	if not is_instance_valid(self) or not timer_active:
		if _android_prev_input_device != "":
			AudioServer.input_device = _android_prev_input_device
		return

	# Call Java startListening — emits speech_ready_for_speech when ready
	var result = android_speech.call("startListening")
	print("DialogueChoice: startListening() result: ", result)
	print("DialogueChoice: Android speech recognition started (direct Java call)")

func _on_android_model_initialized() -> void:
	"""Called when Vosk model finishes initializing (one-shot signal)"""
	print("DialogueChoice: Vosk model initialized signal received")

func _on_android_ready_for_speech() -> void:
	"""Java SpeechService is open and listening — mic is active"""
	print("DialogueChoice: ✓ Ready for speech — mic is active, speak now")
	status_label.text = "Mic active — speak now!"

func _on_android_speech_begin() -> void:
	"""Java SpeechService detected audio energy (voice onset)"""
	print("DialogueChoice: ✓ speech_begin — voice detected by Android!")
	status_label.text = "Listening..."
	_set_chibi_mic_state(true)

func _stop_android_speech_recognition() -> void:
	"""Stop Android speech recognition, disconnect signals, and restore audio input"""
	_android_is_listening = false
	if android_speech == null:
		return
	android_speech.call("stopListening")
	if android_speech.speech_recognized.is_connected(_on_android_speech_result):
		android_speech.speech_recognized.disconnect(_on_android_speech_result)
	if android_speech.speech_partial_result.is_connected(_on_android_speech_partial):
		android_speech.speech_partial_result.disconnect(_on_android_speech_partial)
	if android_speech.speech_end.is_connected(_on_android_speech_end):
		android_speech.speech_end.disconnect(_on_android_speech_end)
	if android_speech.speech_error.is_connected(_on_android_speech_error):
		android_speech.speech_error.disconnect(_on_android_speech_error)
	if android_speech.speech_begin.is_connected(_on_android_speech_begin):
		android_speech.speech_begin.disconnect(_on_android_speech_begin)
	if android_speech.speech_ready_for_speech.is_connected(_on_android_ready_for_speech):
		android_speech.speech_ready_for_speech.disconnect(_on_android_ready_for_speech)
	# Restore Godot's audio input device
	if _android_prev_input_device != "" and AudioServer.input_device == "Disabled":
		print("DialogueChoice: Restoring Godot audio input to '", _android_prev_input_device, "'")
		AudioServer.input_device = _android_prev_input_device
		_android_prev_input_device = ""
	is_listening = false

func _on_android_speech_partial(text: String) -> void:
	"""Show partial transcription while user is speaking"""
	transcription_label.text = text
	status_label.text = "Listening..."
	# Reset silence timer whenever we get a new partial
	if text != _android_last_partial:
		_android_last_partial = text
		_android_silence_timer = 0.0

func _on_android_speech_result(text: String) -> void:
	"""Handle final Android speech result — match against target sentence"""
	is_listening = false
	_stop_android_speech_recognition()
	print("DialogueChoice: Android speech result: ", text)
	transcription_label.text = text

	# Build full target sentence from target_words
	var target_sentence = " ".join(target_words)
	var match_score = _calculate_similarity(text.to_lower(), target_sentence.to_lower())
	print("DialogueChoice: Android match score: ", match_score, " (threshold: 0.6)")

	if match_score >= 0.6:
		status_label.text = "Great job!"
		_complete_minigame(true)
	else:
		status_label.text = "Try again! Say: " + target_sentence
		# Restart listening for retry
		await get_tree().create_timer(1.5).timeout
		if is_instance_valid(self):
			_start_android_speech_recognition()

func _on_android_speech_end() -> void:
	"""Java SpeechService detected end-of-speech but Vosk may not have emitted a result yet.
	   If we have partial text, evaluate it now. If empty, restart to try again."""
	print("DialogueChoice: Android speech_end fired. Last partial: '", _android_last_partial, "'")
	if not _android_is_listening:
		return  # Already handled (e.g., silence timeout already fired)
	if _android_last_partial != "":
		# We have partial text — evaluate it as the final result
		_android_is_listening = false
		_on_android_speech_result(_android_last_partial)
	else:
		# No speech recognized at all — restart immediately
		_android_is_listening = false
		_android_silence_timer = 0.0
		status_label.text = "Didn't catch that — please try again"
		android_speech.call("stopListening")
		await get_tree().create_timer(0.5).timeout
		if is_instance_valid(self) and timer_active:
			_start_android_speech_recognition()

func _on_android_speech_error(error) -> void:
	"""Handle Vosk recognition errors — Java emits Integer error codes, not String.
	   Error 6 = onTimeout (silence/no-speech) — restart listening.
	   Error 5 = client error (model/AudioRecord failed) — restart after delay."""
	print("DialogueChoice: Android speech_error code: ", error)
	if not _android_is_listening:
		return
	_android_is_listening = false
	_android_silence_timer = 0.0
	var error_int = int(error)
	if error_int == 6:
		# Vosk onTimeout: no speech detected. Restart immediately.
		status_label.text = "No speech detected — speak now!"
		await get_tree().create_timer(0.3).timeout
	else:
		status_label.text = "Mic error (" + str(error) + ") — retrying..."
		await get_tree().create_timer(0.8).timeout
	if is_instance_valid(self) and timer_active:
		_start_android_speech_recognition()

func _stop_web_speech_recognition() -> void:
	"""Stop the Web Speech API recognizer"""
	_web_speech_active = false
	JavaScriptBridge.eval("""
		if (window._godotSpeechRecog) {
			try { window._godotSpeechRecog.stop(); } catch(e) {}
			window._godotSpeechRecog = null;
		}
	""")

func _poll_web_speech() -> void:
	"""Poll window._speechResult for interim/final transcript from Web Speech API"""
	var transcript: String = JavaScriptBridge.eval("(window._speechResult && window._speechResult.transcript) ? window._speechResult.transcript : ''")
	var done: bool = bool(JavaScriptBridge.eval("window._speechResult ? window._speechResult.done : false"))
	var error: String = JavaScriptBridge.eval("(window._speechResult && window._speechResult.error) ? window._speechResult.error : ''")

	# Show interim transcript in real-time
	if transcript != "":
		transcription_label.text = "Hearing: " + transcript
		_set_chibi_mic_state(true)

	if not done:
		return

	# Recognition session ended — evaluate result
	_web_speech_active = false
	_set_chibi_mic_state(false)

	if error != "":
		print("Web Speech error: ", error)
		if error == "not_supported":
			status_label.text = "Speech API not supported in this browser."
			transcription_label.text = "Try Chrome or Edge."
			# Auto-complete after showing the message so game isn't stuck
			await get_tree().create_timer(3.0).timeout
			_complete_minigame(true)
		elif error == "no-speech":
			status_label.text = "No speech detected. Try again!"
			transcription_label.text = ""
			# Re-start listening
			await get_tree().create_timer(1.0).timeout
			if timer_active:
				_start_web_speech_recognition()
		else:
			status_label.text = "Mic error: " + error + ". Try again!"
			await get_tree().create_timer(1.5).timeout
			if timer_active:
				_start_web_speech_recognition()
		return

	if transcript.is_empty():
		# Session ended with no result — restart
		status_label.text = "Didn't catch that. Try again!"
		await get_tree().create_timer(0.8).timeout
		if timer_active:
			_start_web_speech_recognition()
		return

	# Evaluate transcript against target sentence
	_evaluate_web_speech_result(transcript)

func _evaluate_web_speech_result(transcript: String) -> void:
	"""Check how well the spoken transcript matches the target sentence"""
	var spoken_clean = transcript.replace(",", "").replace(".", "").replace("?", "").replace("!", "").to_lower().strip_edges()
	var spoken_words = spoken_clean.split(" ", false)

	# Count how many target words were spoken (order-insensitive, lenient match)
	var matched := 0
	var used := []
	used.resize(spoken_words.size())
	used.fill(false)

	for t_word in target_words:
		if t_word in AUTO_SKIP_WORDS:
			matched += 1  # Auto-credit filler words
			continue
		for j in range(spoken_words.size()):
			if not used[j] and _words_match(spoken_words[j], t_word):
				matched += 1
				used[j] = true
				break

	var match_ratio: float = float(matched) / float(max(target_words.size(), 1))
	print("Web Speech match: %d/%d words (%.0f%%)" % [matched, target_words.size(), match_ratio * 100])

	if match_ratio >= PHRASE_MATCH_THRESHOLD:
		_play_sfx("res://assets/audio/sound_effect/correct.wav")
		current_sub_sentence_index += 1

		if current_sub_sentence_index >= target_sub_sentences.size():
			# All parts done
			status_label.text = "✓ COMPLETE!"
			status_label.add_theme_color_override("font_color", Color.GREEN)
			transcription_label.text = "Great job! You read the entire sentence!"
			transcription_label.add_theme_color_override("font_color", Color.GREEN)
			_update_sub_sentence_display()
			await get_tree().create_timer(1.5).timeout
			_complete_minigame(true)
		else:
			# Advance to next sub-sentence
			status_label.text = "✓ Good! Next part..."
			status_label.add_theme_color_override("font_color", Color.GREEN)
			transcription_label.text = ""
			_update_sub_sentence_display()
			await get_tree().create_timer(0.8).timeout
			_prepare_sub_sentence(current_sub_sentence_index)
			status_label.add_theme_color_override("font_color", Color.WHITE)
			if timer_active:
				_start_web_speech_recognition()
	else:
		# Not enough words matched — let them try again
		_play_sfx("res://assets/audio/sound_effect/wrong.wav")
		var part_num = current_sub_sentence_index + 1
		status_label.text = "Try again! Read part %d clearly." % part_num
		transcription_label.text = "I heard: \"" + transcript + "\""
		transcription_label.add_theme_color_override("font_color", Color(1, 0.5, 0.3, 1))
		_update_sub_sentence_display()
		await get_tree().create_timer(1.8).timeout
		if timer_active:
			transcription_label.add_theme_color_override("font_color", Color.WHITE)
			_start_web_speech_recognition()

func _skip_auto_words():
	"""Skip short filler words that Vosk commonly drops"""
	while current_word_index < target_words.size() and target_words[current_word_index].to_lower() in AUTO_SKIP_WORDS:
		print("Auto-skipping short word: '", target_words[current_word_index], "'")
		current_word_index += 1

func _process_partial_text(partial_text: String):
	"""Check any spoken word against the current target word"""
	if partial_text == last_partial_text or partial_text.strip_edges().is_empty():
		return

	if word_just_recognized:
		return

	last_partial_text = partial_text
	var spoken_words = partial_text.to_lower().split(" ", false)
	transcription_label.text = "Hearing: " + partial_text

	if current_word_index >= target_words.size():
		return

	var target_word = target_words[current_word_index]

	# Check every spoken word — Vosk may put the right word anywhere in the partial
	for spoken_word in spoken_words:
		if _words_match(spoken_word, target_word):
			_on_word_recognized()
			return

func _on_word_recognized():
	"""Called when current word is successfully recognized"""
	word_just_recognized = true

	# Advance past recognized word, then auto-skip any short filler words
	current_word_index += 1
	_skip_auto_words()

	# Update display
	_update_word_display()

	# Check if we've completed all words
	if current_word_index >= target_words.size():
		_on_all_words_complete()
		return

	# Update progress
	progress_label.text = "Word " + str(current_word_index + 1) + " / " + str(target_words.size())
	progress_label.add_theme_color_override("font_color", Color.GREEN)

	# Prepare for next word
	status_label.text = "✓ Good! Next word..."
	await get_tree().create_timer(0.4).timeout  # Brief pause

	if is_listening:  # Make sure we haven't stopped
		word_just_recognized = false
		vosk_recognizer.reset()  # Clear Vosk buffer for next word
		last_partial_text = ""
		transcription_label.text = ""
		status_label.text = "Say: " + target_words[current_word_index]
		progress_label.add_theme_color_override("font_color", Color.WHITE)
		print("Waiting for next word: '", target_words[current_word_index], "'")

func _on_all_words_complete():
	"""Called when all words of the current sub-sentence are recognized"""
	is_listening = false
	_play_sfx("res://assets/audio/sound_effect/correct.wav")

	current_sub_sentence_index += 1
	print("Sub-sentence done. Next: %d / %d" % [current_sub_sentence_index, target_sub_sentences.size()])

	if current_sub_sentence_index >= target_sub_sentences.size():
		# All sub-sentences done — full completion
		status_label.text = "✓ COMPLETE!"
		status_label.add_theme_color_override("font_color", Color.GREEN)
		transcription_label.text = "Perfect! You read the entire sentence!"
		transcription_label.add_theme_color_override("font_color", Color.GREEN)
		# Show everything green
		_update_sub_sentence_display()
		await get_tree().create_timer(2.0).timeout
		_complete_minigame(true)
	else:
		# Advance to next sub-sentence
		status_label.text = "✓ Good! Next part..."
		status_label.add_theme_color_override("font_color", Color.GREEN)
		transcription_label.text = ""
		_update_sub_sentence_display()
		await get_tree().create_timer(0.8).timeout

		# Prepare next sub-sentence words
		_prepare_sub_sentence(current_sub_sentence_index)

		# Reset recognition state for next chunk
		status_label.add_theme_color_override("font_color", Color.WHITE)
		status_label.text = "Read part %d of %d" % [current_sub_sentence_index + 1, target_sub_sentences.size()]
		progress_label.text = "Ready..."
		transcription_label.text = ""

		# Restart listening for this sub-sentence
		_start_sentence_recognition()

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

func _check_if_word_timed_out():
	"""Called when silence detected — prompt player to say current word again"""
	if not is_listening or word_just_recognized:
		return

	silence_timer = 0.0
	has_spoken = false

	if current_word_index < target_words.size():
		status_label.text = "Try again! Say: " + target_words[current_word_index]
		transcription_label.text = ""
		# Reset Vosk so it starts fresh for the retry
		vosk_recognizer.reset()
		last_partial_text = ""

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

	# Fallback to similarity check — lenient for non-native speakers and Vosk quirks
	var similarity = _calculate_similarity(spoken_word, target_word)
	return similarity >= 0.4  # 40% similarity threshold

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

	# Stop Web Speech API if running
	if _web_speech_active:
		_stop_web_speech_recognition()

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
	current_sub_sentence_index = 0

	# Re-enable all choice buttons and clear wrong selections
	selected_choice_index = -1
	disabled_wrong_indices.clear()
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

	# Stop Web Speech API if active
	if _web_speech_active:
		_stop_web_speech_recognition()

	# Stop Android speech if active
	if OS.get_name() == "Android" and android_speech != null:
		_android_is_listening = false
		android_speech.call("stopListening")

	# Stop and remove microphone player
	if microphone_player:
		microphone_player.stop()
		microphone_player.queue_free()
		microphone_player = null

	# Note: Don't remove the Record bus as it might be used elsewhere
	audio_bus_index = -1

func _exit_tree():
	_cleanup()
