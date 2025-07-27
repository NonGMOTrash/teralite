extends Node2D

enum TT {
	INPUT_VECTOR,
	BRAIN_TARGET,
	CURSOR,
	MANUAL
}

export(TT) var TARGETING = TT.INPUT_VECTOR
export var PARENT_BOND = true # for testing only, should be true in 99% of cases
export var DEFAULT_HFRAMES = 1
export var DEFAULT_VFRAMES = 1

var target_pos := Vector2.ZERO
var source
var reversed: bool = false
var original_offset: Vector2
var original_texture: Texture

onready var entity = get_parent()
onready var sprite = $anchor/sprite
onready var anchor = $anchor
onready var animation: AnimationPlayer = $AnimationPlayer
onready var light: LightSource = $anchor/light

signal cant_rotate

func _on_held_item_tree_entered():
	get_parent().components["held_item"] = self

func _ready():
	sprite.hframes = DEFAULT_HFRAMES
	sprite.vframes = DEFAULT_VFRAMES
	sprite.frame = 0
	sprite.frame_coords = Vector2.ZERO
	original_offset = sprite.offset
	#original_rotation
	
	if PARENT_BOND == false:
		source = self
	else:
		if not entity is Node2D:
			source = self
			push_error("held_item could not be bound to parent because parent isn't 2D")
			OS.alert("held_item could not be bound to parent because parent isn't 2D","error")
		else:
			source = entity

func _physics_process(_delta: float) -> void:
	if TARGETING != TT.MANUAL and visible:
		if TARGETING == TT.CURSOR:
			target_pos = global.get_look_pos()
		
		elif TARGETING == TT.INPUT_VECTOR or source.components["brain"].targets.size() == 0:
			if source.input_vector != Vector2.ZERO:
				target_pos = source.global_position + source.input_vector * 10
		
		elif TARGETING == TT.BRAIN_TARGET:
			if TARGETING == TT.BRAIN_TARGET and entity.components["brain"] == null:
				push_error("can't use BRAIN_TARGET without a brain, switching to INPUT_VECTOR")
				TARGETING = TT.INPUT_VECTOR
			else:
				var closet_target = entity.components["brain"].get_closest_target()
				if closet_target is Entity:
					target_pos = closet_target.global_position
				else:
					emit_signal("cant_rotate")
		
		rotation_degrees = rad2deg(global_position.direction_to(target_pos).angle())
	
	if facing_left():
		sprite.flip_v = true
		sprite.offset = original_offset * -1
	else:
		sprite.flip_v = false
		sprite.offset = original_offset
	
	if reversed == true:
		sprite.flip_v = not sprite.flip_v
		sprite.offset *= -1
	
	show_behind_parent = (rotation_degrees < 0) as bool
	
	if light.enabled && global.settings["shadows"]:
		var ss := get_world_2d().direct_space_state
		var raycast = ss.intersect_point(sprite.global_position, 1, [], 1)
		if raycast:
			light.visible = false
		else:
			light.visible = true

func _on_AnimationPlayer_animation_started(_anim_name: String) -> void:
	original_texture = sprite.texture

func facing_left() -> bool:
	return ( # PROBLEM_NOTE: maybe i can do this simplier, but it works
		rotation_degrees < -90 or
		rotation_degrees > 0 and rotation_degrees < 180 and
		not rotation_degrees < 90 and rotation_degrees > 0
	)
