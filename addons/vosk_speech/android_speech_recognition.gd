## VOSK Offline Speech Recognition Plugin
## Uses VOSK library for offline, real-time speech-to-text
extends Node

signal speech_recognized(text: String)
signal speech_partial_result(text: String)
signal speech_error(error_code: int)
signal speech_ready_for_speech()
signal speech_begin()
signal speech_end()
signal model_ready()
signal model_error(message: String)

var is_listening: bool = false
var java_instance = null
var model_initialized: bool = false
var model_path: String = ""


func _ready():
	if OS.get_name() == "Android":
		_init_android_speech()
	else:
		print("⚠️ VOSK Speech Recognition: Not running on Android, speech recognition disabled")

func _init_android_speech():
	# In Godot 4, Android plugins are accessed differently
	# First, try to get the plugin as a singleton - check both possible names
	if Engine.has_singleton("AndroidSpeechRecognition"):
		java_instance = Engine.get_singleton("AndroidSpeechRecognition")
		print("✓ Speech Recognition plugin found via singleton (AndroidSpeechRecognition)")
		_connect_signals()
		# Initialize the model after connecting signals
		call_deferred("_initialize_model")
		return

	if Engine.has_singleton("VoskSpeechRecognition"):
		java_instance = Engine.get_singleton("VoskSpeechRecognition")
		print("✓ VOSK Speech Recognition plugin found via singleton")
		_connect_signals()
		# Initialize the model after connecting signals
		call_deferred("_initialize_model")
		return

	# Try to get the plugin via JNI wrapper
	var plugin_name = "AndroidSpeechRecognition"
	if Engine.has_singleton("JNISingleton"):
		var jni = Engine.get_singleton("JNISingleton")
		if jni.has_method("getPlugin"):
			java_instance = jni.call("getPlugin", plugin_name)
			if java_instance:
				print("✓ VOSK Speech Recognition plugin found via JNI")
				_connect_signals()
				call_deferred("_initialize_model")
				return

	# Try AndroidRuntime approach (Godot 4.x)
	if Engine.has_singleton("AndroidRuntime"):
		print("ℹ️ Trying to load plugin via AndroidRuntime...")
		var android_runtime = Engine.get_singleton("AndroidRuntime")

		# Get the Godot activity
		if android_runtime.has_method("getActivity"):
			var activity = android_runtime.call("getActivity")
			print("  ✓ Got Android activity")

			# Try to get the plugin from Godot's plugin registry
			if activity and activity.has_method("getGodotPlugin"):
				java_instance = activity.call("getGodotPlugin", plugin_name)
				if java_instance:
					print("✓ VOSK Speech Recognition plugin loaded!")
					_connect_signals()
					call_deferred("_initialize_model")
					return

	# Final fallback - check if it's available as a direct singleton with different casing
	print("ℹ️ Plugin not found, checking available singletons...")
	print("Available singletons:")
	for singleton_name in Engine.get_singleton_list():
		print("  - ", singleton_name)
		# Try case-insensitive match for speech recognition plugins
		var lower_name = singleton_name.to_lower()
		if lower_name == "voskspeechrecognition" or lower_name == "androidspeechrecognition":
			java_instance = Engine.get_singleton(singleton_name)
			print("✓ Found plugin with name: ", singleton_name)
			_connect_signals()
			call_deferred("_initialize_model")
			return

	print("❌ VOSK Speech Recognition plugin not loaded")
	print("   Make sure:")
	print("   1. Plugin is enabled in Project > Export > Android > Plugins")
	print("   2. Plugin AAR (40MB with VOSK) is in android/plugins/VoskSpeechRecognition/")
	print("   3. Plugin GDAP file is configured correctly")
	print("   4. App was built with the plugin included")

## Initialize the VOSK model
## The model is bundled inside the Vosk AAR's assets.
## We call initModelFromAssets() on the Java plugin, which extracts the model
## from the AAR assets to internal storage and loads it.
func _initialize_model():
	print("--- Initializing VOSK Model ---")

	if not java_instance:
		print("No Java instance to initialize model")
		emit_signal("model_error", "No Java plugin instance")
		return

	# First check if model is already initialized (e.g. from a previous session)
	if is_speech_recognition_available():
		print("Java plugin already reports available - model already loaded!")
		model_initialized = true
		model_path = "assets"
		emit_signal("model_ready")
		return

	# Call initModelFromAssets() on the Java plugin
	# This extracts the Vosk model from AAR assets to app internal storage
	# and calls new Model(path) on a background thread.
	# It emits "model_initialized" signal when done, or "speech_error" on failure.
	print("Calling initModelFromAssets() on Java plugin...")
	java_instance.call("initModelFromAssets")
	print("initModelFromAssets() called - waiting for model_initialized signal...")

	# Poll as backup in case signal doesn't fire
	var wait_time = 0
	var max_wait = 30  # Model extraction can take a while on first run

	while wait_time < max_wait:
		await get_tree().create_timer(1.0).timeout
		wait_time += 1

		if model_initialized or is_speech_recognition_available():
			if not model_initialized:
				model_initialized = true
				print("Model ready (detected via polling after ", wait_time, "s)")
			else:
				print("Model ready (via signal after ", wait_time, "s)")
			model_path = "assets"
			emit_signal("model_ready")
			return

		if wait_time % 5 == 0:
			print("  Still waiting for model... (", wait_time, "s)")

	print("Model failed to initialize after ", max_wait, " seconds")
	print("   Check logcat: adb logcat -s AndroidSpeechRecognition:*")
	emit_signal("model_error", "Model initialization timed out")

func _connect_signals():
	# Connect to signals from the plugin
	if not java_instance:
		return

	# IMPORTANT: has_signal() is also broken for Android plugins in Godot
	# See: https://github.com/godotengine/godot/issues/46673
	# We connect directly without checking has_signal()

	# Connect speech signals
	java_instance.speech_recognized.connect(_on_speech_result)
	print("  ✓ Connected to speech_recognized")

	java_instance.speech_partial_result.connect(_on_speech_partial)
	print("  ✓ Connected to speech_partial_result")

	java_instance.speech_error.connect(_on_speech_error)
	print("  ✓ Connected to speech_error")

	java_instance.speech_ready_for_speech.connect(_on_ready_for_speech)
	print("  ✓ Connected to speech_ready_for_speech")

	java_instance.speech_begin.connect(_on_begin_speech)
	print("  ✓ Connected to speech_begin")

	java_instance.speech_end.connect(_on_end_speech)
	print("  ✓ Connected to speech_end")

	# Connect model initialization signal
	java_instance.model_initialized.connect(_on_java_model_initialized)
	print("  ✓ Connected to model_initialized")

## Request microphone permission (Android 6+)
func request_microphone_permission() -> bool:
	print("--- Checking microphone permission ---")
	print("  OS: ", OS.get_name())

	if OS.get_name() != "Android":
		print("  Not on Android, skipping permission check")
		return true

	# Check if permission is already granted
	var permissions = OS.get_granted_permissions()
	print("  Granted permissions: ", permissions.size(), " total")

	if "android.permission.RECORD_AUDIO" in permissions:
		print("✓ RECORD_AUDIO permission already granted")
		return true

	print("📱 Requesting RECORD_AUDIO permission...")
	OS.request_permissions()

	# Wait for permission dialog and user response (up to 10 seconds)
	var wait_time = 0
	while wait_time < 10:
		await get_tree().create_timer(0.5).timeout
		wait_time += 0.5

		permissions = OS.get_granted_permissions()
		if "android.permission.RECORD_AUDIO" in permissions:
			print("✓ RECORD_AUDIO permission granted after ", wait_time, " seconds!")
			return true

		# If user denied quickly, don't keep waiting
		if wait_time >= 2.0:
			# Check if we're still waiting for user input
			print("  Still waiting for permission... (", wait_time, "s)")

	print("❌ RECORD_AUDIO permission DENIED or timed out")
	return false

## Start listening for speech
func start_listening():
	if OS.get_name() != "Android":
		print("⚠️ Speech recognition only works on Android")
		return

	if is_listening:
		print("⚠️ Already listening")
		return

	print("🎤 Starting VOSK offline speech recognition...")

	# First, ensure we have microphone permission
	var has_permission = await request_microphone_permission()
	if not has_permission:
		print("❌ ERROR: Microphone permission not granted!")
		emit_signal("speech_error", 9)  # Insufficient permissions
		return

	if java_instance:
		# Wait for model to be available (with extended timeout for first-time load)
		var wait_attempts = 0
		var max_attempts = 10  # 10 seconds total
		while not is_speech_recognition_available() and wait_attempts < max_attempts:
			if wait_attempts == 0:
				print("⏳ VOSK model not ready yet. Waiting for initialization...")
			await get_tree().create_timer(1.0).timeout
			wait_attempts += 1
			if wait_attempts % 3 == 0:
				print("  Still waiting for VOSK model... (", wait_attempts, "s)")

		if not is_speech_recognition_available():
			print("❌ ERROR: VOSK model not loaded after ", wait_attempts, " seconds.")
			print("   Model path: ", model_path)
			print("   Please check logcat for Java errors: adb logcat | grep -i vosk")
			emit_signal("speech_error", 5)  # Client error
			return

		print("✓ VOSK model ready, starting recognition...")
		is_listening = true
		java_instance.call("startListening")
		print("✓ Called startListening() on VOSK plugin")
	else:
		print("❌ ERROR: Plugin not loaded, cannot start listening")
		print("   Make sure 'VoskSpeechRecognition' is enabled in Project > Export > Android > Plugins")
		emit_signal("speech_error", 5)  # Client error

## Stop listening
func stop_listening():
	if not is_listening:
		return

	print("⏹️ Stopping VOSK speech recognition...")

	if java_instance:
		is_listening = false
		java_instance.call("stopListening")

## Check if speech recognition is available
func is_speech_recognition_available() -> bool:
	if OS.get_name() != "Android":
		return false

	if not java_instance:
		return false

	# has_method() is broken for Android plugins in Godot 4
	# Call isAvailable() directly - it exists in the Java plugin
	var available = java_instance.call("isAvailable")
	return available

## Check if model is initialized
func is_model_initialized() -> bool:
	return model_initialized

## Get the model path
func get_model_path() -> String:
	return model_path

## Manually set model path (if needed)
func set_model_path(path: String):
	model_path = path
	if java_instance and java_instance.has_method("setModelPath"):
		java_instance.call("setModelPath", path)
		print("✓ Model path set to: ", path)

## Get plugin status for debugging
func get_plugin_status() -> String:
	if OS.get_name() != "Android":
		return "Not on Android"
	if not java_instance:
		return "Plugin not loaded - check export_presets.cfg"

	var status = "Plugin loaded"
	if model_initialized:
		status += ", Model initialized"
	else:
		status += ", Model NOT initialized"

	if model_path != "":
		status += ", Path: " + model_path

	return status

## Callback from Java - final result
func _on_speech_result(text: String):
	print("✅ Speech recognized: ", text)
	emit_signal("speech_recognized", text)

## Callback from Java - partial result (while speaking)
func _on_speech_partial(text: String):
	print("📝 Partial result: ", text)
	emit_signal("speech_partial_result", text)

## Callback from Java - error occurred
func _on_speech_error(error_code: int):
	print("❌ Speech recognition error: ", error_code)
	is_listening = false
	emit_signal("speech_error", error_code)

	# Error codes from Android SpeechRecognizer:
	# 1 = Network error
	# 2 = Network timeout
	# 3 = No match
	# 4 = Server error
	# 5 = Client error
	# 6 = Speech timeout
	# 7 = No match
	# 8 = Recognizer busy
	# 9 = Insufficient permissions

## Callback from Java - ready to listen
func _on_ready_for_speech():
	print("✓ Ready for speech")
	emit_signal("speech_ready_for_speech")

## Callback from Java - user started speaking
func _on_begin_speech():
	print("🗣️ User began speaking")
	emit_signal("speech_begin")

## Callback from Java - user stopped speaking
func _on_end_speech():
	print("🤫 User stopped speaking")
	emit_signal("speech_end")

## Callback from Java - model initialized successfully
func _on_java_model_initialized():
	print("✅ Java plugin: Model initialized!")
	model_initialized = true
	emit_signal("model_ready")
