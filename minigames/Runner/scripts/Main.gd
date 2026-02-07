extends Node2D

signal game_finished(success: bool, score: int)

# Game configuration
var questions: Array = []
var current_question_index: int = 0
var correct_answers_needed: int = 5

# Lane positions (3 lanes)
var lane_positions: Array = []
var lane_count: int = 3

# Game state
var score: int = 0
var health: int = 3
var game_active: bool = false
var game_speed: float = 200.0
var spawn_timer: float = 0.0
var spawn_interval: float = 1.5
var difficulty_timer: float = 0.0

# Scenes
var obstacle_scene = preload("res://minigames/Runner/scenes/Obstacle.tscn")
var collectible_scene = preload("res://minigames/Runner/scenes/Collectible.tscn")

# Screen dimensions
var screen_size: Vector2

# Current question data
var current_correct_answer: String = ""
var current_wrong_answers: Array = []

func _ready():
	screen_size = get_viewport_rect().size
	_setup_lanes()

	# Don't start game yet - wait for configure_puzzle()
	# Game will start after configuration

func configure_puzzle(config: Dictionary):
	if config.has("questions"):
		questions = config.questions
	if config.has("answers_needed"):
		correct_answers_needed = config.answers_needed
	if config.has("starting_speed"):
		game_speed = config.starting_speed

	# Start game after configuration
	_start_game()

func _setup_lanes():
	var lane_width = screen_size.x / lane_count
	for i in range(lane_count):
		lane_positions.append(lane_width * i + lane_width / 2)

func _start_game():
	game_active = true
	score = 0
	health = 3
	current_question_index = 0
	game_speed = 200.0
	_load_question()
	_update_ui()

func _load_question():
	if current_question_index >= questions.size():
		current_question_index = 0  # Loop questions

	var q = questions[current_question_index]
	current_correct_answer = q.correct
	current_wrong_answers = q.wrong.duplicate()

	$UILayer/QuestionLabel.text = q.question
	$UILayer/QuestionPanel.show()

func _process(delta):
	if not game_active:
		return

	# Spawn timer
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		_spawn_objects()

	# Difficulty increase
	difficulty_timer += delta
	if difficulty_timer >= 10.0:
		difficulty_timer = 0.0
		game_speed = min(game_speed + 30, 500.0)
		spawn_interval = max(spawn_interval - 0.1, 0.6)

	# Move all objects
	for obj in get_tree().get_nodes_in_group("runner_objects"):
		obj.position.y += game_speed * delta

		# Remove if off screen
		if obj.position.y > screen_size.y + 50:
			obj.queue_free()

func _spawn_objects():
	# Randomly choose which lanes get objects
	var lanes_to_use = []
	var num_objects = randi_range(1, 2)

	for i in range(num_objects):
		var lane = randi_range(0, lane_count - 1)
		if lane not in lanes_to_use:
			lanes_to_use.append(lane)

	# Decide if we spawn a correct answer this round
	var spawn_correct = randf() < 0.4  # 40% chance for correct answer
	var correct_lane = -1

	if spawn_correct and lanes_to_use.size() > 0:
		correct_lane = lanes_to_use[randi_range(0, lanes_to_use.size() - 1)]

	for lane in lanes_to_use:
		var spawn_pos = Vector2(lane_positions[lane], -50)

		if lane == correct_lane:
			_spawn_collectible(spawn_pos, current_correct_answer)
		else:
			var wrong = current_wrong_answers[randi_range(0, current_wrong_answers.size() - 1)]
			_spawn_obstacle(spawn_pos, wrong)

func _spawn_collectible(pos: Vector2, answer: String):
	var collectible = collectible_scene.instantiate()
	collectible.position = pos
	collectible.answer_text = answer
	collectible.collected.connect(_on_collectible_collected)
	collectible.add_to_group("runner_objects")
	$GameLayer.add_child(collectible)

func _spawn_obstacle(pos: Vector2, answer: String):
	var obstacle = obstacle_scene.instantiate()
	obstacle.position = pos
	obstacle.answer_text = answer
	obstacle.hit_player.connect(_on_obstacle_hit)
	obstacle.add_to_group("runner_objects")
	$GameLayer.add_child(obstacle)

func _on_collectible_collected():
	score += 100

	# Screen flash effect
	_flash_screen(Color(0.2, 0.8, 0.2, 0.3))

	# Check win condition
	if score >= correct_answers_needed * 100:
		_end_game(true)
	else:
		# Next question after collecting correct answer
		current_question_index += 1
		_load_question()

	_update_ui()

func _on_obstacle_hit():
	health -= 1

	# Screen flash effect
	_flash_screen(Color(0.8, 0.2, 0.2, 0.4))

	# Shake effect
	_shake_screen()

	if health <= 0:
		_end_game(false)

	_update_ui()

func _flash_screen(color: Color):
	$UILayer/FlashRect.color = color
	$UILayer/FlashRect.show()

	var tween = create_tween()
	tween.tween_property($UILayer/FlashRect, "color:a", 0.0, 0.3)
	tween.tween_callback($UILayer/FlashRect.hide)

func _shake_screen():
	#awwas CanvasLayer uses 'offset' instead of 'position'
	var original_offset = $GameLayer.offset
	var tween = create_tween()

	for i in range(5):
		var shake_offset = Vector2(randf_range(-10, 10), randf_range(-10, 10))
		tween.tween_property($GameLayer, "offset", original_offset + shake_offset, 0.05)

	tween.tween_property($GameLayer, "offset", original_offset, 0.05)

func _update_ui():
	$UILayer/ScoreLabel.text = "Score: " + str(score)
	$UILayer/HealthLabel.text = "Health: " + "❤️".repeat(health)
	$UILayer/ProgressLabel.text = str(score / 100) + "/" + str(correct_answers_needed)

func _end_game(success: bool):
	game_active = false

	# Clear all objects
	for obj in get_tree().get_nodes_in_group("runner_objects"):
		obj.queue_free()

	# Show result
	$UILayer/QuestionPanel.hide()
	$UILayer/ResultPanel.show()

	if success:
		$UILayer/ResultPanel/ResultLabel.text = "Great Job!\nScore: " + str(score)
		$UILayer/ResultPanel/ResultLabel.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
	else:
		$UILayer/ResultPanel/ResultLabel.text = "Game Over\nScore: " + str(score)
		$UILayer/ResultPanel/ResultLabel.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))

	# Auto-close after delay
	await get_tree().create_timer(2.5).timeout
	game_finished.emit(success, score)
	# Wait a frame to ensure signal is processed before cleanup
	await get_tree().process_frame
	queue_free()
