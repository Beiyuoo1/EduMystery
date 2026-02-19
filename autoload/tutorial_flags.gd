extends Node

## TutorialFlags — stores which minigame tutorials the player has seen.
## Saved to a separate file so flags persist across all save slots and new games.
## A tutorial is shown the first time a player encounters a minigame on this device.

const SAVE_PATH = "user://tutorial_flags.sav"

var logic_grid_tutorial_seen: bool = false
var dialogue_choice_tutorial_seen: bool = false

func _ready() -> void:
	_load()

func mark_seen(tutorial_id: String) -> void:
	match tutorial_id:
		"logic_grid":
			logic_grid_tutorial_seen = true
		"dialogue_choice":
			dialogue_choice_tutorial_seen = true
	_save()

func has_seen(tutorial_id: String) -> bool:
	match tutorial_id:
		"logic_grid":
			return logic_grid_tutorial_seen
		"dialogue_choice":
			return dialogue_choice_tutorial_seen
	return false

func _save() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({
			"logic_grid": logic_grid_tutorial_seen,
			"dialogue_choice": dialogue_choice_tutorial_seen
		}))

func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var data = JSON.parse_string(file.get_as_text())
	if data:
		logic_grid_tutorial_seen = data.get("logic_grid", false)
		dialogue_choice_tutorial_seen = data.get("dialogue_choice", false)
