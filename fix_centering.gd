# Test to see viewport size
extends Control

func _ready():
	var viewport_size = get_viewport_rect().size
	print("Viewport size: ", viewport_size)
	
	# Calculate center position
	var content_width = 1330  # 650 + 30 + 650
	var margin_x = (viewport_size.x - content_width) / 2
	print("Calculated margin X: ", margin_x)
