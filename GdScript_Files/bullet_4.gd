extends Area2D

var traveled_distance = 0
@export var rotate_time := 0.3

func get_closest_enemy() -> Node2D:
	var closest_enemy: Node2D = null
	var closest_distance := INF

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy is Node2D:
			continue

		var distance = global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	return closest_enemy

func _physics_process(delta):
	const SPEED = 500
	const RANGE = 4500
	
	var enemy = get_closest_enemy()
	if enemy:
		var target_angle = (enemy.global_position - global_position).angle()
	
		var t = delta / rotate_time
		rotation = lerp_angle(rotation, target_angle, t)
	
	var direction = Vector2.RIGHT.rotated(rotation)
	global_position += direction * SPEED * delta
	
	traveled_distance += SPEED * delta
	if traveled_distance > RANGE:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		queue_free()
		if body.has_method("take_damage4"):
			body.take_damage4()

func _on_timer_timeout():
	var particle = preload("res://TSCN_Files/bullet4effects.tscn").instantiate()
	particle.global_position = global_position + (-transform.x) * 10
	particle.global_position = global_position + (transform.y) * 6
	add_child(particle)
