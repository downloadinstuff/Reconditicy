extends Node2D

@onready var buttons: Array[Button] = [
	$Panel/Start,
	$Panel/Options,
	$Panel/Quit
]

var current_index: int = 0

func _ready() -> void:
	_highlight_button(current_index)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		_move_selection(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_down"):
		_move_selection(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		_activate_current()
		get_viewport().set_input_as_handled()

func _move_selection(direction: int) -> void:
	current_index = clamp(current_index + direction, 0, buttons.size() - 1)
	_highlight_button(current_index)

func _highlight_button(index: int) -> void:
	buttons[index].grab_focus()

func _activate_current() -> void:
	buttons[current_index].pressed.emit()

func _on_start_pressed() -> void:
	print("Start pressed")

func _on_options_pressed() -> void:
	print("Options pressed")

func _on_quit_pressed() -> void:
	get_tree().quit()
