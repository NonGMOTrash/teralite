extends ColorRect

onready var delay = $Timer

onready var play = $main/center/play
onready var options = $main/center/options
onready var quit = $main/center/quit
onready var msg = $main/msg
onready var version = $main/ver
onready var title_menu = $main
onready var saves_menu = $saves
onready var new_save_menu = $new_save
onready var options_menu = $Options
onready var new = $saves/HBoxContainer/new
onready var create = $new_save/create
onready var saves_list := $saves/ScrollContainer/saves_list
onready var save_icon := $new_save/VBoxContainer/HBoxContainer_2/icon

var locked_input = true

const yellow := Color8(247, 150, 23)
const white := Color8(255, 255, 255)
const SAVE_PREVIEW := preload("res://UI/title_screen/save_preview/save_preview.tscn")

const MESSAGES = [
	"idk", "big floppa edition", "the least bad game yet!",
	"less bugs than something something 76!", 
	"worse than school", "worse than work",
	"don't play project epsilon", "downward spiral",
	"no amogus allowed", "im NOT waiting for godot 4.0",
	"loading a rocket launcher", "pls enjoy", "helo",
	"0% political", "a deep polticial statement",
	"blebsome", "a little something for everyone",
	"don't play at 4:20 PM", "all lowercase",
	"now with 50% more bugs", "play 20xx.io!",
	"it's okay", "5 merits lost :(", "dumpy baby",
	"spikes galore", "women aren't real*",
	"it really makes you feel orange", "t posing allowed",
	"dont go to /r/dontgohere", "game of the year, fornever",
	"100% based", "100% cringe", 
	"i visit newgrounds.com everyday",
	"a quircky new earthbound inspired RPG",
	"straight down to heck", "worst mistake of my life",
	"proof that software is getting worse", 
	"play project eclise!"
]
const SAVE_ICONS := [
	preload("res://UI/Icons/save.png"),
	preload("res://Entities/player/player_flat.png"),
	preload("res://UI/Icons/plain_star.png"),
	preload("res://UI/Icons/teralite_logo_small.png"),
	preload("res://Entities/Item_Pickups/sword/sword.png"),
	preload("res://Entities/Item_Pickups/heart/heart.png"),
	preload("res://Entities/Item_Pickups/bow/bow.png"),
	preload("res://Entities/Item_Pickups/pistol/pistol.png"),
]
var save_icon_id: int = 0

onready var SAVE_ICON = preload("res://UI/Icons/save.png")

func _ready() -> void:
	play.grab_focus()
	visible = true
	load_saves_list_items()
	
	# set display version
	version.text = global.ver_phase + " " + str(global.ver_num)
	if global.ver_num == round(global.ver_num):
		version.text = version.text + ".0"
	if global.ver_hotfix > 0:
		if global.ver_hotfix == 1:
			version.text = version.text + " Hotfix"
		else:
			version.text = version.text + " Hotfix #" + str(global.ver_hotfix)
	if OS.is_debug_build() == true:
		version.text = version.text + " (Debug)"
	
	msg.text = MESSAGES[OS.get_system_time_msecs() % MESSAGES.size()]
	
	# load settings config
	var settings_config = File.new()
	
	if not settings_config.file_exists("user://settings_config"):
		push_warning("could not find settings_config, creating new")
		
		settings_config.open("user://settings_config", File.WRITE)
		settings_config.store_var(global.settings)
		settings_config.close()
	
	var error = settings_config.open("user://settings_config", File.READ)
	if error == OK:
		# load works
		var new_settings = settings_config.get_var()
		if new_settings == null:
			push_warning("settings_config was empty")
			return
		
		for i in global.settings.keys().size():
			var key = global.settings.keys()[i]
			if new_settings.has(key):
				global.settings[key] = new_settings[key]
		
		global.update_settings(false)
	
	else:
		# load failed
		push_error("could not load settings_config")
		OS.alert("could not load settings_config", "reportpls.jpg")

func multi_color_set(target:Control, color:Color):
	target.set_deferred("custom_colors/font_color", color)
	target.set_deferred("custom_colors/font_color_pressed", color)
	target.set_deferred("custom_colors/font_color_hover", color)

func load_saves_list_items(): # add items from the saves directory into here
	# sets saves var to all the files in the saves directory
	global.update_saves()
	
	for save in global.saves:
		var existing_save_preview := saves_list.find_node(save)
		if existing_save_preview:
			existing_save_preview.queue_free()
			yield(existing_save_preview, "tree_exited")
		
		var save_preview := SAVE_PREVIEW.instance()
		saves_list.call_deferred("add_child", save_preview)
		yield(save_preview, "ready")
		
		var reader = File.new()
		var error = reader.open(global.SAVE_DIR + save, File.READ)
		if error == OK:
			var data: Dictionary = reader.get_var()
			
			save_preview.stars.text = str(data["stars"])
			save_preview.save_name.text = data["save_name"]
			save_preview.name = data["save_name"]
			save_preview.version.text = str(data["ver_num"])
			if "icon" in data:
				save_preview.icon.texture = SAVE_ICONS[data["icon"]]
			if data["ver_num"] < global.ver_num:
				if floor(data["ver_num"]) < 1.0:
					save_preview.version.set_deferred("custom_colors/font_color", Color.yellow)
				else:
					save_preview.version.set_deferred("custom_colors/font_color", Color.greenyellow)
			elif data["ver_num"] > global.ver_num:
				save_preview.version.set_deferred("custom_colors/font_color", Color.lightblue)
			
			var deaths: int = 0
			for amount in data["level_deaths"].values():
				deaths += amount
			save_preview.deaths.text = str(deaths)
			
			if "total_time" in data:
				save_preview.time.text = global.sec_to_time(data["total_time"])
			else:
				save_preview.time.text = "0:00.0"
		else:
			save_preview.time.visible = false
			save_preview.deaths.visible = false
			save_preview.get_node("main/HBoxContainer2/deaths_icon").visible = false
			save_preview.get_node("main/HBoxContainer2/stars_icon").visible = false
			save_preview.get_node("main/HBoxContainer2/time_icon").visible = false
			save_preview.stars = "error, data couldn't be loaded :("

func _on_Timer_timeout() -> void:
	locked_input = false

func _on_play_pressed() -> void:
	load_saves_list_items()
	title_menu.visible = false
	saves_menu.visible = true
	new.grab_focus()

func _on_options_pressed() -> void:
	if title_menu.visible == false: return
	title_menu.visible = false
	options_menu.visible = true

func _on_quit_pressed() -> void:
	if title_menu.visible == false: return
	global.quit()

func _on_Options_visibility_changed() -> void:
	if options_menu.visible == false and title_menu.visible == false:
		title_menu.visible = true

func _on_back_pressed() -> void:
	saves_menu.visible = false
	title_menu.visible = true
	play.grab_focus()

func _on_new_pressed() -> void:
	saves_menu.visible = false
	new_save_menu.visible = true
	create.grab_focus()

func _on_cancel_pressed() -> void:
	load_saves_list_items()
	new_save_menu.visible = false
	saves_menu.visible = true
	new.grab_focus()

func _on_create_pressed() -> void:
	var new_save_name = $new_save/VBoxContainer/HBoxContainer/name.text
	if new_save_name == "":
		new_save_name = "untitled_save"
	
	global.save_name = new_save_name
	
	var data = global.get_empty_save_data()
	data["save_name"] = global.save_name
	data["icon"] = save_icon_id
	global.write_save(global.save_name, data)
	global.load_save(global.save_name)

func _on_Options_closed() -> void:
	title_menu.visible = true
	play.grab_focus()

func _on_next_pressed() -> void:
	save_icon_id += 1
	if save_icon_id > SAVE_ICONS.size()-1:
		save_icon_id = 0
	save_icon.texture = SAVE_ICONS[save_icon_id]

func _on_prev_pressed() -> void:
	save_icon_id -= 1
	if save_icon_id < 0:
		save_icon_id = SAVE_ICONS.size()-1
	save_icon.texture = SAVE_ICONS[save_icon_id]
