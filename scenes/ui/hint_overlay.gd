extends CanvasLayer

## HintOverlay - Shared hint panel used by all minigames
## Shows guiding hint text in a BGbox_01A panel without revealing the answer.
## Usage:
##   var overlay = preload("res://scenes/ui/hint_overlay.tscn").instantiate()
##   add_child(overlay)
##   overlay.show_hint("Your guiding hint text here.")

signal closed

const BGBOX = preload("res://assets/UI/BGbox_01A.png")

var _label: RichTextLabel
var _panel: NinePatchRect

func _ready() -> void:
	layer = 200  # Above everything

	# Dim background
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.6)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)

	# BGbox_01A nine-patch panel
	_panel = NinePatchRect.new()
	_panel.texture = BGBOX
	_panel.patch_margin_left   = 28
	_panel.patch_margin_top    = 29
	_panel.patch_margin_right  = 28
	_panel.patch_margin_bottom = 27
	_panel.custom_minimum_size = Vector2(700, 0)
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.offset_left  = -350
	_panel.offset_right =  350
	add_child(_panel)

	# Inner VBox
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 20)
	var m = MarginContainer.new()
	m.add_theme_constant_override("margin_left",   36)
	m.add_theme_constant_override("margin_top",    32)
	m.add_theme_constant_override("margin_right",  36)
	m.add_theme_constant_override("margin_bottom", 32)
	_panel.add_child(m)
	m.add_child(vbox)

	# Title row
	var title_row = HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 10)
	vbox.add_child(title_row)

	var icon = Label.new()
	icon.text = "Detective's Hint"
	icon.add_theme_font_size_override("font_size", 28)
	icon.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	icon.add_theme_color_override("font_outline_color", Color(0.2, 0.1, 0.0))
	icon.add_theme_constant_override("outline_size", 3)
	title_row.add_child(icon)

	# Divider
	var sep = HSeparator.new()
	var sep_style = StyleBoxFlat.new()
	sep_style.bg_color = Color(1.0, 0.85, 0.3, 0.4)
	sep_style.content_margin_top = 1
	sep_style.content_margin_bottom = 1
	sep.add_theme_stylebox_override("separator", sep_style)
	vbox.add_child(sep)

	# Hint text
	_label = RichTextLabel.new()
	_label.bbcode_enabled = true
	_label.fit_content = true
	_label.scroll_active = false
	_label.add_theme_font_size_override("normal_font_size", 22)
	_label.add_theme_color_override("default_color", Color(0.95, 0.95, 0.88))
	_label.custom_minimum_size = Vector2(0, 60)
	vbox.add_child(_label)

	# Got it button
	var btn_row = CenterContainer.new()
	vbox.add_child(btn_row)

	var btn = Button.new()
	btn.text = "Got it!"
	btn.custom_minimum_size = Vector2(160, 50)
	btn.add_theme_font_size_override("font_size", 22)

	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = Color(0.18, 0.52, 0.28, 1.0)
	btn_normal.set_corner_radius_all(10)
	btn_normal.content_margin_left   = 20
	btn_normal.content_margin_top    = 10
	btn_normal.content_margin_right  = 20
	btn_normal.content_margin_bottom = 10
	btn.add_theme_stylebox_override("normal", btn_normal)

	var btn_hover = btn_normal.duplicate()
	btn_hover.bg_color = Color(0.25, 0.7, 0.38, 1.0)
	btn_hover.shadow_color = Color(0.25, 0.7, 0.38, 0.4)
	btn_hover.shadow_size = 8
	btn.add_theme_stylebox_override("hover", btn_hover)

	btn.pressed.connect(_on_close)
	btn_row.add_child(btn)

	# Size panel to fit content after layout
	await get_tree().process_frame
	_panel.offset_top    = -(_panel.size.y / 2.0)
	_panel.offset_bottom =  (_panel.size.y / 2.0)

	# Fade in
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.2)

func show_hint(text: String) -> void:
	_label.text = "[center]" + text + "[/center]"
	# Re-center panel vertically after text is set
	await get_tree().process_frame
	_panel.offset_top    = -(_panel.size.y / 2.0)
	_panel.offset_bottom =  (_panel.size.y / 2.0)

func _on_close() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	await tween.finished
	closed.emit()
	queue_free()

func _unhandled_input(event: InputEvent) -> void:
	# Close on Escape too
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_on_close()
		get_viewport().set_input_as_handled()
