extends Node2D

@export var triangle_count: int = 5
@export var base_width: float = 80
@export var base_height: float = 200
@export var spacing: float = 120
@export var jump_duration: float = 1
@export var stagger_delay: float = 0.3
@export var fall_stretch_x: float = 1.6
@export var land_recover_duration: float = 0.2

var triangles: Array[Polygon2D] = []

func _ready():
	_create_triangles()
	jump_all()

func _input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):
		jump_all()

func _create_triangles():
	for i in range(triangle_count):
		var t: float = float(i) / float(triangle_count - 1)

		var jump_percent: float = lerp(1.0, 0.5, t)
		var growth_percent: float = lerp(0.2, 0.0, t)

		var tri := Polygon2D.new()
		tri.name = "Triangle%d" % i
		tri.position = Vector2(i * spacing, 0)
		tri.set_meta("jump_percent", jump_percent)
		tri.set_meta("growth_percent", growth_percent)

		_draw_triangle(tri, base_width, base_height)
		add_child(tri)
		triangles.append(tri)

func _draw_triangle(tri: Polygon2D, w: float, h: float):
	tri.polygon = PackedVector2Array([
		Vector2(-w / 2.0, 0),
		Vector2(w / 2.0, 0),
		Vector2(0, -h)
	])

func jump_all():
	for i in range(triangles.size()):
		var tri: Polygon2D = triangles[i]
		get_tree().create_timer(i * stagger_delay).timeout.connect(_jump_one.bind(tri))

func _jump_one(tri: Polygon2D):
	var jump_percent: float = tri.get_meta("jump_percent")
	var growth_percent: float = tri.get_meta("growth_percent")
	var jump_distance: float = base_height * jump_percent

	var tween := create_tween()
	tween.tween_property(tri, "position:y", -jump_distance, jump_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if growth_percent > 0.0:
		tween.tween_property(tri, "scale:y", 1.0 + growth_percent, jump_duration)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(jump_duration).timeout

	var tween2 := create_tween()
	tween2.tween_property(tri, "position:y", 0.0, jump_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween2.parallel().tween_property(tri, "scale:x", fall_stretch_x, jump_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if growth_percent > 0.0:
		tween2.parallel().tween_property(tri, "scale:y", 1.0, jump_duration)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	await get_tree().create_timer(jump_duration).timeout

	var tween3 := create_tween()
	tween3.tween_property(tri, "scale", Vector2.ONE, land_recover_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
