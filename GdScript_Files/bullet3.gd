extends CharacterBody2D

var traveled_distance = 0
var direction: Vector2

func _ready():
	direction = Vector2.RIGHT.rotated(rotation)

func _physics_process(delta):
	const SPEED = 1300
	const RANGE = 1500
	
	var collision = move_and_collide(direction * SPEED * delta)
	
	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("walls"):
			queue_free()
		if collider.has_method("take_damage3"):
			collider.take_damage3()
			queue_free()

	traveled_distance += SPEED * delta
	if traveled_distance > RANGE:
		queue_free()
