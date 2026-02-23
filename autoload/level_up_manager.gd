# ============================================
# FILE 1: level_up_manager.gd
# Save as: res://autoload/level_up_manager.gd
# ============================================
# This is an AUTOLOAD script that manages level-up displays

extends Node

var level_up_scene = preload("res://scenes/ui/level_up_scene_flashy.tscn")
var current_level_up_instance = null

# Ability data for each level
var ability_data = {
	2: {
		"name": "Second Chance",
		"desc": "You can now retry failed minigames once!",
		"icon": "⚡"
	},
	3: {
		"name": "Score Improvement",
		"desc": "Retry completed minigames to improve your score!",
		"icon": "*"
	},
	4: {
		"name": "Deductive Hint",
		"desc": "Receive 1 hint per minigame when you need guidance!",
		"icon": ""
	},
	5: {
		"name": "Extended Analysis",
		"desc": "Gain +30 seconds on timed challenges!",
		"icon": "⏱️"
	},
	6: {
		"name": "Double Attempt",
		"desc": "You can now retry failed minigames TWICE!",
		"icon": "->"
	},
	7: {
		"name": "Enhanced Insight",
		"desc": "Receive 2 hints per minigame!",
		"icon": ""
	},
	8: {
		"name": "Master's Focus",
		"desc": "Gain +60 seconds on timed challenges!",
		"icon": "⏱️"
	},
	9: {
		"name": "Strategic Skip",
		"desc": "Skip challenging sections after 3 failed attempts!",
		"icon": "⏭️"
	},
	10: {
		"name": "Perfect Detective",
		"desc": "Unlimited retries and all hints available! You've mastered deduction!",
		"icon": "*"
	}
}

# Main function to show level up
func show_level_up(new_level: int):
	if current_level_up_instance:
		push_warning("Level up already showing!")
		return
	
	# Update ability variables based on level
	update_abilities(new_level)
	
	# Create and show level up scene
	current_level_up_instance = level_up_scene.instantiate()
	get_tree().root.add_child(current_level_up_instance)
	
	# Pass data to the scene
	var old_level = new_level - 1
	current_level_up_instance.show_level_up(old_level, new_level, ability_data.get(new_level, {}))
	
	# Wait for it to finish
	await current_level_up_instance.level_up_finished
	
	# Clean up
	current_level_up_instance.queue_free()
	current_level_up_instance = null

# Update Dialogic variables based on level
func update_abilities(level: int):
	match level:
		2:
			Dialogic.VAR.retry_count = 1
		3:
			Dialogic.VAR.can_redo_for_score = true
		4:
			Dialogic.VAR.hint_count = 1
		5:
			Dialogic.VAR.time_bonus = 30
		6:
			Dialogic.VAR.retry_count = 2
		7:
			Dialogic.VAR.hint_count = 2
		8:
			Dialogic.VAR.time_bonus = 60
		9:
			Dialogic.VAR.can_skip_hard = true
		10:
			Dialogic.VAR.retry_count = 999
			Dialogic.VAR.hint_count = 999
