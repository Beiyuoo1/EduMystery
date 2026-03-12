extends Node

# Android Native Speech Recognition
# Uses Android's built-in SpeechRecognizer API (no gradle build needed!)

signal speech_results_ready(results: Array)
signal speech_error(error_message: String)
signal speech_ready_for_speech()
signal speech_begin_speech()

var _speech_recognizer = null
var _recognition_listener = null
var _is_android: bool = false
var _is_listening: bool = false

func _ready():
	if OS.get_name() == "Android":
		_is_android = true
		print("✓ Android Native Speech Recognition initialized")
	else:
		print("ℹ️ Not on Android - speech recognition disabled")

func is_available() -> bool:
	return _is_android

func start_listening():
	if not _is_android:
		print("⚠️ Speech recognition only works on Android")
		speech_error.emit("Not available on this platform")
		return

	if _is_listening:
		print("⚠️ Already listening")
		return

	print("🎤 Starting speech recognition...")
	_start_android_recognition()

func stop_listening():
	if not _is_android or not _is_listening:
		return

	print("🛑 Stopping speech recognition...")
	_stop_android_recognition()
	_is_listening = false

func _start_android_recognition():
	if Engine.has_singleton("JavaClassWrapper"):
		var jcw = Engine.get_singleton("JavaClassWrapper")

		# Get Android context
		var activity = Engine.get_singleton("AndroidRuntime")
		if not activity:
			speech_error.emit("Cannot access Android activity")
			return

		# Start recognition via Java call
		var result = JavaScriptBridge.eval("""
			(function() {
				if (typeof Android === 'undefined') return false;

				var SpeechRecognizer = Android.require('android.speech.SpeechRecognizer');
				var RecognizerIntent = Android.require('android.speech.RecognizerIntent');
				var Intent = Android.require('android.content.Intent');

				if (!SpeechRecognizer.isRecognitionAvailable(Android.context)) {
					return false;
				}

				var recognizer = SpeechRecognizer.createSpeechRecognizer(Android.context);
				var intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
				intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
				intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, "en-US");
				intent.putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 5);

				recognizer.startListening(intent);
				return true;
			})();
		""")

		if result:
			_is_listening = true
			speech_ready_for_speech.emit()
		else:
			speech_error.emit("Speech recognition not available")
	else:
		# Fallback: Use JNI directly
		_start_via_jni()

func _start_via_jni():
	# Alternative implementation using direct JNI calls
	var plugin = Engine.get_singleton("GodotAndroidPlugin")
	if plugin:
		var can_start = plugin.call("startSpeechRecognition")
		if can_start:
			_is_listening = true
			speech_ready_for_speech.emit()
		else:
			speech_error.emit("Failed to start speech recognition")
	else:
		speech_error.emit("Android plugin not available")

func _stop_android_recognition():
	# Stop recognition
	if Engine.has_singleton("JavaClassWrapper"):
		JavaScriptBridge.eval("""
			if (typeof Android !== 'undefined' && Android.recognizer) {
				Android.recognizer.stopListening();
				Android.recognizer.destroy();
			}
		""")

# Called from Java/Android side when results are ready
func _on_speech_results(results: Array):
	print("📝 Speech results: ", results)
	_is_listening = false
	speech_results_ready.emit(results)

# Called from Java/Android side on error
func _on_speech_error(error_code: int):
	var error_msg = _get_error_message(error_code)
	print("❌ Speech error: ", error_msg)
	_is_listening = false
	speech_error.emit(error_msg)

func _get_error_message(error_code: int) -> String:
	match error_code:
		1: return "Network error"
		2: return "Network timeout"
		3: return "No match found"
		4: return "Server error"
		5: return "Client error"
		6: return "Speech timeout"
		7: return "No speech input"
		8: return "Recognizer busy"
		9: return "Insufficient permissions"
		_: return "Unknown error"
