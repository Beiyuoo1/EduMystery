@tool
extends DialogicPortrait

## Animated portrait for Victor with talking animation
## Automatically plays "talking" animation during dialogue
## Returns to "idle" (Victor.png) when dialogue stops

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_talking: bool = false
var unhighlighted_color := Color.DARK_GRAY
var _prev_z_index := 0

func _ready() -> void:
	# Start with idle animation
	if animated_sprite:
		animated_sprite.play("idle")
		animated_sprite.centered = false

		# Position sprite so pivot is at bottom center
		# Get texture size and offset accordingly
		var sprite_frames = animated_sprite.sprite_frames
		if sprite_frames:
			var texture = sprite_frames.get_frame_texture("idle", 0)
			if texture:
				var size = texture.get_size()
				# Position: x = -width/2 (center horizontally), y = -height (bottom aligned)
				animated_sprite.position = Vector2(-size.x / 2, -size.y)

		# Set initial modulate for unhighlighted state on the sprite
		if not Engine.is_editor_hint():
			animated_sprite.modulate = unhighlighted_color

	# Connect to Dialogic signals if not in editor
	if not Engine.is_editor_hint():
		Dialogic.Text.text_started.connect(_on_text_started)
		Dialogic.Text.text_finished.connect(_on_text_finished)
		Dialogic.Text.speaker_updated.connect(_on_speaker_updated)
		print("Victor portrait: Signals connected")
		# Check immediately in case Victor is already speaking when portrait joins
		_check_if_speaking()


## Called when text starts showing (character is speaking)
func _on_text_started(_text_info: Dictionary) -> void:
	print("Victor portrait: text_started signal received")
	_check_if_speaking()


## Called when text finishes
func _on_text_finished(_text_info: Dictionary) -> void:
	print("Victor portrait: text_finished signal received")
	stop_talking()


## Called when the speaker changes
func _on_speaker_updated(_character: DialogicCharacter) -> void:
	print("Victor portrait: speaker_updated signal received, character: ", _character)
	_check_if_speaking()


## Check if this portrait's character (Victor) is currently speaking
func _check_if_speaking() -> void:
	print("Victor portrait: Checking if speaking. character = ", character)
	if character:
		print("Victor portrait: character.display_name = ", character.display_name)
		var current_speaker = Dialogic.Text.get_current_speaker()
		print("Victor portrait: current_speaker = ", current_speaker)

		if character.display_name == "Victor":
			if current_speaker and current_speaker.display_name == "Victor":
				print("Victor portrait: Victor is speaking!")
				if animated_sprite:
					animated_sprite.modulate = Color.WHITE
				start_talking()
			else:
				print("Victor portrait: Victor is NOT speaking")
				if animated_sprite:
					animated_sprite.modulate = unhighlighted_color
				stop_talking()
	else:
		print("Victor portrait: character is null!")


## Start the talking animation
func start_talking() -> void:
	if animated_sprite and not is_talking:
		is_talking = true
		animated_sprite.play("talking")
		print("Victor: Started talking animation")


## Stop talking and return to idle
func stop_talking() -> void:
	if animated_sprite and is_talking:
		is_talking = false
		animated_sprite.play("idle")
		print("Victor: Stopped talking, back to idle")


#region DIALOGIC PORTRAIT INTERFACE

## Dialogic portrait interface: Called when portrait is updated
func _update_portrait(passed_character: DialogicCharacter, passed_portrait: String) -> void:
	apply_character_and_portrait(passed_character, passed_portrait)

	# Start with idle when portrait first appears
	if animated_sprite:
		animated_sprite.play("idle")
		is_talking = false


## Dialogic portrait interface: Required to return portrait size
func _get_covered_rect() -> Rect2:
	if animated_sprite:
		# Get the texture size from current frame
		var sprite_frames = animated_sprite.sprite_frames
		if sprite_frames:
			var current_animation = animated_sprite.animation
			var current_frame = animated_sprite.frame
			var texture = sprite_frames.get_frame_texture(current_animation, current_frame)
			if texture:
				# Return rect with sprite's position and size
				return Rect2(animated_sprite.position, texture.get_size())
	return Rect2()


## Dialogic portrait interface: Should we update this portrait or create a new one
func _should_do_portrait_update(_character: DialogicCharacter, _portrait: String) -> bool:
	return true


## Dialogic portrait interface: Handle mirror
func _set_mirror(mirror: bool) -> void:
	if animated_sprite:
		animated_sprite.flip_h = mirror


## Dialogic portrait interface: Called when this becomes the active speaker
func _highlight() -> void:
	if animated_sprite:
		create_tween().tween_property(animated_sprite, 'modulate', Color.WHITE, 0.15)
	_prev_z_index = DialogicUtil.autoload().Portraits.get_character_info(character).get('z_index', 0)
	DialogicUtil.autoload().Portraits.change_character_z_index(character, 99)


## Dialogic portrait interface: Called when this stops being the active speaker
func _unhighlight() -> void:
	if animated_sprite:
		create_tween().tween_property(animated_sprite, 'modulate', unhighlighted_color, 0.15)
	DialogicUtil.autoload().Portraits.change_character_z_index(character, _prev_z_index)

#endregion
