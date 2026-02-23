# ============================================
# Flashy Level Up Scene with Particle Effects
# ============================================

extends CanvasLayer

signal level_up_finished

# Node references
@onready var background = $Background
@onready var gradient_overlay = $GradientOverlay
@onready var particles_bg = $ParticlesBG
@onready var particles_stars = $ParticlesStars
@onready var glow_rect = $CenterContainer/GlowPanel
@onready var container = $CenterContainer/VBoxContainer
@onready var star_label = $CenterContainer/VBoxContainer/StarLabel
@onready var level_label = $CenterContainer/VBoxContainer/LevelLabel
@onready var ability_icon = $CenterContainer/VBoxContainer/AbilityIcon
@onready var ability_name_label = $CenterContainer/VBoxContainer/AbilityName
@onready var ability_desc_label = $CenterContainer/VBoxContainer/AbilityDesc
@onready var continue_label = $CenterContainer/VBoxContainer/ContinueLabel
@onready var flash = $Flash

var can_close = false

func _ready():
	# Apply NotoSans font to labels displaying symbols (★ →)
	var symbol_font = load("res://assets/font/game_font.tres")
	if symbol_font:
		if star_label:
			star_label.add_theme_font_override("font", symbol_font)
		if level_label:
			level_label.add_theme_font_override("font", symbol_font)
		if ability_icon:
			ability_icon.add_theme_font_override("font", symbol_font)

	# Start hidden
	if background:
		background.modulate.a = 0
	if gradient_overlay:
		gradient_overlay.modulate.a = 0
	if container:
		container.modulate.a = 0
		container.scale = Vector2(0.5, 0.5)
	if glow_rect:
		glow_rect.modulate.a = 0
	if flash:
		flash.modulate.a = 0

	# Hide particles initially
	if particles_bg:
		particles_bg.emitting = false
	if particles_stars:
		particles_stars.emitting = false

	set_process_input(false)

func show_level_up(old_level: int, new_level: int, ability: Dictionary):
	# Set text content
	level_label.text = "Level %d → %d" % [old_level, new_level]

	if ability.is_empty():
		ability_icon.text = "★"
		ability_name_label.text = "Level Up!"
		ability_desc_label.text = "You've grown stronger!"
	else:
		var icon = ability.get("icon", "★")
		ability_icon.text = icon
		ability_name_label.text = ability.get("name", "New Ability")
		ability_desc_label.text = ability.get("desc", "")

	# Special styling for max level
	if new_level == 10:
		star_label.text = "★★★ MAXIMUM LEVEL REACHED ★★★"
		ability_icon.add_theme_color_override("font_color", Color.GOLD)
		ability_name_label.add_theme_color_override("font_color", Color.GOLD)
		if gradient_overlay:
			gradient_overlay.modulate = Color(1, 0.843, 0, 1.0)  # Golden tint
	else:
		star_label.text = "★ LEVEL UP! ★"

	# ANIMATION SEQUENCE
	await play_entrance_animation()

	# Wait before allowing close
	await get_tree().create_timer(0.5).timeout
	can_close = true
	set_process_input(true)

	# Blink continue label
	if continue_label:
		blink_continue_label()

func play_entrance_animation():
	# Flash effect
	if flash:
		flash.modulate.a = 1.0
		var flash_tween = create_tween()
		flash_tween.tween_property(flash, "modulate:a", 0.0, 0.3)

	# Background fade in
	var bg_tween = create_tween()
	bg_tween.set_parallel(true)
	if background:
		bg_tween.tween_property(background, "modulate:a", 1.0, 0.3)
	if gradient_overlay:
		bg_tween.tween_property(gradient_overlay, "modulate:a", 1.0, 0.3)
	await bg_tween.finished

	# Start particle systems
	if particles_bg:
		particles_bg.emitting = true
	if particles_stars:
		particles_stars.emitting = true

	# Glow panel pulse in
	if glow_rect:
		var glow_tween = create_tween()
		glow_tween.tween_property(glow_rect, "modulate:a", 0.6, 0.4).set_ease(Tween.EASE_OUT)
		glow_tween.tween_property(glow_rect, "modulate:a", 0.3, 0.4).set_ease(Tween.EASE_IN_OUT)

	# Container scale + fade in with bounce
	if container:
		var container_tween = create_tween()
		container_tween.set_parallel(true)
		container_tween.tween_property(container, "scale", Vector2(1.2, 1.2), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		container_tween.tween_property(container, "modulate:a", 1.0, 0.3)
		await container_tween.finished

		# Bounce back to normal size
		var bounce_tween = create_tween()
		bounce_tween.tween_property(container, "scale", Vector2(1.0, 1.0), 0.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
		await bounce_tween.finished

	# Animate labels individually with stagger
	await animate_label_sequence()

	# Continuous glow pulse
	pulse_glow()

func animate_label_sequence():
	var labels = [star_label, level_label, ability_icon, ability_name_label, ability_desc_label]

	for label in labels:
		if label:
			# Start from smaller and fade in
			label.modulate.a = 0
			label.scale = Vector2(0.8, 0.8)

			var label_tween = create_tween()
			label_tween.set_parallel(true)
			label_tween.tween_property(label, "modulate:a", 1.0, 0.2)
			label_tween.tween_property(label, "scale", Vector2(1.05, 1.05), 0.15).set_ease(Tween.EASE_OUT)
			await label_tween.finished

			# Slight bounce back
			var bounce = create_tween()
			bounce.tween_property(label, "scale", Vector2(1.0, 1.0), 0.1).set_ease(Tween.EASE_IN_OUT)

			# Stagger delay
			await get_tree().create_timer(0.1).timeout

func pulse_glow():
	if not glow_rect:
		return

	var pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(glow_rect, "modulate:a", 0.5, 1.0).set_ease(Tween.EASE_IN_OUT)
	pulse_tween.tween_property(glow_rect, "modulate:a", 0.2, 1.0).set_ease(Tween.EASE_IN_OUT)

func blink_continue_label():
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(continue_label, "modulate:a", 0.3, 0.8)
	tween.tween_property(continue_label, "modulate:a", 1.0, 0.8)

func _input(event):
	if can_close and event.is_pressed():
		close_level_up()
		get_viewport().set_input_as_handled()

func close_level_up():
	can_close = false
	set_process_input(false)

	# Stop particles
	if particles_bg:
		particles_bg.emitting = false
	if particles_stars:
		particles_stars.emitting = false

	# Fade out animation
	if background and gradient_overlay and container and glow_rect:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(background, "modulate:a", 0.0, 0.3)
		tween.tween_property(gradient_overlay, "modulate:a", 0.0, 0.3)
		tween.tween_property(glow_rect, "modulate:a", 0.0, 0.3)
		tween.tween_property(container, "modulate:a", 0.0, 0.3)
		tween.tween_property(container, "scale", Vector2(0.8, 0.8), 0.3).set_ease(Tween.EASE_IN)
		await tween.finished

	level_up_finished.emit()
