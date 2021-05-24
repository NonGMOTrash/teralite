extends Node

const OLD_LEVEL_CODES := ["A-1", "A-2", "A-3", "A-4", "A-5", "A-6", "A-7", "A-8", "A-9", "A-10", "A-11", 
		"A-12", "A-13", "A-14", "A-15", "A-secret"]

#all the global variables
var quality_of_this_game = -999 # = very bad game
var the_seed = "downwardspiral"

# PROBLEM_NOTE: this should probably be in the player
var selection = 0 # <-- for the item bar (0 1 2)
var FOV = Vector2(1, 1)
var previous_scene = null # PROBLEM_NOTE i don't think this is used
var player_hub_pos = Vector2(0, 0)
var last_ambiance = 0 # PROBLEM_NOTE: this isn't used

# PROBLEM_NOTE: might be a bit better to have this be in a seperate "save" global?
# data vars
var stars = 0
var last_hub = null
var cleared_levels = []
var perfected_levels = []
var level_deaths = {}
var level_times = {}

const ver_phase = "Beta"
const ver_num = 2.14
const ver_hotfix = 2

# for saving things
const SAVE_DIR := "user://saves/"
var save_name: String = "untitled save"
var save_path = SAVE_DIR + save_name
var saves = []

# PROBLEM_NOTE: make this a class for better autocomplete
var nodes = {
	"level": null,
	"player": null,
	"canvaslayer": null,
	"health_ui": null,
	"item_bar": null,
	"item_info": null,
	"stopwatch": null,
	"pause_menu": null,
	"camera": null,
	"ysort": null,
	"world_tiles": null,
	"background_tiles": null,
	"background": null,
	"navigation": null,
	"level_completed": null,
}

# PROBLEM_NOTE: rename settings to options
var settings = {
	"fullscreen": false,
	"perfection_mode": false,
	"pixel_perfect": false,
	"smooth_camera": true,
	"hide_bar": true,
	"volume": 0.50,
}

# should move this and get_relation to Entity.gd probably
var faction_relationships = {
	"player": 
		{"player": "friendly",
		"monster": "hostile",
		"blue_kingdom": "hostile",},
	
	"monster":
		{"player": "hostile",
		"monster": "friendly",
		"blue_kingdom": "hostile",},
	
	"blue_kingdom":
		{"player": "hostile",
		"monster": "hostile",
		"blue_kingdom": "friendly",},
}

# cursor sprites preloaded:
const CURSOR_NORMAL = preload("res://UI/cursors/cursor_normal.png")
const CURSOR_EMPTY = preload("res://UI/cursors/cursor_empty.png")
const CURSOR_SWORD = preload("res://UI/cursors/cursor_sword.png")
const CURSOR_PISTOL = preload("res://UI/cursors/cursor_pistol.png")
const CURSOR_BOW = preload("res://UI/cursors/cursor_bow.png")
# PROBLEM_NOTE: not sure if i should do this ^

signal update_item_info(current_item, extra_info, item_bar_max, item_bar_value, bar_timer_duration)
signal update_item_bar(inventory)
signal update_health()
signal update_camera()
signal paused()
signal unpaused()

func _ready():
	seed(the_seed.hash())
	var v: String
	v = global.ver_phase + " " + str(global.ver_num)
	if global.ver_hotfix > 0:
		if global.ver_hotfix == 1:
			v = v + " Hotfix"
		else:
			v = v + " Hotfix #" + str(global.ver_hotfix)
	prints("teralite", v)
	prints("seed:", the_seed)
	prints("hashed seed:", the_seed.hash())
	
	Input.set_custom_mouse_cursor(CURSOR_NORMAL, Input.CURSOR_ARROW, Vector2(0, 0))
	
	var hr = OS.get_time()["hour"]
	if hr > 12: hr -= 12
	if hr == 4 and OS.get_time()["minute"] == 20:
		OS.alert("something terrible is going to happen. do you want to proceed?", "IMPORTANT")
		print("you just got rickrolled!!!!1!")
		OS.shell_open("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
	
	push_warning("quality_of_this_game == -999")
	print("===============")
	print("")
	
	# debug stuffz:
	#Engine.time_scale = 1
	#if get_tree().current_scene.get_name() != "test_level":
	#	get_tree().change_scene("res://Levels/test_level.tscn")

# global functions
func get_relation(me:Entity, other:Entity):
	var faction_one = me.faction
	var faction_two = other.faction
	var relation = ""
	
	if faction_one == "" or faction_two == "": 
		return relation
	
	relation = faction_relationships.get(faction_one).get(faction_two)
	
	if me.marked_enemies.has(other): relation = "hostile"
	
	return relation

func get_empty_save_data():
	return {
		"save_name": "untitled save",
		"stars": 0,
		"last_hub": null,
		"hub_pos": null,
		"cleared_levels": [],
		"perfected_levels": [],
		"level_deaths": {},
		"level_times": {},
		"ver_phase": global.ver_phase,
		"ver_num": global.ver_num,
		"ver_hotfix": global.ver_hotfix
	}

func get_save_data_dict():
	return {
		"save_name": save_name,
		"stars": stars,
		"last_hub": last_hub,
		"hub_pos": player_hub_pos,
		"cleared_levels": cleared_levels,
		"perfected_levels": perfected_levels,
		"level_deaths": level_deaths,
		"level_times": level_times,
		"ver_phase": global.ver_phase,
		"ver_num": global.ver_num,
		"ver_hotfix": global.ver_hotfix
	}

func get_saves():
	saves = []
	var dir = Directory.new()
	if not dir.dir_exists(SAVE_DIR): dir.make_dir_recursive(SAVE_DIR)
	
	dir.open(SAVE_DIR)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			saves.append(file)
	dir.list_dir_end()

func write_save(entered_save_name, data):
	var new_save_name = entered_save_name
	if new_save_name == "": 
		new_save_name = "untitled save"
	
	save_name = new_save_name
	save_path = SAVE_DIR + save_name
	
	# makes saves directory if it does not exist
	var dir = Directory.new()
	if not dir.dir_exists(SAVE_DIR): dir.make_dir_recursive(SAVE_DIR)
	
	var new_save_path = SAVE_DIR + entered_save_name
	
	var save_file = File.new()
	var error = save_file.open(new_save_path, File.WRITE)
	if error == OK:
		#load works
		save_file.store_var(data)
		save_file.close()
	else:
		#what happens on a failed load
		push_warning("could not read save on write")

func load_save(entered_save_name):
	var save_file = File.new()
	
	save_name = entered_save_name
	save_path = SAVE_DIR + save_name
	
	if save_file.file_exists(save_path):
		var error = save_file.open(save_path, File.READ)
		if error == OK:
			#load works
			var new_data = save_file.get_var()
			
			# PROBLEM_NOTE: this is kinda dumb because I have to add a new line here every time i add a new
			# var to a save, not sure there's exactly a better way (not a huge deal really)
			if new_data.has("stars"): stars = new_data["stars"]
			if new_data.has("save_name"): save_name = new_data["save_name"]
			if new_data.has("last_hub"): last_hub = new_data["last_hub"]
			if new_data.has("hub_pos"): player_hub_pos = new_data["hub_pos"]
			if new_data.has("cleared_levels"): cleared_levels = new_data["cleared_levels"]
			if new_data.has("perfected_levels"): perfected_levels = new_data["perfected_levels"]
			if new_data.has("level_deaths"): level_deaths = new_data["level_deaths"]
			if new_data.has("level_times"): level_times = new_data["level_times"]
			
			save_file.close()
			
			# compatiability for old A-X level names
			for i in cleared_levels:
				if i in OLD_LEVEL_CODES:
					cleared_levels.append(level_code_to_name(i))
			
			for i in perfected_levels:
				if i in OLD_LEVEL_CODES:
					perfected_levels.append(level_code_to_name(i))
			
			for key in level_deaths.keys():
				for value in level_deaths.values():
					if key in OLD_LEVEL_CODES:
						level_deaths[level_code_to_name(key)] = level_deaths[key]
			
			for key in level_times.keys():
				for value in level_times.values():
					if key in OLD_LEVEL_CODES:
						level_times[level_code_to_name(key)] = level_times[key]
			
			# changes scene to the correct hub
			match last_hub:
				null: get_tree().change_scene_to(load("res://Levels/A/Redwood.tscn"))
				"A_hub": get_tree().change_scene_to(load("res://Levels/A/A-Hub.tscn"))
				"B_hub": pass #ext ext
			
		else:
			#load failed
			push_warning("could not open save on load")
	else:
		#file didn't exist
		push_warning("could not find save on load")

func level_code_to_name(lvl:String) -> String:
	match lvl:
		"A-1": return "Redwood"
		"A-2": return "Midpoint"
		"A-3": return "Spiral"
		"A-4": return "Brick"
		"A-5": return "Barricade"
		"A-6": return "Sprint"
		"A-7": return "Quickstep"
		"A-8": return "Entrance"
		"A-9": return "Timber"
		"A-10": return "Gauntlet"
		"A-11": return "Army"
		"A-12": return "Ambushed"
		"A-13": return "Caged"
		"A-14": return "Monarch"
		"A-15": return "Duo"
		"A-secret": return "Shadow"
		_: return "ERROR; INVALID LEVEL CODE"

func delete_save(entered_save_name):
	var save_file = File.new()
	
	save_name = entered_save_name
	save_path = SAVE_DIR + save_name
	
	if save_file.file_exists(save_path):
		# file found
		var dir = Directory.new()
		dir.remove(save_path)
	else:
		# file not found
		push_warning("could not find save on delete")

func update_settings():
	OS.window_fullscreen = settings["fullscreen"]
	
	if global.settings["pixel_perfect"] == true:
		# PROBLEM_NOTE: should use a screen_size var in global.gd instead of just having a vector2 
			get_tree().set_screen_stretch(#                                                \/
					SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, Vector2(384, 216)
				)
	else:
		get_tree().set_screen_stretch(
					SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, Vector2(384, 216)
				)
	
	if get_tree().current_scene is Navigation2D:
		# is level
		
		var camera = global.nodes["camera"]
		if not camera is Camera2D: 
			push_warning("could not find camera")
		else:
			camera.smoothing_enabled = global.settings["smooth_camera"]
			camera.limit_smoothed = global.settings["smooth_camera"]
		
		var item_bar = global.nodes["item_bar"]
		if item_bar == null: 
			push_warning("could not find item_bar")
		else:
			if global.nodes["player"] == null: return
			var player = get_node_or_null(global.nodes["player"])
			if player == null: return
			var inventory = player.inventory
			if global.settings["hide_bar"]==true and inventory[0]==null and inventory[1]==null and inventory[2]==null:
				item_bar.visible = false
			else:
				item_bar.visible = true
	
	AudioServer.set_bus_volume_db(0, linear2db(settings["volume"]))
	
	var settings_config = File.new()
	
	if settings_config.file_exists("user://settings_config"):
		var error = settings_config.open("user://settings_config", File.WRITE)
		
		if error == OK:
			# load works
			settings_config.store_var(global.settings)
			settings_config.close()
			print("updated settings_config")
		else:
			# load failed
			push_warning("could not load settings_config (on save)")
	else:
		push_warning("could not find settings_config")

func physics_logic(delta, entity):
	# PROBLEM NOTE:
	# i don't think this is used anymore, maybe remove
	
	#remove these once i have this function completely finalized
	var ACCELERATION = entity.ACCELERATION
	var MAX_SPEED = entity.MAX_SPEED
	var FRICTION = entity.FRICTION
	var velocity = entity.velocity
	var forces = entity.forces
	var input_vector = entity.input_vector
	var WEIGHT = entity.WEIGHT
	
	input_vector = input_vector.normalized() # diagonally is same speed as straight
	
	for i in range(forces.size() - 1, -1, -1):
		var direction = forces[i].get("direction").normalized()
		var power = forces[i]["power"]
		
		if direction != Vector2.ZERO:
			velocity = velocity.move_toward(direction * WEIGHT * 3, (power + ACCELERATION) * delta)
			power *= 1 - clamp(WEIGHT / 1000.0, 0.01, 0.99)
			if power < 1.0:
				power = 0
		else:
			power = 0
		
		if power == 0: 
			forces.remove(i)
			return
		forces[i]["power"] = power
	
	#velocity -= pull_vector * delta * FORCE_POWER   #demo for pull, doesn't work properly
	
	if input_vector != Vector2.ZERO:
		# inputing movement: 
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta) # controls velocity
	else:
		# no input:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta) # applys friction
	
	#updates entity's vars
	entity.velocity = velocity
	entity.input_vector = input_vector
	entity.forces = forces

func update_cursor():
	if nodes["player"] == null: return
	var player = get_node_or_null(nodes["player"])
	if player == null: return
	# PROBLEM_NOTE: probably would be better to just have Input.set_custom_mouse_cursor be 
	# called in the item thinkers instead. 
	# (maybe have a default cursor var that is automatically used when the item is selected)
	# UPDATE: I think im doing that already?? not sure. but i might be able to delete this function
	
	var pointer = Vector2.ZERO
	var centered = Vector2(22.5, 22.5)
	
	if get_tree().paused == true or get_tree().current_scene.get_name() == "title_screen":
		Input.set_custom_mouse_cursor(CURSOR_NORMAL, Input.CURSOR_ARROW, pointer)
	else:
		match player.inventory[selection]:
			null: Input.set_custom_mouse_cursor(CURSOR_EMPTY, Input.CURSOR_ARROW, centered)
			"Sword": Input.set_custom_mouse_cursor(CURSOR_SWORD, Input.CURSOR_ARROW, centered)
			"Pistol": Input.set_custom_mouse_cursor(CURSOR_PISTOL, Input.CURSOR_ARROW, centered)
			"Bow": Input.set_custom_mouse_cursor(CURSOR_BOW, Input.CURSOR_ARROW, centered)
