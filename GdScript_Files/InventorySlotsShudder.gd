extends Panel

@export var shake_intensity: float = 0.8
@export var shake_speed: float = 5.0

@export var slot1: AnimatedSprite2D
@export var slot2: AnimatedSprite2D
@export var slot3: AnimatedSprite2D
@export var slot4: AnimatedSprite2D
@export var slot5: AnimatedSprite2D
@export var slot6: AnimatedSprite2D

var slots: Array = []
var origins: Array = []
var times: Array = []
var materials: Array = []
var hovered: Array = []
var hover_sizes: Array = []

func _ready() -> void:
	slots = [slot1, slot2, slot3, slot4, slot5, slot6]
	for slot in slots:
		origins.append(slot.position)
		times.append(randf_range(0.0, 100.0))
		hovered.append(false)

		var existing_material: ShaderMaterial = slot.material
		existing_material.set_shader_parameter("enabled", false)
		materials.append(existing_material)

		# approximate hover bounds from the sprite's current frame texture
		var tex_size: Vector2 = slot.sprite_frames.get_frame_texture(slot.animation, slot.frame).get_size()
		hover_sizes.append(tex_size * slot.scale + Vector2(24, 24) * 2.0)

func _process(delta: float) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()

	for i in slots.size():
		times[i] += delta * shake_speed
		slots[i].position = origins[i] + Vector2(
			sin(times[i] * 1.3) * shake_intensity,
			sin(times[i] * 1.7) * shake_intensity
		)

		var half_size: Vector2 = hover_sizes[i] / 2
		var slot_global_pos: Vector2 = slots[i].global_position
		var rect := Rect2(slot_global_pos - half_size, hover_sizes[i])

		var is_hovering: bool = rect.has_point(mouse_pos)
		if is_hovering and not hovered[i]:
			hovered[i] = true
			materials[i].set_shader_parameter("enabled", true)
		elif not is_hovering and hovered[i]:
			hovered[i] = false
			materials[i].set_shader_parameter("enabled", false)
