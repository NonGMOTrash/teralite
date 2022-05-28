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
onready var no_saves := $saves/ScrollContainer/no_saves
onready var save_icon := $new_save/VBoxContainer/HBoxContainer_2/icon

var locked_input = true
signal loaded_save_previews

const yellow := Color8(247, 150, 23)
const white := Color8(255, 255, 255)
const SAVE_PREVIEW := preload("res://UI/title_screen/save_preview/save_preview.tscn")

const MESSAGES = [
	"idk", "big floppa edition", "the least bad game yet!",
	"less bugs than something something 76!",
	"worse than league", "don't play project epsilon", 
	"downward spiral", "amo", "goblins are reeeeeal",
	"im NOT waiting for godot 4.0", "aaaaaaaaaaaaaaaaaaaa",
	"loading a rocket launcher", "pls enjoy", "welcome",
	"0% political", "a deep polticial statement",
	"blebsome", "a little something for everyone",
	"don't play at 4:20 PM", "all lowercase",
	"now with 50% more bugs", "play 20xx.io!",
	"it's okay", "5 merits lost :(", "dumpy baby",
	"spikes galore", "women aren't real**",
	"it really makes you feel orange", "t posing allowed",
	"game of the year, fornever", "don't die",
	"100% based", "100% cringe", "better than potato thriller",
	"not quircky, or earthbound inspired",
	"straight down to heck", "worst mistake of my life",
	"proof that software is getting worse", 
	"play project eclise!", "engineer gaming", 
	"don't be the goblin of 2fort", "no gamers allowed",
	"play satyrn!", "play better half!", "play brogue maybe",
	"12.345.789.69 doxxed lmao",
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
	visible = true
	#load_saves_list_items()
	play.grab_focus()
	
	# set display version
	if global.ver_phase != "release":
		version.text = global.ver_phase
	else:
		version.text = ""
	version.text += " v" + str(global.ver_num)
	if global.ver_num == round(global.ver_num):
		version.text = version.text + ".0"
	if global.ver_hotfix > 0:
		if global.ver_hotfix == 1:
			version.text = version.text + " hotfix"
		else:
			version.text = version.text + " hotfix #" + str(global.ver_hotfix)
	if OS.is_debug_build() == true:
		version.text = version.text + " (debug)"
	
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
			var key: String = global.settings.keys()[i]
			if key == "perfection_mode":
				continue # i don't want people to accidentally leave it on and wonder why their dying
			if new_settings.has(key):
				global.settings[key] = new_settings[key]
		
		global.update_settings(false)
	
	else:
		# load failed
		push_error("could not load settings_config")
		OS.alert("could not load settings_config", "reportpls.jpg")
	
	global.set_discord_activity("staring at the title screen", "(very intently)")

func multi_color_set(target:Control, color:Color):
	target.set_deferred("custom_colors/font_color", color)
	target.set_deferred("custom_colors/font_color_pressed", color)
	target.set_deferred("custom_colors/font_color_hover", color)

func load_saves_list_items(): # add save previews from the saves directory into here
	# clear old save previews
	var i: int = 0
	for child in saves_list.get_children():
		child.queue_free()
		#if i == saves_list.get_child_count():
		yield(child, "tree_exited")
		i += 0
	
	# sets saves var to all the files in the saves directory
	global.update_saves()
	
	if global.saves.size() == 0:
		no_saves.visible = true
		emit_signal("loaded_save_previews")
		return
	else:
		no_saves.visible = false
	
	for save in global.saves:
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
			if "icon" in data:
				save_preview.icon.texture = SAVE_ICONS[data["icon"]]
			if "ver_num" in data:
				save_preview.version.text = str(data["ver_num"])
				if data["ver_num"] == floor(data["ver_num"]):
					save_preview.version.text = save_preview.version.text + ".0"
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
				save_preview.time.text = global.sec_to_time(data["total_time"], false)
			else:
				save_preview.time.text = "0:00.0"
		else:
			save_preview.time.visible = false
			save_preview.deaths.visible = false
			save_preview.get_node("main/HBoxContainer2/deaths_icon").visible = false
			save_preview.get_node("main/HBoxContainer2/stars_icon").visible = false
			save_preview.get_node("main/HBoxContainer2/time_icon").visible = false
			save_preview.stars = "error, data couldn't be loaded :("
	
	emit_signal("loaded_save_previews")

func _on_Timer_timeout() -> void:
	locked_input = false

func _on_play_pressed() -> void:
	load_saves_list_items()
	yield(self, "loaded_save_previews")
	title_menu.visible = false
	saves_menu.visible = true
	if saves_list.get_child_count() > 0:
		saves_list.get_child(0).play.grab_focus()

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
	var new_save_name: String = $new_save/VBoxContainer/HBoxContainer/name.text
	if new_save_name == "":
		new_save_name = "untitled_save"
	if not new_save_name.is_valid_filename():
		$new_save/VBoxContainer/HBoxContainer/name.text = "invalid filename"
		return
	
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
