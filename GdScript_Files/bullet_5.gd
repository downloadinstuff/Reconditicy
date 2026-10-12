extends Area2D

var traveled_distance = 0

func _physics_process(delta):
	const SPEED = 1400
	const RANGE = 4000
	
	var direction = Vector2.RIGHT.rotated(rotation)
	global_position += direction * SPEED * delta
	
	traveled_distance += SPEED * delta
	if traveled_distance > RANGE:
		queue_free()

func _on_body_entered(body):
	if body.has_method("take_damage5"):
		body.take_damage5()
