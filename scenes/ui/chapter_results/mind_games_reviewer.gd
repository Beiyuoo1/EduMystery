extends Control

## Mind Games Reviewer
## Shows educational content and case summary dynamically based on collected evidence

signal reviewer_dismissed

# Chapter content data (educational concepts only)
var chapter_educational_content = {
	1: {
		"title": "The Stolen Exam Papers",
		"subject": "English (Oral Communication)",
		"concepts": [
			{
				"term": "Speaker",
				"definition": "the originator or creator of the message."
			},
			{
				"term": "Encoding",
				"definition": "process of converting thoughts into understandable symbols (words & gestures)."
			},
			{
				"term": "Channel",
				"definition": "the medium or pathway used to send the message."
			},
			{
				"term": "Feedback",
				"definition": "the receiver's reaction or response that completes the communication loop."
			},
			{
				"term": "Decoding",
				"definition": "the process by which the receiver interprets the message and translates it into meaning."
			}
		],
		"minigame_guides": [
			{
				"title": "Approaching the Janitor",
				"correct_answer": "Good afternoon, sir. I was hoping you could help me with something.",
				"explanation": "This is the correct approach because it uses polite and respectful language. Starting with a greeting ('Good afternoon') and showing respect ('sir') creates a positive atmosphere. Asking for help politely ('I was hoping you could help') makes the janitor more willing to cooperate, which is essential for effective communication and gathering information."
			},
			{
				"title": "WiFi Router Question",
				"correct_answer": "WiFi",
				"explanation": "The correct pronunciation is 'WiFi' (why-figh). Understanding technical terms and pronouncing them correctly shows professionalism and helps avoid miscommunication. In oral communication, clear pronunciation of technical vocabulary is crucial for being understood by others."
			},
			{
				"title": "Communication Model",
				"correct_answer": "The Schramm model emphasizes shared experience.",
				"explanation": "This sentence demonstrates proper grammar and accurate knowledge of communication theory. The Schramm model focuses on how shared experiences between sender and receiver affect message interpretation. Using correct subject-verb agreement ('model emphasizes') and precise terminology shows mastery of both English and the subject matter."
			}
		],
		"culprit": "Greg (accidental)",
		"remaining_mystery": "The signature \"B.C. – Chapter 1\""
	},
	2: {
		"title": "The Student Council Mystery",
		"subject": "English (Oral Communication)",
		"concepts": [
			{
				"term": "Context",
				"definition": "the circumstances or setting surrounding the communication that affect meaning."
			},
			{
				"term": "Barriers",
				"definition": "obstacles that prevent effective communication (physical, psychological, semantic, cultural)."
			},
			{
				"term": "Clarity",
				"definition": "the quality of being easy to understand; using precise and unambiguous language."
			},
			{
				"term": "Active Listening",
				"definition": "fully concentrating on what is being said rather than just passively hearing the message."
			},
			{
				"term": "Non-verbal Communication",
				"definition": "communication through body language, facial expressions, gestures, and tone of voice."
			}
		],
		"minigame_guides": [
			{
				"title": "Ria's Note Question",
				"correct_answer": "She feared it would make her look guilty.",
				"explanation": "This sentence is grammatically correct with proper subject-verb agreement and clear meaning. It uses past tense consistently ('feared', 'would make') and expresses a complete thought about Ria's emotional state and reasoning."
			}
		],
		"culprit": "Ryan (blackmailer)",
		"remaining_mystery": "The B.C. signature appears again"
	},
	3: {
		"title": "Art Week Vandalism",
		"subject": "English (Oral Communication)",
		"concepts": [
			{
				"term": "Tone",
				"definition": "the speaker's attitude toward the subject or audience, conveyed through word choice and delivery."
			},
			{
				"term": "Purpose",
				"definition": "the reason for communication - to inform, persuade, entertain, or express emotion."
			},
			{
				"term": "Audience",
				"definition": "the intended receiver(s) of the message; understanding them shapes how we communicate."
			},
			{
				"term": "Empathy",
				"definition": "the ability to understand and share the feelings of another person."
			},
			{
				"term": "Inference",
				"definition": "drawing logical conclusions based on evidence and reasoning rather than explicit statements."
			}
		],
		"minigame_guides": [
			{
				"title": "Cruel Note Observation",
				"correct_answer": "They left evidence.",
				"explanation": "This sentence uses proper subject-verb-object structure ('They' + 'left' + 'evidence') and past tense consistently. It's a clear, direct observation statement that follows standard English grammar rules. The other options have verb tense errors or incorrect word order."
			},
			{
				"title": "Receipt Riddle",
				"correct_answer": "FLIPPING",
				"explanation": "The riddle describes 'the sound of paper in motion' and 'a quick motion of the wrist and hand,' which matches the action of flipping through pages. This demonstrates inference skills - using contextual clues to deduce the correct word that fits both the physical action and the situation described."
			}
		],
		"culprit": "Victor",
		"remaining_mystery": "The B.C. card appears again - Lesson 3: Creativity"
	},
	4: {
		"title": "Anonymous Notes Mystery",
		"subject": "English (Oral Communication)",
		"concepts": [
			{
				"term": "Ethics",
				"definition": "moral principles that govern behavior and decision-making in communication."
			},
			{
				"term": "Intention",
				"definition": "the purpose or aim behind communication; good intentions don't always lead to good outcomes."
			},
			{
				"term": "Impact vs Intent",
				"definition": "the difference between what we mean to communicate and how it's actually received by others."
			},
			{
				"term": "Critical Thinking",
				"definition": "analyzing information objectively to form reasoned judgments rather than accepting ideas blindly."
			},
			{
				"term": "Wisdom",
				"definition": "the ability to apply knowledge thoughtfully, considering consequences and context before acting."
			}
		],
		"minigame_guides": [
			{
				"title": "Anonymous Notes",
				"correct_answer": "anonymous",
				"explanation": "The word 'anonymous' means without a known name or identity. This word is crucial to understanding the mystery - the notes are anonymous, meaning the sender's identity is hidden. Distinguishing 'anonymous' from similar-sounding words like 'unanimous' (everyone agrees) or 'autonomous' (self-governing) shows attention to detail in communication."
			},
			{
				"title": "Approaching a Suspect",
				"correct_answer": "We should observe her behavior carefully before making assumptions about her intentions.",
				"explanation": "This demonstrates critical thinking and wisdom - the key lesson of Chapter 4. Rather than jumping to conclusions (confronting) or avoiding evidence (ignoring), Conrad learns to observe carefully and withhold judgment until he has full context. This approach respects that good intentions can lead to problematic actions, and understanding 'why' matters as much as knowing 'what happened.'"
			},
			{
				"title": "Curriculum Minigame (Maze)",
				"correct_answer": "Various curriculum questions",
				"explanation": "This minigame tests your knowledge while navigating challenges, representing how Alex tried to educate others through experience rather than lectures - like the journal taught. However, true wisdom requires understanding when and how to teach, not just what to teach."
			}
		],
		"culprit": "Alex (well-intentioned student)",
		"remaining_mystery": "B.C. card appears in the journal - Lesson 4: Wisdom"
	},
	5: {
		"title": "The B.C. Revelation",
		"subject": "English (Oral Communication) - Final Integration",
		"concepts": [
			{
				"term": "Choice",
				"definition": "the power to make decisions freely; respecting others' agency is fundamental to ethical teaching."
			},
			{
				"term": "Free Will",
				"definition": "the ability to make independent decisions without coercion; true education respects this autonomy."
			},
			{
				"term": "Guidance vs Control",
				"definition": "the difference between helping someone find their path (guidance) and forcing them down a path (control)."
			},
			{
				"term": "Experiential Learning",
				"definition": "learning through direct experience and reflection rather than passive instruction."
			},
			{
				"term": "Transformative Education",
				"definition": "teaching that changes how people think and act, not just what they know; focuses on growth and self-discovery."
			}
		],
		"minigame_guides": [
			{
				"title": "Approaching B.C.",
				"correct_answer": "Enter respectfully and thank them for the lessons they have taught through the cards.",
				"explanation": "This is the correct approach because it demonstrates Conrad's growth and understanding. He recognizes that B.C. was guiding, not manipulating - teaching through observation rather than control. Showing gratitude and respect honors the teacher-student relationship and reflects the core lesson: true teaching respects free will. Conrad enters with humility, ready to learn rather than accuse."
			},
			{
				"title": "Teaching Through Observation",
				"correct_answer": "observation",
				"explanation": "The word 'observation' is key to understanding B.C.'s teaching philosophy. Unlike traditional instruction that tells students what to think, B.C. teaches by observing human nature and letting students discover lessons through experience. This pronunciation challenge reinforces the core method: watch, guide, but never control. Conrad learns that true teaching means being patient and observant."
			},
			{
				"title": "Final Lesson (Fill-in-the-Blank)",
				"correct_answer": "True teaching requires wisdom and respects choice while guiding growth.",
				"explanation": "This sentence captures the core of B.C.'s philosophy and the lesson that ties all five chapters together. 'Wisdom' (knowing when and how to act), 'respects choice' (honoring free will), and 'guiding growth' (helping without controlling) form the foundation of ethical teaching. Conrad has become both student and teacher by understanding this principle."
			}
		],
		"culprit": "Principal B.C. (Bernardino Cruz) - not a culprit, but the mysterious guide",
		"remaining_mystery": "No mystery remains. The chain has transformed - Conrad writes his own card, becoming the next guide."
	}
}

func _ready():
	visible = false

func show_reviewer(chapter_num: int):
	"""Show the Mind Games Reviewer for the specified chapter"""
	if not chapter_educational_content.has(chapter_num):
		push_error("No reviewer content for chapter " + str(chapter_num))
		return

	var content = chapter_educational_content[chapter_num]
	_create_ui(chapter_num, content)

	# Show with fade-in
	visible = true
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func _create_ui(chapter_num: int, content: Dictionary):
	"""Create the reviewer UI like a notebook"""
	# Dark semi-transparent overlay background
	var overlay = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.0, 0.0, 0.0, 0.85)
	add_child(overlay)

	# Calculate center position after a frame to get proper viewport size
	await get_tree().process_frame

	var viewport_size = get_viewport_rect().size
	var content_width = 1330.0  # 650 + 30 + 650
	var content_height = 800.0  # Approximate height

	# Calculate margins to center
	var margin_x = max(0, (viewport_size.x - content_width) / 2.0)
	var margin_y = max(0, (viewport_size.y - content_height) / 2.0)

	# Use MarginContainer with calculated margins
	var margin_container = MarginContainer.new()
	margin_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin_container.add_theme_constant_override("margin_left", int(margin_x))
	margin_container.add_theme_constant_override("margin_right", int(margin_x))
	margin_container.add_theme_constant_override("margin_top", int(margin_y))
	margin_container.add_theme_constant_override("margin_bottom", int(margin_y))
	add_child(margin_container)

	# VBox to hold pages and button
	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 30)
	margin_container.add_child(main_vbox)

	# Main HBox for left and right pages
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 30)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(hbox)

	# LEFT PAGE - Clues, Evidence, Culprit (Dynamic data from EvidenceManager)
	var left_page = _create_left_page(chapter_num, content)
	hbox.add_child(left_page)

	# RIGHT PAGE - Mind Games Reviewer (Concepts)
	var right_page = _create_right_page(chapter_num, content)
	hbox.add_child(right_page)

	# Continue button at the bottom (centered)
	var continue_button = Button.new()
	continue_button.text = "Continue"
	continue_button.custom_minimum_size = Vector2(250, 70)
	continue_button.add_theme_font_size_override("font_size", 28)

	# Button style
	var btn_style_normal = StyleBoxFlat.new()
	btn_style_normal.bg_color = Color(0.2, 0.5, 0.8)  # Blue
	btn_style_normal.corner_radius_top_left = 10
	btn_style_normal.corner_radius_top_right = 10
	btn_style_normal.corner_radius_bottom_left = 10
	btn_style_normal.corner_radius_bottom_right = 10

	var btn_style_hover = StyleBoxFlat.new()
	btn_style_hover.bg_color = Color(0.3, 0.6, 0.9)  # Bright blue
	btn_style_hover.corner_radius_top_left = 10
	btn_style_hover.corner_radius_top_right = 10
	btn_style_hover.corner_radius_bottom_left = 10
	btn_style_hover.corner_radius_bottom_right = 10

	continue_button.add_theme_stylebox_override("normal", btn_style_normal)
	continue_button.add_theme_stylebox_override("hover", btn_style_hover)
	continue_button.add_theme_stylebox_override("pressed", btn_style_hover)
	continue_button.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))

	continue_button.pressed.connect(_on_close_pressed)

	# Center the button
	var button_center = CenterContainer.new()
	button_center.add_child(continue_button)
	main_vbox.add_child(button_center)

func _create_left_page(chapter_num: int, content: Dictionary) -> PanelContainer:
	"""Create the left page with dynamically loaded clues and evidence from EvidenceManager"""
	var page = PanelContainer.new()
	page.custom_minimum_size = Vector2(650, 700)

	# Notebook-style background
	var page_style = StyleBoxFlat.new()
	page_style.bg_color = Color(0.95, 0.92, 0.85, 1.0)  # Cream/paper color
	page_style.border_color = Color(0.5, 0.4, 0.3, 0.8)  # Brown border
	page_style.set_border_width_all(3)
	page_style.corner_radius_top_left = 12
	page_style.corner_radius_top_right = 12
	page_style.corner_radius_bottom_left = 12
	page_style.corner_radius_bottom_right = 12
	page_style.shadow_color = Color(0, 0, 0, 0.3)
	page_style.shadow_size = 8
	page.add_theme_stylebox_override("panel", page_style)

	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(650, 700)
	page.add_child(scroll)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 40)
	margin.add_theme_constant_override("margin_bottom", 40)
	scroll.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	margin.add_child(vbox)

	# Title with underline
	var title = Label.new()
	title.text = "Chapter %d:\n%s" % [chapter_num, content.get("title", "Unknown")]
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.1, 0.1, 0.15))
	title.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(title)

	# Decorative line
	var line1 = ColorRect.new()
	line1.color = Color(0.3, 0.25, 0.2, 0.6)
	line1.custom_minimum_size = Vector2(500, 2)
	var line_container1 = CenterContainer.new()
	line_container1.add_child(line1)
	vbox.add_child(line_container1)

	# Spacer
	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(0, 15)
	vbox.add_child(spacer1)

	# DYNAMIC: Get collected evidence for this chapter
	var collected_evidence = []
	if EvidenceManager:
		collected_evidence = EvidenceManager.get_evidence_by_chapter(chapter_num)

	# Clues section - Show evidence titles
	var clues_section = _create_styled_section("Clues:")
	vbox.add_child(clues_section)

	if collected_evidence.size() > 0:
		for evidence in collected_evidence:
			var clue_label = Label.new()
			clue_label.text = "  • " + evidence.get("title", "Unknown")
			clue_label.add_theme_font_size_override("font_size", 20)
			clue_label.add_theme_color_override("font_color", Color(0.15, 0.15, 0.2))
			clue_label.autowrap_mode = TextServer.AUTOWRAP_WORD
			vbox.add_child(clue_label)
	else:
		var no_clues = Label.new()
		no_clues.text = "  • No clues collected yet"
		no_clues.add_theme_font_size_override("font_size", 18)
		no_clues.add_theme_color_override("font_color", Color(0.4, 0.4, 0.45))
		vbox.add_child(no_clues)

	# Spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 15)
	vbox.add_child(spacer2)

	# Evidence section - Show evidence IDs/descriptions (FULL TEXT)
	var evidence_section = _create_styled_section("Evidence:")
	vbox.add_child(evidence_section)

	if collected_evidence.size() > 0:
		for evidence in collected_evidence:
			var evidence_label = Label.new()
			evidence_label.text = "  • " + evidence.get("description", "No description")
			evidence_label.add_theme_font_size_override("font_size", 18)
			evidence_label.add_theme_color_override("font_color", Color(0.15, 0.15, 0.2))
			evidence_label.autowrap_mode = TextServer.AUTOWRAP_WORD
			evidence_label.custom_minimum_size = Vector2(600, 0)
			vbox.add_child(evidence_label)
	else:
		var no_evidence = Label.new()
		no_evidence.text = "  • No evidence collected yet"
		no_evidence.add_theme_font_size_override("font_size", 18)
		no_evidence.add_theme_color_override("font_color", Color(0.4, 0.4, 0.45))
		vbox.add_child(no_evidence)

	# Spacer
	var spacer3 = Control.new()
	spacer3.custom_minimum_size = Vector2(0, 15)
	vbox.add_child(spacer3)

	# Culprit section
	var culprit_section = _create_styled_section("Culprit:")
	vbox.add_child(culprit_section)

	var culprit_value = Label.new()
	culprit_value.text = "  • " + content.get("culprit", "Unknown")
	culprit_value.add_theme_font_size_override("font_size", 20)
	culprit_value.add_theme_color_override("font_color", Color(0.5, 0.1, 0.1))  # Red for culprit
	culprit_value.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(culprit_value)

	# Spacer
	var spacer4 = Control.new()
	spacer4.custom_minimum_size = Vector2(0, 15)
	vbox.add_child(spacer4)

	# Remaining mystery section
	var mystery_section = _create_styled_section("Remaining Mystery:")
	vbox.add_child(mystery_section)

	var mystery_value = Label.new()
	mystery_value.text = "  • " + content.get("remaining_mystery", "")
	mystery_value.add_theme_font_size_override("font_size", 20)
	mystery_value.add_theme_color_override("font_color", Color(0.2, 0.15, 0.4))  # Purple for mystery
	mystery_value.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(mystery_value)

	return page

func _create_right_page(chapter_num: int, content: Dictionary) -> PanelContainer:
	"""Create the right page with Mind Games Reviewer concepts"""
	var page = PanelContainer.new()
	page.custom_minimum_size = Vector2(650, 700)

	# Notebook-style background
	var page_style = StyleBoxFlat.new()
	page_style.bg_color = Color(0.95, 0.92, 0.85, 1.0)  # Cream/paper color
	page_style.border_color = Color(0.5, 0.4, 0.3, 0.8)  # Brown border
	page_style.set_border_width_all(3)
	page_style.corner_radius_top_left = 12
	page_style.corner_radius_top_right = 12
	page_style.corner_radius_bottom_left = 12
	page_style.corner_radius_bottom_right = 12
	page_style.shadow_color = Color(0, 0, 0, 0.3)
	page_style.shadow_size = 8
	page.add_theme_stylebox_override("panel", page_style)

	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(650, 700)
	page.add_child(scroll)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 40)
	margin.add_theme_constant_override("margin_bottom", 40)
	scroll.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	margin.add_child(vbox)

	# Title
	var title = Label.new()
	title.text = "Chapter %d:\nMind Games Reviewer" % chapter_num
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.1, 0.1, 0.15))
	vbox.add_child(title)

	# Decorative line
	var line2 = ColorRect.new()
	line2.color = Color(0.3, 0.25, 0.2, 0.6)
	line2.custom_minimum_size = Vector2(500, 2)
	var line_container2 = CenterContainer.new()
	line_container2.add_child(line2)
	vbox.add_child(line_container2)

	# Add spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer2)

	# Concepts list
	var concepts = content.get("concepts", [])
	if concepts.size() > 0:
		for i in range(concepts.size()):
			var concept = concepts[i]

			# Number and term (bold-ish)
			var term_label = Label.new()
			term_label.text = "%d. %s" % [i + 1, concept.get("term", "")]
			term_label.add_theme_font_size_override("font_size", 22)
			term_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.15))
			vbox.add_child(term_label)

			# Definition (indented, slightly lighter)
			var def_label = Label.new()
			def_label.text = "   - " + concept.get("definition", "")
			def_label.add_theme_font_size_override("font_size", 19)
			def_label.add_theme_color_override("font_color", Color(0.25, 0.25, 0.3))
			def_label.autowrap_mode = TextServer.AUTOWRAP_WORD
			def_label.custom_minimum_size = Vector2(550, 0)
			vbox.add_child(def_label)

			# Spacer between concepts
			var concept_spacer = Control.new()
			concept_spacer.custom_minimum_size = Vector2(0, 10)
			vbox.add_child(concept_spacer)
	else:
		var no_concepts = Label.new()
		no_concepts.text = "Educational content coming soon!"
		no_concepts.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		no_concepts.add_theme_font_size_override("font_size", 20)
		no_concepts.add_theme_color_override("font_color", Color(0.4, 0.4, 0.45))
		vbox.add_child(no_concepts)

	# Add spacer before minigame guides
	var guide_spacer1 = Control.new()
	guide_spacer1.custom_minimum_size = Vector2(0, 25)
	vbox.add_child(guide_spacer1)

	# Decorative line before minigame guides
	var line3 = ColorRect.new()
	line3.color = Color(0.3, 0.25, 0.2, 0.6)
	line3.custom_minimum_size = Vector2(500, 2)
	var line_container3 = CenterContainer.new()
	line_container3.add_child(line3)
	vbox.add_child(line_container3)

	# Minigame Guides Section
	var minigame_guides = content.get("minigame_guides", [])
	if minigame_guides.size() > 0:
		# Section title
		var guide_title = Label.new()
		guide_title.text = "Minigame Solutions & Explanations"
		guide_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		guide_title.add_theme_font_size_override("font_size", 24)
		guide_title.add_theme_color_override("font_color", Color(0.1, 0.1, 0.2))
		guide_title.add_theme_color_override("font_outline_color", Color(0.8, 0.75, 0.65))
		guide_title.add_theme_constant_override("outline_size", 1)
		vbox.add_child(guide_title)

		# Spacer
		var guide_spacer2 = Control.new()
		guide_spacer2.custom_minimum_size = Vector2(0, 15)
		vbox.add_child(guide_spacer2)

		# List each minigame guide
		for i in range(minigame_guides.size()):
			var guide = minigame_guides[i]

			# Minigame title
			var guide_title_label = Label.new()
			guide_title_label.text = "%d. %s" % [i + 1, guide.get("title", "")]
			guide_title_label.add_theme_font_size_override("font_size", 20)
			guide_title_label.add_theme_color_override("font_color", Color(0.1, 0.3, 0.5))
			vbox.add_child(guide_title_label)

			# Correct answer (green highlight)
			var answer_label = Label.new()
			answer_label.text = "   ✓ Answer: \"" + guide.get("correct_answer", "") + "\""
			answer_label.add_theme_font_size_override("font_size", 18)
			answer_label.add_theme_color_override("font_color", Color(0.1, 0.5, 0.1))
			answer_label.autowrap_mode = TextServer.AUTOWRAP_WORD
			answer_label.custom_minimum_size = Vector2(550, 0)
			vbox.add_child(answer_label)

			# Explanation (why this is correct)
			var explanation_label = Label.new()
			explanation_label.text = "   💡 Why: " + guide.get("explanation", "")
			explanation_label.add_theme_font_size_override("font_size", 17)
			explanation_label.add_theme_color_override("font_color", Color(0.25, 0.25, 0.35))
			explanation_label.autowrap_mode = TextServer.AUTOWRAP_WORD
			explanation_label.custom_minimum_size = Vector2(550, 0)
			vbox.add_child(explanation_label)

			# Spacer between guides
			var guide_item_spacer = Control.new()
			guide_item_spacer.custom_minimum_size = Vector2(0, 15)
			vbox.add_child(guide_item_spacer)

	return page

func _create_styled_section(title: String) -> Label:
	"""Helper to create a styled section header"""
	var label = Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.2))
	label.add_theme_color_override("font_outline_color", Color(0.8, 0.75, 0.65))
	label.add_theme_constant_override("outline_size", 1)
	return label

func _on_close_pressed():
	print("DEBUG: Close button pressed - dismissing reviewer")

	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished

	visible = false
	reviewer_dismissed.emit()
