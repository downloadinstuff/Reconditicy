extends Panel

func _ready():
	var text = randi_range(0,36)
	var decay = randf()
	%RichTextLabel.text = str(text)
	%Timer.wait_time += (decay/2)
	%Timer.start()

func _on_timer_timeout():
	queue_free()
