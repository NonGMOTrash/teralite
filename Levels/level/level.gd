extends Navigation2D

const LEVEL_TYPE = 0

func _ready() -> void:
	if name != "test_level":
		global.write_save(global.save_name, global.get_save_data_dict())

func pathfind(start:Vector2, end:Vector2):
	var path = get_simple_path(start, end, true)
	#if path.size() == 0: path = get_simple_path(start, get_closest_point(end), true)
	return path
