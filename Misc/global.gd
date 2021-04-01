extends Node

#all the global variables
var quality_of_this_game = -999 # = very bad game
var the_seed = "downwardspiral"

# PROBLEM_NOTE: this should probably be in the player
var selection = 0 # <-- for the item bar (0 1 2)
var FOV = Vector2(1, 1)
var cam_zoom_default = Vector2(3, 1) # PROBLEM_NOTE: maybe this should be in the camera
var cam_zoom = cam_zoom_default #X = favors player, Y = favors mouse
var previous_scene = null # PROBLEM_NOTE i don't think this is used
var player_hub_pos = Vector2(0, 0)
var last_ambiance = 0 # PROBLEM_NOTE: this isn't used

# data vars
var stars = 0
var last_hub = null
var cleared_levels = []
var perfected_levels = []
var level_deaths = {} # not currently used
var level_times = {} # not currently used

# for saving things
const SAVE_DIR = "user://saves/"
var save_name = "untitled save"
var save_path = SAVE_DIR + save_name
var saves = []

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
}

var settings = {
	"fullscreen": false,
	"auto_restart": false,
	"pixel_perfect": false,
	"smooth_camera": true,
	"hide_bar": true,
	"volume": 0.50,
}

var preloads = {
	#entities:
	"player": "res://Entities/player/player.tscn",
	"spikes": "res://Entities/spikes/spikes.tscn",
	"spikes_offset": "res://Entities/spikes/spikes_offest/spikes_offset.tscn",
	"chaser": "res://Entities/chaser/chaser.tscn",
	"brute_chaser": "res://Entities/chaser/brute_chaser/Brute_Chaser.tscn",
	"gold_chaser": "res://Entities/chaser/gold_chaser/Gold_Chaser.tscn",
	"crate": "res://Entities/crate/Crate.tscn",
	"fire": "res://Entities/fire/fire.tscn",
	"timber_box": "res://Entities/fire/timber_pot/timber_pot.tscn",
	"unlite_timber_box": "res://Entities/fire/timber_pot/unlite_timber_pot/unlite_timber_pot.tscn",
	"specter": "res://Entities/specter/specter.tscn",
	"knight": "res://Entities/knight/knight.tscn",
	"archer": "res://Entities/archer/archer.tscn",
	"rogue": "res://Entities/knight/rogue/rogue.tscn",
	"king": "res://Entities/king/king.tscn",
	"ultra_chaser": "res://Entities/chaser/ultra_chaser/ultra_chaser.tscn",
	"red_spikes": "res://Entities/spikes/red_spikes/red_spikes.tscn",
	"diamond_spikes": "res://Entities/spikes/red_spikes/diamond_spikes/diamond_spikes.tscn",
	
	#items:
	"pistol": "res://Entities/Items Pickups/pistol/pistol.tscn",
	"white_armor": "res://Entities/Items Pickups/white_armor/white armor.tscn",
	"sword": "res://Entities/Items Pickups/sword/sword.tscn",
	"gold_heart": "res://Entities/Items Pickups/gold_heart/gold heart.tscn",
	"heart": "res://Entities/Items Pickups/heart/heart.tscn",
	"star": "res://Entities/Items Pickups/star/star.tscn",
	"bow": "res://Entities/Items Pickups/bow/bow.tscn",
	
	#things:
	"bullet": "res://Entities/Attacks/Projectile/small_bullet/small_bullet.tscn",
	"slash": "res://Entities/Attacks/Melee/slash/slash.tscn",
	"stab": "res://Entities/Attacks/Melee/stab/stab.tscn",
	"arrow": "res://Entities/Attacks/Projectile/arrow/arrow.tscn",
	
	#effects:
	"hit_effect": "res://Effects/hit_effect/hit_effect.tscn",
	"item_pickup_effect": "res://Effects/item_pickup_effect/item_pickup_effect.tscn",
	"exclaimation": "res://Effects/exclaimation/exclaimation.tscn",
	"question": "res://Effects/question/question.tscn",
	"chaser_death": "res://Effects/death_effects/chaser_death_effect.tscn",
	"brute_chaser_death": "res://Effects/death_effects/brute_chaser_death_effect.tscn",
	"gold_chaser_death": "res://Effects/death_effects/gold_chaser_death_effect.tscn",
	"ultra_chaser_death": "res://Effects/death_effects/ultra_chaser_death_effect.tscn",
	"knight_death":"res://Effects/death_effects/knight_death_effect.tscn",
	"archer_death": "res://Effects/death_effects/archer_death_effect.tscn",
	"rogue_death": "res://Effects/death_effects/rogue_death_effect.tscn",
	"king_death": "res://Effects/death_effects/king_death_effect.tscn",
	
	#props
	"maple_tree1": "res://Props/maple_tree1/maple_tree1.tscn",
	"maple_tree2": "res://Props/maple_tree2/maple_tree2.tscn",
	"maple_tree3": "res://Props/maple_tree3/maple_tree3.tscn",
	"tree_stump": "res://Props/tree_stump/tree_stump.tscn",
	"banner": "res://Props/banner/banner.tscn",
	"flag": "res://Props/flag/flag.tscn",
	"torch": "res://Props/torch/torch.tscn",
}

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
const CURSOR_NORMAL = preload("res://HUD and Menus/CURSOR_NORMAL.png")
const CURSOR_EMPTY = preload("res://HUD and Menus/CURSOR_EMPTY.png")
const CURSOR_SWORD = preload("res://HUD and Menus/CURSOR_SWORD.png")
const CURSOR_PISTOL = preload("res://HUD and Menus/CURSOR_PISTOL.png")
const CURSOR_BOW = preload("res://HUD and Menus/CURSOR_BOW.png")
# PROBLEM_NOTE: not sure if i should do this ^

func _ready():
	seed(the_seed.hash())
	prints("seed:", the_seed)
	prints("hashed seed:", the_seed.hash())
	
	Input.set_custom_mouse_cursor(CURSOR_NORMAL, Input.CURSOR_ARROW, Vector2(0, 0))
	
	var hr = OS.get_time()["hour"]
	if hr > 12: hr -= 12
	if hr == 4 and OS.get_time()["minute"] == 20:
		print("you just got rickrolled!!!!1!")
		OS.shell_open("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
	
	push_warning("quality_of_this_game == -999")
	print("===============")

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

func aquire(asset:String):
	#overwrites paths with the packed scene
	if preloads.get(asset.to_lower()) is String:
		preloads[asset.to_lower()] = load(preloads.get(asset.to_lower()))
	
	#finished
	return preloads.get(asset.to_lower()).instance()

func get_empty_save_data():
	return {
		"save_name": "untitled save",
		"stars": 0,
		"last_hub": null,
		"hub_pos": null,
		"cleared_levels": [],
		"perfected_levels": [],
		"level_deaths": {},
		"level_times": {}
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
		"level_times": level_times
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
			# var to a save, but i shouldn't have to add anything else so i might be good
			if new_data.has("stars"): stars = new_data["stars"]
			if new_data.has("save_name"): save_name = new_data["save_name"]
			if new_data.has("last_hub"): last_hub = new_data["last_hub"]
			if new_data.has("hub_pos"): player_hub_pos = new_data["hub_pos"]
			if new_data.has("cleared_levels"): cleared_levels = new_data["cleared_levels"]
			if new_data.has("perfected_levels"): perfected_levels = new_data["perfected_levels"]
			if new_data.has("level_deaths"): level_deaths = new_data["level_deaths"]
			if new_data.has("level_times"): level_times = new_data["level_times"]
			
			save_file.close()
			
			# changes scene to the correct hub
			match last_hub:
				null: get_tree().change_scene_to(load("res://Levels/A/A-1.tscn"))
				"A_hub": get_tree().change_scene_to(load("res://Levels/A/A_hub.tscn"))
				"B_hub": pass #ext ext
			
		else:
			#load failed
			push_warning("could not open save on load")
	else:
		#file didn't exist
		push_warning("could not find save on load")

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
	
	if get_tree().paused == true or get_tree().current_scene.get_name() == "TitleScreen":
		Input.set_custom_mouse_cursor(CURSOR_NORMAL, Input.CURSOR_ARROW, pointer)
	else:
		match player.inventory[selection]:
			null: Input.set_custom_mouse_cursor(CURSOR_EMPTY, Input.CURSOR_ARROW, centered)
			"Sword": Input.set_custom_mouse_cursor(CURSOR_SWORD, Input.CURSOR_ARROW, centered)
			"Pistol": Input.set_custom_mouse_cursor(CURSOR_PISTOL, Input.CURSOR_ARROW, centered)
			"Bow": Input.set_custom_mouse_cursor(CURSOR_BOW, Input.CURSOR_ARROW, centered)

#all the global signals

signal update_item_info(current_item, extra_info, item_bar_max, item_bar_value, bar_timer_duration)
signal update_item_bar(inventory)
signal update_health()
signal update_camera()
signal paused()
signal unpaused()
