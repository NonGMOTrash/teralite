extends Node2D

enum TT {
	INPUT_VECTOR,
	BRAIN_TARGET,
	CURSOR,
	MANUAL
}

export(TT) var TARGETING = TT.INPUT_VECTOR
export var PARENT_BOND = true # for testing only, should be true in 99% of cases

var target_pos = Vector2.ZERO
var source
var reversed = false
var original_offset: Vector2
var original_texture: Texture

onready var sprite = $anchor/sprite
onready var anchor = $anchor
onready var animation = $AnimationPlayer

func _on_held_item_tree_entered():
	get_parent().components["held_item"] = self

func _ready():
	sprite.hframes = 1
	original_offset = sprite.offset
	
	if PARENT_BOND == false:
		source = self
	else:
		if not get_parent() is Node2D:
			source = self
			push_warning("held_item could not be bound to parent because it's not 2D")
		else:
			source = get_parent()
			if TARGETING == TT.INPUT_VECTOR or TARGETING == TT.BRAIN_TARGET and not source is Entity:
				push_error("held_item could not be bound to parent because it's not an Entity")
				source = self
			elif TARGETING == TT.BRAIN_TARGET and source.components["brain"] == null:
				push_error("held_item could not be bound to parent because it has no brain")
				source = self

func _process(delta):
	if TARGETING == TT.MANUAL or visible == false:
		return
	
	elif TARGETING == TT.INPUT_VECTOR:
		target_pos = source.global_position + source.input_vector * 10
	
	elif TARGETING == TT.BRAIN_TARGET:
		if TARGETING == TT.BRAIN_TARGET and get_parent().components["brain"] == null:
			push_error("can't use BRAIN_TARGET targetting because brain couldn't be found, switching to INPUT_VECTOR")
			TARGETING = TT.INPUT_VECTOR
		else:
			var closet_target = get_parent().components["brain"].closest_target().global_position
			if not closet_target is String:
				target_pos = closet_target.global_position
	
	elif TARGETING == TT.CURSOR:
		target_pos = get_global_mouse_position()
	
	rotation_degrees = rad2deg(global_position.direction_to(target_pos).angle())
	
	if (
		rotation_degrees < -90 or 
		rotation_degrees > 0 and rotation_degrees < 180 and 
		not rotation_degrees < 90 and rotation_degrees > 0
	):
		sprite.flip_v = true
		sprite.offset = original_offset * -1
	else:
		sprite.flip_v = false
		sprite.offset = original_offset
	
	if reversed == true:
		sprite.flip_v = not sprite.flip_v
		sprite.offset *= -1
	
	if rotation_degrees < 0:
		show_behind_parent = true
	else:
		show_behind_parent = false

func _on_AnimationPlayer_animation_started(_anim_name: String) -> void:
	original_texture = sprite.texture
