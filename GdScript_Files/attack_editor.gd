@tool
extends Node2D

@export var cell_size: int = 64

@export var Boss_Attack_Highlight_1: Array[Vector2i] = []:
	set(value):
		Boss_Attack_Highlight_1 = value
		queue_redraw()

@export var Boss_Attack_Highlight_2: Array[Vector2i] = []:
	set(value):
		Boss_Attack_Highlight_2 = value
		queue_redraw()

@export var fill_color: Color = Color(1, 0, 0, 0.35)
@export var outline_color: Color = Color(1, 0, 0, 0.9)
@export var outline_width: float = 2.0

func _ready():
	queue_redraw()

func _draw() -> void:
	_draw_pattern(Boss_Attack_Highlight_1)
	_draw_pattern(Boss_Attack_Highlight_2)

func _draw_pattern(cells: Array[Vector2i]) -> void:
	for cell in cells:
		var rect := Rect2(cell.x * cell_size, cell.y * cell_size, cell_size, cell_size)
		draw_rect(rect, fill_color, true)
		draw_rect(rect, outline_color, false, outline_width)
