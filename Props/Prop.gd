extends Node2D
class_name Prop

var has_light: bool = false
var light: LightSource
var light_range: float = 0.0

func _ready() -> void:
	z_index += 201
	for child in get_children():
		if child is Light2D:
			light = child
			break
	
	if is_instance_valid(light):
		has_light = true
		light_range = light.texture_scale * 256
		light.CUSTOM_PROPERTIES = true
		light.shadow_enabled = false

var frame: int = 0
func _process(delta):
	if !has_light:
		return
	
	frame += 1
	if frame % 20 == 0:
		frame = 0
		if !is_instance_valid(refs.camera):
			return
		var cam_pos: Vector2 = refs.camera.global_position
		if abs(light.global_position.x - cam_pos.x) > 384 + light_range:
			light.visible = false
		elif abs(light.global_position.y - cam_pos.y) > 216 + light_range:
			light.visible = false
		else:
			light.visible = true
		
