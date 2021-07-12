extends Entity

var navigation: TileMap
var cell_pos: Vector2

func _ready() -> void:
	navigation = refs.navigation.get_ref()
	
	if navigation == null:
		push_error("navigation == null")
		return
	
	cell_pos = navigation.world_to_map(global_position)
	cell_pos = Vector2(round(cell_pos.x), round(cell_pos.y))
	
# warning-ignore:narrowing_conversion
	navigation.set_cell(cell_pos.x, cell_pos.y, -1)

func death():
# warning-ignore:narrowing_conversion
	navigation.set_cell(cell_pos.x, cell_pos.y, 0)
	.death()
