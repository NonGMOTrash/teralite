extends Node2D
class_name Effect

export(NodePath) var sprite = null
export(bool) var flip_h = false
export(bool) var random_flip_h = false
export(bool) var flip_v = false
export(bool) var random_flip_v = false
export(NodePath) var animation_player = null
export(Animation) var custom_animation
export(float, -64, 64) var effect_speed = 1.0
export(float, -32, 32) var effect_speed_randomness = 0.02

onready var default_sprite = preload("res://Entities/crate/crate.png")

func _ready():
	effect_speed += rand_range(-effect_speed_randomness, effect_speed_randomness)
	if random_flip_h == true:
		flip_h = (randi() % 2 == 0)
	if random_flip_v == true:
		flip_v = (randi() % 2 == 0)
	
	if animation_player == null:
		push_warning("animation_player == null")
	elif animation_player:
		animation_player = get_node(animation_player)
		animation_player.playback_speed *= effect_speed
		if custom_animation != null:
			animation_player.play(custom_animation)
	
	if sprite == null:
		push_warning("sprite == null")
	else:
		sprite = get_node_or_null(sprite)
		if sprite == null:
			push_warning("could not find sprite node")
		elif sprite.texture == null:
			push_error(get_name()+" was not given a texture")
			sprite.texture = default_sprite
			sprite.flip_h = flip_h
			sprite.flip_v = flip_v
	
	# PROBLEM_NOTE: would probably be better to do this with the GUI instead of code
	animation_player.connect("animation_finished", self, "delete_self")

# have to do this because animation_finished has 1 argument and queue_free() only takes 0 arguments
func delete_self(_anim_name: String):
	queue_free()

# old code for the speed change based on duration value:

# if abs(effect_duration) < 1.0:
#	animation_player.playback_speed = 1.0 + abs(effect_duration)
# elif abs(effect_duration) > 1.0:
#	animation_player.playback_speed = 1.0 / abs(effect_duration)
# 
#	if effect_duration < 0: animation_player.playback_speed *= -1
