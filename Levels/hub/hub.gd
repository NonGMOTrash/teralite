extends Node2D

enum TYPES {NONE, AUTUMN, UNDERGROUND}

export(TYPES) var AMBIANCE = TYPES.AUTUMN
export(TYPES) var GLOBAL_PARTICLES = TYPES.AUTUMN
export(String) var LETTER := "A" 

const LEVEL_TYPE = 1

func _ready() -> void:
	global.nodes["level"] = self
	global.nodes["canvaslayer"] = $CanvasLayer
	global.nodes["ysort"] = $YSort
	global.nodes["background"] = $Background
	global.nodes["background_tiles"] = $YSort/background_tiles
	
	global.last_hub = get_tree().current_scene.LETTER
	if not (global.save_name == "untitled_save" and global.stars == 0):
		global.write_save(global.save_name, global.get_save_data_dict())
	global.emit_signal("update_health")
	global.update_cursor()
	
	var player = $YSort.find_node("player")
	if player == null: 
		push_warning("could not find player")
	else:
		var pos = global.player_hub_pos.get(LETTER)
		if pos != null and pos != Vector2.ZERO:
			player.global_position = global.player_hub_pos[LETTER]
	
	if global.last_ambiance == AMBIANCE: return
	else: 
		# PROBLEM_NOTE: not sure why i have to do this instead of find_node(), maybe a bug with godot
		# (this same thing is also done in level.gd)
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
