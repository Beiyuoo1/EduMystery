extends ColorRect

var word_data = "" 
var original_parent = null
var click_offset = Vector2.ZERO # Added for "jigsaw" movement

func _ready():
	original_parent = get_parent()

# Implements the drag action and sets up the visual preview
func _get_drag_data(at_position):
	# --- Create the Visual Representation ---
	# In Godot 4, set_drag_preview anchors the preview top-left to the cursor.
	# To offset it, place the actual tile as a child of a transparent root Control,
	# then position the child negatively to shift it relative to the cursor.

	var half = size / 2.0

	# Root control — large enough so the offset child is visible, invisible itself
	var root = Control.new()
	root.size = size * 2.0

	# Actual visible tile
	var drag_preview = ColorRect.new()
	drag_preview.size = size
	drag_preview.color = color * Color(1.2, 1.2, 1.2)
	# Shift so cursor lands at center of tile
	drag_preview.position = -half

	var label_copy = get_node("Label").duplicate()
	drag_preview.add_child(label_copy)
	label_copy.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	root.add_child(drag_preview)
	set_drag_preview(root)

	return word_data
