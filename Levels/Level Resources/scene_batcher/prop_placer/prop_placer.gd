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
	}
