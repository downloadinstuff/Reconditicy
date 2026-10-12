extends Area2D

var stop = true

func _on_body_entered(body):
	if body.is_in_group("player") and stop:
		body.get_parent().fightstart()
		stop = false
