extends Control

@onready var title_label = $MainPanel/MarginContainer/VBoxContainer/HeaderContainer/TitleContainer/Title
@onready var clue_image_1 = $MainPanel/MarginContainer/VBoxContainer/CluesContainer/Clue1Container/ClueFrame1/MarginContainer/ClueImage1
@onready var clue_image_2 = $MainPanel/MarginContainer/VBoxContainer/CluesContainer/Clue2Container/ClueFrame2/MarginContainer/ClueImage2
@onready var clue_image_3 = $MainPanel/MarginContainer/VBoxContainer/CluesContainer/Clue3Container/ClueFrame3/MarginContainer/ClueImage3
@onready var clue_label_1 = $MainPanel/MarginContainer/VBoxContainer/CluesContainer/Clue1Container/ClueLabel1
@onready var clue_label_2 = $MainPanel/MarginContainer/VBoxContainer/CluesContainer/Clue2Container/ClueLabel2
@onready var clue_label_3 = $MainPanel/MarginContainer/VBoxContainer/CluesContainer/Clue3Container/ClueLabel3
@onready var next_button = $MainPanel/MarginContainer/VBoxContainer/NextButton

var current_chapter: int = 1
var evidence_list: Array = []
var current_page: int = 0
var items_per_page: int = 3

func _ready():
	update_evidence_display()

func show_evidence_panel():
	visible = true
	current_page = 0
	# Get current chapter from Dialogic
	current_chapter = Dialogic.VAR.current_chapter
	update_evidence_display()

func hide_evidence_panel():
	visible = false

func update_evidence_display():
	# Update title
	title_label.text = "Clues in Chapter " + str(current_chapter)

	# Get all evidence for current chapter
	evidence_list = EvidenceManager.get_evidence_by_chapter(current_chapter)

	# Calculate page range
	var start_index = current_page * items_per_page
	var end_index = min(start_index + items_per_page, evidence_list.size())

	# Update clue images and labels
	var clue_images = [clue_image_1, clue_image_2, clue_image_3]
	var clue_labels = [clue_label_1, clue_label_2, clue_label_3]

	for i in range(items_per_page):
		var evidence_index = start_index + i
		# ClueImage -> MarginContainer -> ClueFrame(PanelContainer) -> Clue1Container(VBoxContainer)
		var slot_container = clue_images[i].get_parent().get_parent().get_parent()

		if evidence_index < evidence_list.size():
			var evidence = evidence_list[evidence_index]
			# Try to load image
			var img_path = evidence.get("image_path", "")
			if img_path != "" and ResourceLoader.exists(img_path):
				clue_images[i].texture = load(img_path)
				clue_images[i].get_parent().get_parent().visible = true  # Show ClueFrame
			else:
				clue_images[i].texture = null
				clue_images[i].get_parent().get_parent().visible = false  # Hide ClueFrame
			clue_labels[i].text = evidence["title"]
			slot_container.visible = true
		else:
			# Hide entire slot container
			slot_container.visible = false

	# Update Next button visibility
	next_button.visible = (end_index < evidence_list.size())

func _on_back_button_pressed():
	if current_page > 0:
		current_page -= 1
		update_evidence_display()
	else:
		hide_evidence_panel()

func _on_next_button_pressed():
	var max_pages = ceili(float(evidence_list.size()) / items_per_page)
	if current_page < max_pages - 1:
		current_page += 1
		update_evidence_display()
