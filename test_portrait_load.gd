extends Node

func _ready():
	print("Testing portrait scene loading...")
	
	# Try to load Conrad's animated portrait
	var conrad_scene = load("res://scenes/portraits/conrad_animated_portrait.tscn")
	if conrad_scene:
		print("✓ Conrad animated portrait scene loaded successfully")
		var conrad_instance = conrad_scene.instantiate()
		if conrad_instance:
			print("✓ Conrad portrait instantiated successfully")
			print("  Script attached:", conrad_instance.get_script())
			conrad_instance.queue_free()
	else:
		print("✗ Failed to load Conrad animated portrait scene")
	
	# Try to load Mark's animated portrait
	var mark_scene = load("res://scenes/portraits/mark_animated_portrait.tscn")
	if mark_scene:
		print("✓ Mark animated portrait scene loaded successfully")
		var mark_instance = mark_scene.instantiate()
		if mark_instance:
			print("✓ Mark portrait instantiated successfully")
			print("  Script attached:", mark_instance.get_script())
			mark_instance.queue_free()
	else:
		print("✗ Failed to load Mark animated portrait scene")
	
	print("Test complete")
	get_tree().quit()
