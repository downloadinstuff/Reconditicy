extends Node2D

@export var wave_delay: float = 0.3

# The order of circle names following path from circle 1 (clockwise)
var path_from_1: Array = [
	"1","2","3","4","5","6","7","8","9","10","11","12","13",
	"14","15","16","17","18","19"
]

# The order of circle names following path from circle 19 (counter-clockwise)
var path_from_19: Array = [
	"20","21","22","23","24","25","26","27","28","29","30",
	"31","32","33","34","35","36"
]

var circles: Dictionary = {}  # name -> AnimatedSprite2D
var circle_delays: Dictionary = {}  # name -> delay

func _ready():
	wave_delay = TAU / 36.0

	for child in get_children():
		if child is AnimatedSprite2D:
			circles[str(child.name)] = child
	
	for idx in range(path_from_1.size()):
		var thing_name: String = path_from_1[idx]
		circle_delays[thing_name] = idx * wave_delay

	var offset: float = circle_delays["19"]
	
	for idx in range(path_from_19.size()):
		var thing_name: String = path_from_19[idx]
		var delay: float = offset + (idx * wave_delay)
		if thing_name in circle_delays:
			circle_delays[thing_name] = min(circle_delays[thing_name], delay)
		else:
			circle_delays[thing_name] = delay

	var total_circles: int = path_from_1.size() + path_from_19.size()
	circle_delays["36"] = (total_circles - 1) * wave_delay
	
	
func _process(_delta: float) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	
	for circle_name in circles:
		var circle := circles[circle_name] as AnimatedSprite2D
		var delay: float = circle_delays.get(circle_name, 0.0)
		var local_t := t - delay
		
		var sine_value := (sin(local_t) + 1.0) / 2.0
		var target_scale: float = lerp(0.7, 1.3, sine_value)
		var target_snapped: float = round(target_scale * 10.0) / 10.0
		
		var anim_name := "%.1f" % target_snapped
		if circle.animation != anim_name:
			circle.play(anim_name)
