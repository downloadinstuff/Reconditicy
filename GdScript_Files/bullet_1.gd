extends Area2D

var traveled_distance = 0

func _physics_process(delta):
	const SPEED = 800
	const RANGE = 1200
	
	var direction = Vector2.RIGHT.rotated(rotation)
	global_position += direction * SPEED * delta
	
	traveled_distance += SPEED * delta
	if traveled_distance > RANGE:
		queue_free()

func _on_body_entered(body):
	queue_free()
	if body.is_in_group("enemies"):
		queue_free()
		if body.has_method("take_damage1"):
			body.take_damage1()
