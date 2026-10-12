extends Sprite2D

func _physics_process(_delta):
	var mousepos = get_global_mouse_position()
	look_at(mousepos)
