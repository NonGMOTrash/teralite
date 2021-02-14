extends Navigation2D

const LEVEL_TYPE = 0

signal pathfound(start, end)

func _ready() -> void:
	if name != "test_level":
		global.write_save(global.save_name, global.get_save_data_dict())
	
	global.nodes["canvaslayer"] = $CanvasLayer
	global.nodes["ysort"] = $YSort

func pathfind(start:Vector2, end:Vector2):
	var path = get_simple_path(start, get_closest_point(end), true)
	#if path.size() == 0: path = get_simple_path(start, get_closest_point(end), false)
	return path
	emit_signal("pathfound", start, end)
