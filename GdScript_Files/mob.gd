extends CharacterBody2D

var health = 20

@onready var player = get_node("/root/Scene/Player")
@onready var attack_range: Area2D = $AttackRange
@onready var timervalue: Timer = $Timer

var moving = false
var see = false

func _ready():
	pass

func _physics_process(_delta):
	if see and moving:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * 300
		move_and_slide()
	
	if velocity.x > 0:
		%Sprite2D.flip_h = true
	elif velocity.x < 0:
		%Sprite2D.flip_h = false
	
func _on_attack_range_body_entered(body):
	if body.is_in_group("player"):
		timervalue.start()
		moving = false

func _on_attack_range_body_exited(body):
	if body.is_in_group("player"):
		if see:
			moving = true
		timervalue.stop()

func _on_detection_range_body_entered(body):
	if body.is_in_group("player"):
		see = true
		moving = true

func _on_detection_range_body_exited(body):
	if body.is_in_group("player"):
		see = false
		moving = false

func _on_timer_timeout():
	if player.has_method("take_damage"):
		player.take_damage()
	timervalue.start()

func take_damage1():
	health -= 2
	if health <= 0:
		queue_free()

func take_damage2():
	health -= 4
	if health <= 0:
		queue_free()

func take_damage3():
	health -= 3
	if health <= 0:
		queue_free()

func take_damage4():
	health -= 8
	if health <= 0:
		queue_free()

func take_damage5():
	health -= 7
	if health <= 0:
		queue_free()

func take_damage6():
	health -= 11
	if health <= 0:
		queue_free()
