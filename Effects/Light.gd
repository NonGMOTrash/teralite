extends Light2D
class_name LightSource
# the only reason i can't use Light2D's is because i can't have those auto adjust (easily) based
# on the game options

const LIGHT_TEXTURE := preload("res://Effects/light.png")

export var CUSTOM_PROPERTIES := false

func _ready() -> void:
	if CUSTOM_PROPERTIES == true:
		return
	
	if texture == null:
		texture = LIGHT_TEXTURE
	
	shadow_buffer_size = 512
	shadow_enabled = true
