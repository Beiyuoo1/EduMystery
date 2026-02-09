extends Control

## The End Screen
## Displays after Chapter 5 completion with elegant fade-in animation

signal the_end_dismissed

func _ready():
	visible = false

func show_the_end():
	"""Display The End screen with elegant animation"""
	visible = true
	modulate.a = 0.0

	# Fade in background
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 2.0)

	# Wait a moment, then fade in the text
	await get_tree().create_timer(1.0).timeout

	var title_label = get_node_or_null("CenterContainer/VBoxContainer/TitleLabel")
	var subtitle_label = get_node_or_null("CenterContainer/VBoxContainer/SubtitleLabel")
	var credits_label = get_node_or_null("CenterContainer/VBoxContainer/CreditsLabel")

	# Animate title
	if title_label:
		title_label.modulate.a = 0.0
		var title_tween = create_tween()
		title_tween.tween_property(title_label, "modulate:a", 1.0, 1.5)

	await get_tree().create_timer(1.0).timeout

	# Animate subtitle
	if subtitle_label:
		subtitle_label.modulate.a = 0.0
		var subtitle_tween = create_tween()
		subtitle_tween.tween_property(subtitle_label, "modulate:a", 1.0, 1.5)

	await get_tree().create_timer(1.5).timeout

	# Animate credits
	if credits_label:
		credits_label.modulate.a = 0.0
		var credits_tween = create_tween()
		credits_tween.tween_property(credits_label, "modulate:a", 1.0, 2.0)

	# Wait for user input after all animations complete
	await get_tree().create_timer(3.0).timeout
	_enable_continue()

func _enable_continue():
	"""Enable the continue button or ESC to dismiss"""
	# Show a subtle "Press any key to continue" message
	var continue_hint = get_node_or_null("CenterContainer/VBoxContainer/ContinueHint")
	if continue_hint:
		continue_hint.visible = true
		continue_hint.modulate.a = 0.0

		# Pulse animation
		var pulse_tween = create_tween()
		pulse_tween.set_loops()
		pulse_tween.tween_property(continue_hint, "modulate:a", 1.0, 1.0)
		pulse_tween.tween_property(continue_hint, "modulate:a", 0.3, 1.0)

	# Wait for input
	set_process_input(true)

func _input(event):
	if event is InputEventKey and event.pressed:
		_on_continue()
	elif event is InputEventMouseButton and event.pressed:
		_on_continue()

func _on_continue():
	"""Fade out and dismiss"""
	set_process_input(false)

	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.5)
	await tween.finished

	emit_signal("the_end_dismissed")
	queue_free()
