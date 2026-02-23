extends CanvasLayer

signal review_completed

@onready var title_label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var explanation_label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ExplanationLabel
@onready var concepts_vbox = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ConceptsVBox
@onready var example_panel = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ExamplePanel
@onready var example_label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ExamplePanel/MarginContainer/ExampleLabel
@onready var tip_panel = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TipPanel
@onready var tip_label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TipPanel/MarginContainer/TipLabel
@onready var continue_button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContinueButton
@onready var panel = $CenterContainer/PanelContainer

func _ready():
	continue_button.pressed.connect(_on_continue_pressed)
	panel.modulate.a = 0  # Start invisible for fade-in

func show_review(content: Dictionary):
	# Populate UI
	title_label.text = "Let's Review: " + content.get("title", "This Topic")
	explanation_label.text = content.get("explanation", "Review the material before trying again.")

	# Clear and add concept bullets
	for child in concepts_vbox.get_children():
		child.queue_free()

	for concept in content.get("key_concepts", []):
		var label = Label.new()
		label.text = "• " + concept
		label.add_theme_font_size_override("font_size", 22)
		concepts_vbox.add_child(label)

	# Example and tip (hide if empty)
	var example_text = content.get("example", "")
	if example_text:
		example_label.text = "Example: " + example_text
		example_panel.visible = true
	else:
		example_panel.visible = false

	var tip_text = content.get("tip", "")
	if tip_text:
		tip_label.text = " Tip: " + tip_text
		tip_panel.visible = true
	else:
		tip_panel.visible = false

	# Fade in
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.3)
	await tween.finished

	continue_button.disabled = false

func _on_continue_pressed():
	continue_button.disabled = true

	# Fade out
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, 0.2)
	await tween.finished

	review_completed.emit()
	queue_free()
