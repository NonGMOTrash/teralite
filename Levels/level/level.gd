extends Navigation2D

enum AMBIANCE_TYPES {NONE, FOREST}
export(AMBIANCE_TYPES) var AMBIANCE = AMBIANCE_TYPES.FOREST

enum PARTICLE_TYPES {NONE, FOREST}
export(PARTICLE_TYPES) var GLOBAL_PARTICLES = PARTICLE_TYPES.FOREST

export var FORCE_SLEEP_UNTIL_VISIBLE = false

export(String) var WORLD = "A"
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
		AMBIANCE_TYPES.FOREST: ambiance.stream = load("res://Levels/level/forest_ambiance.wav")
		_: return

	global.add_child(ambiance)
	global.nodes["ambiance"] = ambiance

func pathfind(start:Vector2, end:Vector2) -> PoolVector2Array:
	#if start != get_closest_point(start):
	#	return PoolVector2Array([])

	#var true_end = get_closest_point(end)

	var path = get_simple_path(start, get_closest_point(end), true)
	#if path.size() == 0: path = get_simple_path(start, get_closest_point(end), false)

	return path
