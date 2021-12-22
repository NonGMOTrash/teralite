extends "res://Levels/Level Resources/scene_batcher/scene_batcher.gd"

func set_data():
	data = {
		"maple_tree1": get_used_cells_by_id(0),
		"maple_tree2": get_used_cells_by_id(1),
		"maple_tree3": get_used_cells_by_id(2),
		"tree_stump": get_used_cells_by_id(3),
		"banner": get_used_cells_by_id(4),
		"flag": get_used_cells_by_id(5),
		"torch": get_used_cells_by_id(6),
		"rock": get_used_cells_by_id(7),
		"rock2": get_used_cells_by_id(8),
		"stalagmite": get_used_cells_by_id(9),
		"stalagmite2": get_used_cells_by_id(10),
		"water_stalagmite": get_used_cells_by_id(11),
		"ore": get_used_cells_by_id(12),
		"cactus": get_used_cells_by_id(13),
		"campfire": get_used_cells_by_id(14),
		"dead_bush": get_used_cells_by_id(15),
		"dead_tree": get_used_cells_by_id(16),
		"old_barrel": get_used_cells_by_id(17),
	}
