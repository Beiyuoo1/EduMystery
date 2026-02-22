extends Control

@onready var new_game_button = $LeftPanel/MenuButtons/NewGameButton
@onready var continue_button = $LeftPanel/MenuButtons/ContinueButton
@onready var settings_button = $LeftPanel/MenuButtons/SettingsButton
@onready var quit_button = $LeftPanel/MenuButtons/QuitButton
@onready var background_music = $BackgroundMusic
@onready var title_logo: TextureRect = $TitleArea/TitleLogo
@onready var title_shimmer: ColorRect = $TitleArea/TitleShimmer

const SAVE_LOAD_SCREEN = preload("res://scenes/ui/save_load_screen.tscn")

var music_started: bool = false
var music_manually_stopped: bool = false  # Prevent _process from auto-restarting

func _ready() -> void:
	# Wait for AudioBusSetup to fully initialize before starting music
	while not AudioBusSetup.is_ready:
		await get_tree().process_frame

	print("DEBUG: AudioBusSetup is ready, proceeding with music setup")
	print("DEBUG: Platform = ", OS.get_name())

	# Wait for Vosk to load before starting background music
	if MinigameManager and not MinigameManager.vosk_is_loaded:
		set_process(true)
	else:
		# On web, Chrome blocks audio until user interacts with the page.
		# Music will start on first click/keypress via _input().
		print("DEBUG: Vosk ready, platform check: is_web=", OS.get_name() == "Web")
		if OS.get_name() != "Web":
			_start_background_music()
		else:
			print("DEBUG: Web platform detected - waiting for user gesture to start music")


	# Check if any saves exist to enable/disable continue button
	var has_save = Dialogic.Save.has_slot("continue_save")
	if SaveManager:
		has_save = has_save or SaveManager.has_any_save()
	continue_button.disabled = not has_save

	# Connect button signals
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Start title logo effects
	_start_title_effects()

func _start_title_effects() -> void:
	# Fade-in on load
	title_logo.modulate.a = 0.0
	var fade_in = create_tween()
	fade_in.tween_property(title_logo, "modulate:a", 1.0, 1.2).set_ease(Tween.EASE_OUT)
	fade_in.tween_callback(_start_title_pulse)

func _start_title_pulse() -> void:
	# Continuous gentle pulse (scale breathe)
	var pulse = create_tween().set_loops()
	pulse.tween_property(title_logo, "scale", Vector2(1.03, 1.03), 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(title_logo, "scale", Vector2(1.0, 1.0), 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	title_logo.pivot_offset = title_logo.size / 2.0

	# Repeating shimmer sweep across the title every 4 seconds
	_run_shimmer_loop()

func _run_shimmer_loop() -> void:
	# Shimmer: a bright flash that sweeps left→right over the logo
	title_shimmer.modulate = Color(1, 1, 1, 0)
	var shimmer = create_tween()
	shimmer.tween_property(title_shimmer, "modulate:a", 0.18, 0.3).set_ease(Tween.EASE_OUT)
	shimmer.tween_property(title_shimmer, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
	shimmer.tween_interval(3.5)
	shimmer.tween_callback(_run_shimmer_loop)

func _input(event: InputEvent) -> void:
	# Debug: Press Delete key to clear all save data
	if event.is_action_pressed("ui_text_delete"):
		if Dialogic.Save.has_slot("continue_save"):
			Dialogic.Save.delete_slot("continue_save")
			print("DEBUG: Save data cleared!")
			continue_button.disabled = true

	# On web, start music on first REAL user interaction (Chrome autoplay policy)
	# Must check .pressed to avoid synthetic/internal Godot events firing this
	if OS.get_name() == "Web" and not music_started and not music_manually_stopped:
		var is_real_click = event is InputEventMouseButton and event.pressed
		var is_real_key = event is InputEventKey and event.pressed and not event.echo
		if is_real_click or is_real_key:
			print("DEBUG: Real user gesture detected on web, starting music")
			_start_background_music()

func _process(_delta: float) -> void:
	# Check if Vosk has finished loading and start music
	# But don't auto-restart if music was manually stopped
	if not music_started and not music_manually_stopped and MinigameManager and MinigameManager.vosk_is_loaded:
		# On web, defer to _input for user-gesture-gated audio start
		if OS.get_name() != "Web":
			_start_background_music()
			set_process(false)  # Stop processing once music starts

func _start_background_music() -> void:
	if background_music and not music_started:
		# Explicitly set bus to Music (fixes .tscn file not loading correctly on first run)
		background_music.bus = "Music"

		# Debug: Check Music bus volume and mute state before starting
		var music_bus_idx = AudioServer.get_bus_index("Music")
		if music_bus_idx >= 0:
			var music_db = AudioServer.get_bus_volume_db(music_bus_idx)
			var is_muted = AudioServer.is_bus_mute(music_bus_idx)
			print("DEBUG: Music bus volume when starting music = ", music_db, " dB")
			print("DEBUG: Music bus muted = ", is_muted)

		background_music.play()
		music_started = true
		print("Main menu background music started")
		print("DEBUG: BackgroundMusic node volume_db = ", background_music.volume_db, " dB")
		print("DEBUG: BackgroundMusic node bus = ", background_music.bus)

func stop_background_music() -> void:
	"""Public function to stop background music (called when loading save)"""
	if background_music and background_music.playing:
		background_music.stop()
		music_started = false
		print("Main menu background music stopped")

func _on_load_screen_closed() -> void:
	"""Called when load screen close button is pressed - restart music"""
	print("DEBUG: _on_load_screen_closed() called!")
	print("DEBUG: music_started = ", music_started)

	# Clear the manually stopped flag and restart music
	music_manually_stopped = false

	# This is only called when user clicks close button (not when loading a save)
	# So we can safely restart the music
	if not music_started:
		print("DEBUG: Restarting music...")
		_start_background_music()
	else:
		print("DEBUG: Music already started, not restarting")

func _on_new_game_pressed() -> void:
	# Stop background music
	if background_music and background_music.playing:
		background_music.stop()

	# Reset player stats for new game
	PlayerStats.reset_stats()

	# Reset evidence for new game
	EvidenceManager.reset_evidence()

	# Clear any existing continue save to start fresh
	if Dialogic.Save.has_slot("continue_save"):
		Dialogic.Save.delete_slot("continue_save")

	# Ensure Dialogic is not paused
	Dialogic.paused = false

	# Reset Dialogic variables for new game
	Dialogic.VAR.conrad_level = 1
	Dialogic.VAR.chapter1_score = 0
	Dialogic.VAR.chapter2_score = 0
	Dialogic.VAR.chapter3_score = 0
	Dialogic.VAR.chapter4_score = 0
	Dialogic.VAR.chapter5_score = 0
	Dialogic.VAR.minigames_completed = 0
	Dialogic.VAR.selected_subject = ""
	Dialogic.VAR.current_chapter = 1

	# Navigate to subject selection screen
	get_tree().change_scene_to_file("res://scenes/ui/subject_selection.tscn")

func _on_continue_pressed() -> void:
	print("DEBUG: Continue button pressed")

	# Mark that we manually stopped the music (prevents _process from restarting)
	music_manually_stopped = true

	# Stop background music before showing load screen
	stop_background_music()

	# Show load screen for player to choose which save to load
	var load_screen = SAVE_LOAD_SCREEN.instantiate()
	get_tree().root.add_child(load_screen)
	load_screen.set_mode(1)  # LOAD mode

	# Set callback to restart music when load screen closes (if user cancels without loading)
	load_screen.on_close_callback = _on_load_screen_closed
	print("DEBUG: Callback set on load screen")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/settings_menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
