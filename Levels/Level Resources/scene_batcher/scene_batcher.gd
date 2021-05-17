extends TileMap

export var placement_offset: Vector2 = Vector2.ZERO

#onready var ysort = $YSort

onready var ysort = get_parent()

onready var data = {}

func set_data():
	pass

func _ready(): # converts tiles to their respective scenes
	set_data()
	if data == {}:
		push_error("data was not set")
		return
	
	# replaces the number with the cells of that id
	for i in data.keys().size():
		if data[data.keys()[i]] is int:
			data[data.keys()[i]] = get_used_cells_by_id(data.values()[i])
	
	for i in data.keys().size():
		if data.values()[i].size() > 0:
			convert_tile(data.values()[i], data.keys()[i])
	
	clear() #remove all the tiles

func convert_tile(tiles, thingName): # deletes the tile and places the entity
	var tilePos
	for i in range(0, tiles.size()):
		var newEntity = res.aquire(thingName).instance()
		tilePos = map_to_world(tiles[i]) + placement_offset
		newEntity.set_position(Vector2(tilePos.x + 8, tilePos.y + 8))
		ysort.call_deferred("add_child", newEntity)
