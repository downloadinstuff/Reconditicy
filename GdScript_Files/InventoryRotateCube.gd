extends MeshInstance3D

var smoothness = 3.0

func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = Vector2(get_viewport().size)

	var offset = mouse_pos - viewport_size / 2

	# Normalize to screen size
	var normalized_x = offset.x / (viewport_size.x / 2)
	var normalized_y = offset.y / (viewport_size.y / 2)

	# Smooth resistance curve
	rotation.y = tanh(normalized_x * 0.6) * deg_to_rad(30)
	rotation.x = tanh(normalized_y * 0.6) * deg_to_rad(20)
	
	self.scale = self.scale.lerp(
			Vector3(1,1,1),
			smoothness * delta)
	
	if Input.is_action_just_pressed("shoot"):
		scale = Vector3(1.1, 1.1, 1.1)
		
	
