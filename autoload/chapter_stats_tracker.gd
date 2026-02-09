extends Node

## Chapter Statistics Tracker
## Tracks player performance throughout each chapter for the results screen

signal chapter_stats_updated

# Current chapter being tracked
var current_chapter: int = 1

# Chapter statistics
var chapter_stats: Dictionary = {
	"chapter_number": 1,
	"start_time": 0.0,
	"end_time": 0.0,
	"completion_time": 0.0,
	"start_level": 1,
	"end_level": 1,
	"xp_earned": 0,
	"score": 0,
	"correct_choices": 0,
	"wrong_choices": 0,
	"clues_collected": 0,
	"total_clues": 0,
	"minigames_completed": 0,
	"minigames_failed": 0,  # Minigames that timed out or were failed
	"speed_bonuses_earned": 0,
	"hints_used": 0,
	"hints_earned": 0,
	"perfect_interrogations": 0,  # Sequences of choices without mistakes
}

# Track current interrogation sequence
var current_interrogation_perfect: bool = true

# Store initial values for comparison
var initial_hints: int = 0
var initial_xp: int = 0

func _ready():
	# Connect to relevant signals
	if PlayerStats:
		PlayerStats.stats_changed.connect(_on_player_stats_changed)

## Start tracking a new chapter
func start_chapter(chapter_num: int):
	current_chapter = chapter_num

	# Reset all stats
	chapter_stats = {
		"chapter_number": chapter_num,
		"start_time": Time.get_ticks_msec() / 1000.0,
		"end_time": 0.0,
		"completion_time": 0.0,
		"start_level": Dialogic.VAR.conrad_level if Dialogic else 1,
		"end_level": 1,
		"xp_earned": 0,
		"score": 0,
		"correct_choices": 0,
		"wrong_choices": 0,
		"clues_collected": 0,
		"total_clues": _get_total_clues_for_chapter(chapter_num),
		"minigames_completed": 0,
		"minigames_failed": 0,
		"speed_bonuses_earned": 0,
		"hints_used": 0,
		"hints_earned": 0,
		"perfect_interrogations": 0,
	}

	# Store initial values
	if PlayerStats:
		initial_hints = PlayerStats.hints
		initial_xp = PlayerStats.xp + (PlayerStats.level - 1) * PlayerStats.XP_PER_LEVEL

	current_interrogation_perfect = true

	print("ChapterStatsTracker: Started tracking Chapter ", chapter_num)

## End chapter tracking and calculate final stats
func end_chapter():
	chapter_stats["end_time"] = Time.get_ticks_msec() / 1000.0
	chapter_stats["completion_time"] = chapter_stats["end_time"] - chapter_stats["start_time"]
	chapter_stats["end_level"] = Dialogic.VAR.conrad_level if Dialogic else 1

	# Get final score from Dialogic
	var score_var = "chapter" + str(current_chapter) + "_score"
	if Dialogic and Dialogic.VAR.has(score_var):
		chapter_stats["score"] = Dialogic.VAR.get(score_var)

	# Calculate XP earned
	if PlayerStats:
		var final_xp = PlayerStats.xp + (PlayerStats.level - 1) * PlayerStats.XP_PER_LEVEL
		chapter_stats["xp_earned"] = final_xp - initial_xp

	print("ChapterStatsTracker: Ended Chapter ", current_chapter)
	print("Final Stats: ", chapter_stats)

	chapter_stats_updated.emit()

## Record a correct choice
func record_correct_choice():
	chapter_stats["correct_choices"] += 1
	# Don't break interrogation streak
	print("ChapterStatsTracker: Correct choice recorded")

## Record a wrong choice
func record_wrong_choice():
	chapter_stats["wrong_choices"] += 1
	current_interrogation_perfect = false
	print("ChapterStatsTracker: Wrong choice recorded")

## Start a new interrogation sequence
func start_interrogation():
	current_interrogation_perfect = true

## End interrogation sequence and record if perfect
func end_interrogation():
	if current_interrogation_perfect and chapter_stats["correct_choices"] > 0:
		chapter_stats["perfect_interrogations"] += 1
		print("ChapterStatsTracker: Perfect interrogation recorded!")
	current_interrogation_perfect = true

## Record a clue/evidence collection
func record_clue_collected():
	chapter_stats["clues_collected"] += 1
	print("ChapterStatsTracker: Clue collected (", chapter_stats["clues_collected"], "/", chapter_stats["total_clues"], ")")

## Record minigame completion
func record_minigame_completed(speed_bonus: bool = false):
	chapter_stats["minigames_completed"] += 1
	if speed_bonus:
		chapter_stats["speed_bonuses_earned"] += 1
		chapter_stats["hints_earned"] += 1
	print("ChapterStatsTracker: Minigame completed (Speed bonus: ", speed_bonus, ")")

## Record minigame failure (timeout or failed)
func record_minigame_failed():
	chapter_stats["minigames_failed"] += 1
	print("ChapterStatsTracker: Minigame failed (", chapter_stats["minigames_failed"], " total)")

## Record hint usage
func record_hint_used():
	chapter_stats["hints_used"] += 1
	print("ChapterStatsTracker: Hint used (", chapter_stats["hints_used"], " total)")

## Get current chapter stats
func get_current_stats() -> Dictionary:
	return chapter_stats.duplicate()

## Calculate detective rank based on performance
func get_detective_rank() -> String:
	var accuracy = get_accuracy_percent()
	var clue_percent = get_clue_collection_percent()
	var avg_performance = (accuracy + clue_percent) / 2.0

	if avg_performance >= 95.0 and chapter_stats["wrong_choices"] == 0:
		return "S"  # Perfect
	elif avg_performance >= 90.0:
		return "A"  # Excellent
	elif avg_performance >= 80.0:
		return "B"  # Good
	elif avg_performance >= 70.0:
		return "C"  # Average
	elif avg_performance >= 60.0:
		return "D"  # Below Average
	else:
		return "F"  # Poor

## Get accuracy percentage
func get_accuracy_percent() -> float:
	var total_choices = chapter_stats["correct_choices"] + chapter_stats["wrong_choices"]
	if total_choices == 0:
		return 100.0
	return (float(chapter_stats["correct_choices"]) / float(total_choices)) * 100.0

## Get clue collection percentage
func get_clue_collection_percent() -> float:
	if chapter_stats["total_clues"] == 0:
		return 100.0
	return (float(chapter_stats["clues_collected"]) / float(chapter_stats["total_clues"])) * 100.0

## Format completion time as MM:SS
func get_formatted_time() -> String:
	var total_seconds = int(chapter_stats["completion_time"])
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	return "%02d:%02d" % [minutes, seconds]

## Get total clues available in chapter
func _get_total_clues_for_chapter(chapter: int) -> int:
	# Count evidence items defined for this chapter in EvidenceManager
	var count = 0
	if EvidenceManager:
		for evidence_id in EvidenceManager.evidence_definitions:
			var evidence = EvidenceManager.evidence_definitions[evidence_id]
			if evidence.get("chapter", 0) == chapter:
				count += 1
	return count

## Listen for PlayerStats changes
func _on_player_stats_changed(stats: Dictionary):
	# Track hints earned/used by comparing with initial
	if PlayerStats:
		var current_hints = PlayerStats.hints
		var hint_diff = current_hints - initial_hints

		# If hints increased, it's earned (already tracked via minigame)
		# If hints decreased, it's used
		if hint_diff < 0:
			# Hints were used (but we track this explicitly in record_hint_used)
			pass

## Check if player achieved specific milestones
func has_achievement(achievement_name: String) -> bool:
	match achievement_name:
		"perfect_detective":
			return chapter_stats["wrong_choices"] == 0 and chapter_stats["correct_choices"] > 0
		"speed_demon":
			return chapter_stats["minigames_completed"] > 0 and \
				   chapter_stats["speed_bonuses_earned"] == chapter_stats["minigames_completed"]
		"eagle_eye":
			return chapter_stats["clues_collected"] == chapter_stats["total_clues"] and \
				   chapter_stats["total_clues"] > 0
		"hint_master":
			return chapter_stats["hints_used"] == 0 and chapter_stats["minigames_completed"] > 0
		"perfect_interrogation":
			return chapter_stats["perfect_interrogations"] > 0
	return false

## Get achievements earned
func get_achievements() -> Array:
	var achievements = []

	if has_achievement("perfect_detective"):
		achievements.append({
			"name": "Perfect Detective",
			"description": "No wrong choices made",
			"icon": "🌟"
		})

	if has_achievement("speed_demon"):
		achievements.append({
			"name": "Speed Demon",
			"description": "All minigames under 60 seconds",
			"icon": "⚡"
		})

	if has_achievement("eagle_eye"):
		achievements.append({
			"name": "Eagle Eye",
			"description": "All clues collected",
			"icon": "🔍"
		})

	if has_achievement("hint_master"):
		achievements.append({
			"name": "Hint Master",
			"description": "Completed without using hints",
			"icon": "🧠"
		})

	if has_achievement("perfect_interrogation"):
		achievements.append({
			"name": "Smooth Interrogator",
			"description": "Perfect interrogation sequences",
			"icon": "💬"
		})

	return achievements
