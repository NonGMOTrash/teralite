extends TileMap
# thanks LukeNaz
# https://stackoverflow.com/questions/53685183/navigation-tilemaps-without-placing-walkable-tiles-manually


# Empty/invisible tile marked as completely walkable. The ID of the tile should correspond
# to the order in which it was created in the tileset editor.
const _nav_tile_id = 10

func _ready() -> void:
	
	# for doing the entire level
	#var bounds_min = Vector2(0, 0)
	#var bounds_max = Vector2(63, 63)
	var bounds_min = get_used_rect().position - Vector2(5, 5)
	var bounds_max = get_used_rect().end + Vector2(5, 5)
	
	# Replace all empty tiles with the provided navigation tile
	for x in range(bounds_min.x, bounds_max.x):
		for y in range(bounds_min.y, bounds_max.y):
			if get_cell(x, y) == -1:
				set_cell(x, y, _nav_tile_id)
	
	# Force the navigation mesh to update immediately
	update_dirty_quadrants()
