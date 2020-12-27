extends Node2D

var Astar = AStar2D.new()
onready var tilemap = get_parent()
onready var half_cell_size = tilemap.cell_size / 2
onready var used_rect = tilemap.get_used_rect()

func nav_map():
	var tiles = tilemap.tiles
	
	add_path_tiles(tiles)
	
	connect_path_tiles(tiles)

func add_path_tiles(tiles: Array):
	for tile in tiles:
		var id = get_id(tile)
		Astar.add_point(id, tile)

func connect_path_tiles(tiles: Array):
	for tile in tiles:
		var id = get_id(tile)
		for x in range(3):
			for y in range(3):
				var target = tile + Vector2(x-1, y-1)
				var target_id = get_id(target)
				
				if tile == target or not Astar.has_point(target_id):
					continue
				
				Astar.connect_points(id, target_id, true)

func get_id(point: Vector2):
	var x = point.x - used_rect.x
	var y = point.y - used_rect.y
	return x + y * used_rect.x

func get_new_path(start: Vector2, end: Vector2):
	var start_tile = tilemap.world_to_map(start)
	var end_tile = tilemap.world_to_map(end)
	var start_id = get_id(start_tile)
	var end_id = get_id(end_tile)
	
	if not Astar.has_point(start_id) or not Astar.has_point(end_id): return null
	
	var path_map = Astar.get_point_path(start_id, end_id)
	
	var path_world = []
	for point in path_map:
		var point_world = tilemap.map_to_world(point) + half_cell_size
