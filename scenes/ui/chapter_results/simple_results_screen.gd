extends Control

## Simple Chapter Results Screen
## Shows: LEVEL UP!, Chapter Complete, Star Rating, Continue Button

signal results_dismissed

# Star rating based on average minigame time
var stars_earned: int = 0

func _ready():
	visible = false

## Show the results screen with star rating
func show_results(chapter_num: int, avg_minigame_time: float):
	# Calculate stars based on average time per minigame
	stars_earned = _calculate_stars(avg_minigame_time)

	# Build UI programmatically for simplicity
	await _create_ui(chapter_num)

	# Show with fade-in
	visible = true
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func _calculate_stars(avg_time: float) -> int:
	"""Calculate stars based on average minigame completion time"""
	# 3 stars: < 30 seconds average
	# 2 stars: < 60 seconds average
	# 1 star: >= 60 seconds average
	if avg_time < 30.0:
		return 3
	elif avg_time < 60.0:
		return 2
	else:
		return 1

func _create_ui(chapter_num: int):
	"""Create the UI programmatically"""
	# Dark semi-transparent overlay background
	var overlay = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.0, 0.0, 0.0, 0.85)  # Dark overlay
	add_child(overlay)

	# Wait one frame to get viewport size
	await get_tree().process_frame

	var viewport_size = get_viewport_rect().size
	var content_width = 900.0
	var content_height = 700.0

	# Calculate margins to center
	var margin_x = max(0, (viewport_size.x - content_width) / 2.0)
	var margin_y = max(0, (viewport_size.y - content_height) / 2.0)

	# Use MarginContainer with calculated margins
	var margin_container = MarginContainer.new()
	margin_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin_container.add_theme_constant_override("margin_left", int(margin_x))
	margin_container.add_theme_constant_override("margin_right", int(margin_x))
	margin_container.add_theme_constant_override("margin_top", int(margin_y))
	margin_container.add_theme_constant_override("margin_bottom", int(margin_y))
	add_child(margin_container)

	# Main panel with nice background
	var panel_container = PanelContainer.new()
	panel_container.custom_minimum_size = Vector2(900, 700)
	margin_container.add_child(panel_container)

	# Create stylebox for panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.15, 0.2, 0.95)  # Dark blue-grey
	panel_style.border_color = Color(1.0, 0.84, 0.0, 0.8)  # Gold border
	panel_style.set_border_width_all(4)
	panel_style.corner_radius_top_left = 20
	panel_style.corner_radius_top_right = 20
	panel_style.corner_radius_bottom_left = 20
	panel_style.corner_radius_bottom_right = 20
	panel_style.set_content_margin_all(40)
	panel_container.add_theme_stylebox_override("panel", panel_style)

	# Main VBox container
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 30)
	panel_container.add_child(vbox)

	# Add spacer
	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(spacer1)

	# "LEVEL UP!" title with shadow effect
	var level_up_label = Label.new()
	level_up_label.text = "LEVEL UP!"
	level_up_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_up_label.add_theme_font_size_override("font_size", 72)
	level_up_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))  # Gold
	level_up_label.add_theme_color_override("font_outline_color", Color(0.3, 0.2, 0.0))
	level_up_label.add_theme_constant_override("outline_size", 4)
	vbox.add_child(level_up_label)

	# "Chapter X Complete!" subtitle
	var chapter_label = Label.new()
	chapter_label.text = "Chapter %d Complete!" % chapter_num
	chapter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chapter_label.add_theme_font_size_override("font_size", 42)
	chapter_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0))  # Light blue-white
	chapter_label.add_theme_color_override("font_outline_color", Color(0.1, 0.1, 0.2))
	chapter_label.add_theme_constant_override("outline_size", 2)
	vbox.add_child(chapter_label)

	# Add spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(spacer2)

	# Stars (HBox for horizontal layout)
	var stars_hbox = HBoxContainer.new()
	stars_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	stars_hbox.add_theme_constant_override("separation", 30)
	vbox.add_child(stars_hbox)

	# Add 3 stars with glowing effect
	for i in range(3):
		var star_label = Label.new()
		if i < stars_earned:
			star_label.text = "★"  # Filled star
			star_label.modulate = Color(1.2, 1.1, 0.8)  # Bright glow
		else:
			star_label.text = "☆"   # Empty star
			star_label.modulate = Color(0.5, 0.5, 0.6)  # Dim
		star_label.add_theme_font_size_override("font_size", 100)
		stars_hbox.add_child(star_label)

	# Star rating explanation
	var rating_label = Label.new()
	var rating_text = ""
	if stars_earned == 3:
		rating_text = "⚡ Outstanding Performance! ⚡"
	elif stars_earned == 2:
		rating_text = "Great Job!"
	else:
		rating_text = "Case Solved!"
	rating_label.text = rating_text
	rating_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rating_label.add_theme_font_size_override("font_size", 28)
	rating_label.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	vbox.add_child(rating_label)

	# Add spacer
	var spacer3 = Control.new()
	spacer3.custom_minimum_size = Vector2(0, 60)
	vbox.add_child(spacer3)

	# Continue button with custom styling
	var continue_btn = Button.new()
	continue_btn.text = "Continue"
	continue_btn.custom_minimum_size = Vector2(250, 70)
	continue_btn.add_theme_font_size_override("font_size", 28)

	# Button style
	var btn_style_normal = StyleBoxFlat.new()
	btn_style_normal.bg_color = Color(0.2, 0.5, 0.8)  # Blue
	btn_style_normal.corner_radius_top_left = 10
	btn_style_normal.corner_radius_top_right = 10
	btn_style_normal.corner_radius_bottom_left = 10
	btn_style_normal.corner_radius_bottom_right = 10

	var btn_style_hover = StyleBoxFlat.new()
	btn_style_hover.bg_color = Color(0.3, 0.6, 0.9)  # Bright blue
	btn_style_hover.corner_radius_top_left = 10
	btn_style_hover.corner_radius_top_right = 10
	btn_style_hover.corner_radius_bottom_left = 10
	btn_style_hover.corner_radius_bottom_right = 10

	continue_btn.add_theme_stylebox_override("normal", btn_style_normal)
	continue_btn.add_theme_stylebox_override("hover", btn_style_hover)
	continue_btn.add_theme_stylebox_override("pressed", btn_style_hover)
	continue_btn.pressed.connect(_on_continue_pressed)

	# Center the button
	var button_container = CenterContainer.new()
	button_container.add_child(continue_btn)
	vbox.add_child(button_container)

func _on_continue_pressed():
	print("DEBUG: Continue button pressed - going to Mind Games Reviewer")

	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished

	visible = false
	results_dismissed.emit()
