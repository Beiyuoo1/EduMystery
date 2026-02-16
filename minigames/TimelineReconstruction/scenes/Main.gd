extends Control

## Timeline Reconstruction Minigame
## Drag-and-drop events into correct chronological order
## Students sequence events based on time, causality, and evidence

# UI Nodes
@onready var title_label: Label = $Panel/VBox/Header/HeaderVBox/TitleLabel
@onready var subtitle_label: Label = $Panel/VBox/Header/HeaderVBox/SubtitleLabel
@onready var context_label: RichTextLabel = $Panel/VBox/ContextPanel/ContextLabel
@onready var events_pool: HBoxContainer = $Panel/VBox/MainContent/EventsContainer/EventsPanel/EventsPool
@onready var timeline_slots: HBoxContainer = $Panel/VBox/MainContent/TimelineContainer/TimelinePanel/TimelineSlots
@onready var timer_label: Label = $Panel/VBox/TopBar/TimerPanel/TimerLabel
@onready var hint_button: Button = $Panel/VBox/TopBar/HintPanel/HintHBox/HintButton
@onready var hint_counter: Label = $Panel/VBox/TopBar/HintPanel/HintHBox/HintCounter
@onready var submit_button: Button = $Panel/VBox/SubmitButton
@onready var feedback_panel: Panel = $FeedbackPanel
@onready var feedback_icon: Label = $FeedbackPanel/VBox/FeedbackIcon
@onready var feedback_title: Label = $FeedbackPanel/VBox/FeedbackTitle
@onready var feedback_label: RichTextLabel = $FeedbackPanel/VBox/FeedbackScroll/FeedbackLabel
@onready var continue_button: Button = $FeedbackPanel/VBox/ButtonsHBox/ContinueButton
@onready var retry_button: Button = $FeedbackPanel/VBox/ButtonsHBox/RetryButton

# Tutorial nodes (will be created dynamically)
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
@onready var main_panel: Panel = $Panel
@onready var header_panel: PanelContainer = $Panel/VBox/Header
@onready var timer_panel: PanelContainer = $Panel/VBox/TopBar/TimerPanel
@onready var hint_panel: PanelContainer = $Panel/VBox/TopBar/HintPanel
@onready var context_panel: PanelContainer = $Panel/VBox/ContextPanel

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

# Drag-and-drop state
var currently_dragging_card: Control = null

signal minigame_completed(success: bool, time_taken: float)

func _ready() -> void:
	print("🎮 Timeline Reconstruction _ready() called")
	feedback_panel.hide()
	hint_button.pressed.connect(_on_hint_pressed)
	submit_button.pressed.connect(_on_submit_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	_update_hint_display()
	_apply_modern_styles()
	_create_tutorial()
	print("🎮 Timeline Reconstruction _ready() complete")

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
	tutorial_panel.custom_minimum_size = Vector2(800, 650)
	tutorial_panel.set_anchors_preset(Control.PRESET_CENTER)
	tutorial_panel.offset_left = -400
	tutorial_panel.offset_top = -325
	tutorial_panel.offset_right = 400
	tutorial_panel.offset_bottom = 325

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
	tutorial_panel.add_theme_stylebox_override("panel", panel_style)

	tutorial_overlay.add_child(tutorial_panel)

	# VBox for content
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
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

	# Button container
	tutorial_button_container = HBoxContainer.new()
	tutorial_button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	tutorial_button_container.add_theme_constant_override("separation", 15)
	content_vbox.add_child(tutorial_button_container)

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
		# Page 1: How to Play
		tutorial_title.text = "📚 How to Play"
		tutorial_instructions.text = "[center][color=#A0D8EF]Click orange cards to place them in timeline slots (1→5)[/color]\n[color=#A0D8EF]Click cards in timeline to return them to the pool[/color]\n[color=#A0D8EF]Arrange all events in correct chronological order[/color][/center]"

		# Show single image
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
		# Page 2: Hints & Timer
		tutorial_title.text = "💡 Hints & Timer"
		tutorial_instructions.text = "[center][color=#F4D03F]💡 Hints & Cooldown:[/color] [color=#A0D8EF]12-second cooldown between uses[/color]\n[color=#F4D03F]⏱ Timer:[/color] [color=#A0D8EF]Complete within 2:00 minutes[/color]\n[color=#F4D03F]⚡ Speed Bonus:[/color] [color=#A0D8EF]Finish under 1:00 to earn +1 hint![/color][/center]"

		# Hide the main single image
		tutorial_image.visible = false

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
			img1.custom_minimum_size = Vector2(365, 380)
			img1.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			img1.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			img1.set_meta("is_tutorial_image_2", true)
			image_container.add_child(img1)

			var img2 = TextureRect.new()
			img2.custom_minimum_size = Vector2(365, 380)
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
	# Fade out tutorial
	var tween = create_tween()
	tween.tween_property(tutorial_overlay, "modulate:a", 0.0, 0.3)
	await tween.finished
	tutorial_overlay.hide()
	tutorial_overlay.modulate.a = 1.0

	# Start the minigame timer
	start_time = Time.get_ticks_msec() / 1000.0
	set_process(true)

func _apply_modern_styles() -> void:
	"""Apply modern gradient and shadow styling to all UI elements"""
	# Main panel - gradient background with shadow
	var main_style = StyleBoxFlat.new()
	main_style.bg_color = Color(0.12, 0.15, 0.20, 0.98)
	main_style.set_corner_radius_all(16)
	main_style.shadow_color = Color(0, 0, 0, 0.6)
	main_style.shadow_size = 20
	main_style.shadow_offset = Vector2(0, 8)
	main_style.border_width_left = 2
	main_style.border_width_top = 2
	main_style.border_width_right = 2
	main_style.border_width_bottom = 2
	main_style.border_color = Color(0.3, 0.4, 0.5, 0.4)
	main_panel.add_theme_stylebox_override("panel", main_style)

	# Header panel - accent gradient
	var header_style = StyleBoxFlat.new()
	header_style.bg_color = Color(0.18, 0.22, 0.28, 0.9)
	header_style.set_corner_radius_all(10)
	header_style.border_width_bottom = 3
	header_style.border_color = Color(0.95, 0.85, 0.4, 0.5)
	header_style.content_margin_left = 20
	header_style.content_margin_top = 15
	header_style.content_margin_right = 20
	header_style.content_margin_bottom = 15
	header_panel.add_theme_stylebox_override("panel", header_style)

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

	# Submit button - primary action style
	var submit_normal = StyleBoxFlat.new()
	submit_normal.bg_color = Color(0.25, 0.65, 0.35, 0.95)
	submit_normal.set_corner_radius_all(10)
	submit_normal.content_margin_left = 20
	submit_normal.content_margin_top = 12
	submit_normal.content_margin_right = 20
	submit_normal.content_margin_bottom = 12
	submit_button.add_theme_stylebox_override("normal", submit_normal)

	var submit_hover = StyleBoxFlat.new()
	submit_hover.bg_color = Color(0.3, 0.75, 0.45, 1.0)
	submit_hover.set_corner_radius_all(10)
	submit_hover.shadow_color = Color(0.3, 0.75, 0.45, 0.4)
	submit_hover.shadow_size = 10
	submit_hover.content_margin_left = 20
	submit_hover.content_margin_top = 12
	submit_hover.content_margin_right = 20
	submit_hover.content_margin_bottom = 12
	submit_button.add_theme_stylebox_override("hover", submit_hover)

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
	print("🎮 Timeline Reconstruction configure_puzzle() called")
	print("🎮 Config title: ", config.get("title", "NO TITLE"))
	print("🎮 Visible: ", visible)
	print("🎮 Modulate: ", modulate)
	print("🎮 Global position: ", global_position)
	print("🎮 Size: ", size)
	print("🎮 Z-index: ", z_index)

	# Force visibility
	visible = true
	modulate = Color(1, 1, 1, 1)
	z_index = 100
	print("🎮 Forced visibility settings")

	puzzle_config = config

	# Set title and context
	title_label.text = config.get("title", "Timeline Reconstruction")
	context_label.text = config.get("context", "Arrange the events in chronological order.")

	# Center-align event pool to match timeline slots
	events_pool.alignment = BoxContainer.ALIGNMENT_CENTER

	print("🎮 Title label text set to: ", title_label.text)
	print("🎮 Title label visible: ", title_label.visible)
	print("🎮 Number of events: ", config.get("events", []).size())

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

	# Show tutorial instead of starting timer immediately
	# Timer will start when tutorial is dismissed
	var tutorial_img_page1 = config.get("tutorial_image_page1", "")
	var tutorial_img_page2 = config.get("tutorial_image_page2", "")
	_show_tutorial(tutorial_img_page1, tutorial_img_page2)

	print("🎮 Timeline Reconstruction configuration complete!")
	print("🎮 Events pool children: ", events_pool.get_child_count())
	print("🎮 Timeline slots children: ", timeline_slots.get_child_count())
	print("🎮 Title label: ", title_label.text)
	print("🎮 Submit button visible: ", submit_button.visible)

func _create_event_card(event: Dictionary) -> Control:
	"""Create a vertical event card with image on top and text below (draggable)"""
	var card_wrapper = Control.new()
	card_wrapper.custom_minimum_size = Vector2(180, 220)
	card_wrapper.mouse_filter = Control.MOUSE_FILTER_STOP  # Enable mouse interaction

	# Store event data
	card_wrapper.set_meta("event_id", event.get("id", ""))
	card_wrapper.set_meta("event_data", event)
	card_wrapper.set_meta("in_pool", true)  # Track if card is in pool
	card_wrapper.set_meta("original_pool_index", -1)  # Will be set after adding to pool

	# Enable clicking to move to timeline
	card_wrapper.gui_input.connect(_on_card_clicked.bind(card_wrapper))

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(180, 220)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Let parent handle mouse events

	# Panel style - Orange/tan color for event pool
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.85, 0.55, 0.25, 0.95)
	style.set_corner_radius_all(10)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.7, 0.45, 0.2, 1.0)
	style.content_margin_left = 12
	style.content_margin_top = 12
	style.content_margin_right = 12
	style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", style)

	# Hover effects
	card_wrapper.mouse_entered.connect(_on_card_hover.bind(panel, true))
	card_wrapper.mouse_exited.connect(_on_card_hover.bind(panel, false))

	card_wrapper.add_child(panel)

	# VBox for image on top, text below
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block drag events
	panel.add_child(vbox)

	# Image
	var texture_rect = TextureRect.new()
	texture_rect.custom_minimum_size = Vector2(164, 164)
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block drag events

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

	# Text below image - fixed height container for consistent card sizes
	var label_container = CenterContainer.new()
	label_container.custom_minimum_size = Vector2(164, 44)  # Fixed height to match card total minus image
	label_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(label_container)

	var label = Label.new()
	label.text = event.get("text", "")
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color(0.05, 0.05, 0.05))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(156, 0)  # Fixed width for text wrapping
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER  # Center vertically in container
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block drag events
	label_container.add_child(label)

	return card_wrapper


func _create_timeline_slot(index: int) -> Control:
	"""Create a numbered timeline slot box (blue box) that accepts drops"""
	var slot_wrapper = Control.new()
	slot_wrapper.custom_minimum_size = Vector2(180, 220)
	slot_wrapper.mouse_filter = Control.MOUSE_FILTER_STOP  # Enable mouse interaction
	slot_wrapper.set_meta("slot_index", index)
	slot_wrapper.set_meta("is_empty", true)

	var slot = PanelContainer.new()
	slot.custom_minimum_size = Vector2(180, 220)
	slot.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	slot.mouse_filter = Control.MOUSE_FILTER_PASS  # Pass through to parent for drag-drop

	# Slot style - Blue color for timeline
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.25, 0.45, 0.75, 0.95)
	style.set_corner_radius_all(10)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.2, 0.35, 0.6, 1.0)
	style.content_margin_left = 0
	style.content_margin_top = 0
	style.content_margin_right = 0
	style.content_margin_bottom = 0
	slot.add_theme_stylebox_override("panel", style)

	# Make clickable for returning cards (use wrapper for input)
	slot_wrapper.gui_input.connect(_on_slot_gui_input.bind(slot_wrapper))
	slot_wrapper.mouse_entered.connect(_on_slot_hover.bind(slot, slot_wrapper, true))
	slot_wrapper.mouse_exited.connect(_on_slot_hover.bind(slot, slot_wrapper, false))

	slot_wrapper.add_child(slot)

	# Content container - will hold number or card
	var content = Control.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.set_meta("is_content_area", true)
	slot.add_child(content)

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
					var card_panel = card_wrapper.get_child(0)
					var tween = create_tween()
					tween.tween_property(card_panel, "modulate", Color(0.5, 0.8, 1.0), 0.1)
					tween.tween_property(card_panel, "modulate", Color.WHITE, 0.1)

					break
		else:
			# Card is in timeline slot - return it to pool
			# Find which slot contains this card
			for slot_wrapper in timeline_slots.get_children():
				if slot_wrapper is Control and not slot_wrapper.get_meta("is_empty", true):
					var slot_panel = slot_wrapper.get_child(0)
					var content = slot_panel.get_child(0)
					# Check if this slot contains our card
					for child in content.get_children():
						if child == card_wrapper:
							_move_card_to_pool(card_wrapper, slot_wrapper)
							return

## End Click-Based Interaction

func _on_card_hover(panel: PanelContainer, is_hovering: bool) -> void:
	"""Handle hover effect for event cards"""
	var style = StyleBoxFlat.new()
	if is_hovering:
		style.bg_color = Color(0.95, 0.65, 0.35, 1.0)
		style.border_color = Color(0.9, 0.6, 0.3, 1.0)
	else:
		style.bg_color = Color(0.85, 0.55, 0.25, 0.95)
		style.border_color = Color(0.7, 0.45, 0.2, 1.0)

	style.set_corner_radius_all(10)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.content_margin_left = 12
	style.content_margin_top = 12
	style.content_margin_right = 12
	style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", style)

func _on_slot_gui_input(event: InputEvent, slot_wrapper: Control) -> void:
	"""Handle mouse click on timeline slot to return card to pool"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not slot_wrapper.get_meta("is_empty", true):
			_on_timeline_slot_pressed(slot_wrapper)

func _on_slot_hover(slot: PanelContainer, slot_wrapper: Control, is_hovering: bool) -> void:
	"""Handle hover effect for timeline slots"""
	var is_empty = slot_wrapper.get_meta("is_empty", true)
	var style = StyleBoxFlat.new()

	if is_hovering and not is_empty:
		# Hover on filled slot - lighter blue
		style.bg_color = Color(0.35, 0.55, 0.85, 1.0)
		style.border_color = Color(0.3, 0.45, 0.7, 1.0)
	elif not is_empty:
		# Filled slot - normal blue
		style.bg_color = Color(0.25, 0.45, 0.75, 0.95)
		style.border_color = Color(0.2, 0.35, 0.6, 1.0)
	else:
		# Empty slot - normal blue
		style.bg_color = Color(0.25, 0.45, 0.75, 0.95)
		style.border_color = Color(0.2, 0.35, 0.6, 1.0)

	style.set_corner_radius_all(10)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.content_margin_left = 12
	style.content_margin_top = 12
	style.content_margin_right = 12
	style.content_margin_bottom = 12
	slot.add_theme_stylebox_override("panel", style)

func _on_timeline_slot_pressed(slot_wrapper: Control) -> void:
	"""Handle timeline slot click - return card to pool"""
	if not slot_wrapper.get_meta("is_empty", true):
		# Find and return the card
		var slot_panel = slot_wrapper.get_child(0)
		var content = slot_panel.get_child(0)
		for child in content.get_children():
			if child is Control and child.has_meta("event_id"):
				_move_card_to_pool(child, slot_wrapper)
				break

func _move_card_to_slot(card_wrapper: Control, slot_wrapper: Control) -> void:
	"""Move card from pool to timeline slot"""
	# Remove from events pool
	card_wrapper.get_parent().remove_child(card_wrapper)

	# Get content area (slot_wrapper -> PanelContainer -> content)
	var slot_panel = slot_wrapper.get_child(0)
	var content = slot_panel.get_child(0)

	# Clear placeholder number
	for child in content.get_children():
		child.queue_free()

	# Add card to slot and mark as not in pool
	card_wrapper.set_meta("in_pool", false)

	# Reset anchors and set explicit size to match slot (180x220)
	card_wrapper.set_anchors_preset(Control.PRESET_TOP_LEFT)
	card_wrapper.position = Vector2.ZERO
	card_wrapper.custom_minimum_size = Vector2(180, 220)
	card_wrapper.size = Vector2(180, 220)

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

	# Reset card positioning for pool layout
	card_wrapper.position = Vector2.ZERO
	card_wrapper.size = Vector2.ZERO
	card_wrapper.custom_minimum_size = Vector2(180, 220)  # Restore original size
	card_wrapper.set_anchors_preset(Control.PRESET_TOP_LEFT)
	card_wrapper.set_offsets_preset(Control.PRESET_TOP_LEFT, Control.PRESET_MODE_MINSIZE)

	# Insert at original index (or at end if index is invalid)
	if original_index >= 0 and original_index <= events_pool.get_child_count():
		events_pool.add_child(card_wrapper)
		events_pool.move_child(card_wrapper, original_index)
	else:
		events_pool.add_child(card_wrapper)

	# Flash animation
	var card_panel = card_wrapper.get_child(0)
	var tween = create_tween()
	tween.tween_property(card_panel, "modulate", Color(1.0, 0.8, 0.5), 0.1)
	tween.tween_property(card_panel, "modulate", Color.WHITE, 0.1)

	_update_current_order()

func _update_current_order() -> void:
	"""Update the current order array based on timeline slots"""
	current_order.clear()

	for slot_wrapper in timeline_slots.get_children():
		if slot_wrapper is Control:
			var slot_panel = slot_wrapper.get_child(0)
			var content = slot_panel.get_child(0)

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
	elif remaining <= 30:
		timer_label.add_theme_color_override("font_color", Color.YELLOW)
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
			hint_button.text = "💡 Wait: %ds" % ceil(hint_cooldown_remaining)

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

func _show_feedback(is_correct: bool, time_taken: float) -> void:
	"""Show feedback panel with modern presentation"""
	var feedback_text = ""

	if is_correct:
		# Success styling
		feedback_icon.text = "✓"
		feedback_icon.add_theme_color_override("font_color", Color(0.3, 0.9, 0.5))
		feedback_title.text = "CORRECT!"
		feedback_title.add_theme_color_override("font_color", Color(0.3, 0.9, 0.5))

		feedback_text = "[center]You successfully reconstructed the timeline in correct chronological order![/center]\n\n"

		# Award speed bonus (only on first attempt)
		if time_taken < 60.0 and not hint_used and first_attempt_correct:
			PlayerStats.add_hints(1)
			feedback_text += "[center][color=#FFD700]⚡ Speed Bonus: +1 Hint! ⚡[/color][/center]\n\n"

		# Show Continue button only, hide Retry button
		continue_button.show()
		retry_button.hide()
	else:
		# Error styling
		feedback_icon.text = "✗"
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
			var slot_panel = slot_wrapper.get_child(0)
			var content = slot_panel.get_child(0)

			# Find card
			for child in content.get_children():
				if child is Control and child.has_meta("event_id"):
					_move_card_to_pool(child, slot_wrapper)
					break

	# Reset timer
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
	feedback_icon.text = "⏱"
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
	"""Use hint to place the FIRST correct event that's not yet in the correct position"""
	# Don't allow hints during cooldown
	if hint_on_cooldown:
		return

	if PlayerStats.use_hint():
		hint_used = true

		# Start cooldown
		hint_on_cooldown = true
		hint_cooldown_remaining = hint_cooldown_time
		hint_button.disabled = true

		# Update current order to get latest state
		_update_current_order()

		print("🔍 Hint: Current order = ", current_order)
		print("🔍 Hint: Correct order = ", correct_order)

		# Find the first position that doesn't have the correct event
		for i in range(correct_order.size()):
			var correct_event_id = correct_order[i]

			# Check if this position already has the correct event
			var current_event_id = current_order[i] if i < current_order.size() else ""
			if current_event_id == correct_event_id:
				print("🔍 Hint: Slot ", i, " already correct (", correct_event_id, ")")
				continue  # This slot is already correct

			print("🔍 Hint: Need to place ", correct_event_id, " in slot ", i)

			# Find this event card in the pool
			for card_wrapper in events_pool.get_children():
				if card_wrapper is Control and card_wrapper.has_meta("event_id"):
					if card_wrapper.get_meta("event_id") == correct_event_id:
						# Check if card is in pool
						if not card_wrapper.get_meta("in_pool", false):
							print("🔍 Hint: Card ", correct_event_id, " not in pool, skipping")
							continue

						# Get the target slot
						var target_slot_wrapper = timeline_slots.get_child(i)

						# If slot has wrong card, move it back first
						if not target_slot_wrapper.get_meta("is_empty", true):
							print("🔍 Hint: Slot ", i, " occupied, clearing it first")
							var slot_panel = target_slot_wrapper.get_child(0)
							var content = slot_panel.get_child(0)
							for child in content.get_children():
								if child is Control and child.has_meta("event_id"):
									_move_card_to_pool(child, target_slot_wrapper)
									break

						# Move correct card to slot
						print("🔍 Hint: Moving ", correct_event_id, " to slot ", i)
						_move_card_to_slot(card_wrapper, target_slot_wrapper)

						# Flash animation
						var card_panel = card_wrapper.get_child(0)
						var tween = create_tween()
						tween.set_loops(3)
						tween.tween_property(card_panel, "modulate", Color.YELLOW, 0.3)
						tween.tween_property(card_panel, "modulate", Color.WHITE, 0.3)

						return

		# If we get here, all cards are already in correct positions
		print("🔍 Hint: All cards already in correct positions!")
	else:
		var label = Label.new()
		label.text = "No hints available!"
		label.add_theme_color_override("font_color", Color.RED)
		label.add_theme_font_size_override("font_size", 20)
		label.position = hint_button.global_position + Vector2(0, -40)
		add_child(label)

		await get_tree().create_timer(1.5).timeout
		label.queue_free()

func _update_hint_display() -> void:
	"""Update hint counter and button state"""
	hint_counter.text = "Hints: %d" % PlayerStats.hints

	# Update button state based on cooldown and available hints
	if hint_on_cooldown:
		hint_button.disabled = true
		# Button text will be updated in _process() with countdown
	else:
		hint_button.disabled = (PlayerStats.hints <= 0)
		hint_button.text = "💡 Use Hint"

func _unhandled_input(event: InputEvent) -> void:
	"""Handle F5 skip"""
	if InputMap.has_action("skip_minigame") and event.is_action_pressed("skip_minigame"):
		print("Timeline Reconstruction: F5 pressed - skipping minigame")
		set_process(false)

		var elapsed = Time.get_ticks_msec() / 1000.0 - start_time
		minigame_completed.emit(true, elapsed)
		queue_free()

		get_viewport().set_input_as_handled()
