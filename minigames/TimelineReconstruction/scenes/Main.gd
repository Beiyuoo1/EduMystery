extends Control

## Timeline Reconstruction Minigame
## Drag-and-drop events into correct chronological order
## Students sequence events based on time, causality, and evidence

# UI Nodes
@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var context_label: RichTextLabel = $Panel/VBox/ContextLabel
@onready var events_pool: VBoxContainer = $Panel/VBox/HBox/EventsPanel/EventsPool
@onready var timeline_slots: VBoxContainer = $Panel/VBox/HBox/TimelinePanel/TimelineSlots
@onready var timer_label: Label = $Panel/VBox/TopBar/TimerLabel
@onready var hint_button: Button = $Panel/VBox/TopBar/HintButton
@onready var hint_counter: Label = $Panel/VBox/TopBar/HintCounter
@onready var submit_button: Button = $Panel/VBox/SubmitButton
@onready var feedback_panel: Panel = $FeedbackPanel
@onready var feedback_label: RichTextLabel = $FeedbackPanel/VBox/FeedbackLabel
@onready var continue_button: Button = $FeedbackPanel/VBox/ButtonsHBox/ContinueButton
@onready var retry_button: Button = $FeedbackPanel/VBox/ButtonsHBox/RetryButton

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

signal minigame_completed(success: bool, time_taken: float)

func _ready() -> void:
	print("🎮 Timeline Reconstruction _ready() called")
	feedback_panel.hide()
	hint_button.pressed.connect(_on_hint_pressed)
	submit_button.pressed.connect(_on_submit_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	_update_hint_display()
	print("🎮 Timeline Reconstruction _ready() complete")

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
	for event in shuffled_events:
		var event_card = _create_event_card(event)
		events_pool.add_child(event_card)

	# Create empty timeline slots
	for i in range(events.size()):
		var slot = _create_timeline_slot(i)
		timeline_slots.add_child(slot)

	# Start timer
	start_time = Time.get_ticks_msec() / 1000.0
	set_process(true)

	print("🎮 Timeline Reconstruction configuration complete!")
	print("🎮 Events pool children: ", events_pool.get_child_count())
	print("🎮 Timeline slots children: ", timeline_slots.get_child_count())
	print("🎮 Title label: ", title_label.text)
	print("🎮 Submit button visible: ", submit_button.visible)

func _create_event_card(event: Dictionary) -> Button:
	"""Create a draggable event card"""
	var card = Button.new()
	card.custom_minimum_size = Vector2(450, 80)
	card.text = event.get("text", "")
	card.add_theme_font_size_override("font_size", 18)
	card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	# Store event data
	card.set_meta("event_id", event.get("id", ""))
	card.set_meta("event_data", event)

	# Style card
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.25, 0.3, 0.4, 0.9)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.5, 0.6, 0.7, 1.0)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	card.add_theme_stylebox_override("normal", style)

	var style_hover = style.duplicate()
	style_hover.bg_color = Color(0.35, 0.45, 0.55, 1.0)
	style_hover.border_color = Color(0.7, 0.8, 0.9, 1.0)
	card.add_theme_stylebox_override("hover", style_hover)

	# Connect drag signals
	card.pressed.connect(_on_event_card_pressed.bind(card))

	return card

func _create_timeline_slot(index: int) -> PanelContainer:
	"""Create a timeline slot"""
	var slot = PanelContainer.new()
	slot.custom_minimum_size = Vector2(450, 90)
	slot.set_meta("slot_index", index)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2, 0.8)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.4, 0.4, 0.5, 1.0)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	slot.add_theme_stylebox_override("panel", style)

	var vbox = VBoxContainer.new()
	slot.add_child(vbox)

	var slot_label = Label.new()
	slot_label.text = "Slot %d" % (index + 1)
	slot_label.add_theme_font_size_override("font_size", 16)
	slot_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(slot_label)

	return slot

func _on_event_card_pressed(card: Button) -> void:
	"""Handle event card click - move to timeline or back to pool"""
	var event_id = card.get_meta("event_id")

	# Check if card is in pool or timeline
	if card.get_parent() == events_pool:
		# Move to first empty slot
		for child in timeline_slots.get_children():
			if child.get_child_count() == 1:  # Only has label, no card
				_move_card_to_slot(card, child)
				break
	else:
		# Move back to pool
		_move_card_to_pool(card)

func _move_card_to_slot(card: Button, slot: PanelContainer) -> void:
	"""Move card to a timeline slot"""
	# Remove from current parent
	card.get_parent().remove_child(card)

	# Add to slot
	slot.add_child(card)

	# Update current order
	_update_current_order()

func _move_card_to_pool(card: Button) -> void:
	"""Move card back to events pool"""
	# Remove from current parent (slot)
	var slot = card.get_parent()
	slot.remove_child(card)

	# Add back to pool
	events_pool.add_child(card)

	# Update current order
	_update_current_order()

func _update_current_order() -> void:
	"""Update the current order array based on timeline slots"""
	current_order.clear()

	for slot in timeline_slots.get_children():
		if slot.get_child_count() > 1:  # Has a card
			var card = slot.get_child(1)  # First child is label
			var event_id = card.get_meta("event_id")
			current_order.append(event_id)

func _process(delta: float) -> void:
	"""Update timer"""
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
	"""Show feedback panel with result"""
	var feedback_text = ""

	if is_correct:
		feedback_text = "[center][color=green][b]✓ CORRECT![/b][/color][/center]\n\n"
		feedback_text += "You successfully reconstructed the timeline in correct chronological order!\n\n"

		# Award speed bonus (only on first attempt)
		if time_taken < 60.0 and not hint_used and first_attempt_correct:
			PlayerStats.add_hints(1)
			feedback_text += "\n[center][color=yellow]⚡ Speed Bonus: +1 Hint! ⚡[/color][/center]"

		# Show Continue button only, hide Retry button
		continue_button.show()
		retry_button.hide()
	else:
		feedback_text = "[center][color=red][b]✗ INCORRECT[/b][/color][/center]\n\n"
		feedback_text += "The sequence doesn't match the evidence. Review the time stamps and causality.\n\n"
		feedback_text += "[b]Correct Order:[/b]\n"
		for i in range(correct_order.size()):
			var event_id = correct_order[i]
			for event in events:
				if event.get("id") == event_id:
					feedback_text += "%d. %s\n" % [i + 1, event.get("text")]
					break

		# Show only Retry button, hide Continue button
		continue_button.hide()
		retry_button.show()

	if puzzle_config.has("explanation"):
		feedback_text += "\n" + puzzle_config["explanation"]

	feedback_label.text = feedback_text
	feedback_panel.show()

func _on_continue_pressed() -> void:
	"""Continue to next scene - only available after completing correctly"""
	var elapsed = Time.get_ticks_msec() / 1000.0 - start_time

	# Emit completion signal with first attempt accuracy (for star rating)
	# But minigame was completed successfully (true)
	minigame_completed.emit(first_attempt_correct, elapsed)
	queue_free()

func _on_retry_pressed() -> void:
	"""Retry the minigame - reset timer and hide feedback"""
	feedback_panel.hide()

	# Move all cards back to pool
	for slot in timeline_slots.get_children():
		if slot is PanelContainer and slot.get_child_count() > 1:
			var card = slot.get_child(1)  # Get the card (skip VBox at index 0)
			if card is Button:
				_move_card_to_pool(card)

	# Reset timer
	start_time = Time.get_ticks_msec() / 1000.0
	set_process(true)

func _on_time_up() -> void:
	"""Handle time running out"""
	set_process(false)

	# Track as failed first attempt if this is first attempt
	if first_attempt:
		first_attempt_correct = false
		first_attempt = false

	feedback_label.text = "[center][color=red][b]⏱ TIME'S UP![/b][/color][/center]\n\n"
	feedback_label.text += "You ran out of time to complete the timeline.\n\n"
	feedback_label.text += "[b]Correct Order:[/b]\n"
	for i in range(correct_order.size()):
		var event_id = correct_order[i]
		for event in events:
			if event.get("id") == event_id:
				feedback_label.text += "%d. %s\n" % [i + 1, event.get("text")]
				break

	if puzzle_config.has("explanation"):
		feedback_label.text += "\n" + puzzle_config["explanation"]

	# Show only Retry button, hide Continue button
	continue_button.hide()
	retry_button.show()

	feedback_panel.show()

func _on_hint_pressed() -> void:
	"""Use hint to place first unplaced correct event"""
	if PlayerStats.use_hint():
		hint_used = true
		_update_hint_display()

		# Find next correct event that's not placed
		for i in range(correct_order.size()):
			var correct_event_id = correct_order[i]

			# Check if this event is already in correct position
			if i < current_order.size() and current_order[i] == correct_event_id:
				continue

			# Find this event card in pool
			for card in events_pool.get_children():
				if card is Button and card.get_meta("event_id") == correct_event_id:
					# Find the correct slot (skip index 0 which is the header Label)
					var target_slot = timeline_slots.get_child(i + 1)

					# If slot has wrong card, move it back to pool first
					if target_slot.get_child_count() > 1:
						var wrong_card = target_slot.get_child(1)
						_move_card_to_pool(wrong_card)

					# Move correct card to slot
					_move_card_to_slot(card, target_slot)

					# Flash animation
					var tween = create_tween()
					tween.set_loops(3)
					tween.tween_property(card, "modulate", Color.YELLOW, 0.3)
					tween.tween_property(card, "modulate", Color.WHITE, 0.3)

					hint_button.disabled = true
					return

		hint_button.disabled = true
	else:
		var label = Label.new()
		label.text = "No hints available!"
		label.add_theme_color_override("font_color", Color.RED)
		label.position = hint_button.global_position + Vector2(0, -30)
		add_child(label)

		await get_tree().create_timer(1.5).timeout
		label.queue_free()

func _update_hint_display() -> void:
	"""Update hint counter display"""
	hint_counter.text = "Hints: %d" % PlayerStats.hints

func _unhandled_input(event: InputEvent) -> void:
	"""Handle F5 skip"""
	if InputMap.has_action("skip_minigame") and event.is_action_pressed("skip_minigame"):
		print("Timeline Reconstruction: F5 pressed - skipping minigame")
		set_process(false)

		var elapsed = Time.get_ticks_msec() / 1000.0 - start_time
		minigame_completed.emit(true, elapsed)
		queue_free()

		get_viewport().set_input_as_handled()
