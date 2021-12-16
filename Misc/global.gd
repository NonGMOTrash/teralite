extends Node

var debug: int = 0

const OLD_LEVEL_CODES := [
	"A-1", "A-2", "A-3", "A-4", "A-5", "A-6", "A-7", "A-8", "A-9", "A-10", "A-11", 
	"A-12", "A-13", "A-14", "A-15", "A-secret"
]

const DEV_TIMES := {
	"Redwood": 9.5,
	"Midpoint": 12.7,
	"Quickstep": 14.8,
	"Barricade": 17.1,
	"Brick": 15.7,
	"Gauntlet": 22.1,
	"Sprint": 24.1,
	"Timber": 8.8,
	"Army": 8.2,
	"Entrance": 10.5,
	"Ambushed": 10.4,
	"Caged": 22.5,
	"Monarch": 19.6,
	"River": 8.4,
	"Conflict": 23.8,
	"Settlement": 80.9,
	"Horde": 25.3,
	"Duo": 21.8,
	"Spiral": 14.1,
	"Shadow": 21.7,
	"Fortified": 17.6,
	"Vault": 14.4,
	"Pathway": 9.2,
	"Slice": 12.5,
	"Disorderly": 16.5,
	"Across": 15.0,
	"Halls": 30.5,
	"Mythical": 21.8,
	"Ranger": 16.6,
	"Breach": 26.7,
	"Duel": 61.0,
	"Poison": 22.3,
	"Isolated": 11.2,
	"Hex": 11.1,
}

#all the global variables
var quality_of_this_game = -999 # = very bad game
var the_seed = "downwardspiral"

# PROBLEM_NOTE: this should probably be in the player
var selection = 0 # <-- for the item bar (0 1 2)
var FOV = Vector2(1, 1)
var previous_scene = null # PROBLEM_NOTE i don't think this is used
var player_hub_pos = {"A":Vector2(0, 0)}
var last_ambiance = 0 # PROBLEM_NOTE: this isn't used i don't think

# data vars
var stars = 0
var last_hub = null
var cleared_levels = []
var perfected_levels = []
var level_deaths = {}
var level_times = {}
var total_time = 0.0
var speedrun_time = 0.0
var icon = 0

const ver_phase = "beta"
const ver_num = 4.0
const ver_hotfix = 0

# for saving things
const SAVE_DIR := "user://saves/"
var save_name: String = "untitled_save"
var saves = []

var settings := {
	"fullscreen": false,
	"perfection_mode": false,
	"pixel_perfect": false,
	"smooth_camera": true,
	"hide_bar": false,
	"volume": 0.50,
	"vsync": true,
	"particles": 3, # 0 = none, 1 = low, 2 = medium, 3 = all
	"gpu_snap": false,
	"spawn_pause": false,
}

# should move this and get_relation to Entity.gd probably
var faction_relationships = {
	"player": 
		{
			"solo": "hostile",
			"player": "friendly",
			"monster": "hostile",
			"blue_kingdom": "hostile",
			"army": "hostile",
		},
	"monster":
		{
			"solo": "hostile",
			"player": "hostile",
			"monster": "friendly",
			"blue_kingdom": "hostile",
			"army": "hostile",
		},
	"blue_kingdom":
		{
			"solo": "hostile",
			"player": "hostile",
			"monster": "hostile",
			"blue_kingdom": "friendly",
			"army": "hostile",
		},
	"solo":
		{
			"solo": "hostile",
			"player": "hostile",
			"monster": "hostile",
			"blue_kingdom": "hostile",
			"army": "hostile",
		},
	"army":
		{
			"solo": "hostile",
			"player": "hostile",
			"monster": "hostile",
			"blue_kingdom": "hostile",
			"army": "friendly",
		},
	"my_entity": # special friendly to the same entity type, but hostile to everyone else
		{
			"solo": "hostile",
			"player": "hostile",
			"monster": "hostile",
			"blue_kingdom": "hostile",
			"army": "hostile",
		},
}

const VER_INCOMPATIABILITY := []

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
	v = ver_phase + " " + str(ver_num)
	if ver_num == round(ver_num):
		v = v + ".0"
	if ver_hotfix > 0:
		if ver_hotfix == 1:
			v = v + " Hotfix"
		else:
			v = v + " Hotfix #" + str(global.ver_hotfix)
	if OS.is_debug_build() == true:
		v = v + " (Debug)"
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
	print("")
	
	# debug stuffz:
	Engine.time_scale = 1.0
	#if get_tree().current_scene.get_name() != "test_level":
	#	get_tree().change_scene("res://Levels/test_level.tscn")

# PROBLEM_NOTE: should probably move this to the Entity class
func get_relation(me:Entity, other:Entity) -> String:
	if me.faction == "my_entity" or other.faction == "my_entity":
		if me.truName == other.truName:
			return "friendly"
		else:
			return "hostile"
	
	if me.marked_enemies.has(other):
		return "hostile"
	if me.marked_allies.has(other):
		return "friendly"
	
	var faction_one = me.faction
	var faction_two = other.faction
	
	if faction_one == "" or faction_two == "": 
		return ""
	else:
		return faction_relationships[faction_one][faction_two]

func get_empty_save_data():
	return {
		"save_name": "untitled_save",
		"stars": 0,
		"last_hub": null,
		"hub_pos": {"A": Vector2.ZERO},
		"cleared_levels": [],
		"perfected_levels": [],
		"level_deaths": {},
		"level_times": {},
		"ver_phase": ver_phase,
		"ver_num": ver_num,
		"ver_hotfix": ver_hotfix,
		"total_time": 0.0,
		"speedrun_time": 0.0,
		"icon": 0,
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
		"ver_phase": ver_phase,
		"ver_num": ver_num,
		"ver_hotfix": ver_hotfix,
		"total_time": total_time,
		"speedrun_time": speedrun_time,
		"icon": icon,
	}

func update_saves():
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
		new_save_name = "untitled_save"
	
	save_name = new_save_name
	
	# makes saves directory if it does not exist
	var dir = Directory.new()
	if not dir.dir_exists(SAVE_DIR): dir.make_dir_recursive(SAVE_DIR)
	
	var save_file = File.new()
	var error = save_file.open(SAVE_DIR + save_name, File.WRITE)
	if error == OK:
		# load works
		save_file.store_var(data)
		save_file.close()
	else:
		# load failed
		push_error("could not open save '%s' on write" % save_name)
		OS.alert("could not open save '%s' on write" % save_name, "reportpls.jpg")

func load_save(entered_save_name):
	var save_file = File.new()
	
	save_name = entered_save_name
	if not save_name.is_valid_filename():
		# rename the save file to not have spaces
		if save_file.file_exists(SAVE_DIR + save_name):
			var error = save_file.open(SAVE_DIR + save_name, File.READ)
			if error == OK:
				var save_data = save_file.get_var()
				save_file.close()
				
				var new_name := ""
				for letter in save_name:
					if letter.is_valid_filename():
						new_name = new_name + letter
					else:
						new_name = new_name + "_"
				
				delete_save(save_name)
				save_name = new_name
				write_save(save_name, save_data)
			else:
				push_error("could not open save '%s' on load (for renaming)" % save_name)
				OS.alert("could not open save '%s' on load (for renaming)" % save_name, "reportpls.jpg")
		else:
			push_error("could not find save '%s' on load (for renaming)" % save_name)
			OS.alert("could not find save '%s' on load (for renaming)" % save_name, "reportpls.jpg")
	
	if save_file.file_exists(SAVE_DIR + save_name):
		var error = save_file.open(SAVE_DIR + save_name, File.READ)
		if error == OK:
			#load works
			var new_data = save_file.get_var()
			
			# PROBLEM_NOTE: this is kinda bad because I have to add a new line here every time i add a new
			# var to a save, not sure there's exactly a better way (not a huge deal really)
			if new_data.has("stars"): stars = new_data["stars"]
			if new_data.has("last_hub"): last_hub = new_data["last_hub"]
			if new_data.has("hub_pos"): player_hub_pos = new_data["hub_pos"]
			if new_data.has("cleared_levels"): cleared_levels = new_data["cleared_levels"]
			if new_data.has("perfected_levels"): perfected_levels = new_data["perfected_levels"]
			if new_data.has("level_deaths"): level_deaths = new_data["level_deaths"]
			if new_data.has("level_times"): level_times = new_data["level_times"]
			if new_data.has("total_time"): total_time = new_data["total_time"]
			if new_data.has("speedrun_time"): speedrun_time = new_data["speedrun_time"]
			if new_data.has("icon"): icon = new_data["icon"]
			
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
			
			if player_hub_pos is Vector2:
				player_hub_pos = {"A": player_hub_pos}
			
			# changes scene to the correct hub
			if last_hub == null:
				get_tree().change_scene("res://Levels/A/Redwood.tscn")
			elif last_hub.length() != 1:
				get_tree().change_scene("res://Levels/A/A-Hub.tscn")
			else:
				get_tree().change_scene("res://Levels/%s/%s-Hub.tscn" % [last_hub, last_hub])
			
		else:
			# load failed
			push_error("could not open save on load")
			OS.alert("could not open save on load", "reportpls.jpg")
	else:
		# file didn't exist
		push_error("could not find save '%s' on load" % save_name)
		OS.alert("could not find save '%s' on load" % save_name, "reportpls.jpg")

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
		_: 
			push_error("invalid level code '%s'" % lvl)
			return lvl

func delete_save(entered_save_name):
	var save_file = File.new()
	
	save_name = entered_save_name
	
	if save_file.file_exists(SAVE_DIR + save_name):
		# file found
		var dir = Directory.new()
		dir.remove(SAVE_DIR + save_name)
	else:
		# file not found
		push_warning("could not find save on delete")
		OS.alert("could not find save on delete", "reportpls.jpg")
		

func update_settings(save_settings_config:=true):
	OS.window_fullscreen = settings["fullscreen"]
	ProjectSettings.set_setting("rendering/2d/snapping/use_gpu_pixel_snap", settings["gpu_snap"])
	
	OS.vsync_enabled = settings["vsync"]
	
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
		# is map
		
		var camera = refs.camera.get_ref()
		if not camera is Camera2D:
			push_warning("could not find camera")
		else:
			camera.smoothing_enabled = global.settings["smooth_camera"]
			camera.limit_smoothed = global.settings["smooth_camera"]
		
		var item_bar = refs.item_bar.get_ref()
		if item_bar == null: 
			push_warning("could not find item_bar")
		else:
			var player = refs.player.get_ref()
			if player == null: return
			
			var inventory = player.inventory
			if (
				global.settings["hide_bar"] == true and 
				inventory[0] == null and
				inventory[1] == null and
				inventory[2] == null
			):
				item_bar.visible = false
			else:
				item_bar.visible = true
		
		if get_tree().current_scene.has_particles == true:
			var particles: Particles2D = get_tree().current_scene.particles
			
			var enabled := false
			if global.settings["particles"] == 3:
				enabled = true
			
			get_tree().current_scene.update_particles = enabled
			get_tree().current_scene.set_physics_process(enabled)
			particles.visible = enabled
			particles.emitting = enabled
	
	AudioServer.set_bus_volume_db(0, linear2db(settings["volume"]))
	
	if save_settings_config == false:
		return
	
	# saving to settings_config file
	var settings_config = File.new()
	
	var error = settings_config.open("user://settings_config", File.WRITE)
	if error == OK:
		# load works
		settings_config.store_var(global.settings)
		settings_config.close()
	else:
		# load failed
		push_error("could not load settings_config (on update), deleting")
		OS.alert("could not load settings config (on update)", "reportpls.jpg")
		
		if settings_config.file_exists("user://settings_config"):
			var dir := Directory.new()
			dir.remove("user://settings_config")
		else:
			push_error("could not find settings_config (on deletion)")
			OS.alert("could not find settings_config (on deletion)", "reportpls.jpg")

func quit():
	print(
		"\n" +
		"hope you had fun or whatever\n" +
		"there's some memory leaks that happen when the game quits, and i have no idea why :(\n" +
		"i guess it doesn't really matter\n"
	)
#	res.queue_free()
#	self.queue_free()
	get_tree().quit()

func sec_to_time(time: float) -> String:
	var hours = int(floor(time / 3600))
	var minute = int(floor(time / 60))
	var second = int(floor(time - (minute * 60)))
	var tenth = stepify(time - ((minute*60) + second), 0.1) * 10
	if tenth == 10: tenth = 0
	
	if second < 10: 
		second = str(second)
		second = "0"+second
	
	if hours > 1:
		return (
			str(hours) +
			":" +
			str(minute) +
			":" +
			str(second) +
			"." +
			str(tenth)
		)
	else:
		return (
			str(minute) +
			":" +
			str(second) +
			"." +
			str(tenth)
		)
