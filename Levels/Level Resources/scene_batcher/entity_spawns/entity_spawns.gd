extends "res://Levels/Level Resources/scene_batcher/scene_batcher.gd"

func set_data():
	data = {
		"player": get_used_cells_by_id(2),
		"chaser": get_used_cells_by_id(3),
		"pistol": get_used_cells_by_id(6),
		"white_armor": get_used_cells_by_id(7),
		"brute_chaser": get_used_cells_by_id(8),
		"gold_chaser": get_used_cells_by_id(9),
		"sword": get_used_cells_by_id(10),
		"crate": get_used_cells_by_id(11),
		"heart": get_used_cells_by_id(12),
		"gold_heart": get_used_cells_by_id(13),
		"star": get_used_cells_by_id(14),
		"spikes": get_used_cells_by_id(27),
		"spikes_offset": get_used_cells_by_id(30),
		"fire": get_used_cells_by_id(17),
		"timber_box": get_used_cells_by_id(18),
		"unlite_timber_box": get_used_cells_by_id(19),
		"specter": get_used_cells_by_id(20),
		"bow": get_used_cells_by_id(21),
		"knight": get_used_cells_by_id(22),
		"archer": get_used_cells_by_id(23),
		"rogue": get_used_cells_by_id(24),
		"king": get_used_cells_by_id(25),
		"ultra_chaser": get_used_cells_by_id(26),
		"red_spikes": get_used_cells_by_id(31),
		"diamond_spikes": get_used_cells_by_id(32)
	}

