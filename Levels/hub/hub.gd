extends Node2D

enum AMBIANCE_TYPES {NONE, FOREST}
export(AMBIANCE_TYPES) var AMBIANCE = AMBIANCE_TYPES.FOREST
export(String) var LETTER := "A" 

const LEVEL_TYPE = 1

func _ready() -> void:
	global.last_hub = get_tree().current_scene.get_name()
	global.write_save(global.save_name, global.get_save_data_dict())
	global.emit_signal("update_health")
	global.update_cursor()
	var player = $YSort.find_node("player")
	if player == null: 
		push_warning("could not find player")
	else:
		if not global.player_hub_pos == null and not global.player_hub_pos == Vector2.ZERO:
			player.global_position = global.player_hub_pos
	
	global.nodes["level"] = self
	global.nodes["canvaslayer"] = $CanvasLayer
	global.nodes["ysort"] = $YSort
	global.nodes["background"] = $Background
	global.nodes["background_tiles"] = $YSort/background_tiles
	
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
		AMBIANCE_TYPES.FOREST: ambiance.stream = load("res://Levels/level/forest_ambiance.wav")
		_: return
	
	global.add_child(ambiance)
	global.nodes["ambiance"] = ambiance
