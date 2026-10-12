extends CharacterBody2D

@onready var camera: Camera2D = $Camera2D
@export var look_ahead_distance := 10
@export var camera_smooth_speed := 7.0

@export var health = 3
@export var speed = 300
var acceleration = 1700
var friction = 1200
var recoil_strength = 10
var camerafollow = true
var direction = null
var allowaction = true
var allowroll = true
var allowshoot = false
var allowmove = true
var rate = -1.8


var is_inventory = false
var is_rolling = false
var is_shooting = false

var animations = []

var attackcooldown = 0.2

enum State { IDLE, RUN, ROLL, SHOOT, RUNSHOOT_FORWARD, RUNSHOOT_BACKWARD, INVENTORY}
var current_state: State = State.IDLE
var previous_state: State = State.IDLE


func _ready():
	AutoScripts1.dialogue_finished.connect(yes_allowaction)
	animations = get_tree().get_nodes_in_group("animations")
	allowaction = true
	allowshoot = false
	if _another_camera_exists():
		camera.enabled = false

func _physics_process(delta):
	if allowaction and allowmove:
		direction = Input.get_vector("left", "right", "up", "down")
	else:
		direction = null
		
	if direction != null:
		if direction.x < 0:
			velocity.x = move_toward(velocity.x, -speed, acceleration * delta)
		if direction.x > 0:
			velocity.x = move_toward(velocity.x, speed, acceleration * delta)
		if direction.y > 0:
			velocity.y = move_toward(velocity.y, speed, acceleration * delta)
		if direction.y < 0:
			velocity.y = move_toward(velocity.y, -speed, acceleration * delta)
		
		if direction.x == 0:
			velocity.x = move_toward(velocity.x, 0, friction * delta)
		if direction.y == 0:
			velocity.y = move_toward(velocity.y, 0, friction * delta)

	if direction == null:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.y = move_toward(velocity.y, 0, friction * delta)

	move_and_slide()
	

	current_state = get_next_state()
	if current_state != previous_state:
		enter_state(current_state)
		previous_state = current_state
	
	
	if allowaction and !allowroll:
		rate += 0.2
		animations[0].global_position.y += rate
	else:
		animations[0].global_position.y = global_position.y


	if allowaction:
		var cursor_texture = load("res://Sprites/Cursor2.png")
		var cursor_texture2 = load("res://Sprites/Cursor3.png")
		if Input.is_action_pressed("left"):
			animations[0].flip_h = false
			animations[1].flip_h = false
		if Input.is_action_pressed("right"):
			animations[0].flip_h = true
			animations[1].flip_h = true
		
		#if Input.is_action_just_pressed("test"):
			#if not AutoScripts1.active:
				#AutoScripts1.start_dialogue_by_name("cowboy_intro")
			#else:
				#AutoScripts1.advance()
		#if Input.is_action_just_pressed("test2"):
			#AutoScripts1.start_auto_dialogue_by_name("cowboy_intro")
	
		if Input.is_action_just_pressed("test"):
			Input.set_custom_mouse_cursor(cursor_texture)
		if Input.is_action_just_pressed("test2"):
			Input.set_custom_mouse_cursor(cursor_texture2)

		if Input.is_action_pressed("roll") and allowroll and velocity.length() != 0:
			rate = -1.8
			keeprolling()
		
		if Input.is_action_pressed("shoot") and allowshoot and !is_inventory and allowaction\
		 or Input.is_action_pressed("ui_accept") and allowshoot and !is_inventory and allowaction:
			if velocity.length() == 0:
				var angle = get_global_mouse_position()
				if angle.x < global_position.x:
					animations[0].flip_h = false
					animations[1].flip_h = false
				if angle.x > global_position.x:
					animations[0].flip_h = true
					animations[1].flip_h = true
			
			if abs(velocity.x) + abs(velocity.y) < 600 and velocity.length() != 0:
				var mouse_angle = get_angle_to(get_global_mouse_position())
				var recoil_direction = Vector2.RIGHT.rotated(mouse_angle) * -1
				velocity += recoil_direction * recoil_strength
				
			var attacknum = randi_range(1,6)
			allowshoot = false
			$AttackCooldown.start(attackcooldown + 0.01)
			is_shooting = true
			await get_tree().create_timer(attackcooldown).timeout
			is_shooting = false
			shoot(attacknum)
			

	if camerafollow:
		var dir = velocity.normalized()
		var target_offset = Vector2.ZERO
		if dir.length() > 0:
			target_offset = dir * look_ahead_distance
		camera.position = camera.position.lerp(
			target_offset,
			camera_smooth_speed * delta)


func get_next_state() -> State:
	if is_rolling:
		return State.ROLL
	if is_inventory:
		return State.INVENTORY
	if velocity.length() >= 20 and is_shooting:
		var cursor = get_global_mouse_position()
		var to_cursor_x = cursor.x - global_position.x
		var facing = 1.0 if $Animations.flip_h else -1.0
		if to_cursor_x * facing >= 0:
			return State.RUNSHOOT_FORWARD
		else:
			return State.RUNSHOOT_BACKWARD
	if velocity.length() >= 20:
		return State.RUN
	if is_shooting:
		return State.SHOOT
	return State.IDLE


func enter_state(state: State):
	match state:
		State.IDLE:
			play_animation("Idle")
		State.RUN:
			play_animation("Run")
		State.ROLL:
			play_animation("Roll")
		State.SHOOT:
			play_animation("Shoot")
		State.RUNSHOOT_FORWARD:
			var current_frame = $Animations2.get_frame()
			var current_progress = $Animations2.get_frame_progress()
			$Animations2.play("RunShoot")
			$Animations2.set_frame_and_progress(current_frame, current_progress)
			$Animations.play("RunShootForward")
		State.RUNSHOOT_BACKWARD:
			var current_frame = $Animations2.get_frame()
			var current_progress = $Animations2.get_frame_progress()
			$Animations2.play("RunShoot")
			$Animations2.set_frame_and_progress(current_frame, current_progress)
			$Animations.play("RunShootBackward")
		State.INVENTORY:
			play_animation("InventoryOpen")

func keeprolling():
	is_rolling = true
	allowroll = false
	allowshoot = false
	speed = 450
	await get_tree().create_timer(0.3).timeout
	is_rolling = false
	speed = 300
	allowroll = true
	allowshoot = true

func _another_camera_exists() -> bool:
	var all_cameras := _find_all_cameras(get_tree().root)
	for cam in all_cameras:
		if cam != camera:
			return true
	return false
func _find_all_cameras(node: Node) -> Array[Camera2D]:
	var result: Array[Camera2D] = []
	if node is Camera2D:
		result.append(node)
	for child in node.get_children():
		result.append_array(_find_all_cameras(child))
	return result

func yes_allowaction():
	allowaction = true
	is_inventory = false
func no_allowaction():
	allowaction = false
	
func yes_allowinventory():
	is_inventory = true
	

func play_animation(anim):
	for animation in get_tree().get_nodes_in_group("animations"):
		animation.play(anim)

func shoot(attack):
	if attack == 1:
		const BULLET1 = preload("res://TSCN_Files/bullet1.tscn")
		var new_bullet1 = BULLET1.instantiate()
		new_bullet1.global_position = %Angle.global_position
		new_bullet1.global_rotation = %Angle.global_rotation
		%Angle.add_child(new_bullet1)
	if attack == 2:
		const BULLET2 = preload("res://TSCN_Files/bullet2.tscn")
		var new_bullet2 = BULLET2.instantiate()
		new_bullet2.global_position = %Angle.global_position
		new_bullet2.global_rotation = %Angle.global_rotation
		%Angle.add_child(new_bullet2)
	if attack == 3:
		const BULLET3 = preload("res://TSCN_Files/bullet3.tscn")
		var offsets = [-5, 0, 5]
		for offset in offsets:
			var new_bullet3 = BULLET3.instantiate()
			new_bullet3.global_position = %Angle.global_position
			new_bullet3.global_rotation = %Angle.global_rotation + deg_to_rad(offset)
			%Angle.add_child(new_bullet3)
	if attack == 4:
		const BULLET4 = preload("res://TSCN_Files/bullet4.tscn")
		var new_bullet4 = BULLET4.instantiate()
		new_bullet4.global_position = %Angle.global_position
		new_bullet4.global_rotation = %Angle.global_rotation
		%Angle.add_child(new_bullet4)
	if attack == 5:
		const BULLET5 = preload("res://TSCN_Files/bullet5.tscn")
		var offsets = [-10, -5, 0, 5, 10]
		for offset in offsets:
			var new_bullet5 = BULLET5.instantiate()
			new_bullet5.global_position = %Angle.global_position
			new_bullet5.global_rotation = %Angle.global_rotation + deg_to_rad(offset)
			%Angle.add_child(new_bullet5)
		
	if attack == 6:
		const BULLET6 = preload("res://TSCN_Files/bullet6.tscn")
		var new_bullet6 = BULLET6.instantiate()
		new_bullet6.global_position = %Angle.global_position
		new_bullet6.global_rotation = %Angle.global_rotation
		%Angle.add_child(new_bullet6)


func take_damage():
	if health <= 0:
		return
	
	health -= 1
	
	var parent = get_parent()

	if health == 2 and parent.has_method("loselives1"):
		parent.loselives1()
	elif health == 1 and parent.has_method("loselives2"):
		parent.loselives2()
	elif health == 0 and parent.has_method("loselives3"):
		parent.loselives3()


func _on_attack_cooldown_timeout():
	allowshoot = true
