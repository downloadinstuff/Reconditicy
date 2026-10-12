extends Node2D

var hoard1 = 0

func _ready():
	pass

func _physics_process(_delta):
	pass

func spawn_mob():
	var new_mob = preload("res://TSCN_Files/Mob.tscn").instantiate()
	%EnemyPath.progress_ratio = randf()
	new_mob.global_position = %EnemyPath.global_position
	add_child(new_mob)

func _on_timer_timeout():
	if hoard1 < 30:
		spawn_mob()
		hoard1 += 1

func loselives1():
	%Health3.visible = false
func loselives2():
	%Health2.visible = false
func loselives3():
	%Health1.visible = false
	
func fightstart():
	print("uh oh")
	%Timer.start()
