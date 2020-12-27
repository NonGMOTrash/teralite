extends Node2D
class_name Effect

export(NodePath) var sprite = null
export(NodePath) var animation_player = null
export(Animation) var custom_animation
export(float, -64, 64) var effect_speed = 1.0

onready var default_sprite = preload("res://Entities/crate/crate.png")

func _ready():
	if animation_player == null:
		global.var_debug_msg(self, 0, "animation_player")
	elif animation_player:
		animation_player = get_node(animation_player)
		animation_player.playback_speed *= effect_speed
		if custom_animation != null:
			animation_player.play(custom_animation)
	
	if sprite == null:
		global.var_debug_msg(self, 0, "sprite")
	else:
		sprite = get_node_or_null(sprite)
		if sprite == null:
			global.debug_msg(self, 0, "could not find sprite node")
		elif sprite.texture == null:
			global.debug_msg(self, 1, "sprite was not given a texture, defaulting to crate.png")
			sprite.texture = default_sprite

# old code for the speed change based on duration value
# if abs(effect_duration) < 1.0:
#	animation_player.playback_speed = 1.0 + abs(effect_duration)
# elif abs(effect_duration) > 1.0:
#	animation_player.playback_speed = 1.0 / abs(effect_duration)
# 
#	if effect_duration < 0: animation_player.playback_speed *= -1
