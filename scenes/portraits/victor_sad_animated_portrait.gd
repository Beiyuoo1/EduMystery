@tool
extends DialogicPortrait

## Animated portrait for Victor (Sad expression) with talking animation

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_talking: bool = false
var unhighlighted_color := Color.DARK_GRAY
var _prev_z_index := 0

func _ready() -> void:
	if animated_sprite:
		animated_sprite.play("idle")
		animated_sprite.centered = false

		var sprite_frames = animated_sprite.sprite_frames
		if sprite_frames:
			var texture = sprite_frames.get_frame_texture("idle", 0)
			if texture:
				var size = texture.get_size()
				animated_sprite.position = Vector2(-size.x / 2, -size.y)

		if not Engine.is_editor_hint():
			animated_sprite.modulate = unhighlighted_color

	if not Engine.is_editor_hint():
		Dialogic.Text.text_started.connect(_on_text_started)
		Dialogic.Text.text_finished.connect(_on_text_finished)
		Dialogic.Text.speaker_updated.connect(_on_speaker_updated)
		_check_if_speaking()


func _on_text_started(_text_info: Dictionary) -> void:
	_check_if_speaking()

func _on_text_finished(_text_info: Dictionary) -> void:
	stop_talking()

func _on_speaker_updated(_character: DialogicCharacter) -> void:
	_check_if_speaking()

func _check_if_speaking() -> void:
	if character:
		var current_speaker = Dialogic.Text.get_current_speaker()
		if current_speaker and current_speaker.display_name == "Victor":
			if animated_sprite:
				animated_sprite.modulate = Color.WHITE
			start_talking()
		else:
			if animated_sprite:
				animated_sprite.modulate = unhighlighted_color
			stop_talking()

func start_talking() -> void:
	if animated_sprite and not is_talking:
		is_talking = true
		animated_sprite.play("talking")

func stop_talking() -> void:
	if animated_sprite and is_talking:
		is_talking = false
		animated_sprite.play("idle")


#region DIALOGIC PORTRAIT INTERFACE

func _update_portrait(passed_character: DialogicCharacter, passed_portrait: String) -> void:
	apply_character_and_portrait(passed_character, passed_portrait)
	if animated_sprite:
		animated_sprite.play("idle")
		is_talking = false

func _get_covered_rect() -> Rect2:
	if animated_sprite:
		var sprite_frames = animated_sprite.sprite_frames
		if sprite_frames:
			var texture = sprite_frames.get_frame_texture(animated_sprite.animation, animated_sprite.frame)
			if texture:
				return Rect2(animated_sprite.position, texture.get_size())
	return Rect2()

func _should_do_portrait_update(_character: DialogicCharacter, _portrait: String) -> bool:
	return true

func _set_mirror(mirror: bool) -> void:
	if animated_sprite:
		animated_sprite.flip_h = mirror

func _highlight() -> void:
	if animated_sprite:
		create_tween().tween_property(animated_sprite, 'modulate', Color.WHITE, 0.15)
	_prev_z_index = DialogicUtil.autoload().Portraits.get_character_info(character).get('z_index', 0)
	DialogicUtil.autoload().Portraits.change_character_z_index(character, 99)

func _unhighlight() -> void:
	if animated_sprite:
		create_tween().tween_property(animated_sprite, 'modulate', unhighlighted_color, 0.15)
	DialogicUtil.autoload().Portraits.change_character_z_index(character, _prev_z_index)

#endregion
