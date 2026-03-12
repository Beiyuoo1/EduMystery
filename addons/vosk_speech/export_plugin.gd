@tool
extends EditorExportPlugin

const PLUGIN_NAME = "VoskSpeechRecognition"
const MODEL_PATH = "res://addons/vosk_speech/vosk-model-small-en-us-0.15"

# List of model files that must be exported
const MODEL_FILES = [
	"README",
	"am/final.mdl",
	"conf/mfcc.conf",
	"conf/model.conf",
	"graph/disambig_tid.int",
	"graph/Gr.fst",
	"graph/HCLr.fst",
	"graph/phones/word_boundary.int",
	"ivector/final.dubm",
	"ivector/final.ie",
	"ivector/final.mat",
	"ivector/global_cmvn.stats",
	"ivector/online_cmvn.conf",
	"ivector/splice.conf"
]

func _get_name() -> String:
	return PLUGIN_NAME

func _supports_platform(platform: EditorExportPlatform) -> bool:
	if platform is EditorExportPlatformAndroid:
		return true
	return false

func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
	# On Android, model files are already bundled via android/plugins/src/main/assets/
	# Using add_file() creates a corrupt assets.sparsepck that breaks ALL texture loading
	if "android" in features:
		print("VOSK Export Plugin: Skipping add_file() on Android (model bundled via gradle plugin assets)")
		return

	print("VOSK Export Plugin: Adding model files to export...")

	# Add each model file to the export (non-Android platforms only)
	for file_name in MODEL_FILES:
		var source_path = MODEL_PATH + "/" + file_name
		var file = FileAccess.open(source_path, FileAccess.READ)
		if file:
			var content = file.get_buffer(file.get_length())
			file.close()

			add_file(source_path, content, false)
			print("  ✓ Added: ", source_path, " (", content.size(), " bytes)")
		else:
			print("  ⚠️ Failed to read: ", source_path)

	print("VOSK Export Plugin: Model files added!")

func _get_android_libraries(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
	if debug:
		return PackedStringArray(["res://addons/vosk_speech/bin/debug/VoskSpeechRecognition.aar"])
	else:
		return PackedStringArray(["res://addons/vosk_speech/bin/release/VoskSpeechRecognition.aar"])

func _get_android_dependencies(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
	# VOSK offline speech recognition library
	return PackedStringArray(["com.alphacephei:vosk-android:0.3.47"])

func _get_android_dependencies_maven_repos(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
	return PackedStringArray([])

func _get_android_manifest_activity_element_contents(platform: EditorExportPlatform, debug: bool) -> String:
	return ""

func _get_android_manifest_application_element_contents(platform: EditorExportPlatform, debug: bool) -> String:
	return ""

func _get_android_manifest_element_contents(platform: EditorExportPlatform, debug: bool) -> String:
	return """
	<uses-permission android:name="android.permission.RECORD_AUDIO" />
	<uses-permission android:name="android.permission.INTERNET" />
"""
