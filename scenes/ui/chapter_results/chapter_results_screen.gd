extends Control

## Chapter Results Screen
## Displays comprehensive statistics at the end of each chapter

signal results_dismissed

# UI References (will be created in scene)
@onready var chapter_title_label = $CenterContainer/ResultsPanel/MarginContainer/VBoxContainer/Header/ChapterTitle
@onready var rank_label = $CenterContainer/ResultsPanel/MarginContainer/VBoxContainer/Header/RankContainer/RankLabel
@onready var rank_glow = $CenterContainer/ResultsPanel/MarginContainer/VBoxContainer/Header/RankContainer/RankGlow

# Performance stats
@onready var score_value = $CenterContainer/ResultsPanel/MarginContainer/VBoxContainer/StatsGrid/PerformanceSection/ScoreRow/ScoreValue
@onready var accuracy_value = $CenterContainer/ResultsPanel/MarginContainer/VBoxContainer/StatsGrid/PerformanceSection/AccuracyRow/AccuracyValue
@onready var clues_value = $CenterContainer/ResultsPanel/MarginContainer/VBoxContainer/StatsGrid/PerformanceSection/CluesRow/CluesValue

# Choice analysis
@onready var correct_value = $CenterContainer/ResultsPanel/MarginContainer/VBoxContainer/StatsGrid/ChoicesSection/CorrectRow/CorrectValue
@onready var wrong_value = $CenterContainer/ResultsPanel/MarginContainer/VBoxContainer/StatsGrid/ChoicesSection/WrongRow/WrongValue
@onready var perfect_value = $CenterContainer/ResultsPanel/MarginContainer/VBoxContainer/StatsGrid/ChoicesSection/PerfectRow/PerfectValue

# Time & efficiency
@onready var time_value = $CenterContainer/ResultsPanel/MarginContainer/VBoxContainer/StatsGrid/EfficiencySection/TimeRow/TimeValue
@onready var minigames_value = $CenterContainer/ResultsPanel/MarginContainer/VBoxContainer/StatsGrid/EfficiencySection/MinigamesRow/MinigamesValue
@onready var speed_bonus_value = $CenterContainer/ResultsPanel/MarginContainer/VBoxContainer/StatsGrid/EfficiencySection/SpeedRow/SpeedValue
@onready var hints_used_value = $CenterContainer/ResultsPanel/MarginContainer/VBoxContainer/StatsGrid/EfficiencySection/HintsUsedRow/HintsValue

# Progress
@onready var level_value = $CenterContainer/ResultsPanel/MarginContainer/VBoxContainer/StatsGrid/ProgressSection/LevelRow/LevelValue
@onready var xp_value = $CenterContainer/ResultsPanel/MarginContainer/VBoxContainer/StatsGrid/ProgressSection/XPRow/XPValue

# Achievements
@onready var achievements_container = $CenterContainer/ResultsPanel/MarginContainer/VBoxContainer/AchievementsSection/AchievementsList

# Buttons
@onready var continue_button = $CenterContainer/ResultsPanel/MarginContainer/VBoxContainer/ButtonsContainer/ContinueButton

func _ready():
	visible = false
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)

## Show the results screen with current chapter stats
func show_results():
	print("DEBUG: show_results() started")
	var stats = ChapterStatsTracker.get_current_stats()
	print("DEBUG: Stats retrieved: ", stats)
	var rank = ChapterStatsTracker.get_detective_rank()
	print("DEBUG: Rank: ", rank)

	# Update header
	print("DEBUG: Checking chapter_title_label: ", chapter_title_label != null)
	if chapter_title_label:
		chapter_title_label.text = "Chapter %d Complete!" % stats["chapter_number"]

	if rank_label:
		rank_label.text = rank
		_set_rank_color(rank)

	# Performance Section
	if score_value:
		score_value.text = str(stats["score"])

	if accuracy_value:
		var accuracy = ChapterStatsTracker.get_accuracy_percent()
		accuracy_value.text = "%.1f%%" % accuracy

	if clues_value:
		clues_value.text = "%d / %d" % [stats["clues_collected"], stats["total_clues"]]

	# Choice Analysis Section
	if correct_value:
		correct_value.text = str(stats["correct_choices"])

	if wrong_value:
		wrong_value.text = str(stats["wrong_choices"])

	if perfect_value:
		perfect_value.text = str(stats["perfect_interrogations"])

	# Time & Efficiency Section
	if time_value:
		time_value.text = ChapterStatsTracker.get_formatted_time()

	if minigames_value:
		minigames_value.text = str(stats["minigames_completed"])

	if speed_bonus_value:
		speed_bonus_value.text = str(stats["speed_bonuses_earned"])

	if hints_used_value:
		hints_used_value.text = str(stats["hints_used"])

	# Progress Section
	if level_value:
		level_value.text = "%d → %d" % [stats["start_level"], stats["end_level"]]

	if xp_value:
		xp_value.text = "+%d XP" % stats["xp_earned"]

	# Achievements
	print("DEBUG: Displaying achievements...")
	_display_achievements()

	# Show screen with animation
	print("DEBUG: Making screen visible...")
	visible = true
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	print("DEBUG: Fade-in tween started")

	# Play rank reveal animation
	print("DEBUG: Animating rank reveal...")
	_animate_rank_reveal()
	print("DEBUG: show_results() completed")

## Set rank label color based on rank
func _set_rank_color(rank: String):
	if not rank_label:
		return

	match rank:
		"S":
			rank_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))  # Gold
			if rank_glow:
				rank_glow.color = Color(1.0, 0.84, 0.0, 0.5)
		"A":
			rank_label.add_theme_color_override("font_color", Color(0.0, 0.8, 1.0))  # Cyan
			if rank_glow:
				rank_glow.color = Color(0.0, 0.8, 1.0, 0.5)
		"B":
			rank_label.add_theme_color_override("font_color", Color(0.0, 1.0, 0.5))  # Green
			if rank_glow:
				rank_glow.color = Color(0.0, 1.0, 0.5, 0.5)
		"C":
			rank_label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.0))  # Yellow
			if rank_glow:
				rank_glow.color = Color(1.0, 1.0, 0.0, 0.5)
		"D", "F":
			rank_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))  # Red
			if rank_glow:
				rank_glow.color = Color(1.0, 0.3, 0.3, 0.5)

## Animate rank reveal with scale and glow
func _animate_rank_reveal():
	if not rank_label:
		return

	rank_label.scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(rank_label, "scale", Vector2(1.2, 1.2), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(rank_label, "scale", Vector2(1.0, 1.0), 0.2)

	# Pulse glow
	if rank_glow:
		var glow_tween = create_tween()
		glow_tween.set_loops()
		glow_tween.tween_property(rank_glow, "modulate:a", 0.3, 0.8)
		glow_tween.tween_property(rank_glow, "modulate:a", 0.8, 0.8)

## Display earned achievements
func _display_achievements():
	if not achievements_container:
		return

	# Clear existing achievements
	for child in achievements_container.get_children():
		child.queue_free()

	var achievements = ChapterStatsTracker.get_achievements()

	if achievements.is_empty():
		var no_achievements = Label.new()
		no_achievements.text = "No achievements earned this chapter"
		no_achievements.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		no_achievements.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		achievements_container.add_child(no_achievements)
		return

	# Display each achievement
	for achievement in achievements:
		var achievement_box = HBoxContainer.new()
		achievement_box.add_theme_constant_override("separation", 10)

		# Icon
		var icon_label = Label.new()
		icon_label.text = achievement["icon"]
		icon_label.add_theme_font_size_override("font_size", 24)
		achievement_box.add_child(icon_label)

		# Name and description
		var text_vbox = VBoxContainer.new()

		var name_label = Label.new()
		name_label.text = achievement["name"]
		name_label.add_theme_font_size_override("font_size", 18)
		name_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
		text_vbox.add_child(name_label)

		var desc_label = Label.new()
		desc_label.text = achievement["description"]
		desc_label.add_theme_font_size_override("font_size", 14)
		desc_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		text_vbox.add_child(desc_label)

		achievement_box.add_child(text_vbox)
		achievements_container.add_child(achievement_box)

## Handle continue button press
func _on_continue_pressed():
	print("DEBUG: Continue button pressed!")
	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished

	visible = false
	print("DEBUG: Emitting results_dismissed signal")
	results_dismissed.emit()
