extends Control

## Timeline Reconstruction Minigame
## Drag-and-drop events into correct chronological order
## Students sequence events based on time, causality, and evidence

# UI Nodes
@onready var title_label: Label = $Panel/VBox/Header/TitleLabel
@onready var subtitle_label: Label = $Panel/VBox/Header/SubtitleLabel
@onready var context_label: RichTextLabel = $Panel/VBox/ContextPanel/ContextLabel
@onready var events_pool: HBoxContainer = $Panel/VBox/MainContent/EventsContainer/EventsPanel/EventsPool
@onready var timeline_slots: HBoxContainer = $Panel/VBox/MainContent/TimelineContainer/TimelinePanel/TimelineSlots
@onready var timer_label: Label = $Panel/VBox/TopBar/TimerPanel/TimerLabel
@onready var hint_button: Button = $Panel/VBox/TopBar/HintPanel/HintHBox/HintButton
@onready var hint_counter: Label = $Panel/VBox/TopBar/HintPanel/HintHBox/HintCounter
@onready var submit_button: Button = $Panel/VBox/SubmitButtonContainer/SubmitButton
@onready var feedback_panel: NinePatchRect = $FeedbackPanel
@onready var feedback_icon: Label = $FeedbackPanel/VBox/FeedbackIcon
@onready var feedback_title: Label = $FeedbackPanel/VBox/FeedbackTitle
@onready var feedback_label: RichTextLabel = $FeedbackPanel/VBox/FeedbackScroll/FeedbackLabel
@onready var continue_button: Button = $FeedbackPanel/VBox/ButtonsHBox/ContinueButton
@onready var retry_button: Button = $FeedbackPanel/VBox/ButtonsHBox/RetryButton

# Tutorial nodes (will be crefted dynamically)
var tutorial_overlay: ColorRect
var tutorial_panel: Panel
var tutorial_image: TextureRect
var tutorial_title: Label
var tutorial_instructions: RichTextLabel
var tutorial_button_container: HBoxContainer
var tutorial_back_button: Button
var tutorial_next_button: Button
var tutorial_start_button: Button
var tutorial_current_page: int = 0
var tutorial_image_page1: String = ""
var tutorial_image_page2: String = ""

# Style references
@onready var main_panel: NinePatchRect = $Panel
@onready var header_panel: VBoxContainer = $Panel/VBox/Header
@onready var timer_panel: PanelContainer = $Panel/VBox/TopBar/TimerPanel
@onready var hint_panel: PanelContainer = $Panel/VBox/TopBar/HintPanel
@onready var context_panel: PanelContainer = $Panel/VBox/ContextPanel

# Card colors
const CARD_COLOR_NORMAL := Color(0.72, 0.50, 0.18, 1.0)   # Orange/yellow
const CARD_COLOR_HOVER  := Color(0.90, 0.65, 0.25, 1.0)   # Brighter on hover
const SLOT_COLOR_NORMAL := Color(0.22, 0.38, 0.60, 1.0)   # Blue
const SLOT_COLOR_HOVER  := Color(0.32, 0.52, 0.80, 1.0)   # Lighter blue on hover

# Minigame data
var puzzle_config: Dictionary = {}
var events: Array = []  # Event data with time/text
var correct_order: Array = []  # Correct sequence
var current_order: Array = []  # Player's current sequence
var dragging_event: Dictionary = {}
var start_time: float = 0.0
var time_limit: float = 120.0  # 2 minutes
var hint_used: bool = false
var first_attempt: bool = true  # Track if this is first attempt
var first_attempt_correct: bool = false  # Track first attempt accuracy

# Hint cooldown system
var hint_cooldown_time: float = 12.0  # 12 seconds cooldown
var hint_cooldown_remaining: float = 0.0
var hint_on_cooldown: bool = false

# Timer warning sound tracking (play each only once per round)
var played_one_minute_sfx: bool = false
var played_thirty_sec_sfx: bool = false
var played_ten_sec_sfx: bool = false

# SFX base path
const SFX_PATH := "res://assets/audio/sound_effect/timeline_analysis_minigame/"

# Drag-and-drop state
var currently_dragging_card: Control = null

# Tutorial first-time tracking (resets each scene load)
var seen_tutorial: bool = false

# Countdown overlay
var countdown_overlay: ColorRect
var countdown_label: Label

signal minigame_completed(success: bool, time_taken: float)

# Cached icon textures for feedback
var _icon_correct: Texture2D = null
var _icon_incorrect: Texture2D = null
var _icon_timer: Texture2D = null

func _set_feedback_icon(icon_name: String) -> void:
	"""Set the feedback icon TextureRect (reuses or creates a sibling TextureRect next to feedback_icon label)."""
	# Load icon
	var tex: Texture2D = null
	match icon_name:
		"correct":
			if _icon_correct == null:
				_icon_correct = load("res://assets/UI/core/correct.png")
			tex = _icon_correct
		"incorrect":
			if _icon_incorrect == null:
				_icon_incorrect = load("res://assets/UI/core/incorrect.png")
			tex = _icon_incorrect
		"timer":
			if _icon_timer == null:
				_icon_timer = load("res://assets/UI/core/timer.png")
			tex = _icon_timer

	# feedback_icon is a Label — clear its text and use it as a size-holder,
	# then create or update a TextureRect sibling right above it.
	feedback_icon.text = ""

	var parent = feedback_icon.get_parent()
	var icon_rect: TextureRect = null
	# Try to find existing icon_rect by metadata
	for child in parent.get_children():
		if child.has_meta("is_feedback_icon_rect"):
			icon_rect = child
			break

	if icon_rect == null:
		icon_rect = TextureRect.new()
		icon_rect.set_meta("is_feedback_icon_rect", true)
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.custom_minimum_size = Vector2(64, 64)
		icon_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		# Insert right before feedback_icon in the parent
		parent.add_child(icon_rect)
		parent.move_child(icon_rect, feedback_icon.get_index())

	icon_rect.texture = tex

func _ready() -> void:
	print(" Timeline Reconstruction _ready() called")
	set_process(false)  # Timer must NOT start until after tutorial + countdown
	feedback_panel.hide()
	hint_button.pressed.connect(_on_hint_pressed)
	hint_button.icon = load("res://assets/UI/core/hints.png")
	hint_button.add_theme_constant_override("icon_max_width", 32)
	hint_button.text = ""
	submit_button.pressed.connect(_on_submit_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	_update_hint_display()
	_apply_modern_styles()
	_create_tutorial()
	_create_countdown_overlay()
	print(" Timeline Reconstruction _ready() complete")

func _create_tutorial() -> void:
	"""Create tutorial overlay UI with multi-page support"""
	# Dark overlay background
	tutorial_overlay = ColorRect.new()
	tutorial_overlay.color = Color(0, 0, 0, 0.85)
	tutorial_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tutorial_overlay.z_index = 200
	add_child(tutorial_overlay)

	# Tutorial panel
	tutorial_panel = Panel.new()
	tutorial_panel.custom_minimum_size = Vector2(800, 0)
	tutorial_panel.set_anchors_preset(Control.PRESET_CENTER)
	tutorial_panel.offset_left = -400
	tutorial_panel.offset_right = 400

	# Panel style
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.14, 0.17, 0.22, 0.98)
	panel_style.set_corner_radius_all(20)
	panel_style.shadow_color = Color(0, 0, 0, 0.8)
	panel_style.shadow_size = 30
	panel_style.border_width_left = 3
	panel_style.border_width_top = 3
	panel_style.border_width_right = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color(0.4, 0.5, 0.6, 0.5)
	panel_style.content_margin_bottom = 40
	tutorial_panel.add_theme_stylebox_override("panel", panel_style)

	tutorial_overlay.add_child(tutorial_panel)

	# VBox for content — offset_bottom shrinks it from the bottom, creating space
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_bottom = -40
	vbox.add_theme_constant_override("separation", 20)
	tutorial_panel.add_child(vbox)

	# Margins
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 30)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_right", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	vbox.add_child(margin)

	var content_vbox = VBoxContainer.new()
	content_vbox.add_theme_constant_override("separation", 20)
	margin.add_child(content_vbox)

	# Title (will be updated per page)
	tutorial_title = Label.new()
	tutorial_title.add_theme_font_size_override("font_size", 36)
	tutorial_title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4, 1))
	tutorial_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content_vbox.add_child(tutorial_title)

	# Tutorial image (will be updated per page)
	tutorial_image = TextureRect.new()
	tutorial_image.custom_minimum_size = Vector2(740, 380)
	tutorial_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tutorial_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	content_vbox.add_child(tutorial_image)

	# Instructions text (will be updated per page)
	tutorial_instructions = RichTextLabel.new()
	tutorial_instructions.bbcode_enabled = true
	tutorial_instructions.custom_minimum_size = Vector2(0, 70)
	tutorial_instructions.add_theme_font_size_override("normal_font_size", 18)
	tutorial_instructions.fit_content = true
	tutorial_instructions.scroll_active = false
	content_vbox.add_child(tutorial_instructions)

	# Button container with bottom spacing
	var btn_margin = MarginContainer.new()
	btn_margin.add_theme_constant_override("margin_top", 0)
	btn_margin.add_theme_constant_override("margin_bottom", 24)
	btn_margin.add_theme_constant_override("margin_left", 0)
	btn_margin.add_theme_constant_override("margin_right", 0)
	content_vbox.add_child(btn_margin)

	tutorial_button_container = HBoxContainer.new()
	tutorial_button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	tutorial_button_container.add_theme_constant_override("separation", 15)
	btn_margin.add_child(tutorial_button_container)

	# Back button
	tutorial_back_button = Button.new()
	tutorial_back_button.text = "← Back"
	tutorial_back_button.custom_minimum_size = Vector2(150, 50)
	tutorial_back_button.add_theme_font_size_override("font_size", 20)
	tutorial_back_button.pressed.connect(_on_tutorial_back_pressed)
	_style_tutorial_button(tutorial_back_button, Color(0.4, 0.5, 0.6, 0.9), Color(0.5, 0.6, 0.7, 1.0))
	tutorial_button_container.add_child(tutorial_back_button)

	# Next button
	tutorial_next_button = Button.new()
	tutorial_next_button.text = "Next →"
	tutorial_next_button.custom_minimum_size = Vector2(150, 50)
	tutorial_next_button.add_theme_font_size_override("font_size", 20)
	tutorial_next_button.pressed.connect(_on_tutorial_next_pressed)
	_style_tutorial_button(tutorial_next_button, Color(0.2, 0.6, 0.8, 0.95), Color(0.3, 0.7, 0.9, 1.0))
	tutorial_button_container.add_child(tutorial_next_button)

	# Start button
	tutorial_start_button = Button.new()
	tutorial_start_button.text = "Got it! Let's Start"
	tutorial_start_button.custom_minimum_size = Vector2(200, 50)
	tutorial_start_button.add_theme_font_size_override("font_size", 22)
	tutorial_start_button.pressed.connect(_on_tutorial_start_pressed)
	_style_tutorial_button(tutorial_start_button, Color(0.25, 0.65, 0.35, 0.95), Color(0.3, 0.75, 0.45, 1.0))
	tutorial_button_container.add_child(tutorial_start_button)

	# Bottom spacer so panel has breathing room below the button
	var bottom_spacer = Control.new()
	bottom_spacer.custom_minimum_size = Vector2(0, 24)
	content_vbox.add_child(bottom_spacer)

	# Hide tutorial initially
	tutorial_overlay.hide()

func _style_tutorial_button(button: Button, normal_color: Color, hover_color: Color) -> void:
	"""Apply consistent styling to tutorial buttons"""
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = normal_color
	btn_normal.set_corner_radius_all(10)
	btn_normal.content_margin_left = 20
	btn_normal.content_margin_top = 12
	btn_normal.content_margin_right = 20
	btn_normal.content_margin_bottom = 12
	button.add_theme_stylebox_override("normal", btn_normal)

	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = hover_color
	btn_hover.set_corner_radius_all(10)
	btn_hover.shadow_color = Color(hover_color.r, hover_color.g, hover_color.b, 0.4)
	btn_hover.shadow_size = 10
	btn_hover.content_margin_left = 20
	btn_hover.content_margin_top = 12
	btn_hover.content_margin_right = 20
	btn_hover.content_margin_bottom = 12
	button.add_theme_stylebox_override("hover", btn_hover)

func _show_tutorial(image_page1: String = "", image_page2: String = "") -> void:
	"""Show tutorial with optional custom images for each page"""
	tutorial_image_page1 = image_page1
	tutorial_image_page2 = image_page2
	tutorial_current_page = 0

	_update_tutorial_page()
	tutorial_overlay.show()
	set_process(false)  # Pause timer while tutorial is showing

func _update_tutorial_page() -> void:
	"""Update tutorial content based on current page"""
	if tutorial_current_page == 0:
		# Page 1: How to Play - tall panel for large image
		tutorial_panel.custom_minimum_size = Vector2(800, 690)
		tutorial_panel.offset_top = -345
		tutorial_panel.offset_bottom = 345
		tutorial_title.text = " How to Play"
		tutorial_instructions.text = "[center][color=#A0D8EF]Click orange cards to place them in timeline slots (1→5)[/color]\n[color=#A0D8EF]Click cards in timeline to return them to the pool[/color]\n[color=#A0D8EF]Arrange all events in correct chronological order[/color][/center]"

		# Show single image and restore its size
		tutorial_image.visible = true
		tutorial_image.custom_minimum_size = Vector2(740, 380)

		# Hide image container from page 2 if it exists
		var parent = tutorial_image.get_parent()
		for child in parent.get_children():
			if child.has_meta("is_image_container"):
				child.visible = false
				break

		# Load page 1 image (default to assets/tutorials/timeline_page1.png)
		var page1_path = tutorial_image_page1 if tutorial_image_page1 != "" else "res://assets/tutorials/timeline_page1.png"
		if ResourceLoader.exists(page1_path):
			tutorial_image.texture = load(page1_path)
		else:
			tutorial_image.texture = null

		# Show only Next button
		tutorial_back_button.hide()
		tutorial_next_button.show()
		tutorial_start_button.hide()

	elif tutorial_current_page == 1:
		# Page 2: Hints & Timer - shorter panel, no large image
		tutorial_panel.custom_minimum_size = Vector2(800, 0)
		tutorial_panel.offset_top = -230
		tutorial_panel.offset_bottom = 230
		tutorial_title.text = "Hints & Timer"
		tutorial_instructions.text = "[center][color=#F4D03F]Hints & Cooldown:[/color] [color=#A0D8EF]12-second cooldown between uses[/color]\n[color=#F4D03F]⏱ Timer:[/color] [color=#A0D8EF]Complete within 2:00 minutes[/color]\n[color=#F4D03F]⚡ Speed Bonus:[/color] [color=#A0D8EF]Finish under 1:00 to earn +1 hint![/color][/center]"

		# Hide the main single image and collapse its space
		tutorial_image.visible = false
		tutorial_image.custom_minimum_size = Vector2.ZERO

		# Create two side-by-side images for page 2 (if not already created)
		var parent = tutorial_image.get_parent()
		var image_container = null

		# Check if image container already exists
		for child in parent.get_children():
			if child.has_meta("is_image_container"):
				image_container = child
				break

		# Create image container if it doesn't exist
		if image_container == null:
			image_container = HBoxContainer.new()
			image_container.set_meta("is_image_container", true)
			image_container.add_theme_constant_override("separation", 10)
			image_container.alignment = BoxContainer.ALIGNMENT_CENTER

			# Add after tutorial_image
			var image_index = tutorial_image.get_index()
			parent.add_child(image_container)
			parent.move_child(image_container, image_index + 1)

			# Create two image slots
			var img1 = TextureRect.new()
			img1.custom_minimum_size = Vector2(355, 160)
			img1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			img1.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			img1.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			img1.set_meta("is_tutorial_image_2", true)
			image_container.add_child(img1)

			var img2 = TextureRect.new()
			img2.custom_minimum_size = Vector2(355, 160)
			img2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			img2.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			img2.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			img2.set_meta("is_tutorial_image_3", true)
			image_container.add_child(img2)

		# Show image container and load images
		image_container.visible = true

		# Load images timeline_page2 and timeline_page3
		var img2_path = "res://assets/tutorials/timeline_page2.png"
		var img3_path = "res://assets/tutorials/timeline_page3.png"

		for child in image_container.get_children():
			if child.has_meta("is_tutorial_image_2"):
				if ResourceLoader.exists(img2_path):
					child.texture = load(img2_path)
				else:
					child.texture = null
			elif child.has_meta("is_tutorial_image_3"):
				if ResourceLoader.exists(img3_path):
					child.texture = load(img3_path)
				else:
					child.texture = null

		# Show Back and Start buttons
		tutorial_back_button.show()
		tutorial_next_button.hide()
		tutorial_start_button.show()
	else:
		# Hide image container for other pages
		var parent = tutorial_image.get_parent()
		for child in parent.get_children():
			if child.has_meta("is_image_container"):
				child.visible = false
				break

func _on_tutorial_back_pressed() -> void:
	"""Go to previous tutorial page"""
	if tutorial_current_page > 0:
		tutorial_current_page -= 1
		_update_tutorial_page()

func _on_tutorial_next_pressed() -> void:
	"""Go to next tutorial page"""
	tutorial_current_page += 1
	_update_tutorial_page()

func _on_tutorial_start_pressed() -> void:
	"""Handle tutorial start button press"""
	seen_tutorial = true
	# Fade out tutorial
	var tween = create_tween()
	tween.tween_property(tutorial_overlay, "modulate:a", 0.0, 0.3)
	await tween.finished
	tutorial_overlay.hide()
	tutorial_overlay.modulate.a = 1.0

	# Show countdown then start timer
	await _play_countdown()
	start_time = Time.get_ticks_msec() / 1000.0
	set_process(true)

func _create_countdown_overlay() -> void:
	"""Create the 3-2-1 Start countdown overlay (hidden until needed)"""
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

	# Set pivot to center after adding to tree so size is known
	await get_tree().process_frame
	countdown_label.pivot_offset = countdown_label.size / 2.0


func _animate_cards_in(tutorial_img_page1: String, tutorial_img_page2: String) -> void:
	"""Glide event pool cards in from the right, one by one, like being dealt onto a table"""
	var cards = events_pool.get_children()
	var screen_width = get_viewport_rect().size.x

	# For each card, reparent it into a same-size Control wrapper so HBoxContainer
	# controls the wrapper's position, but we can freely animate the card inside it.
	var wrappers: Array = []
	for card in cards:
		# Create a wrapper Control the same size as the card
		var wrapper = Control.new()
		wrapper.custom_minimum_size = card.custom_minimum_size
		wrapper.clip_contents = false

		# Insert wrapper where card is, then move card inside wrapper
		var idx = card.get_index()
		events_pool.add_child(wrapper)
		events_pool.move_child(wrapper, idx)
		card.get_parent().remove_child(card)
		wrapper.add_child(card)

		# Position card off-screen to the right inside wrapper
		card.position = Vector2(screen_width + 200.0, 0.0)
		card.modulate.a = 0.0
		wrappers.append(wrapper)

	# Wait a frame for layout
	await get_tree().process_frame

	# Glide each card into position one by one
	for i in range(cards.size()):
		var card = cards[i]
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(card, "position:x", 0.0, 0.5)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(card, "modulate:a", 1.0, 0.25)

		# Play card slide sound for each card
		_play_sfx(SFX_PATH + "card_sound_effect.wav")

		await get_tree().create_timer(0.15).timeout

	# Wait for last card to land
	await get_tree().create_timer(0.55).timeout

	# Unwrap: move each card back directly into events_pool and remove wrapper
	for i in range(wrappers.size()):
		var wrapper = wrappers[i]
		var card = cards[i]
		var idx = wrapper.get_index()
		wrapper.remove_child(card)
		card.position = Vector2.ZERO
		events_pool.add_child(card)
		events_pool.move_child(card, idx)
		wrapper.queue_free()

	await get_tree().process_frame

	# Show tutorial if first time, otherwise go straight to countdown
	if not seen_tutorial:
		_show_tutorial(tutorial_img_page1, tutorial_img_page2)
	else:
		await _play_countdown()
		start_time = Time.get_ticks_msec() / 1000.0
		set_process(true)


func _play_countdown() -> void:
	"""Show 3, 2, 1, Start! countdown then hide"""
	countdown_overlay.show()

	var steps = [["3", Color(0.9, 0.3, 0.3, 1)], ["2", Color(0.9, 0.7, 0.2, 1)], ["1", Color(0.3, 0.85, 0.4, 1)], ["START!", Color(1, 1, 1, 1)]]

	# Ensure pivot is at center of the full-rect label
	countdown_label.pivot_offset = countdown_label.size / 2.0

	for step in steps:
		var text = step[0]
		var color = step[1]
		countdown_label.text = text
		countdown_label.add_theme_color_override("font_color", color)
		countdown_label.scale = Vector2(1.5, 1.5)
		countdown_label.modulate.a = 1.0

		# Play matching sound for each countdown step
		match text:
			"3": _play_sfx(SFX_PATH + "three.mp3")
			"2": _play_sfx(SFX_PATH + "two.mp3")
			"1": _play_sfx(SFX_PATH + "one.mp3")
			"START!":
				_play_sfx(SFX_PATH + "start.mp3")
				_play_sfx(SFX_PATH + "Whistle.mp3")

		# Animate: scale down and fade slightly
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(countdown_label, "scale", Vector2(1.0, 1.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		if text == "START!":
			tween.tween_property(countdown_label, "modulate:a", 0.0, 0.6).set_delay(0.4)
		await get_tree().create_timer(0.8).timeout

	countdown_overlay.hide()


func _apply_modern_styles() -> void:
	"""Apply modern gradient and shadow styling to all UI elements"""
	# Main panel is NinePatchRect - no stylebox override needed, uses BGbox_01A.png texture

	# Timer panel - info style
	var timer_style = StyleBoxFlat.new()
	timer_style.bg_color = Color(0.15, 0.20, 0.28, 0.95)
	timer_style.set_corner_radius_all(8)
	timer_style.border_width_left = 2
	timer_style.border_color = Color(0.4, 0.6, 0.8, 0.6)
	timer_style.content_margin_left = 15
	timer_style.content_margin_top = 10
	timer_style.content_margin_right = 15
	timer_style.content_margin_bottom = 10
	timer_panel.add_theme_stylebox_override("panel", timer_style)

	# Hint panel - accent style
	var hint_style = StyleBoxFlat.new()
	hint_style.bg_color = Color(0.20, 0.18, 0.25, 0.95)
	hint_style.set_corner_radius_all(8)
	hint_style.border_width_left = 2
	hint_style.border_color = Color(0.9, 0.7, 0.3, 0.6)
	hint_style.content_margin_left = 15
	hint_style.content_margin_top = 10
	hint_style.content_margin_right = 15
	hint_style.content_margin_bottom = 10
	hint_panel.add_theme_stylebox_override("panel", hint_style)

	# Context panel
	var context_style = StyleBoxFlat.new()
	context_style.bg_color = Color(0.16, 0.19, 0.24, 0.9)
	context_style.set_corner_radius_all(8)
	context_style.content_margin_left = 20
	context_style.content_margin_top = 15
	context_style.content_margin_right = 20
	context_style.content_margin_bottom = 15
	context_panel.add_theme_stylebox_override("panel", context_style)

	# Hint button - modern gradient button
	var hint_btn_normal = StyleBoxFlat.new()
	hint_btn_normal.bg_color = Color(0.7, 0.55, 0.2, 0.9)
	hint_btn_normal.set_corner_radius_all(8)
	hint_btn_normal.content_margin_left = 15
	hint_btn_normal.content_margin_top = 8
	hint_btn_normal.content_margin_right = 15
	hint_btn_normal.content_margin_bottom = 8
	hint_button.add_theme_stylebox_override("normal", hint_btn_normal)

	var hint_btn_hover = StyleBoxFlat.new()
	hint_btn_hover.bg_color = Color(0.85, 0.7, 0.3, 1.0)
	hint_btn_hover.set_corner_radius_all(8)
	hint_btn_hover.shadow_color = Color(0.9, 0.7, 0.3, 0.4)
	hint_btn_hover.shadow_size = 8
	hint_btn_hover.content_margin_left = 15
	hint_btn_hover.content_margin_top = 8
	hint_btn_hover.content_margin_right = 15
	hint_btn_hover.content_margin_bottom = 8
	hint_button.add_theme_stylebox_override("hover", hint_btn_hover)

	# Submit button uses button_normal/button_hover textures set in the scene

	# Feedback panel - elevated card style
	var feedback_style = StyleBoxFlat.new()
	feedback_style.bg_color = Color(0.14, 0.17, 0.22, 0.98)
	feedback_style.set_corner_radius_all(20)
	feedback_style.shadow_color = Color(0, 0, 0, 0.8)
	feedback_style.shadow_size = 30
	feedback_style.shadow_offset = Vector2(0, 10)
	feedback_style.border_width_left = 3
	feedback_style.border_width_top = 3
	feedback_style.border_width_right = 3
	feedback_style.border_width_bottom = 3
	feedback_style.border_color = Color(0.4, 0.5, 0.6, 0.5)
	feedback_panel.add_theme_stylebox_override("panel", feedback_style)

	# Continue button - success style
	var continue_normal = StyleBoxFlat.new()
	continue_normal.bg_color = Color(0.2, 0.6, 0.8, 0.95)
	continue_normal.set_corner_radius_all(10)
	continue_normal.content_margin_left = 20
	continue_normal.content_margin_top = 12
	continue_normal.content_margin_right = 20
	continue_normal.content_margin_bottom = 12
	continue_button.add_theme_stylebox_override("normal", continue_normal)

	var continue_hover = StyleBoxFlat.new()
	continue_hover.bg_color = Color(0.3, 0.7, 0.9, 1.0)
	continue_hover.set_corner_radius_all(10)
	continue_hover.shadow_color = Color(0.3, 0.7, 0.9, 0.5)
	continue_hover.shadow_size = 10
	continue_hover.content_margin_left = 20
	continue_hover.content_margin_top = 12
	continue_hover.content_margin_right = 20
	continue_hover.content_margin_bottom = 12
	continue_button.add_theme_stylebox_override("hover", continue_hover)

	# Retry button - warning style
	var retry_normal = StyleBoxFlat.new()
	retry_normal.bg_color = Color(0.7, 0.4, 0.2, 0.95)
	retry_normal.set_corner_radius_all(10)
	retry_normal.content_margin_left = 20
	retry_normal.content_margin_top = 12
	retry_normal.content_margin_right = 20
	retry_normal.content_margin_bottom = 12
	retry_button.add_theme_stylebox_override("normal", retry_normal)

	var retry_hover = StyleBoxFlat.new()
	retry_hover.bg_color = Color(0.85, 0.5, 0.3, 1.0)
	retry_hover.set_corner_radius_all(10)
	retry_hover.shadow_color = Color(0.85, 0.5, 0.3, 0.5)
	retry_hover.shadow_size = 10
	retry_hover.content_margin_left = 20
	retry_hover.content_margin_top = 12
	retry_hover.content_margin_right = 20
	retry_hover.content_margin_bottom = 12
	retry_button.add_theme_stylebox_override("hover", retry_hover)

func configure_puzzle(config: Dictionary) -> void:
	"""Configure the timeline puzzle"""
	print(" Timeline Reconstruction configure_puzzle() called")
	print(" Config title: ", config.get("title", "NO TITLE"))
	print(" Visible: ", visible)
	print(" Modulate: ", modulate)
	print(" Global position: ", global_position)
	print(" Size: ", size)
	print(" Z-index: ", z_index)

	# Force visibility
	visible = true
	modulate = Color(1, 1, 1, 1)
	z_index = 100
	print(" Forced visibility settings")

	puzzle_config = config

	# Set title and context
	title_label.text = config.get("title", "Timeline Reconstruction")
	context_label.text = config.get("context", "Arrange the events in chronological order.")

	# Center-align event pool to match timeline slots
	events_pool.alignment = BoxContainer.ALIGNMENT_CENTER

	print(" Title label text set to: ", title_label.text)
	print(" Title label visible: ", title_label.visible)
	print(" Number of events: ", config.get("events", []).size())

	# Get events (will be shuffled for display)
	events = config.get("events", []).duplicate()
	correct_order = config.get("correct_order", [])

	# Shuffle events for pool
	var shuffled_events = events.duplicate()
	shuffled_events.shuffle()

	# Create event cards in pool
	for i in range(shuffled_events.size()):
		var event = shuffled_events[i]
		var event_card = _create_event_card(event)
		event_card.set_meta("original_pool_index", i)  # Track original position in shuffled pool
		events_pool.add_child(event_card)

	# Create empty timeline slots
	for i in range(events.size()):
		var slot = _create_timeline_slot(i)
		timeline_slots.add_child(slot)

	# Animate cards sliding in, then show tutorial or countdown
	var tutorial_img_page1 = config.get("tutorial_image_page1", "")
	var tutorial_img_page2 = config.get("tutorial_image_page2", "")
	_animate_cards_in(tutorial_img_page1, tutorial_img_page2)

	print(" Timeline Reconstruction configuration complete!")
	print(" Events pool children: ", events_pool.get_child_count())
	print(" Timeline slots children: ", timeline_slots.get_child_count())
	print(" Title label: ", title_label.text)
	print(" Submit button visible: ", submit_button.visible)

func _create_event_card(event: Dictionary) -> Control:
	"""Create a vertical event card with image on top and text below (clickable)"""
	var card_wrapper = PanelContainer.new()
	card_wrapper.custom_minimum_size = Vector2(180, 220)
	card_wrapper.mouse_filter = Control.MOUSE_FILTER_STOP

	# StyleBoxFlat for yellow/orange card background
	var style = StyleBoxFlat.new()
	style.bg_color = CARD_COLOR_NORMAL
	style.set_corner_radius_all(6)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.9, 0.72, 0.3, 1.0)
	style.content_margin_left = 8
	style.content_margin_top = 8
	style.content_margin_right = 8
	style.content_margin_bottom = 8
	card_wrapper.add_theme_stylebox_override("panel", style)

	# Store event data
	card_wrapper.set_meta("event_id", event.get("id", ""))
	card_wrapper.set_meta("event_data", event)
	card_wrapper.set_meta("in_pool", true)
	card_wrapper.set_meta("original_pool_index", -1)
	card_wrapper.set_meta("card_style", style)

	# Hover + click
	card_wrapper.mouse_entered.connect(_on_card_hover.bind(card_wrapper, true))
	card_wrapper.mouse_exited.connect(_on_card_hover.bind(card_wrapper, false))
	card_wrapper.gui_input.connect(_on_card_clicked.bind(card_wrapper))

	# VBox: image on top, text below
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card_wrapper.add_child(vbox)

	# Image — fixed size so all cards are uniform
	var texture_rect = TextureRect.new()
	texture_rect.custom_minimum_size = Vector2(156, 150)
	texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texture_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var image_path = event.get("image_path", "")
	if image_path != "":
		if "{protagonist}" in image_path:
			var protagonist = "conrad"
			if "selected_character" in PlayerStats:
				protagonist = PlayerStats.selected_character
			image_path = image_path.replace("{protagonist}", protagonist)
		var texture = load(image_path)
		if texture:
			texture_rect.texture = texture

	vbox.add_child(texture_rect)

	# Text label below image — fixed height so all cards stay uniform
	var label = Label.new()
	label.text = event.get("text", "")
	label.custom_minimum_size = Vector2(156, 44)
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color(0.05, 0.05, 0.05))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(label)

	return card_wrapper


func _create_timeline_slot(index: int) -> Control:
	"""Create a numbered timeline slot box (blue) that accepts cards"""
	var slot_wrapper = PanelContainer.new()
	slot_wrapper.custom_minimum_size = Vector2(180, 220)
	slot_wrapper.mouse_filter = Control.MOUSE_FILTER_STOP
	slot_wrapper.set_meta("slot_index", index)
	slot_wrapper.set_meta("is_empty", true)

	# StyleBoxFlat for blue slot background
	var style = StyleBoxFlat.new()
	style.bg_color = SLOT_COLOR_NORMAL
	style.set_corner_radius_all(6)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.45, 0.65, 1.0, 1.0)
	style.content_margin_left = 4
	style.content_margin_top = 4
	style.content_margin_right = 4
	style.content_margin_bottom = 4
	slot_wrapper.add_theme_stylebox_override("panel", style)
	slot_wrapper.set_meta("slot_style", style)

	# Click and hover
	slot_wrapper.gui_input.connect(_on_slot_gui_input.bind(slot_wrapper))
	slot_wrapper.mouse_entered.connect(_on_slot_hover.bind(slot_wrapper, true))
	slot_wrapper.mouse_exited.connect(_on_slot_hover.bind(slot_wrapper, false))

	# Content container - will hold number label or card
	var content = Control.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.set_meta("is_content_area", true)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot_wrapper.add_child(content)

	# Number label (shows when empty)
	var number_label = Label.new()
	number_label.text = str(index + 1)
	number_label.add_theme_font_size_override("font_size", 80)
	number_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.8))
	number_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	number_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	number_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	number_label.set_meta("is_placeholder", true)
	content.add_child(number_label)

	return slot_wrapper

## Click-Based Interaction Implementation

func _on_card_clicked(event: InputEvent, card_wrapper: Control) -> void:
	"""Handle clicking on a card - moves to timeline if in pool, returns to pool if in timeline"""
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if card_wrapper.get_meta("in_pool", false):
			# Card is in pool - move to first empty timeline slot
			for slot_wrapper in timeline_slots.get_children():
				if slot_wrapper is Control and slot_wrapper.get_meta("is_empty", true):
					_move_card_to_slot(card_wrapper, slot_wrapper)

					# Flash animation on card
					var tween = create_tween()
					tween.tween_property(card_wrapper, "modulate", Color(0.5, 0.8, 1.0), 0.1)
					tween.tween_property(card_wrapper, "modulate", Color.WHITE, 0.1)

					break
		else:
			# Card is in timeline slot - return it to pool
			for slot_wrapper in timeline_slots.get_children():
				if slot_wrapper is Control and not slot_wrapper.get_meta("is_empty", true):
					var content = slot_wrapper.get_child(0)
					for child in content.get_children():
						if child == card_wrapper:
							_move_card_to_pool(card_wrapper, slot_wrapper)
							return

## End Click-Based Interaction

func _on_card_hover(card_wrapper: PanelContainer, is_hovering: bool) -> void:
	"""Handle hover effect for event cards - change StyleBoxFlat bg color"""
	var style = card_wrapper.get_meta("card_style", null) as StyleBoxFlat
	if style:
		style.bg_color = CARD_COLOR_HOVER if is_hovering else CARD_COLOR_NORMAL

func _on_slot_gui_input(event: InputEvent, slot_wrapper: Control) -> void:
	"""Handle mouse click on timeline slot to return card to pool"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not slot_wrapper.get_meta("is_empty", true):
			_on_timeline_slot_pressed(slot_wrapper)

func _on_slot_hover(slot_wrapper: PanelContainer, is_hovering: bool) -> void:
	"""Handle hover effect for timeline slots - change StyleBoxFlat bg color"""
	var style = slot_wrapper.get_meta("slot_style", null) as StyleBoxFlat
	if style:
		style.bg_color = SLOT_COLOR_HOVER if is_hovering else SLOT_COLOR_NORMAL

func _on_timeline_slot_pressed(slot_wrapper: Control) -> void:
	"""Handle timeline slot click - return card to pool"""
	if not slot_wrapper.get_meta("is_empty", true):
		# Find and return the card (content is first child of slot_wrapper)
		var content = slot_wrapper.get_child(0)
		for child in content.get_children():
			if child is Control and child.has_meta("event_id"):
				_move_card_to_pool(child, slot_wrapper)
				break

func _move_card_to_slot(card_wrapper: Control, slot_wrapper: Control) -> void:
	"""Move card from pool to timeline slot"""
	# Remove from events pool
	card_wrapper.get_parent().remove_child(card_wrapper)

	# Content is first child of slot_wrapper (PanelContainer)
	var content = slot_wrapper.get_child(0)

	# Clear placeholder number
	for child in content.get_children():
		child.queue_free()

	# Add card to slot and mark as not in pool
	card_wrapper.set_meta("in_pool", false)
	card_wrapper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	card_wrapper.custom_minimum_size = Vector2.ZERO
	content.add_child(card_wrapper)
	slot_wrapper.set_meta("is_empty", false)

	_update_current_order()

func _move_card_to_pool(card_wrapper: Control, slot_wrapper: Control) -> void:
	"""Move card from timeline slot back to its original position in events pool"""
	# Get content area
	var content = card_wrapper.get_parent()

	# Remove card from slot
	content.remove_child(card_wrapper)

	# Restore placeholder number
	var slot_index = slot_wrapper.get_meta("slot_index", 0)
	var number_label = Label.new()
	number_label.text = str(slot_index + 1)
	number_label.add_theme_font_size_override("font_size", 80)
	number_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.8))
	number_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	number_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	number_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	number_label.set_meta("is_placeholder", true)
	content.add_child(number_label)

	slot_wrapper.set_meta("is_empty", true)

	# Return card to its original position in pool
	card_wrapper.set_meta("in_pool", true)
	var original_index = card_wrapper.get_meta("original_pool_index", 0)

	# Reset card for pool layout (HBoxContainer controls sizing)
	card_wrapper.set_anchors_preset(Control.PRESET_TOP_LEFT)
	card_wrapper.position = Vector2.ZERO
	card_wrapper.size = Vector2.ZERO
	card_wrapper.custom_minimum_size = Vector2(180, 220)
	card_wrapper.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	card_wrapper.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	# Insert at original index (or at end if index is invalid)
	if original_index >= 0 and original_index <= events_pool.get_child_count():
		events_pool.add_child(card_wrapper)
		events_pool.move_child(card_wrapper, original_index)
	else:
		events_pool.add_child(card_wrapper)

	# Flash animation
	var tween = create_tween()
	tween.tween_property(card_wrapper, "modulate", Color(1.0, 0.8, 0.5), 0.1)
	tween.tween_property(card_wrapper, "modulate", Color.WHITE, 0.1)

	_update_current_order()

func _update_current_order() -> void:
	"""Update the current order array based on timeline slots"""
	current_order.clear()

	for slot_wrapper in timeline_slots.get_children():
		if slot_wrapper is Control:
			# Structure: slot_wrapper (PanelContainer) → content (Control) → card_wrapper
			var content = slot_wrapper.get_child(0)

			# Check if content has a card (Control wrapper)
			for child in content.get_children():
				if child is Control and child.has_meta("event_id"):
					current_order.append(child.get_meta("event_id"))
					break

func _process(delta: float) -> void:
	"""Update timer and hint cooldown"""
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
		if not played_ten_sec_sfx:
			played_ten_sec_sfx = true
			_play_sfx(SFX_PATH + "ten_seconds_left.mp3")
	elif remaining <= 30:
		timer_label.add_theme_color_override("font_color", Color.YELLOW)
		if not played_thirty_sec_sfx:
			played_thirty_sec_sfx = true
			_play_sfx(SFX_PATH + "thirty_seconds_left.mp3")
	elif remaining <= 60:
		timer_label.add_theme_color_override("font_color", Color.WHITE)
		if not played_one_minute_sfx:
			played_one_minute_sfx = true
			_play_sfx(SFX_PATH + "one_minute_left.mp3")
	else:
		timer_label.add_theme_color_override("font_color", Color.WHITE)

	# Handle hint cooldown
	if hint_on_cooldown:
		hint_cooldown_remaining -= delta
		if hint_cooldown_remaining <= 0:
			hint_on_cooldown = false
			hint_cooldown_remaining = 0.0
			_update_hint_display()
		else:
			# Update button text with cooldown timer
			hint_button.icon = null
			hint_button.text = "Wait: %ds" % ceil(hint_cooldown_remaining)

func _on_submit_pressed() -> void:
	"""Check if timeline is correct"""
	set_process(false)

	_update_current_order()
	var is_correct = (current_order == correct_order)
	var elapsed = Time.get_ticks_msec() / 1000.0 - start_time

	# Track first attempt accuracy
	if first_attempt:
		first_attempt_correct = is_correct
		first_attempt = false

	_show_feedback(is_correct, elapsed)

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

func _show_feedback(is_correct: bool, time_taken: float) -> void:
	"""Show feedback panel with modern presentation"""
	if is_correct:
		_play_sfx("res://assets/audio/sound_effect/correct.wav")
	else:
		_play_sfx("res://assets/audio/sound_effect/wrong.wav")
	var feedback_text = ""

	if is_correct:
		# Success styling
		_set_feedback_icon("correct")
		feedback_icon.add_theme_color_override("font_color", Color(0.3, 0.9, 0.5))
		feedback_title.text = "CORRECT!"
		feedback_title.add_theme_color_override("font_color", Color(0.3, 0.9, 0.5))

		feedback_text = "[center]You successfully reconstructed the timeline in correct chronological order![/center]\n\n"

		# Award speed bonus (only on first attempt)
		if time_taken < 60.0 and not hint_used and first_attempt_correct:
			PlayerStats.add_hints(1)
			feedback_text += "[center][color=#FFD700][img=28x28]res://assets/UI/core/speed_bonus.png[/img] Speed Bonus: +1 Hint![/color][/center]\n\n"

		# Show Continue button only, hide Retry button
		continue_button.show()
		retry_button.hide()
	else:
		# Error styling
		_set_feedback_icon("incorrect")
		feedback_icon.add_theme_color_override("font_color", Color(0.95, 0.4, 0.35))
		feedback_title.text = "INCORRECT"
		feedback_title.add_theme_color_override("font_color", Color(0.95, 0.4, 0.35))

		feedback_text = "[center]The sequence doesn't match the evidence. Review the time stamps and causality.[/center]\n\n"
		feedback_text += "[b][color=#6FC3DF]Correct Order:[/color][/b]\n"
		for i in range(correct_order.size()):
			var event_id = correct_order[i]
			for event in events:
				if event.get("id") == event_id:
					feedback_text += "[color=#A0D8EF]%d.[/color] %s\n" % [i + 1, event.get("text")]
					break

		# Show only Retry button, hide Continue button
		continue_button.hide()
		retry_button.show()

	if puzzle_config.has("explanation"):
		feedback_text += "\n[b][color=#F4D03F]Mathematical Reasoning:[/color][/b]\n" + puzzle_config["explanation"]

	feedback_label.text = feedback_text

	# Fade-in animation
	feedback_panel.modulate.a = 0
	feedback_panel.show()
	var tween = create_tween()
	tween.tween_property(feedback_panel, "modulate:a", 1.0, 0.3)

func _on_continue_pressed() -> void:
	"""Continue to next scene - only available after completing correctly"""
	var elapsed = Time.get_ticks_msec() / 1000.0 - start_time

	# Emit completion signal with first attempt accuracy (for star rating)
	# But minigame was completed successfully (true)
	minigame_completed.emit(first_attempt_correct, elapsed)
	queue_free()

func _on_retry_pressed() -> void:
	"""Retry the minigame - reset timer and hide feedback with animation"""
	# Fade-out animation
	var tween = create_tween()
	tween.tween_property(feedback_panel, "modulate:a", 0.0, 0.2)
	await tween.finished
	feedback_panel.hide()

	# Move all cards back to pool
	for slot_wrapper in timeline_slots.get_children():
		if slot_wrapper is Control and not slot_wrapper.get_meta("is_empty", true):
			# Structure: slot_wrapper (PanelContainer) → content (Control) → card_wrapper
			var content = slot_wrapper.get_child(0)

			# Find card
			for child in content.get_children():
				if child is Control and child.has_meta("event_id"):
					_move_card_to_pool(child, slot_wrapper)
					break

	# Reset timer and warning sound flags
	played_one_minute_sfx = false
	played_thirty_sec_sfx = false
	played_ten_sec_sfx = false
	start_time = Time.get_ticks_msec() / 1000.0
	set_process(true)

func _on_time_up() -> void:
	"""Handle time running out with modern styling"""
	set_process(false)

	# Track as failed first attempt if this is first attempt
	if first_attempt:
		first_attempt_correct = false
		first_attempt = false

	# Warning styling
	_set_feedback_icon("timer")
	feedback_icon.add_theme_color_override("font_color", Color(0.95, 0.65, 0.35))
	feedback_title.text = "TIME'S UP!"
	feedback_title.add_theme_color_override("font_color", Color(0.95, 0.65, 0.35))

	var feedback_text = "[center]You ran out of time to complete the timeline.[/center]\n\n"
	feedback_text += "[b][color=#6FC3DF]Correct Order:[/color][/b]\n"
	for i in range(correct_order.size()):
		var event_id = correct_order[i]
		for event in events:
			if event.get("id") == event_id:
				feedback_text += "[color=#A0D8EF]%d.[/color] %s\n" % [i + 1, event.get("text")]
				break

	if puzzle_config.has("explanation"):
		feedback_text += "\n[b][color=#F4D03F]Mathematical Reasoning:[/color][/b]\n" + puzzle_config["explanation"]

	feedback_label.text = feedback_text

	# Show only Retry button, hide Continue button
	continue_button.hide()
	retry_button.show()

	# Fade-in animation
	feedback_panel.modulate.a = 0
	feedback_panel.show()
	var tween = create_tween()
	tween.tween_property(feedback_panel, "modulate:a", 1.0, 0.3)

func _on_hint_pressed() -> void:
	"""Show a guiding hint overlay without revealing the answer"""
	if hint_on_cooldown:
		return

	if not PlayerStats.use_hint():
		var label = Label.new()
		label.text = "No hints available!"
		label.add_theme_color_override("font_color", Color.RED)
		label.add_theme_font_size_override("font_size", 20)
		label.position = hint_button.global_position + Vector2(0, -40)
		add_child(label)
		await get_tree().create_timer(1.5).timeout
		label.queue_free()
		return

	hint_used = true
	hint_on_cooldown = true
	hint_cooldown_remaining = hint_cooldown_time
	hint_button.disabled = true
	_update_hint_display()
	var hint_text = puzzle_config.get("hint_text", "Think about cause and effect. Which event must happen before the others can occur? Work through the sequence one step at a time.")
	var overlay = CanvasLayer.new()
	overlay.set_script(load("res://scenes/ui/hint_overlay.gd"))
	get_tree().root.add_child(overlay)
	overlay.show_hint(hint_text)

func _update_hint_display() -> void:
	"""Update hint counter and button state"""
	hint_counter.text = "Hints: %d" % PlayerStats.hints

	# Update button state based on cooldown and available hints
	if hint_on_cooldown:
		hint_button.disabled = true
		# Button text will be updated in _process() with countdown
	else:
		hint_button.disabled = (PlayerStats.hints <= 0)
		hint_button.icon = load("res://assets/UI/core/hints.png")
		hint_button.add_theme_constant_override("icon_max_width", 32)
		hint_button.text = ""

func _unhandled_input(event: InputEvent) -> void:
	"""Handle F5 skip"""
	if InputMap.has_action("skip_minigame") and event.is_action_pressed("skip_minigame"):
		print("Timeline Reconstruction: F5 pressed - skipping minigame")
		set_process(false)

		var elapsed = Time.get_ticks_msec() / 1000.0 - start_time
		minigame_completed.emit(true, elapsed)
		queue_free()

		get_viewport().set_input_as_handled()
