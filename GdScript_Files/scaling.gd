extends AnimatedSprite2D

@export var scroll_speed_x: float = 0.3
@export var scroll_speed_y: float = 0.3
@export var noise_scale: float = 5.0
@export var min_scale: float = 0.7
@export var max_scale: float = 1.3

var uv_offset: Vector2
var current_anim: String = ""

func _ready():
	uv_offset = Vector2(randf() * 100.0, randf() * 100.0)

func _process(_delta: float) -> void:
	var noise_value := _sample_noise(Vector2(0.5, 0.5))
	var target_scale: float = lerp(min_scale, max_scale, noise_value)
	#var new_snapped: float = round(target_scale * 10.0) / 10.0
	
	# Build the animation name e.g. "0.7", "1.0", "1.3"
	var anim_name := "%.1f" % target_scale
	
	# Only switch if it changed, to avoid restarting the animation every frame
	if anim_name != current_anim:
		current_anim = anim_name
		play(anim_name)

# Everything below is unchanged
func _hash2(p: Vector2) -> Vector2:
	var x := fmod(sin(p.dot(Vector2(127.1, 311.7))) * 43758.5453123, 1.0)
	var y := fmod(sin(p.dot(Vector2(269.5, 183.3))) * 43758.5453123, 1.0)
	return Vector2(x, y) * 2.0 - Vector2.ONE

func _noise(p: Vector2) -> float:
	var i := Vector2(floor(p.x), floor(p.y))
	var f := Vector2(fmod(p.x, 1.0), fmod(p.y, 1.0))
	if f.x < 0: f.x += 1.0
	if f.y < 0: f.y += 1.0
	var u := f * f * (Vector2(3,3) - f * 2.0)
	var a := _hash2(i + Vector2(0,0)).dot(f - Vector2(0,0))
	var b := _hash2(i + Vector2(1,0)).dot(f - Vector2(1,0))
	var c := _hash2(i + Vector2(0,1)).dot(f - Vector2(0,1))
	var d := _hash2(i + Vector2(1,1)).dot(f - Vector2(1,1))
	return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y)

func _sample_noise(uv: Vector2) -> float:
	var t := Time.get_ticks_msec() / 1000.0
	var p := (uv + uv_offset) * noise_scale + Vector2(t * scroll_speed_x, t * scroll_speed_y)
	var n := 0.0
	n += 0.500 * _noise(p)
	n += 0.250 * _noise(p * 2.0)
	n += 0.125 * _noise(p * 4.0)
	n += 0.125 * _noise(p * 8.0)
	return clamp(n * 0.5 + 0.5, 0.0, 1.0)
	
