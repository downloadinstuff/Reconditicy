extends Area2D

@onready var hit_delay_timer: Timer = $HitDelay
@onready var life_timer: Timer = $LifeTime
@onready var collision: CollisionShape2D = $CollisionShape2D
var allowhit = false

func _ready():
	hit_delay_timer.start()
	life_timer.start()
	collision.disabled = true

func _physics_process(delta):
	const SPEED = 100
	
	var direction = Vector2.RIGHT.rotated(rotation)
	if !allowhit:
		global_position += direction * SPEED * delta

func _on_timer_timeout():
	allowhit = true
	collision.disabled = false

func _on_life_time_timeout():
	queue_free()

func _on_body_entered(body):
	if body.has_method("take_damage6") and allowhit:
		body.take_damage6()
