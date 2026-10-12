extends CharacterBody2D

var traveled_distance = 0
var direction: Vector2

func _ready():
	direction = Vector2.RIGHT.rotated(rotation)

func _physics_process(delta):
	const SPEED = 1000
	const RANGE = 3000
	
	var collision = move_and_collide(direction * SPEED * delta)
	
	if collision:
		direction = direction.bounce(collision.get_normal())
		var collider = collision.get_collider()
		if collider.has_method("take_damage2"):
			collider.take_damage2()
			queue_free()
			
	traveled_distance += SPEED * delta
	if traveled_distance > RANGE:
		queue_free()
