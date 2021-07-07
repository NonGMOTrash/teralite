extends Navigation2D

enum TYPES {NONE, AUTUMN, UNDERGROUND}

export(TYPES) var AMBIANCE = TYPES.AUTUMN
export(TYPES) var GLOBAL_PARTICLES = TYPES.AUTUMN
export var FORCE_SLEEP_UNTIL_VISIBLE = false

export(String) var WORLD := "A"
const LEVEL_TYPE := 0 # PROBLEM_NOTE: make this a string

var max_kills: int = 0

func _ready() -> void:
	if name != "test_level":
		global.write_save(global.save_name, global.get_save_data_dict())
	
	global.nodes["level"] = self
	global.nodes["canvaslayer"] = $CanvasLayer
	global.nodes["ysort"] = $YSort
	global.nodes["background"] = $background
	global.nodes["background_tiles"] = $YSort/background_tiles
	
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
		TYPES.AUTUMN: ambiance.stream = load("res://Levels/level/forest_ambiance.wav")
		TYPES.UNDERGROUND: ambiance.stream = load("res://Levels/level/cave_ambiance.ogg")
		_: return
	
	global.add_child(ambiance)
	global.nodes["ambiance"] = ambiance

func pathfind(start:Vector2, end:Vector2) -> PoolVector2Array:
	var path := get_simple_path(start, get_closest_point(end), true)
	
	if path.size() == 0:
		return path
	
	return path
