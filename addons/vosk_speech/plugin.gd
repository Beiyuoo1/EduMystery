@tool
extends EditorPlugin

const ExportPlugin = preload("res://addons/vosk_speech/export_plugin.gd")

var export_plugin: EditorExportPlugin

func _enter_tree():
	export_plugin = ExportPlugin.new()
	add_export_plugin(export_plugin)
	print("VOSK Speech Recognition plugin loaded (v2 Android plugin)")

func _exit_tree():
	remove_export_plugin(export_plugin)
	export_plugin = null
	print("VOSK Speech Recognition plugin unloaded")
