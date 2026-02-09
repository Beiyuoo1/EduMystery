extends Control

@onready var new_game_button = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/MenuButtons/NewGameButton
@onready var continue_button = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/MenuButtons/ContinueButton
@onready var settings_button = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/MenuButtons/SettingsButton
@onready var quit_button = $CenterContainer/MainPanel/MarginContainer/VBoxContainer/MenuButtons/QuitButton
@onready var background_music = $BackgroundMusic

const SAVE_LOAD_SCREEN = preload("res://scenes/ui/save_load_screen.tscn")

var music_started: bool = false

func _ready() -> void:
	# Wait for Vosk to load before starting background music
	if MinigameManager and not MinigameManager.vosk_is_loaded:
		# Connect to MinigameManager's process to check when Vosk is loaded
		set_process(true)
	else:
		# Vosk already loaded, start music immediately
		_start_background_music()

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

func _input(event: InputEvent) -> void:
	# Debug: Press Delete key to clear all save data
	if event.is_action_pressed("ui_text_delete"):
		if Dialogic.Save.has_slot("continue_save"):
			Dialogic.Save.delete_slot("continue_save")
			print("DEBUG: Save data cleared!")
			continue_button.disabled = true

func _process(_delta: float) -> void:
	# Check if Vosk has finished loading and start music
	if not music_started and MinigameManager and MinigameManager.vosk_is_loaded:
		_start_background_music()
		set_process(false)  # Stop processing once music starts

func _start_background_music() -> void:
	if background_music and not music_started:
		background_music.play()
		music_started = true
		print("Main menu background music started")

func stop_background_music() -> void:
	"""Public function to stop background music (called when loading save)"""
	if background_music and background_music.playing:
		background_music.stop()
		music_started = false
		print("Main menu background music stopped")

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
	# Stop background music before showing load screen
	stop_background_music()

	# Show load screen for player to choose which save to load
	var load_screen = SAVE_LOAD_SCREEN.instantiate()
	get_tree().root.add_child(load_screen)
	load_screen.set_mode(1)  # LOAD mode

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/settings_menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
