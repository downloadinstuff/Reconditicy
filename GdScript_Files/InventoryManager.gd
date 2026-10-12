extends Node2D

var cursor_texture = load("res://Sprites/cursoralt2.png")
var cursor_texture2 = load("res://Sprites/cursoralt3.png")
@export var animation: AnimatedSprite2D
@export var cam: Camera2D
@export var panel: Panel
@export var parent: CharacterBody2D
@export var angle: Sprite2D
@export var white_wobble: ColorRect

var entered = false

func _ready():
	entered = false
	#Input.set_custom_mouse_cursor(cursor_texture)
	panel.scale = Vector2(0.01,0.01)

func _process(_delta):
	if Input.is_action_just_pressed("inventory"):
		if !entered and $InventoryCooldown.time_left == 0:
			$InventoryCooldown.start(3.0)
			InventoryEnhance()
			parent.yes_allowinventory()
			
		elif entered and $InventoryCooldown.time_left == 0:
			$InventoryCooldown.start(2.1)
			InventoryExit()

	#if Input.is_action_pressed("shoot"):
		#Input.set_custom_mouse_cursor(cursor_texture2)
	#else:
		#Input.set_custom_mouse_cursor(cursor_texture)

func InventoryExit():
	animation.animation = "InventoryOpen"
	animation.frame = 14
	
	var tween = create_tween()
	
	tween.tween_property(
	white_wobble, "modulate:a", 1, 0.2)\
	.set_ease(Tween.EASE_IN_OUT)\
	.set_trans(Tween.TRANS_QUAD)
	
	tween.set_parallel(true)
	
	tween.tween_property(
	panel, "scale", Vector2(0.01,0.01), 0.6)\
	.set_ease(Tween.EASE_IN_OUT)\
	.set_trans(Tween.TRANS_QUAD)
	
	await get_tree().create_timer(0.6).timeout
	
	cam.global_position = parent.global_position
	cam.zoom = Vector2(300, 300)
	cam.offset = Vector2(-6,12)
	
	var tween2 = create_tween()
	
	tween2.tween_property(
	cam, "zoom", Vector2(1, 1), 1)\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_QUINT)
	
	tween2.set_parallel(true)
	
	tween2.tween_property(
	cam, "offset", Vector2(0, 0), 1.1)\
	.set_ease(Tween.EASE_IN_OUT)\
	.set_trans(Tween.TRANS_QUAD)
	
	tween2.tween_property(
	angle, "modulate:a", 1, 0.6)\
	.set_ease(Tween.EASE_IN_OUT)\
	.set_trans(Tween.TRANS_QUAD)
	
	await get_tree().create_timer(0.6).timeout
	
	animation.play_backwards("InventoryOpen")
	panel.visible = false
	
	await get_tree().create_timer(0.5).timeout

	parent.enablecam()

func InventoryEnhance():
	var tween = create_tween()
	animation.flip_h = false
	parent.disablecam()
	
	tween.tween_property(
	cam, "zoom", Vector2(10, 10), 1)\
	.set_ease(Tween.EASE_IN_OUT)\
	.set_trans(Tween.TRANS_QUAD)
	tween.set_parallel(true)
	
	tween.tween_property(
	angle, "modulate:a", 0, 0.6)\
	.set_ease(Tween.EASE_IN_OUT)\
	.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(
	cam, "position", Vector2(0,0), 1.1)\
	.set_ease(Tween.EASE_IN_OUT)\
	.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(
	cam, "offset", Vector2(-6, 12), 1.1)\
	.set_ease(Tween.EASE_IN_OUT)\
	.set_trans(Tween.TRANS_QUAD)
	
	tween.set_parallel(false)
	tween.tween_property(
	cam, "zoom", Vector2(300, 300), 0.7)\
	.set_ease(Tween.EASE_IN)\
	.set_trans(Tween.TRANS_QUINT)
	
	await get_tree().create_timer(1.9).timeout
	cam.global_position = global_position
	cam.offset = Vector2(0,0)
	cam.zoom = Vector2(0.5, 0.5)
	#cam.zoom = Vector2(0.08, 0.08)
	panel.visible = true
	
	var tween2 = create_tween()
	tween2.tween_property(
	panel, "scale", Vector2(1,1), 0.6)\
	.set_ease(Tween.EASE_IN_OUT)\
	.set_trans(Tween.TRANS_QUAD)
	
	tween2.tween_property(
	white_wobble, "modulate:a", 0.8, 0.2)\
	.set_ease(Tween.EASE_IN_OUT)\
	.set_trans(Tween.TRANS_QUAD)



func _on_inventory_cooldown_timeout():
	if entered:
		entered = false
		parent.yes_allowaction()
	elif !entered:
		entered = true
