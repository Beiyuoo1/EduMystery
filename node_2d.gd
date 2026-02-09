extends Node2D

# Flag to indicate if we should load a save instead of starting fresh
static var load_continue_save := false

# Flag to indicate if a timeline is already running (e.g., from debug skip)
static var timeline_already_started := false

func _ready() -> void:
	Dialogic.paused = false

	if load_continue_save:
		# Load the saved game state
		print("DEBUG: node_2d.gd loading continue save.")
		load_continue_save = false
		# Wait for scene to be fully ready, then load save
		call_deferred("_load_save")
	elif timeline_already_started:
		# Timeline was started by debug skip or other means - don't start c1s1
		print("DEBUG: node_2d.gd - timeline already running, not starting c1s1.")
		timeline_already_started = false
	else:
		# Start fresh from Chapter 1 Scene 1
		print("DEBUG: node_2d.gd starting c1s1.")
		Dialogic.start("c1s1")

func _load_save() -> void:
	# Wait an extra frame to ensure Dialogic is fully initialized
	await get_tree().process_frame

	# Dialogic.Save.load() handles starting the timeline from saved state
	# This will restore the timeline, position, and all game state
	Dialogic.Save.load("continue_save")
