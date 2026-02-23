extends CanvasLayer

## HintOverlay - Shared hint panel used by all minigames
## Shows guiding hint text in a BGbox_01A panel without revealing the answer.
## Usage:
##   var overlay = CanvasLayer.new()
##   overlay.set_script(load("res://scenes/ui/hint_overlay.gd"))
##   get_tree().root.add_child(overlay)
##   overlay.show_hint("Your guiding hint text here.")

signal closed

const BGBOX = preload("res://assets/UI/BGbox_01A.png")

var _label: RichTextLabel
var _panel: NinePatchRect
var _root: Control  # All visuals live here so we can modulate this node
var _pending_text: String = ""

func _ready() -> void:
	layer = 200  # Above everything

	# Root Control that covers the full screen — modulate applied here
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.modulate = Color(1, 1, 1, 0)  # Start invisible
	add_child(_root)

	# Dim background
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.6)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(bg)

	# BGbox_01A nine-patch panel — fixed size, centered
	_panel = NinePatchRect.new()
	_panel.texture = BGBOX
	_panel.patch_margin_left   = 28
	_panel.patch_margin_top    = 29
	_panel.patch_margin_right  = 28
	_panel.patch_margin_bottom = 27
	_panel.custom_minimum_size = Vector2(700, 300)
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.offset_left   = -350
	_panel.offset_right  =  350
	_panel.offset_top    = -200
	_panel.offset_bottom =  200
	_root.add_child(_panel)

	# Inner margin + VBox
	var m = MarginContainer.new()
	m.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	m.add_theme_constant_override("margin_left",   36)
	m.add_theme_constant_override("margin_top",    32)
	m.add_theme_constant_override("margin_right",  36)
	m.add_theme_constant_override("margin_bottom", 32)
	_panel.add_child(m)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 16)
	m.add_child(vbox)

	# Title
	var title = Label.new()
	title.text = "Detective's Hint"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	title.add_theme_color_override("font_outline_color", Color(0.2, 0.1, 0.0))
	title.add_theme_constant_override("outline_size", 3)
	vbox.add_child(title)

	# Divider
	var sep = HSeparator.new()
	var sep_style = StyleBoxFlat.new()
	sep_style.bg_color = Color(1.0, 0.85, 0.3, 0.4)
	sep_style.content_margin_top = 1
	sep_style.content_margin_bottom = 1
	sep.add_theme_stylebox_override("separator", sep_style)
	vbox.add_child(sep)

	# Hint text label
	_label = RichTextLabel.new()
	_label.bbcode_enabled = true
	_label.fit_content = true
	_label.scroll_active = false
	_label.add_theme_font_size_override("normal_font_size", 22)
	_label.add_theme_color_override("default_color", Color(0.95, 0.95, 0.88))
	_label.custom_minimum_size = Vector2(0, 60)
	vbox.add_child(_label)

	# Apply pending text if show_hint() was called before _ready()
	if _pending_text != "":
		_label.text = "[center]" + _pending_text + "[/center]"

	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	vbox.add_child(spacer)

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
	btn.add_theme_stylebox_override("hover", btn_hover)

	btn.pressed.connect(_on_close)
	btn_row.add_child(btn)

	# Fade in
	var tween = create_tween()
	tween.tween_property(_root, "modulate:a", 1.0, 0.2)

func show_hint(text: String) -> void:
	_pending_text = text
	if _label != null:
		_label.text = "[center]" + text + "[/center]"

func _on_close() -> void:
	var tween = create_tween()
	tween.tween_property(_root, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func():
		closed.emit()
		queue_free()
	)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_on_close()
		get_viewport().set_input_as_handled()
