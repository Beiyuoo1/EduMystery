extends ColorRect

var word_data = "" 
var original_parent = null
var click_offset = Vector2.ZERO # Added for "jigsaw" movement

func _ready():
	original_parent = get_parent()

# Implements the drag action and sets up the visual preview
func _get_drag_data(at_position):
	# Store the offset relative to the tile's top-left corner
	click_offset = at_position

	# --- Create the Visual Representation (The Jigsaw Piece) ---
	# Create a wrapper Control for the transform
	var wrapper = Control.new()

	# Create the actual tile preview
	var drag_preview = ColorRect.new()
	drag_preview.size = size # Corrected: use size instead of rect_size
	drag_preview.color = color * Color(1.2, 1.2, 1.2)

	# Reparent the label and fix its layout on the preview tile
	var label_copy = get_node("Label").duplicate()
	drag_preview.add_child(label_copy)

	# Corrected: Renamed function in Godot 4
	label_copy.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Add drag preview to wrapper
	wrapper.add_child(drag_preview)

	# Apply transforms to the wrapper instead of drag_preview directly
	wrapper.scale = Vector2(1.1, 1.1)
	wrapper.rotation_degrees = 2

	set_drag_preview(wrapper)

	# CRITICAL: Adjust the wrapper position by the offset for "jigsaw" feel
	wrapper.position -= click_offset * wrapper.scale

	# Return the word data
	return word_data
