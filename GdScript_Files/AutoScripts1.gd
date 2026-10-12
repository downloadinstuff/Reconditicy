extends Node

# ── Signals ──────────────────────────────────────────
signal dialogue_started
signal dialogue_finished
signal line_shown(line: String)

# ── Config ───────────────────────────────────────────
const CHAR_DELAY := 0.02
const SCROLL_DURATION := 0.2

# ── Dialogue data ────────────────────────────────────
var dialogues := {
	"cowboy_intro": [
		"yap",
		"yap",
		"yap"
	],
	"cowboy_arming": [
		"Careful with that thing.",
		"It's loaded."
	],
}

# ── State ────────────────────────────────────────────
var labels: Array = []
var slot_order: Array = []
var base_positions: Array = []
var active_label: Node = null

var lines: Array = []
var current_index: int = 0
var typing: bool = false
var active: bool = false

var player_ref: Node = null


func _ready():
	labels = get_tree().get_nodes_in_group("texts")
	labels.sort_custom(func(a, b): return a.name < b.name)  # ensures Text1, Text2, Text3 order

	for label in labels:
		base_positions.append(label.position)
		label.text = ""
		label.modulate.a = 0.0

	slot_order = labels.duplicate()


# ── Public API ───────────────────────────────────────
func start_dialogue_by_name(dialogue_key: String):
	if not dialogues.has(dialogue_key):
		push_error("No dialogue found for key: " + dialogue_key)
		return
	start_dialogue(dialogues[dialogue_key])

func start_dialogue(dialogue_lines: Array):
	lines = dialogue_lines
	current_index = 0
	active = true

	player_ref = get_tree().get_first_node_in_group("player")
	if player_ref:
		for label in labels:
			label.global_position = player_ref.global_position

	dialogue_started.emit()
	_advance_line(lines[current_index])

func advance():
	if not active:
		return
	if typing:
		_skip_typing()
		return

	current_index += 1
	if current_index < lines.size():
		_advance_line(lines[current_index])
	else:
		_end_dialogue()


# ── Internals ────────────────────────────────────────
func _advance_line(text: String):
	var recycled = slot_order.pop_front()
	slot_order.append(recycled)
	active_label = recycled

	for i in slot_order.size():
		var label = slot_order[i]
		var tween = create_tween()
		tween.tween_property(label, "position", base_positions[i], SCROLL_DURATION)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	recycled.modulate.a = 0.0
	var fade_tween = create_tween()
	fade_tween.tween_property(recycled, "modulate:a", 1.0, SCROLL_DURATION)

	await _type_text(recycled, text)

func _type_text(label, text: String):
	typing = true
	label.text = ""
	for i in text.length():
		if not typing:
			label.text = text
			return
		label.text = text.substr(0, i + 1)
		await get_tree().create_timer(CHAR_DELAY).timeout
	typing = false
	line_shown.emit(text)

func _skip_typing():
	typing = false
	active_label.text = lines[current_index]

func _end_dialogue():
	active = false
	for label in labels:
		var tween = create_tween()
		tween.tween_property(label, "modulate:a", 0.0, SCROLL_DURATION)
	dialogue_finished.emit()








func start_auto_dialogue_by_name(dialogue_key: String):
	if active:
		return
	if not dialogues.has(dialogue_key):
		push_error("No dialogue found for key: " + dialogue_key)
		return
	start_auto_dialogue(dialogues[dialogue_key])

func start_auto_dialogue(dialogue_lines: Array):
	if active:
		return
	lines = dialogue_lines
	current_index = 0
	active = true

	player_ref = get_tree().get_first_node_in_group("player")
	if player_ref:
		for label in labels:
			label.global_position = player_ref.global_position

	dialogue_started.emit()
	_run_auto_dialogue()

func _run_auto_dialogue():
	for i in lines.size():
		current_index = i
		await _advance_line(lines[i])
		if i < lines.size() - 1:
			await get_tree().create_timer(1.0).timeout
	await get_tree().create_timer(1.0).timeout
	_end_dialogue()
