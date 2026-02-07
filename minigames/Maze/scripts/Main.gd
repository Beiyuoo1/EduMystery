extends Node2D

signal game_finished(success: bool, score: int)

# Maze configuration - using preset map dimensions
const CELL_SIZE = 32  # Larger cells for better visibility
var maze_width: int = 25
var maze_height: int = 15

# Cell types
enum Cell { WALL, FLOOR }

# Game state
var maze: Array = []
var question: Dictionary = {}  # Single fill-in-the-blank question
var correct_answers: Array = []  # 2 correct answers for the blanks
var wrong_answers: Array = []   # Wrong answer options
var answers_collected: int = 0
var score: int = 0
var health: int = 3
var game_active: bool = false

# Preset map data
var start_pos: Vector2i = Vector2i(1, 1)
var correct_spots: Array = []  # 2 spots for correct answers
var wrong_spots: Array = []     # Spots for wrong answers

# Scenes
var collectible_scene = preload("res://minigames/Maze/scenes/Collectible.tscn")

# Colors
const WALL_COLOR = Color(0.25, 0.2, 0.35, 1)
const FLOOR_COLOR = Color(0.9, 0.87, 0.8, 1)
const PLAYER_START_COLOR = Color(0.3, 0.8, 0.4, 0.4)

func _ready():
	# Quick fade-in for smooth transition
	modulate.a = 0.0
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 1.0, 0.15)

	# Default question for testing (only used if configure_puzzle is not called)
	question = {
		"text": "Who is the person who creates the message in the communication process?",
		"options": [
			{"letter": "A", "text": "Sender", "correct": true},
			{"letter": "B", "text": "Receiver", "correct": false},
			{"letter": "C", "text": "Listener", "correct": false},
			{"letter": "D", "text": "Decoder", "correct": false},
			{"letter": "E", "text": "Creates", "correct": false},
			{"letter": "F", "text": "Receives", "correct": false},
			{"letter": "G", "text": "Sends", "correct": false},
			{"letter": "H", "text": "Interprets", "correct": false}
		]
	}
	# Don't start game yet - wait for configure_puzzle() to be called

func configure_puzzle(config: Dictionary):
	# Handle curriculum format: {"questions": [{question, correct, wrong[]}, ...]}
	if config.has("questions") and config.questions is Array and config.questions.size() > 0:
		# Pick a random question from the curriculum
		var random_q = config.questions[randi() % config.questions.size()]

		# Convert curriculum format to Maze format
		# Curriculum: {question: String, correct: String, wrong: Array}
		# Maze: {text: String, options: [{letter, text, correct: bool}]}

		var options = []
		var letters = ["A", "B", "C", "D", "E", "F", "G", "H"]

		# Add correct answer
		options.append({
			"letter": letters[0],
			"text": random_q.correct,
			"correct": true
		})

		# Add wrong answers
		for i in range(min(random_q.wrong.size(), 7)):  # Max 7 wrong (total 8 options)
			options.append({
				"letter": letters[i + 1],
				"text": random_q.wrong[i],
				"correct": false
			})

		# Shuffle options so correct answer isn't always first
		options.shuffle()

		question = {
			"text": random_q.question,
			"options": options
		}

		print("DEBUG: Maze configured with curriculum question: ", question.text)
	elif config.has("question"):
		# Legacy format support
		question = config.question

	# Start the game after configuration
	_start_game()

func _start_game():
	game_active = true
	score = 0
	health = 3
	answers_collected = 0

	_load_preset_map()
	_draw_maze()
	_place_answers()
	_setup_player()
	_update_ui()

func _load_preset_map():
	var map_data: Array = PresetMaps.get_map()
	var parsed = PresetMaps.parse_map(map_data)

	maze = parsed.maze
	start_pos = parsed.start
	correct_spots = parsed.correct_spots
	wrong_spots = parsed.wrong_spots
	maze_width = parsed.width
	maze_height = parsed.height

	# Debug output
	print("Loaded maze: ", maze_width, "x", maze_height)
	print("Start position: ", start_pos)
	print("Correct answer spots: ", correct_spots)
	print("Wrong answer spots: ", wrong_spots)

# ============ MAZE LOADING (Preset Maps) ============
# Maze generation is now handled by PresetMaps class
# See _load_preset_map() for map loading logic

# ============ DRAWING ============

func _draw_maze():
	# Clear existing maze visuals (but keep the Player!)
	for child in $MazeLayer.get_children():
		if child.name != "Player":
			child.queue_free()

	for y in range(maze_height):
		for x in range(maze_width):
			var cell_rect = ColorRect.new()
			cell_rect.size = Vector2(CELL_SIZE, CELL_SIZE)
			cell_rect.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)

			if maze[y][x] == Cell.WALL:
				cell_rect.color = WALL_COLOR
			else:
				cell_rect.color = FLOOR_COLOR

			$MazeLayer.add_child(cell_rect)

	# Highlight player start position from map data
	var start_highlight = ColorRect.new()
	start_highlight.size = Vector2(CELL_SIZE, CELL_SIZE)
	start_highlight.position = Vector2(start_pos.x * CELL_SIZE, start_pos.y * CELL_SIZE)
	start_highlight.color = PLAYER_START_COLOR
	$MazeLayer.add_child(start_highlight)

# ============ PATHFINDING (BFS) ============

func _find_path(from_pos: Vector2i, to_pos: Vector2i) -> Array:
	# BFS to find shortest path between two floor positions
	var queue: Array = [[from_pos]]
	var visited: Dictionary = {from_pos: true}

	var directions = [
		Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)
	]

	while queue.size() > 0:
		var path = queue.pop_front()
		var current = path[-1]

		if current == to_pos:
			return path

		for dir in directions:
			var next = current + dir
			if next.x >= 0 and next.x < maze_width and next.y >= 0 and next.y < maze_height:
				if maze[next.y][next.x] == Cell.FLOOR and not visited.has(next):
					visited[next] = true
					var new_path = path.duplicate()
					new_path.append(next)
					queue.append(new_path)

	return []  # No path found

func _get_reachable_positions(from_pos: Vector2i, exclude: Array = []) -> Array:
	# Get all floor positions reachable from a starting point
	var reachable: Array = []
	var queue: Array = [from_pos]
	var visited: Dictionary = {from_pos: true}

	var directions = [
		Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)
	]

	while queue.size() > 0:
		var current = queue.pop_front()

		if current != from_pos and not exclude.has(current):
			reachable.append(current)

		for dir in directions:
			var next = current + dir
			if next.x >= 0 and next.x < maze_width and next.y >= 0 and next.y < maze_height:
				if maze[next.y][next.x] == Cell.FLOOR and not visited.has(next):
					visited[next] = true
					queue.append(next)

	return reachable

# ============ ANSWER PLACEMENT ============

func _place_answers():
	# Clear existing collectibles
	for child in $CollectibleLayer.get_children():
		child.queue_free()

	# Separate options into correct and wrong answers
	var correct_options = []
	var wrong_options = []

	for option in question.options:
		if option.correct:
			correct_options.append(option)
		else:
			wrong_options.append(option)

	# Shuffle the spots for randomization
	var shuffled_correct_spots = correct_spots.duplicate()
	shuffled_correct_spots.shuffle()

	var shuffled_wrong_spots = wrong_spots.duplicate()
	shuffled_wrong_spots.shuffle()

	# Place 2 correct answers randomly in the 2 correct spots
	for i in range(min(correct_options.size(), shuffled_correct_spots.size())):
		var pos = shuffled_correct_spots[i]
		var option = correct_options[i]
		_spawn_collectible(pos, option.letter, i, true)
		print("DEBUG: Placed correct answer '", option.letter, "' (", option.text, ") at ", pos)

	# Place wrong answers randomly in the wrong spots
	var num_wrong_to_place = min(wrong_options.size(), shuffled_wrong_spots.size())
	for i in range(num_wrong_to_place):
		var pos = shuffled_wrong_spots[i]
		var option = wrong_options[i]
		_spawn_collectible(pos, option.letter, -1, false)
		print("DEBUG: Placed wrong answer '", option.letter, "' (", option.text, ") at ", pos)

# Get all floor positions sorted by distance from start (BFS)
func _get_positions_by_distance_from_start() -> Array:
	var result: Array = []
	var queue: Array = [[start_pos, 0]]  # [position, distance]
	var visited: Dictionary = {start_pos: true}

	var directions = [
		Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)
	]

	while queue.size() > 0:
		var current_data = queue.pop_front()
		var current = current_data[0]
		var distance = current_data[1]

		result.append({"pos": current, "distance": distance})

		for dir in directions:
			var next = current + dir
			if next.x >= 0 and next.x < maze_width and next.y >= 0 and next.y < maze_height:
				if maze[next.y][next.x] == Cell.FLOOR and not visited.has(next):
					visited[next] = true
					queue.append([next, distance + 1])

	return result

func _spawn_collectible(
		grid_pos: Vector2i, answer_text: String, q_index: int, is_correct: bool
	):
	var collectible = collectible_scene.instantiate()
	var pos_x = grid_pos.x * CELL_SIZE + CELL_SIZE / 2
	var pos_y = grid_pos.y * CELL_SIZE + CELL_SIZE / 2
	collectible.position = Vector2(pos_x, pos_y)
	collectible.z_index = 5  # Render on top of maze tiles
	collectible.setup(answer_text, q_index, is_correct)
	collectible.collected.connect(_on_answer_collected)
	$CollectibleLayer.add_child(collectible)

# ============ PLAYER ============

func _setup_player():
	var player = $MazeLayer/Player
	# Use start position from preset map
	player.position = Vector2(
		start_pos.x * CELL_SIZE + CELL_SIZE / 2,
		start_pos.y * CELL_SIZE + CELL_SIZE / 2
	)
	player.cell_size = CELL_SIZE
	player.maze_width = maze_width
	player.maze_height = maze_height
	player.z_index = 10  # Render on top of maze tiles
	player.set_maze(maze)
	var cols = maze[0].size() if maze.size() > 0 else 0
	print("DEBUG: Player maze set, size: ", maze.size(), " x ", cols)

# ============ GAME LOGIC ============

func _on_answer_collected(collectible: Node, answer_text: String, _question_index: int, is_correct: bool):
	if not game_active:
		return

	if is_correct:
		# Correct answer collected!
		collectible.confirm_collect()
		score += 100
		answers_collected += 1
		_flash_screen(Color(0.2, 0.8, 0.2, 0.3))
		_show_feedback("Correct! '" + answer_text + "'", Color(0.2, 0.8, 0.2))

		# Count how many correct answers exist
		var total_correct = 0
		for option in question.options:
			if option.correct:
				total_correct += 1

		# Check if all correct answers are collected
		if answers_collected >= total_correct:
			_end_game(true)
	else:
		# Wrong answer - remove it as penalty
		collectible.reject_collect()
		health -= 1
		_flash_screen(Color(0.8, 0.2, 0.2, 0.4))
		_show_feedback("Wrong! '" + answer_text + "'", Color(0.8, 0.2, 0.2))
		_check_game_over()

	_update_ui()

func _check_game_over():
	if health <= 0:
		_end_game(false)

func _end_game(success: bool):
	game_active = false
	$MazeLayer/Player.set_physics_process(false)

	var result_text = "Victory!" if success else "Game Over"
	$UILayer/ResultPanel.show()
	$UILayer/ResultPanel/ResultLabel.text = result_text

	# Emit signal after delay, then fade out
	await get_tree().create_timer(1.5).timeout
	emit_signal("game_finished", success, score)
	# Wait a frame to ensure signal is processed before cleanup
	await get_tree().process_frame
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.2)
	fade_tween.tween_callback(get_parent().queue_free)

# ============ UI ============

func _update_ui():
	# Update health display
	var hearts = ""
	for i in range(health):
		hearts += "♥"
	for i in range(3 - health):
		hearts += "♡"
	$UILayer/HealthLabel.text = hearts

	# Update score
	$UILayer/ScoreLabel.text = "Score: " + str(score)

	# Update question queue
	_update_question_queue()

func _update_question_queue():
	var queue_text = "Question:\n" + question.text + "\n\n"

	# List all options with letters
	for option in question.options:
		queue_text += option.letter + ". " + option.text + "\n"

	# Count total correct answers dynamically
	var total_correct = 0
	for option in question.options:
		if option.correct:
			total_correct += 1

	queue_text += "\nCollected: " + str(answers_collected) + "/" + str(total_correct)

	$UILayer/QuestionQueue.text = queue_text

func _show_feedback(text: String, color: Color):
	var feedback = $UILayer/FeedbackLabel
	feedback.text = text
	feedback.modulate = color
	feedback.show()

	var tween = create_tween()
	tween.tween_property(feedback, "modulate:a", 0.0, 1.0)
	tween.tween_callback(feedback.hide)

func _flash_screen(color: Color):
	$UILayer/FlashRect.color = color
	$UILayer/FlashRect.show()

	var tween = create_tween()
	tween.tween_property($UILayer/FlashRect, "modulate:a", 0.0, 0.3)
	tween.tween_callback($UILayer/FlashRect.hide)
	tween.tween_callback(func(): $UILayer/FlashRect.modulate.a = 1.0)
