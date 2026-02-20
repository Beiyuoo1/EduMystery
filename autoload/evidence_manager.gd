extends Node

signal evidence_unlocked(evidence_id: String)

const SAVE_PATH = "user://evidence.sav"

# Master evidence library
var evidence_definitions = {
	# Chapter 1: Faculty Room Leak Mystery
	"exam_papers_c1": {
		"id": "exam_papers_c1",
		"title": "Damaged Exam Papers",
		"description": "Grade 12-A History examination papers ruined by water damage. Found in faculty room filing cabinet.",
		"image_path": "res://assets/evidence/placeholder_document.png",
		"chapter": 1
	},
	"water_source_c1": {
		"id": "water_source_c1",
		"title": "Water Leak Source",
		"description": "Leak originated from ceiling area near the air conditioning unit. Recent maintenance records show no issues.",
		"image_path": "res://assets/evidence/placeholder_leak.png",
		"chapter": 1
	},
	"bracelet_c1": {
		"id": "bracelet_c1",
		"title": "Charm Bracelet",
		"description": "A worn charm bracelet with distinctive blue, red, and white beads, and a tiny silver cross. Found under the desk in the faculty room.",
		"image_path": "res://Bg/Charm.png",
		"chapter": 1
	},
	"maintenance_log_c1": {
		"id": "maintenance_log_c1",
		"title": "Maintenance Log",
		"description": "Building maintenance log showing recent A/C servicing. Last entry dated 3 days before the incident.",
		"image_path": "res://assets/evidence/placeholder_document.png",
		"chapter": 1
	},
	"witness_statement_c1": {
		"id": "witness_statement_c1",
		"title": "Witness Statement",
		"description": "Statement from a student who was near the faculty room the previous evening. Heard unusual sounds.",
		"image_path": "res://assets/evidence/placeholder_document.png",
		"chapter": 1
	},
	"wifi_logs_c1": {
		"id": "wifi_logs_c1",
		"title": "WiFi Connection Logs",
		"description": "Faculty WiFi logs showing two devices connected yesterday evening: Galaxy A52 at 8:00 PM and Redmi Note 10 at 9:00 PM.",
		"image_path": "res://Pics/Wifi_Logs.png",
		"chapter": 1
	},
	"spider_envelope_c1": {
		"id": "spider_envelope_c1",
		"title": "Mysterious Envelope",
		"description": "An envelope given to Greg containing a faculty room key. No name written on it, but stamped with a pixelated spider symbol on the inside flap.",
		"image_path": "res://Pics/clue3.png",
		"chapter": 1
	},
	# Chapter 2: Student Council Mystery
	"lockbox_c2": {
		"id": "lockbox_c2",
		"title": "Empty Lockbox",
		"description": "The Student Council lockbox sits empty on the desk. Whatever was inside has been taken, leaving only questions behind.",
		"image_path": "res://Pics/lockbox.jpg",
		"chapter": 2
	},
	"threat_note_c2": {
		"id": "threat_note_c2",
		"title": "Threatening Note",
		"description": "A threatening note found in Ria's locker: \"I know what you did with last year's fund. Resign or I'll expose you.\" Someone was blackmailing her.",
		"image_path": "res://Pics/threat_note.jpg",
		"chapter": 2
	},
	# Chapter 3: Art Week Vandalism Mystery
	"cruel_note_c3": {
		"id": "cruel_note_c3",
		"title": "Cruel Note",
		"description": "A handwritten note found at the vandalized sculpture scene: \"Not everyone deserves to shine.\" The message is personal and emotional, suggesting the vandal felt overshadowed.",
		"image_path": "res://Bg/assets/evidence/cruel_note.png",
		"chapter": 3
	},
	"receipt_c3": {
		"id": "receipt_c3",
		"title": "Art Supply Receipt",
		"description": "Receipt from an art supply store dated yesterday at 8:47 PM. Found in Victor's sketchbook. Proves he was out near the school despite claiming to be home all night.",
		"image_path": "res://Bg/assets/evidence/receipt.png",
		"chapter": 3
	},
	"victor_sketchbook_c3": {
		"id": "victor_sketchbook_c3",
		"title": "Victor's Sketchbook",
		"description": "Victor's personal sketchbook containing technical studies and later pages filled with angry, violent sketches. One page shows Mia's sculpture 'The Reader' with harsh X marks drawn over it, revealing his dark thoughts and resentment.",
		"image_path": "res://Bg/assets/evidence/victor_sketchbook.png",
		"chapter": 3
	},
	"paint_cloth_c3": {
		"id": "paint_cloth_c3",
		"title": "Paint-Stained Cloth",
		"description": "A cloth rag stained with various paint colors found in Victor's art supply cabinet. Matches the fabric and paint patterns of the cloth found at the vandalism scene. Contains an inventory tag linking it to Victor's assigned supplies.",
		"image_path": "res://Bg/assets/evidence/rug.png",
		"chapter": 3
	},
	# Chapter 4: Anonymous Notes Mystery
	"anonymous_note_c4": {
		"id": "anonymous_note_c4",
		"title": "Anonymous Note",
		"description": "A folded note found in Ben's locker containing a moral accusation: \"You witnessed your friend cheat on the exam but said nothing. Silence protects the guilty. What does that make you?\" The handwriting is neat and deliberate, written on standard school paper.",
		"image_path": "res://Bg/assets/evidence/anonymous_note.png",
		"chapter": 4
	},
	# B.C. Cards - Overarching Mystery (shown in the chapter they are unlocked)
	"bc_card_truth_c1": {
		"id": "bc_card_truth_c1",
		"title": "B.C. Card - Truth",
		"description": "An elegant card with beautiful calligraphy reading: \"Lesson 1: Truth. Evidence and honesty matter. The chain begins.\" Signed \"B.C.\" A mysterious teacher figure is guiding Conrad's journey.",
		"image_path": "res://Bg/assets/evidence/BC_card1.png",
		"chapter": 1
	},
	"bc_card_responsibility_c2": {
		"id": "bc_card_responsibility_c2",
		"title": "B.C. Card - Responsibility",
		"description": "An elegant card reading: \"Lesson 2: Responsibility. True responsibility isn't about pointing out others' failures. It's about building trust, even when no one is watching. The chain continues.\" Signed \"B.C.\"",
		"image_path": "res://Bg/assets/evidence/BC_card2.png",
		"chapter": 2
	},
	"bc_card_creativity_c3": {
		"id": "bc_card_creativity_c3",
		"title": "B.C. Card - Creativity",
		"description": "An elegant card reading: \"Lesson 3: Creativity. True artists create to express, not to compete. Envy sees another's light and tries to extinguish it, not realizing it could have warmed them both.\" Signed \"B.C.\"",
		"image_path": "res://Bg/assets/evidence/BC_card3.png",
		"chapter": 3
	},
	"bc_card_wisdom_c4": {
		"id": "bc_card_wisdom_c4",
		"title": "B.C. Card - Wisdom",
		"description": "An elegant card reading: \"Lesson 4: Wisdom. Knowledge illuminates, but wisdom guides. The eager student learned what the patient teacher already knew. Choice defines character.\" Signed \"B.C.\"",
		"image_path": "res://Bg/assets/evidence/BC_card4.png",
		"chapter": 4
	}
}

# Player's collected evidence
var collected_evidence: Array = []

func _ready():
	# Evidence is now loaded per-save-slot by SaveManager
	# Delete old global evidence file if it exists (migration)
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("Migrated: Deleted old global evidence file, evidence is now saved per-slot")

func unlock_evidence(evidence_id: String):
	if not evidence_definitions.has(evidence_id):
		push_error("Unknown evidence ID: ", evidence_id)
		return

	if not collected_evidence.has(evidence_id):
		collected_evidence.append(evidence_id)
		# Don't save to global file - evidence is now saved per-slot by SaveManager
		evidence_unlocked.emit(evidence_id)
		print("Evidence unlocked: ", evidence_definitions[evidence_id]["title"])

func is_unlocked(evidence_id: String) -> bool:
	return collected_evidence.has(evidence_id)

func collect_bc_cards_silently() -> void:
	# Add all B.C. cards to collected evidence without animation or signal
	var bc_ids = ["bc_card_truth_c1", "bc_card_responsibility_c2", "bc_card_creativity_c3", "bc_card_wisdom_c4"]
	for id in bc_ids:
		if not collected_evidence.has(id):
			collected_evidence.append(id)
			print("BC card silently collected: ", evidence_definitions[id]["title"])

func get_evidence_by_chapter(chapter: int) -> Array:
	var chapter_evidence = []
	for id in collected_evidence:
		if evidence_definitions.has(id) and evidence_definitions[id]["chapter"] == chapter:
			chapter_evidence.append(evidence_definitions[id])

	# Sort by collection order (chronological)
	return chapter_evidence

## DEPRECATED: Evidence is now saved per-slot by SaveManager
## This function is kept for backwards compatibility but should not be used
func save_evidence():
	push_warning("save_evidence() is deprecated - evidence is now saved per-slot by SaveManager")
	# Don't save to global file anymore

## DEPRECATED: Evidence is now loaded per-slot by SaveManager
## This function is kept for backwards compatibility but should not be used
func load_evidence():
	push_warning("load_evidence() is deprecated - evidence is now loaded per-slot by SaveManager")
	# Don't load from global file anymore

func reset_evidence():
	collected_evidence = []
	# Evidence is now managed per-slot by SaveManager, no need to save globally
