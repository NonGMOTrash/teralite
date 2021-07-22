extends Sprite

enum AFM { # auto flip modes
	OFF,
	MOVEMENT,
	TARGET
}

export(AFM) var auto_flip_mode = AFM.MOVEMENT
export var invert_flipping = false
export(int, -1, 2) var shadow_size = 1
export(Texture) var back_texture: Texture

var original_offset: Vector2

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

onready var entity := get_parent() as Entity

onready var front_texture: Texture = texture

func _on_entity_sprite_tree_entered():
	get_parent().components["entity_sprite"] = self

func _ready():
	original_offset = offset
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
	stats.connect("health_changed", self, "_on_health_changed")

func _process(_delta):
	match auto_flip_mode:
		AFM.OFF:
			pass
		
		AFM.TARGET:
			var brain: Node2D = entity.components["brain"]
			if brain != null and brain.targets.size() > 0:
				var closest_target = brain.get_closest_target()
				
				if global_position.direction_to(closest_target.global_position).x > 0:
					if invert_flipping == true: h_flip()
					else: h_unflip()
				elif global_position.direction_to(closest_target.global_position).x < 0:
					if invert_flipping == true: h_unflip()
					else: h_flip()
				
				if global_position.direction_to(closest_target.global_position).y > 0:
					if invert_flipping == true: v_flip()
					else: v_unflip()
				elif global_position.direction_to(closest_target.global_position).y < 0:
					if invert_flipping == true: v_unflip()
					else: v_flip()
		
		AFM.MOVEMENT:
			var input_vector = entity.input_vector
			
			if input_vector.x > 0:
				if invert_flipping == true: h_flip()
				else: h_unflip()
			elif input_vector.x < 0:
				if invert_flipping == true: h_unflip()
				else: h_flip()
			
			if input_vector.y > 0:
				if invert_flipping == true: v_flip()
				else: v_unflip()
			elif input_vector.y < 0:
				if invert_flipping == true: v_unflip()
				else: v_flip()

func h_flip():
	flip_h = true
	offset = original_offset * -1

func h_unflip():
	flip_h = false
	offset = original_offset

func v_flip():
	if texture != back_texture and back_texture != null:
		texture = back_texture

func v_unflip():
	if texture != front_texture:
		texture = front_texture

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

func _on_health_changed(_type, result, _net):
	play_effect(result)

func play_effect(effect: String, speed:=1.0):
	animate_overlay()
	
	var color_effect: AnimationPlayer = color_a_effect
	var texture_effect: AnimationPlayer = texture_a_effect
	if color_a_effect.is_playing() == true or texture_a_effect.is_playing() == true: 
		color_effect = color_b_effect
		texture_effect = texture_b_effect
		if color_b_effect.is_playing() == true or texture_b_effect.is_playing() == true:
			color_effect = color_c_effect
			texture_effect = texture_c_effect
	
	match effect:
		"hurt": color_effect.play("hurt", -1, speed)
		"block": color_effect.play("block", -1, speed)
		"heal": color_effect.play("heal", -1, speed)
		"poison": color_effect.play("poison", -1, speed)
		"bleed": color_effect.play("bleed", -1, speed)
		"burn": 
			color_effect.play("burn", -1, speed)
			texture_effect.play("fire", -1, speed)
		"invincibility": color_a_effect.play("invincibility", -1, speed)
		_: push_error("'%s' is not a valid effect (entity_sprite.gd)" % effect)
