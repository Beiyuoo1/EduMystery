extends Node

func _ready():
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_dialogic_signal(argument: String):
	print("DEBUG: Signal received: ", argument)

	# Handle level up signal
	if argument == "show_level_up":
		_handle_level_up_signal()
		return

	# Handle minigame signals: "start_minigame <puzzle_id>"
	if argument.begins_with("start_minigame "):
		var puzzle_id = argument.trim_prefix("start_minigame ").strip_edges()
		print("DEBUG: Starting minigame: ", puzzle_id)
		_handle_minigame_signal(puzzle_id)
		return

	# Handle evidence unlock: "unlock_evidence <evidence_id>"
	if argument.begins_with("unlock_evidence "):
		var evidence_id = argument.trim_prefix("unlock_evidence ").strip_edges()
		await _handle_evidence_unlock(evidence_id)
		return

	# Handle level up check after all minigames complete
	if argument == "check_level_up":
		_handle_check_level_up()
		return

	# Handle character variable initialization
	if argument == "init_character_var":
		_handle_init_character_var()
		return

	# Debug character check
	if argument == "debug_character_check":
		print("================================================================================")
		print("DEBUG CHARACTER CHECK AT c3s1 CONDITIONAL:")
		var char_value = Dialogic.current_state_info['variables'].get('selected_character', 'NOT FOUND')
		print("  selected_character (from state_info) = '", char_value, "'")
		print("  Type: ", typeof(char_value))
		print("  Is 'celestine'? ", char_value == "celestine")
		print("  Is 'conrad'? ", char_value == "conrad")
		print("  Is empty? ", char_value == "")
		# Also check via Dialogic.VAR if possible
		if Dialogic.VAR.has("selected_character"):
			print("  Dialogic.VAR.selected_character = '", Dialogic.VAR.selected_character, "'")
		else:
			print("  Dialogic.VAR does NOT have selected_character!")
		print("================================================================================")
		return

	# Handle textbox visibility
	if argument == "hide_textbox":
		Dialogic.Text.hide_textbox(true)
		return
	if argument == "show_textbox":
		Dialogic.Text.show_textbox(true)
		return

	# Handle title card signals: "show_title_card <chapter_number>"
	if argument.begins_with("show_title_card "):
		var chapter = argument.trim_prefix("show_title_card ").strip_edges()
		_handle_title_card_signal(chapter)
		return

	# Handle silent BC card collection for Chapter 5 reveal
	if argument == "collect_bc_cards":
		if EvidenceManager:
			EvidenceManager.collect_bc_cards_silently()
		return

	# Handle chapter results: "show_chapter_results"
	if argument == "show_chapter_results":
		print("DEBUG: show_chapter_results signal received!")
		_handle_chapter_results()
		return

	# Track correct/wrong choices: "track_correct_choice" or "track_wrong_choice"
	if argument == "track_correct_choice":
		if ChapterStatsTracker:
			ChapterStatsTracker.record_correct_choice()
		return

	if argument == "track_wrong_choice":
		if ChapterStatsTracker:
			ChapterStatsTracker.record_wrong_choice()
		return

	# Track interrogation sequences: "start_interrogation" or "end_interrogation"
	if argument == "start_interrogation":
		if ChapterStatsTracker:
			ChapterStatsTracker.start_interrogation()
		return

	if argument == "end_interrogation":
		if ChapterStatsTracker:
			ChapterStatsTracker.end_interrogation()
		return

func _handle_level_up_signal():
	Dialogic.paused = true
	var conrad_level = Dialogic.VAR.conrad_level
	await LevelUpManager.show_level_up(conrad_level)
	Dialogic.paused = false

func _handle_minigame_signal(puzzle_id: String):
	Dialogic.paused = true
	MinigameManager.start_minigame(puzzle_id)
	await MinigameManager.minigame_completed

	# Track minigame completion or failure
	if ChapterStatsTracker:
		var success = MinigameManager.last_minigame_success
		if success:
			var speed_bonus = MinigameManager.last_minigame_speed_bonus
			ChapterStatsTracker.record_minigame_completed(speed_bonus)
		else:
			ChapterStatsTracker.record_minigame_failed()

	# Auto-save after completing minigame (requires SaveManager autoload)
	if SaveManager:
		await SaveManager.auto_save()

	# Re-show evidence button in case auto-save triggered timeline_ended and hid it
	if EvidenceButtonManager and EvidenceButtonManager.button_enabled:
		EvidenceButtonManager.show_evidence_button()

	# Safety check: ensure Dialogic is still valid before resuming
	if is_instance_valid(Dialogic) and Dialogic.current_timeline != null:
		Dialogic.paused = false
	else:
		push_warning("Dialogic timeline was cleared during minigame, skipping resume")

func _handle_check_level_up():
	if Dialogic.VAR.minigames_completed >= 3 and Dialogic.VAR.conrad_level < 2:
		Dialogic.paused = true
		Dialogic.VAR.conrad_level = 2
		await LevelUpManager.show_level_up(2)
		Dialogic.paused = false

func _handle_title_card_signal(chapter: String):
	Dialogic.paused = true
	# Update current chapter for curriculum question selection
	Dialogic.VAR.current_chapter = int(chapter)
	TitleCardManager.show_chapter_title(chapter)
	await TitleCardManager.title_card_completed

	# Start tracking new chapter
	if ChapterStatsTracker:
		ChapterStatsTracker.start_chapter(int(chapter))

	# Auto-save at chapter transitions (requires SaveManager autoload)
	if SaveManager:
		await SaveManager.auto_save()

	if is_instance_valid(Dialogic) and Dialogic.current_timeline != null:
		Dialogic.paused = false

func _handle_evidence_unlock(evidence_id: String):
	# Pause dialogic and show evidence unlock animation
	Dialogic.paused = true
	EvidenceManager.unlock_evidence(evidence_id)

	# Track clue collection
	if ChapterStatsTracker:
		ChapterStatsTracker.record_clue_collected()

	# Show evidence unlock animation
	await _show_evidence_unlock_animation(evidence_id)

	# Resume dialogic
	if is_instance_valid(Dialogic) and Dialogic.current_timeline != null:
		Dialogic.paused = false

func _show_evidence_unlock_animation(evidence_id: String):
	"""Show an animated popup when evidence is unlocked"""
	var evidence = EvidenceManager.evidence_definitions.get(evidence_id)
	if not evidence:
		return

	# Create the evidence unlock popup scene
	var canvas_layer = _create_evidence_popup(evidence)
	get_tree().root.add_child(canvas_layer)

	# Play clue found sound effect
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.stream = load("res://assets/audio/sound_effect/clue_found.wav")
	sfx_player.bus = "SFX"
	canvas_layer.add_child(sfx_player)
	sfx_player.play()

	# Wait for animation to complete
	await get_tree().create_timer(3.5).timeout

	# Fade out and remove
	if is_instance_valid(canvas_layer):
		var overlay = canvas_layer.get_child(0)  # Get the overlay ColorRect
		var center_container = canvas_layer.get_child(1)  # Get the center container
		if is_instance_valid(overlay) and is_instance_valid(center_container):
			var tween = create_tween()
			tween.set_parallel(true)
			tween.tween_property(overlay, "modulate:a", 0.0, 0.5)
			tween.tween_property(center_container, "modulate:a", 0.0, 0.5)
			await tween.finished
		canvas_layer.queue_free()

func _create_evidence_popup(evidence: Dictionary) -> CanvasLayer:
	"""Create an evidence unlock popup UI"""
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100

	# Create background overlay
	var overlay = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.8)
	canvas_layer.add_child(overlay)

	# Create center container
	var center_container = CenterContainer.new()
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas_layer.add_child(center_container)

	# Create content VBox
	var vbox = VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(600, 400)
	center_container.add_child(vbox)

	# Add "Clue Found!" label
	var clue_label = Label.new()
	clue_label.text = "🔍 CLUE FOUND! 🔍"
	clue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clue_label.add_theme_font_size_override("font_size", 48)
	clue_label.add_theme_color_override("font_color", Color(1, 0.8, 0, 1))
	vbox.add_child(clue_label)

	# Add spacer
	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer1)

	# Add evidence image
	var texture_rect = TextureRect.new()
	texture_rect.custom_minimum_size = Vector2(500, 300)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var texture = load(evidence["image_path"])
	if texture:
		texture_rect.texture = texture
	else:
		push_error("Failed to load evidence image: " + evidence["image_path"])
	vbox.add_child(texture_rect)

	# Add spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer2)

	# Add evidence title
	var title_label = Label.new()
	title_label.text = evidence["title"]
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(title_label)

	# Add evidence description
	var desc_label = Label.new()
	desc_label.text = evidence["description"]
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.custom_minimum_size = Vector2(500, 0)
	desc_label.add_theme_font_size_override("font_size", 18)
	desc_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1))
	vbox.add_child(desc_label)

	# Animate entrance - fade in the overlay
	overlay.modulate.a = 0.0
	vbox.modulate.a = 0.0
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(overlay, "modulate:a", 0.8, 0.5)
	tween.tween_property(vbox, "modulate:a", 1.0, 0.5)

	# Pulse animation for clue label
	var pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(clue_label, "scale", Vector2(1.1, 1.1), 0.5)
	pulse_tween.tween_property(clue_label, "scale", Vector2(1.0, 1.0), 0.5)

	return canvas_layer

func _handle_chapter_results():
	"""Show the simplified chapter results screen with stars, then Mind Games Reviewer"""
	print("DEBUG: _handle_chapter_results() called")

	# Skip results if loading from a saved game (to prevent getting stuck)
	# SaveManager sets a flag when loading, which we check here
	if SaveManager and SaveManager.is_loading_save:
		print("DEBUG: Skipping chapter results - loading from save")
		return

	print("DEBUG: Pausing Dialogic and showing results...")

	# Show evidence button during chapter results so player can review clues
	# Layer must be above the chapter results CanvasLayer (200) to receive input
	if EvidenceButtonManager:
		EvidenceButtonManager.show_evidence_button()
		if EvidenceButtonManager.evidence_button_instance and is_instance_valid(EvidenceButtonManager.evidence_button_instance):
			EvidenceButtonManager.evidence_button_instance.layer = 210

	# Pause Dialogic (this will pause all audio players via Dialogic's audio subsystem)
	Dialogic.paused = true
	print("DEBUG: Dialogic paused")

	# Find and unpause the chapter end music player
	# (Dialogic's pause() sets stream_paused=true on all audio, but we want the music to keep playing)
	var music_player = _find_chapter_end_music_player()
	if music_player:
		music_player.stream_paused = false
		print("DEBUG: Unpaused chapter end music player - playing=", music_player.playing, " stream_paused=", music_player.stream_paused)

	# End chapter tracking
	var stats = {}
	if ChapterStatsTracker:
		print("DEBUG: Ending chapter tracking...")
		ChapterStatsTracker.end_chapter()
		stats = ChapterStatsTracker.get_current_stats()

	# Calculate average minigame time for star rating
	# Failed minigames count as 90 seconds each (full timer penalty)
	var avg_time = 60.0  # Default 1 star
	var total_minigames = stats.get("minigames_completed", 0) + stats.get("minigames_failed", 0)
	if total_minigames > 0:
		var failed_penalty = stats.get("minigames_failed", 0) * 90.0  # 90s penalty per failed minigame
		avg_time = (stats.get("completion_time", 60.0) + failed_penalty) / total_minigames

	# Get chapter number from Dialogic variable (more reliable than stats)
	var chapter_num = 1
	if Dialogic and Dialogic.VAR.has("current_chapter"):
		chapter_num = Dialogic.VAR.current_chapter
		print("DEBUG: Using current_chapter from Dialogic.VAR: ", chapter_num)
	else:
		chapter_num = stats.get("chapter_number", 1)
		print("DEBUG: Using chapter_number from stats: ", chapter_num)

	# STEP 1: Show simplified results screen (LEVEL UP! + Stars)
	print("DEBUG: Creating simplified results screen...")
	var results_script = load("res://scenes/ui/chapter_results/simple_results_screen.gd")
	var results_screen = Control.new()
	results_screen.set_script(results_script)

	var canvas_layer1 = CanvasLayer.new()
	canvas_layer1.layer = 200
	get_tree().root.add_child(canvas_layer1)
	canvas_layer1.add_child(results_screen)

	print("DEBUG: Showing results with %d stars (avg time: %.1fs)" % [results_screen._calculate_stars(avg_time), avg_time])
	results_screen.show_results(chapter_num, avg_time)

	# Wait for user to click Continue
	print("DEBUG: Waiting for results to be dismissed...")
	await results_screen.results_dismissed
	print("DEBUG: Results dismissed!")
	canvas_layer1.queue_free()

	# STEP 2: Show Mind Games Reviewer
	print("DEBUG: Creating Mind Games Reviewer...")
	var reviewer_script = load("res://scenes/ui/chapter_results/mind_games_reviewer.gd")
	var reviewer_screen = Control.new()
	reviewer_screen.set_script(reviewer_script)

	var canvas_layer2 = CanvasLayer.new()
	canvas_layer2.layer = 200
	get_tree().root.add_child(canvas_layer2)
	canvas_layer2.add_child(reviewer_screen)

	print("DEBUG: Showing Mind Games Reviewer for chapter %d..." % chapter_num)
	reviewer_screen.show_reviewer(chapter_num)

	# Wait for user to close reviewer
	print("DEBUG: Waiting for reviewer to be dismissed...")
	await reviewer_screen.reviewer_dismissed
	print("DEBUG: Reviewer dismissed!")
	canvas_layer2.queue_free()

	# Restore evidence button layer and hide it now that chapter results are done
	if EvidenceButtonManager:
		if EvidenceButtonManager.evidence_button_instance and is_instance_valid(EvidenceButtonManager.evidence_button_instance):
			EvidenceButtonManager.evidence_button_instance.layer = 99
		EvidenceButtonManager.hide_evidence_button()

	# STEP 3: Show "The chain continues." screen only for Chapter 5, then go to main menu
	if chapter_num == 5:
		print("DEBUG: Chapter 5 complete - showing The End screen...")
		var the_end_scene = load("res://scenes/ui/the_end_screen.tscn")
		var the_end_screen = the_end_scene.instantiate()

		var canvas_layer3 = CanvasLayer.new()
		canvas_layer3.layer = 200
		get_tree().root.add_child(canvas_layer3)
		canvas_layer3.add_child(the_end_screen)

		the_end_screen.show_the_end()

		# Wait for signal - the_end_screen itself calls change_scene_to_file
		print("DEBUG: Waiting for The End screen to be dismissed...")
		await the_end_screen.the_end_dismissed
		print("DEBUG: The End screen dismissed - main menu transition in progress")
		return

	# Resume dialogic (for chapters 1-4)
	print("DEBUG: Resuming Dialogic...")
	if is_instance_valid(Dialogic) and Dialogic.current_timeline != null:
		Dialogic.paused = false
		print("DEBUG: Dialogic resumed")
	else:
		print("DEBUG: Dialogic or timeline is invalid, cannot resume")

func _handle_init_character_var():
	"""Initialize selected_character from PlayerStats at the start of the game"""
	print("DEBUG: _handle_init_character_var called")
	print("DEBUG: PlayerStats.selected_character = ", PlayerStats.selected_character if PlayerStats else "PlayerStats is null")

	if PlayerStats and PlayerStats.selected_character:
		# Access Dialogic's internal variable storage directly
		# The variable should exist from the timeline's "set {selected_character} = ''" line
		if Dialogic.current_state_info.has('variables'):
			var current_value = Dialogic.current_state_info['variables'].get('selected_character', 'NOT SET')
			print("DEBUG: Before assignment - selected_character = ", current_value)

			# Set via internal dictionary (Dialogic.VAR assignment doesn't work for runtime changes)
			Dialogic.current_state_info['variables']['selected_character'] = PlayerStats.selected_character

			print("DEBUG: After assignment - selected_character = ", Dialogic.current_state_info['variables']['selected_character'])
			print("DEBUG: Verification via Dialogic.VAR = ", Dialogic.VAR.selected_character)
		else:
			push_warning("DEBUG: Dialogic variables dictionary not initialized yet")
	else:
		print("DEBUG: PlayerStats or PlayerStats.selected_character is null/empty!")

func _debug_find_audio_recursive(node: Node) -> void:
	"""Recursively find all audio players in the scene tree"""
	if node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D:
		var stream_info = ""
		if node.stream:
			stream_info = node.stream.resource_path if node.stream.resource_path else str(node.stream)
		print("DEBUG AUDIO: '%s' (type: %s) playing=%s bus='%s' stream=%s" % [node.name, node.get_class(), node.playing, node.bus, stream_info])

	for child in node.get_children():
		_debug_find_audio_recursive(child)

func _find_chapter_end_music_player() -> AudioStreamPlayer:
	"""Find the Dialogic audio player for chapter_end_bg.mp3"""
	# Dialogic creates an "Audio" node under the Dialogic subsystem
	# Look for it by checking Dialogic's audio_node
	if Dialogic and Dialogic.Audio and Dialogic.Audio.audio_node:
		for child in Dialogic.Audio.audio_node.get_children():
			if child is AudioStreamPlayer and child.stream:
				# Check if this is the chapter end music
				if "chapter_end_bg" in child.stream.resource_path:
					print("DEBUG: Found chapter end music player: ", child.name)
					return child
	return null
