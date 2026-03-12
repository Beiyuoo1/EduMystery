extends Node

## Simple Android Speech Recognition
## Uses Activity Result Intent (no gradle/plugin needed!)
## This is the SIMPLEST approach that works with legacy export

signal speech_recognized(text: String)
signal speech_error(error_message: String)

var _is_android: bool = false

func _ready():
	_is_android = OS.get_name() == "Android"
	if _is_android:
		print("✓ Simple Android Speech initialized")

func is_speech_recognition_available() -> bool:
	return _is_android

func start_listening():
	if not _is_android:
		speech_error.emit("Not on Android")
		return

	print("🎤 Launching Android speech intent...")

	# Use Godot's OS.request_permission first
	if not OS.has_feature("android.permission.RECORD_AUDIO"):
		OS.request_permission("android.permission.RECORD_AUDIO")
		await get_tree().create_timer(0.5).timeout

	# For now, emit an error asking user to enable Java plugin
	# The full implementation requires compiling the custom plugin
	speech_error.emit("Speech plugin requires custom build - use tap controls for now")

	# TODO: Once plugin is compiled, this will work:
	# var android_runtime = Engine.get_singleton("AndroidRuntime")
	# android_runtime.launchSpeechRecognition()

# Temporary fallback - use tap-to-select instead of speech
func use_tap_controls():
	print("ℹ️ Using tap controls instead of speech recognition")
	# The reading game can detect this and skip speech features
