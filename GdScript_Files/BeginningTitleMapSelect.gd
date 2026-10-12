extends MeshInstance3D

var is_dragging := false
var last_mouse_pos := Vector2.ZERO
@export var rotation_speed := 0.002


func _process(_delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	if direction.x < 0:
		rotate_y(-0.01)
	if direction.x > 0:
		rotate_y(0.01)
	if direction.y < 0:
		rotate_x(-0.01)
	if direction.y > 0:
		rotate_x(0.01)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Check if click is on this mesh
				var camera := get_viewport().get_camera_3d()
				var from := camera.project_ray_origin(event.position)
				var to := from + camera.project_ray_normal(event.position) * 1000.0
				
				var space := get_world_3d().direct_space_state
				var query := PhysicsRayQueryParameters3D.create(from, to)
				var result := space.intersect_ray(query)
				
				if result and result.collider.get_parent() == self:
					is_dragging = true
					last_mouse_pos = event.position
			else:
				is_dragging = false

	if event is InputEventMouseMotion and is_dragging:
		var delta : Vector2 = event.position - last_mouse_pos
		
		# Rotate around Y axis for horizontal mouse movement
		rotate_y(delta.x * rotation_speed)
		# Rotate around X axis for vertical mouse movement
		rotate_x(delta.y * rotation_speed)
		
		last_mouse_pos = event.position
