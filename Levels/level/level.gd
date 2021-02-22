extends Navigation2D

enum AMBIANCE_TYPES {NONE, FOREST}
export(AMBIANCE_TYPES) var AMBIANCE = AMBIANCE_TYPES.FOREST

const LEVEL_TYPE = 0

signal pathfound(start, end)

func _ready() -> void:
	if name != "test_level":
		global.write_save(global.save_name, global.get_save_data_dict())
	
	global.nodes["level"] = self
	global.nodes["canvaslayer"] = $CanvasLayer
	global.nodes["ysort"] = $YSort
	
	if global.last_ambiance == AMBIANCE: return
	else:
		var old_ambiance
		for global_sound in global.get_children():
			if global_sound.name == "ambiance":
				old_ambiance = global_sound
				break
		
		if old_ambiance != null: 
			old_ambiance.free()
	
	var ambiance = Global_Sound.new()
	ambiance.volume_db = 0.2
	ambiance.name = "ambiance"
	ambiance.SCENE_PERSIST = true
	ambiance.autoplay = true
	ambiance.pause_mode = PAUSE_MODE_PROCESS
	ambiance.MODE = Sound.MODES.REPEATING
	
	match AMBIANCE:
		AMBIANCE_TYPES.FOREST: ambiance.stream = load("res://Levels/level/forest_ambiance.wav")
		_: return
	
	global.add_child(ambiance)
	global.nodes["ambiance"] = ambiance

func pathfind(start:Vector2, end:Vector2):
	var path = get_simple_path(start, get_closest_point(end), true)
	#if path.size() == 0: path = get_simple_path(start, get_closest_point(end), false)
	return path
	emit_signal("pathfound", start, end)
