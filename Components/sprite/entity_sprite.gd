extends Sprite

enum AFM { # auto flip modes
	OFF,
	MOVEMENT,
	TARGET
}

export(AFM) var auto_flip_mode = AFM.MOVEMENT
export var invert_flipping = false
export(int, -1, 2) var shadow_size = 1

var stored_offset

const SHADOW_ONE = preload("res://Components/sprite/shadow0.png")
const SHADOW_TWO = preload("res://Components/sprite/shadow1.png")
const SHADOW_THREE = preload("res://Components/sprite/shadow2.png")

onready var color_a = $color_overlay_a
onready var color_a_effect = $color_overlay_a/effects
onready var texture_a = $texture_overlay_a
onready var texture_a_effect = $texture_overlay_a/effects

onready var color_b = $color_overlay_b
onready var color_b_effect = $color_overlay_b/effects
onready var texture_b = $texture_overlay_b
onready var texture_b_effect = $texture_overlay_b/effects

onready var color_c = $color_overlay_c
onready var color_c_effect = $color_overlay_c/effects
onready var texture_c = $texture_overlay_c
onready var texture_c_effect = $texture_overlay_c/effects

func _on_entity_sprite_tree_entered():
	get_parent().components["entity_sprite"] = self

func _ready():
	stored_offset = offset
	shadow_size = clamp(shadow_size, 1, 3)
	var shadow_sprite
	match shadow_size:
		-1: shadow_sprite = null
		0: shadow_sprite = SHADOW_ONE
		1: shadow_sprite = SHADOW_TWO
		2: shadow_sprite = SHADOW_THREE
	$shadow.texture = shadow_sprite
	
	color_a.visible = true
	color_a_effect.play("off")
	color_a.texture = get_texture()
	color_a.hframes = hframes
	color_a.vframes = vframes
	
	color_b.visible = true
	color_b_effect.play("off")
	color_b.texture = get_texture()
	color_b.hframes = hframes
	color_b.vframes = vframes
	
	color_c.visible = true
	color_c_effect.play("off")
	color_c.texture = get_texture()
	color_c.hframes = hframes
	color_c.vframes = vframes
	
	connect("frame_changed", self, "animate_overlay")
	
	var stats = get_parent().components["stats"]
	if stats == null: return
	stats.connect("health_changed", self, "play_effect")

func _physics_process(_delta):
	# off
	if auto_flip_mode == AFM.OFF: return
	var parent = get_parent()
	
	# target
	if auto_flip_mode == AFM.TARGET:
		var brain = get_parent().components["brain"]
		if brain == null: return
		var closest_target = brain.closest_target()
		if brain != null and not closest_target is String:
			if global_position.direction_to(closest_target.global_position).x > 0:
				if invert_flipping == true: flip()
				else: unflip()
			elif global_position.direction_to(closest_target.global_position).x < 0:
				if invert_flipping == true: unflip()
				else: flip()
			return
	
	# movement
	if not "input_vector" in parent: return
	var input_vector = parent.input_vector
	if input_vector.x > 0:
		if invert_flipping == true: flip()
		else: unflip()
	elif input_vector.x < 0:
		if invert_flipping == true: unflip()
		else: flip()

func flip():
	flip_h = true
	offset = stored_offset * -1

func unflip():
	flip_h = false
	offset = stored_offset

func animate_overlay():
	color_a.hframes = hframes
	color_a.vframes = vframes
	color_a.flip_h = flip_h
	color_a.frame = frame

	color_b.hframes = hframes
	color_b.vframes = vframes
	color_b.flip_h = flip_h
	color_b.frame = frame

	color_c.hframes = hframes
	color_c.vframes = vframes
	color_c.flip_h = flip_h
	color_c.frame = frame

func play_effect(_type, result, _net):
	var color_effect: AnimationPlayer = color_a_effect
	var texture_effect: AnimationPlayer = texture_a_effect
	if color_a_effect.is_playing() == true or texture_a_effect.is_playing() == true: 
		color_effect = color_b_effect
		texture_effect = texture_b_effect
		if color_b_effect.is_playing() == true or texture_b_effect.is_playing() == true:
			color_effect = color_c_effect
			texture_effect = texture_c_effect
	
	match result:
		"hurt": color_effect.play("hurt")
		"block": color_effect.play("block")
		"heal": color_effect.play("heal")
		"poison": color_effect.play("poison")
		"bleed": color_effect.play("bleed")
		"burn": 
			color_effect.play("burn")
			texture_effect.play("fire")
