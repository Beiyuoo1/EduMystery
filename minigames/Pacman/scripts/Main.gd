# Main.gd - Pacman Quiz Minigame with Complex AI
extends Node2D

# Signal for MinigameManager integration
signal game_finished(success: bool, score: int)

# Preload the Enemy script to access its enum
const EnemyScript = preload("res://minigames/Pacman/scripts/Enemy.gd")

# Default question database (can be overridden via configure_puzzle)
var questions = [
	{
		"question": "What is the capital of France?",
		"correct": "Paris",
		"wrong": ["London", "Berlin", "Madrid"]
	},
	{
		"question": "What is 5 + 7?",
		"correct": "12",
		"wrong": ["13", "11", "14"]
	},
	{
		"question": "What color is the sky?",
		"correct": "Blue",
		"wrong": ["Red", "Green", "Yellow"]
	},
	{
		"question": "How many continents are there?",
		"correct": "7",
		"wrong": ["5", "6", "8"]
	}
]

var current_question = 0
var player = null
var answer_objects = []
var enemy_objects = []
var obstacle_objects = []
var power_pellet_objects = []
var score = 0
var lives = 3  # Player starts with 3 lives
var game_over = false
var is_configured = false
var is_respawning = false  # Prevent multiple hits during respawn

# Player tracking
var last_player_position = Vector2.ZERO
var player_direction = Vector2.RIGHT

# Wrong answer penalty system
var base_enemy_speed = 100.0
var penalty_speed_multiplier = 1.0
var penalty_timer = 0.0
const PENALTY_DURATION = 3.0
const PENALTY_SPEED_BOOST = 1.3

# Combo system
var combo_count = 0
var combo_timer = 0.0
const COMBO_WINDOW = 5.0

# Invincibility after correct answer
var invincible = false
var invincibility_timer = 0.0
const INVINCIBILITY_DURATION = 1.0

# Difficulty progression
var difficulty_multiplier = 1.0
const DIFFICULTY_INCREMENT = 0.08

# Screen effects
var screen_flash_timer = 0.0

# Ghost references for AI coordination
var blinky = null  # Red ghost - needed for Inky's targeting

# Global teleport system - only one ghost can teleport at a time
var global_teleport_cooldown = 0.0
const GLOBAL_TELEPORT_COOLDOWN = 2.5  # Time between any ghost teleporting

func _ready():
	# Don't start game yet - wait for configure_puzzle()
	pass

func configure_puzzle(config: Dictionary) -> void:
	if config.has("questions"):
		questions = config.questions
	is_configured = true
	start_game()

func start_game():
	game_over = false
	current_question = 0
	score = 0
	lives = 3  # Reset lives to 3
	is_respawning = false
	combo_count = 0
	combo_timer = 0.0
	difficulty_multiplier = 1.0
	penalty_speed_multiplier = 1.0
	invincible = false
	last_player_position = Vector2.ZERO
	player_direction = Vector2.RIGHT

	spawn_obstacles()
	spawn_power_pellets()
	spawn_player()
	spawn_enemies()
	load_question()
	_update_combo_display()
	_update_lives_display()

func spawn_player():
	if player != null and is_instance_valid(player):
		player.queue_free()

	var player_scene = load("res://minigames/Pacman/scenes/Player.tscn")
	player = player_scene.instantiate()
	var screen_size = get_viewport_rect().size
	player.position = screen_size / 2
	$GameLayer.add_child(player)
	player.connect("hit_answer", Callable(self, "_on_answer_hit"))
	player.connect("hit_enemy", Callable(self, "_on_enemy_hit"))

func spawn_obstacles():
	for obstacle in obstacle_objects:
		if is_instance_valid(obstacle):
			obstacle.queue_free()
	obstacle_objects.clear()

	var screen_size = get_viewport_rect().size
	var obstacle_scene = load("res://minigames/Pacman/scenes/Obstacle.tscn")

	# More complex maze layout inspired by classic Pac-Man
	var wall_configs = [
		# Border walls (with gaps for movement)
		{"pos": Vector2(screen_size.x * 0.25, 40), "size": Vector2(300, 16), "rot": 0},
		{"pos": Vector2(screen_size.x * 0.75, 40), "size": Vector2(300, 16), "rot": 0},
		{"pos": Vector2(screen_size.x * 0.25, screen_size.y - 40), "size": Vector2(300, 16), "rot": 0},
		{"pos": Vector2(screen_size.x * 0.75, screen_size.y - 40), "size": Vector2(300, 16), "rot": 0},

		# Vertical border segments
		{"pos": Vector2(40, screen_size.y * 0.3), "size": Vector2(16, 150), "rot": 0},
		{"pos": Vector2(40, screen_size.y * 0.7), "size": Vector2(16, 150), "rot": 0},
		{"pos": Vector2(screen_size.x - 40, screen_size.y * 0.3), "size": Vector2(16, 150), "rot": 0},
		{"pos": Vector2(screen_size.x - 40, screen_size.y * 0.7), "size": Vector2(16, 150), "rot": 0},

		# Inner maze - T shapes
		{"pos": Vector2(screen_size.x * 0.2, screen_size.y * 0.25), "size": Vector2(120, 16), "rot": 0},
		{"pos": Vector2(screen_size.x * 0.2, screen_size.y * 0.32), "size": Vector2(16, 80), "rot": 0},

		{"pos": Vector2(screen_size.x * 0.8, screen_size.y * 0.25), "size": Vector2(120, 16), "rot": 0},
		{"pos": Vector2(screen_size.x * 0.8, screen_size.y * 0.32), "size": Vector2(16, 80), "rot": 0},

		{"pos": Vector2(screen_size.x * 0.2, screen_size.y * 0.75), "size": Vector2(120, 16), "rot": 0},
		{"pos": Vector2(screen_size.x * 0.2, screen_size.y * 0.68), "size": Vector2(16, 80), "rot": 0},

		{"pos": Vector2(screen_size.x * 0.8, screen_size.y * 0.75), "size": Vector2(120, 16), "rot": 0},
		{"pos": Vector2(screen_size.x * 0.8, screen_size.y * 0.68), "size": Vector2(16, 80), "rot": 0},

		# Center cross structure
		{"pos": Vector2(screen_size.x * 0.5, screen_size.y * 0.35), "size": Vector2(180, 16), "rot": 0},
		{"pos": Vector2(screen_size.x * 0.5, screen_size.y * 0.65), "size": Vector2(180, 16), "rot": 0},
		{"pos": Vector2(screen_size.x * 0.38, screen_size.y * 0.5), "size": Vector2(16, 180), "rot": 0},
		{"pos": Vector2(screen_size.x * 0.62, screen_size.y * 0.5), "size": Vector2(16, 180), "rot": 0},

		# L-shaped corners
		{"pos": Vector2(screen_size.x * 0.15, screen_size.y * 0.5), "size": Vector2(80, 16), "rot": 0},
		{"pos": Vector2(screen_size.x * 0.11, screen_size.y * 0.43), "size": Vector2(16, 80), "rot": 0},

		{"pos": Vector2(screen_size.x * 0.85, screen_size.y * 0.5), "size": Vector2(80, 16), "rot": 0},
		{"pos": Vector2(screen_size.x * 0.89, screen_size.y * 0.43), "size": Vector2(16, 80), "rot": 0},

		# Additional complexity - small blocks
		{"pos": Vector2(screen_size.x * 0.35, screen_size.y * 0.2), "size": Vector2(60, 16), "rot": 0},
		{"pos": Vector2(screen_size.x * 0.65, screen_size.y * 0.2), "size": Vector2(60, 16), "rot": 0},
		{"pos": Vector2(screen_size.x * 0.35, screen_size.y * 0.8), "size": Vector2(60, 16), "rot": 0},
		{"pos": Vector2(screen_size.x * 0.65, screen_size.y * 0.8), "size": Vector2(60, 16), "rot": 0},

		# Diagonal elements for variety
		{"pos": Vector2(screen_size.x * 0.12, screen_size.y * 0.15), "size": Vector2(70, 16), "rot": 45},
		{"pos": Vector2(screen_size.x * 0.88, screen_size.y * 0.15), "size": Vector2(70, 16), "rot": -45},
		{"pos": Vector2(screen_size.x * 0.12, screen_size.y * 0.85), "size": Vector2(70, 16), "rot": -45},
		{"pos": Vector2(screen_size.x * 0.88, screen_size.y * 0.85), "size": Vector2(70, 16), "rot": 45},
	]

	for config in wall_configs:
		var obstacle = obstacle_scene.instantiate()
		obstacle.position = config.pos

		var collision_shape = obstacle.get_node("CollisionShape2D")
		var shape = RectangleShape2D.new()
		shape.size = config.size
		collision_shape.shape = shape

		var color_rect = obstacle.get_node("ColorRect")
		color_rect.size = config.size
		color_rect.position = -config.size / 2
		# Give walls a nice blue color like classic Pac-Man
		color_rect.color = Color(0.2, 0.3, 0.8)

		obstacle.rotation_degrees = config.rot
		$GameLayer.add_child(obstacle)
		obstacle_objects.append(obstacle)

func spawn_power_pellets():
	for pellet in power_pellet_objects:
		if is_instance_valid(pellet):
			# Stop tween before freeing
			if pellet.has_meta("pulse_tween"):
				var tween = pellet.get_meta("pulse_tween")
				if tween and tween.is_valid():
					tween.kill()
			pellet.queue_free()
	power_pellet_objects.clear()

	var screen_size = get_viewport_rect().size

	# Power pellets in the four corners
	var pellet_positions = [
		Vector2(80, 80),
		Vector2(screen_size.x - 80, 80),
		Vector2(80, screen_size.y - 80),
		Vector2(screen_size.x - 80, screen_size.y - 80)
	]

	for pos in pellet_positions:
		var pellet = _create_power_pellet()
		pellet.position = pos
		$GameLayer.add_child(pellet)
		power_pellet_objects.append(pellet)

func _create_power_pellet() -> Area2D:
	var pellet = Area2D.new()
	pellet.add_to_group("power_pellet")

	# Collision shape
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 12
	collision.shape = shape
	pellet.add_child(collision)

	# Visual - glowing orb
	var visual = Polygon2D.new()
	visual.color = Color(1.0, 0.8, 0.2)
	# Create circle points
	var points = PackedVector2Array()
	for i in range(12):
		var angle = i * TAU / 12
		points.append(Vector2(cos(angle), sin(angle)) * 10)
	visual.polygon = points
	pellet.add_child(visual)

	# Glow effect
	var glow = Polygon2D.new()
	glow.color = Color(1.0, 0.9, 0.3, 0.4)
	glow.z_index = -1
	var glow_points = PackedVector2Array()
	for i in range(12):
		var angle = i * TAU / 12
		glow_points.append(Vector2(cos(angle), sin(angle)) * 16)
	glow.polygon = glow_points
	pellet.add_child(glow)

	# Pulsing animation - use a high loop count instead of infinite to avoid detection issues
	var tween = create_tween()
	tween.set_loops(999)  # Very high number, effectively infinite for gameplay
	tween.tween_property(visual, "scale", Vector2(1.2, 1.2), 0.5)
	tween.tween_property(visual, "scale", Vector2(1.0, 1.0), 0.5)
	# Store tween reference to stop it when pellet is freed
	pellet.set_meta("pulse_tween", tween)

	pellet.area_entered.connect(_on_power_pellet_collected.bind(pellet))

	return pellet

func _on_power_pellet_collected(area: Area2D, pellet: Area2D):
	if area.get_parent() == player:
		# Trigger frightened mode on all enemies
		for enemy in enemy_objects:
			if is_instance_valid(enemy):
				enemy.start_frightened_mode(6.0)

		# Visual feedback
		_flash_screen(Color(0.2, 0.2, 1.0, 0.4))
		_show_floating_text("Power Up!", Color(0.3, 0.5, 1.0))

		# Stop the pulsing tween before removing
		if pellet.has_meta("pulse_tween"):
			var tween = pellet.get_meta("pulse_tween")
			if tween and tween.is_valid():
				tween.kill()

		# Remove pellet
		power_pellet_objects.erase(pellet)
		pellet.queue_free()

func spawn_enemies():
	for enemy in enemy_objects:
		if is_instance_valid(enemy):
			enemy.queue_free()
	enemy_objects.clear()
	blinky = null

	var screen_size = get_viewport_rect().size

	# Four ghosts with different personalities and starting positions
	var ghost_configs = [
		{"type": EnemyScript.GhostType.BLINKY, "pos": Vector2(screen_size.x - 100, 100)},
		{"type": EnemyScript.GhostType.PINKY, "pos": Vector2(100, 100)},
		{"type": EnemyScript.GhostType.INKY, "pos": Vector2(screen_size.x - 100, screen_size.y - 100)},
		{"type": EnemyScript.GhostType.CLYDE, "pos": Vector2(100, screen_size.y - 100)}
	]

	var enemy_scene = load("res://minigames/Pacman/scenes/Enemy.tscn")

	for config in ghost_configs:
		var enemy = enemy_scene.instantiate()
		enemy.position = config.pos
		enemy.ghost_type = config.type

		$GameLayer.add_child(enemy)

		# Initialize after adding to tree and setting ghost_type
		enemy.initialize()

		enemy_objects.append(enemy)

		# Keep reference to Blinky for Inky's AI
		if config.type == EnemyScript.GhostType.BLINKY:
			blinky = enemy

func load_question():
	for obj in answer_objects:
		if is_instance_valid(obj):
			obj.queue_free()
	answer_objects.clear()

	if current_question >= questions.size():
		show_victory()
		return

	var q = questions[current_question]
	$UI/QuestionLabel.text = q.question
	$UI/ScoreLabel.text = "Score: " + str(score)
	_update_lives_display()

	var all_answers = q.wrong.duplicate()
	all_answers.append(q.correct)
	all_answers.shuffle()

	var screen_size = get_viewport_rect().size
	# Position answers in more strategic locations
	var positions = [
		Vector2(screen_size.x * 0.15, screen_size.y * 0.35),
		Vector2(screen_size.x * 0.85, screen_size.y * 0.35),
		Vector2(screen_size.x * 0.15, screen_size.y * 0.65),
		Vector2(screen_size.x * 0.85, screen_size.y * 0.65)
	]

	var answer_scene = load("res://minigames/Pacman/scenes/AnswerObject.tscn")
	for i in range(all_answers.size()):
		var answer_obj = answer_scene.instantiate()
		answer_obj.position = positions[i]
		answer_obj.answer_text = all_answers[i]
		answer_obj.is_correct = (all_answers[i] == q.correct)
		$GameLayer.add_child(answer_obj)
		answer_objects.append(answer_obj)

func _on_answer_hit(answer_text, is_correct):
	if is_correct:
		_handle_correct_answer()
	else:
		_handle_wrong_answer(answer_text)

func _handle_correct_answer():
	# Combo system
	if combo_timer > 0:
		combo_count += 1
	else:
		combo_count = 1
	combo_timer = COMBO_WINDOW

	# Score with combo bonus
	var combo_bonus = combo_count - 1
	score += 1 + combo_bonus

	# Brief invincibility
	invincible = true
	invincibility_timer = INVINCIBILITY_DURATION
	if is_instance_valid(player):
		player.modulate = Color(1.5, 1.5, 0.5)

	# Visual feedback
	_flash_screen(Color(0, 1, 0, 0.3))
	_show_floating_text("Correct!", Color.GREEN)
	if combo_count > 1:
		_show_floating_text("Combo x" + str(combo_count) + "!", Color.WHITE, Vector2(0, 40))

	# Increase difficulty
	difficulty_multiplier += DIFFICULTY_INCREMENT

	current_question += 1
	_update_combo_display()

	await get_tree().create_timer(0.5).timeout
	load_question()

func _handle_wrong_answer(answer_text):
	# Reset combo
	combo_count = 0
	combo_timer = 0.0
	_update_combo_display()

	# Apply time penalty
	penalty_speed_multiplier = PENALTY_SPEED_BOOST
	penalty_timer = PENALTY_DURATION

	# Visual feedback
	_flash_screen(Color(1, 0, 0, 0.4))
	_show_floating_text("Incorrect!", Color.RED)
	_screen_shake()

	# Remove the wrong answer
	for obj in answer_objects:
		if is_instance_valid(obj) and obj.answer_text == answer_text:
			var tween = create_tween()
			tween.tween_property(obj, "modulate:a", 0.0, 0.3)
			tween.tween_callback(obj.queue_free)
			answer_objects.erase(obj)
			break

func _on_enemy_hit():
	# Check if enemy is frightened - if so, eat the ghost instead
	for enemy in enemy_objects:
		if is_instance_valid(enemy) and is_instance_valid(player):
			if enemy.position.distance_to(player.position) < 50:
				if enemy.is_frightened():
					# Eat the ghost!
					enemy.get_eaten()
					score += 2
					$UI/ScoreLabel.text = "Score: " + str(score)
					_show_floating_text("+2", Color(0.3, 0.5, 1.0))
					return

	if invincible or is_respawning:
		return

	# Player got hit - lose a life
	lives -= 1
	_update_lives_display()

	# Visual feedback
	_flash_screen(Color(1, 0, 0, 0.6))
	_show_floating_text("-1 Life", Color.RED)
	_screen_shake()

	if lives <= 0:
		# No more lives - game over
		show_game_over()
	else:
		# Still have lives - respawn at center
		respawn_player()

func respawn_player():
	"""Respawn player at center after losing a life"""
	is_respawning = true

	# Make player invisible briefly
	if is_instance_valid(player):
		player.visible = false

	# Brief pause
	await get_tree().create_timer(0.5).timeout

	# Respawn at center
	if is_instance_valid(player):
		var screen_size = get_viewport_rect().size
		player.position = screen_size / 2
		player.visible = true

		# Give brief invincibility after respawn
		invincible = true
		invincibility_timer = 2.0  # 2 seconds of invincibility
		player.modulate = Color(1.0, 1.0, 1.0, 0.5)  # Semi-transparent during invincibility

		# Show respawn message
		_show_floating_text("Respawned!", Color(0.5, 0.8, 1.0))

	is_respawning = false

func _update_lives_display():
	"""Update the lives counter in the UI"""
	if has_node("UI/LivesLabel"):
		$UI/LivesLabel.text = "Lives: " + str(lives)

func show_game_over():
	game_over = true
	$UI/QuestionLabel.text = "Game Over! Score: " + str(score)

	for obj in answer_objects:
		if is_instance_valid(obj):
			obj.queue_free()
	answer_objects.clear()

	if player != null and is_instance_valid(player):
		player.queue_free()
		player = null

	# Auto-close after delay
	await get_tree().create_timer(2.0).timeout
	game_finished.emit(false, score)
	# Wait a frame to ensure signal is processed before cleanup
	await get_tree().process_frame
	queue_free()

func show_victory():
	game_over = true
	$UI/QuestionLabel.text = "Victory! Score: " + str(score)

	# Auto-close after delay
	await get_tree().create_timer(2.0).timeout
	game_finished.emit(true, score)
	# Wait a frame to ensure signal is processed before cleanup
	await get_tree().process_frame
	queue_free()

func _process(delta):
	_update_timers(delta)
	_update_player_direction()
	_update_enemy_data()
	_update_screen_flash(delta)

	# Game now auto-closes after victory/game over

func _update_player_direction():
	if is_instance_valid(player):
		var movement = player.position - last_player_position
		if movement.length() > 1:
			player_direction = movement.normalized()
		last_player_position = player.position

func _update_enemy_data():
	if not is_instance_valid(player):
		return

	# Get Blinky's position for Inky's AI
	var blinky_pos = Vector2.ZERO
	if is_instance_valid(blinky):
		blinky_pos = blinky.position

	# Update all enemies with current game state
	var current_speed = base_enemy_speed * difficulty_multiplier * penalty_speed_multiplier

	for enemy in enemy_objects:
		if is_instance_valid(enemy):
			enemy.player_position = player.position
			enemy.player_direction = player_direction
			enemy.blinky_position = blinky_pos
			enemy.chase_speed = current_speed
			enemy.scatter_speed = current_speed * 0.8

func _update_timers(delta):
	if penalty_timer > 0:
		penalty_timer -= delta
		if penalty_timer <= 0:
			penalty_speed_multiplier = 1.0

	if combo_timer > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			combo_count = 0
			_update_combo_display()

	if global_teleport_cooldown > 0:
		global_teleport_cooldown -= delta

	if invincibility_timer > 0:
		invincibility_timer -= delta
		if invincibility_timer <= 0:
			invincible = false
			if is_instance_valid(player):
				player.modulate = Color.WHITE

# Called by ghosts to request permission to teleport (one at a time)
func request_ghost_teleport(_ghost) -> bool:
	if global_teleport_cooldown > 0:
		return false

	# Grant permission and set global cooldown
	global_teleport_cooldown = GLOBAL_TELEPORT_COOLDOWN
	return true

func _update_combo_display():
	if has_node("UI/ComboLabel"):
		if combo_count > 1:
			$UI/ComboLabel.text = "Combo: x" + str(combo_count)
			$UI/ComboLabel.visible = true
		else:
			$UI/ComboLabel.visible = false

func _flash_screen(color: Color):
	screen_flash_timer = 0.2
	if has_node("UI/FlashRect"):
		$UI/FlashRect.color = color
		$UI/FlashRect.visible = true

func _update_screen_flash(delta):
	if screen_flash_timer > 0:
		screen_flash_timer -= delta
		if has_node("UI/FlashRect"):
			$UI/FlashRect.color.a = screen_flash_timer * 2
		if screen_flash_timer <= 0 and has_node("UI/FlashRect"):
			$UI/FlashRect.visible = false

func _show_floating_text(text: String, color: Color, offset: Vector2 = Vector2.ZERO):
	if not is_instance_valid(player):
		return

	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 24)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = player.position + Vector2(-50, -60) + offset
	$GameLayer.add_child(label)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 50, 1.0)
	tween.tween_property(label, "modulate:a", 0.0, 1.0)
	tween.set_parallel(false)
	tween.tween_callback(label.queue_free)

func _screen_shake():
	var original_pos = $GameLayer.offset
	var tween = create_tween()
	for i in range(5):
		var shake_offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
		tween.tween_property($GameLayer, "offset", original_pos + shake_offset, 0.05)
	tween.tween_property($GameLayer, "offset", original_pos, 0.05)
