extends Sprite

enum IDs {
	NONE = -1, 
	MAPLE
}

export(IDs) var ID = IDs.MAPLE

#var camera: Camera2D
#
#func _ready() -> void:
#	region_rect.size = get_viewport_rect().size * 1.25
#	camera = global.nodes["camera"]
#	global_position = camera.global_position
#
#func _process(_delta) -> void:
#	if abs(global_position.x - camera.global_position.x) >= 16:
#		global_position.x = camera.global_position.x
#
#	if abs(global_position.y - camera.global_position.y) >= 16:
#		global_position.y = camera.global_position.y
