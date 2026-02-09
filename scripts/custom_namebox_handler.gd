extends Node

## Custom script to handle character-specific nameboxes
## This script changes the namebox style based on the current speaker

# Character name to namebox style mapping
const NAMEBOX_STYLES = {
	"Celestine": "res://assets/VisualNovelDialogueGUI_PNG/namebox_pink_style.tres",
	"Conrad": "res://assets/VisualNovelDialogueGUI_PNG/namebox_yellow_style.tres",
	"Mark": "res://assets/VisualNovelDialogueGUI_PNG/namebox_blue_style.tres",
	"Alex": "res://assets/VisualNovelDialogueGUI_PNG/namebox_2_purple_style.tres",
	"Diwata Laya": "res://assets/VisualNovelDialogueGUI_PNG/namebox_2_blue_style.tres",
	"Greg": "res://assets/VisualNovelDialogueGUI_PNG/namebox_2_blue_style.tres",
	"Janitor Fred": "res://assets/VisualNovelDialogueGUI_PNG/namebox_2_green_style.tres",
	"Mia": "res://assets/VisualNovelDialogueGUI_PNG/namebox_purple_style.tres",
	"Ms. Reyes": "res://assets/VisualNovelDialogueGUI_PNG/namebox_green_style.tres",
	"Ms. Santos": "res://assets/VisualNovelDialogueGUI_PNG/namebox_orange_style.tres",
	"???": "res://assets/VisualNovelDialogueGUI_PNG/namebox_red_style.tres",
	"Principal Alan": "res://assets/VisualNovelDialogueGUI_PNG/namebox_green_style.tres",
	"Principal": "res://assets/VisualNovelDialogueGUI_PNG/namebox_green_style.tres",
	"Ria": "res://assets/VisualNovelDialogueGUI_PNG/namebox_2_pink_style.tres",
	"Ryan": "res://assets/VisualNovelDialogueGUI_PNG/namebox_blue_style.tres",
	"Alice": "res://assets/VisualNovelDialogueGUI_PNG/namebox_blue_style.tres",
	"Ben": "res://assets/VisualNovelDialogueGUI_PNG/namebox_2_green_style.tres",
	"Victor": "res://assets/VisualNovelDialogueGUI_PNG/namebox_orange_style.tres",
}

func _ready():
	# Connect to speaker updated signal
	if Dialogic.Text:
		Dialogic.Text.speaker_updated.connect(_on_speaker_updated)
		print("CustomNameboxHandler: Connected to speaker_updated signal")

func _on_speaker_updated(character: DialogicCharacter):
	# Find the namebox panel first
	var namebox_panel = _find_namebox_panel()
	if not namebox_panel:
		print("CustomNameboxHandler: Namebox panel not found yet")
		return

	# Remove any self_modulate that might be making it dark
	namebox_panel.self_modulate = Color(1, 1, 1, 1)

	if not character:
		return

	var character_name = character.display_name
	print("CustomNameboxHandler: Speaker updated to: ", character_name)

	# Get the appropriate namebox style for this character
	if NAMEBOX_STYLES.has(character_name):
		var style_path = NAMEBOX_STYLES[character_name]
		var style = load(style_path) as StyleBox

		if style:
			namebox_panel.add_theme_stylebox_override("panel", style)
			print("CustomNameboxHandler: Applied namebox style for ", character_name)
		else:
			push_error("CustomNameboxHandler: Failed to load style: ", style_path)
	else:
		# Use default yellow namebox if character not in list
		var default_style = load("res://assets/VisualNovelDialogueGUI_PNG/namebox_yellow_style.tres") as StyleBox
		if default_style:
			namebox_panel.add_theme_stylebox_override("panel", default_style)
			print("CustomNameboxHandler: Applied default namebox for ", character_name)

func _find_namebox_panel() -> PanelContainer:
	# Try to find using unique name first (faster)
	var root = get_tree().root
	var namebox = _find_unique_node(root, "NameLabelPanel")

	if namebox and namebox is PanelContainer:
		return namebox

	return null

func _find_unique_node(node: Node, unique_name: String) -> Node:
	# Check if this node matches
	if node.name == unique_name:
		return node

	# Recursively search children
	for child in node.get_children():
		var result = _find_unique_node(child, unique_name)
		if result:
			return result

	return null
