extends Node
## Autoload script that ensures all required audio buses exist at game startup

const USER_SETTINGS_PATH := "user://settings.cfg"
var config := ConfigFile.new()
var is_ready := false  # Flag to indicate AudioBusSetup has finished initialization

func _ready() -> void:
	_ensure_audio_buses()
	_load_and_apply_volume_settings()
	# Workaround for Godot 4.5 web export bug: non-Master buses are silent
	# (GitHub issue #100102). On web, reroute all buses to send to Master.
	if OS.get_name() == "Web":
		_fix_web_audio_buses()
	is_ready = true  # Signal that setup is complete
	print("Audio buses initialized and volume settings loaded")

func _ensure_audio_buses() -> void:
	"""Create audio buses if they don't exist"""
	# Ensure Music bus exists
	var music_bus_idx = AudioServer.get_bus_index("Music")
	if music_bus_idx == -1:
		AudioServer.add_bus()
		var new_bus_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(new_bus_idx, "Music")
		AudioServer.set_bus_send(new_bus_idx, "Master")
		print("Created Music audio bus at index ", new_bus_idx)

	# Ensure SFX bus exists
	var sfx_bus_idx = AudioServer.get_bus_index("SFX")
	if sfx_bus_idx == -1:
		AudioServer.add_bus()
		var new_bus_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(new_bus_idx, "SFX")
		AudioServer.set_bus_send(new_bus_idx, "Master")
		print("Created SFX audio bus at index ", new_bus_idx)

	# Ensure Voice bus exists
	var voice_bus_idx = AudioServer.get_bus_index("Voice")
	if voice_bus_idx == -1:
		AudioServer.add_bus()
		var new_bus_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(new_bus_idx, "Voice")
		AudioServer.set_bus_send(new_bus_idx, "Master")
		print("Created Voice audio bus at index ", new_bus_idx)

func _load_and_apply_volume_settings() -> void:
	"""Load saved volume settings and apply them to audio buses"""
	var err = config.load(USER_SETTINGS_PATH)
	if err != OK:
		print("No saved audio settings found, using defaults")
		# Apply default volumes even if no config exists
		_apply_audio_volume("Master", 100)
		_apply_audio_volume("Music", 80)
		_apply_audio_volume("SFX", 80)
		_apply_audio_volume("Voice", 100)
		return

	# Load volume settings (default to 100 for Master/Voice, 80 for Music/SFX)
	var master_vol = config.get_value("audio", "master_volume", 100)
	var music_vol = config.get_value("audio", "music_volume", 80)
	var sfx_vol = config.get_value("audio", "sfx_volume", 80)
	var voice_vol = config.get_value("audio", "voice_volume", 100)

	# Apply volumes
	_apply_audio_volume("Master", master_vol)
	_apply_audio_volume("Music", music_vol)
	_apply_audio_volume("SFX", sfx_vol)
	_apply_audio_volume("Voice", voice_vol)

	print("Loaded audio settings - Master: ", master_vol, "%, Music: ", music_vol, "%, SFX: ", sfx_vol, "%, Voice: ", voice_vol, "%")

	# Debug: Print actual bus volumes
	var music_bus_idx = AudioServer.get_bus_index("Music")
	if music_bus_idx >= 0:
		var actual_db = AudioServer.get_bus_volume_db(music_bus_idx)
		print("DEBUG: Music bus actual volume = ", actual_db, " dB")

func _fix_web_audio_buses() -> void:
	"""On web, non-Master buses are silent (Godot 4.5 bug #100102).
	Set all buses to send directly to Master so audio is audible."""
	for bus_name in ["Music", "SFX", "Voice"]:
		var idx = AudioServer.get_bus_index(bus_name)
		if idx >= 0:
			AudioServer.set_bus_send(idx, "Master")
			print("Web audio fix: rerouted ", bus_name, " bus to Master")

func _apply_audio_volume(bus_name: String, volume_percent: float) -> void:
	"""Convert percentage (0-100) to dB and apply to audio bus"""
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		if volume_percent <= 0:
			AudioServer.set_bus_mute(bus_idx, true)
			print("DEBUG: Muted ", bus_name, " bus (volume = ", volume_percent, "%)")
		else:
			AudioServer.set_bus_mute(bus_idx, false)
			var db = linear_to_db(volume_percent / 100.0)
			AudioServer.set_bus_volume_db(bus_idx, db)
			print("DEBUG: Set ", bus_name, " bus to ", volume_percent, "% (", db, " dB)")
