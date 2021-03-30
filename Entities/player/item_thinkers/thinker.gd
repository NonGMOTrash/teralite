extends Node
class_name Thinker

enum ACTION_MODES { SEMI, AUTOMATIC, RELEASE }

enum CURSOR_MODES { POINTER, CENTERED }

export var auto_ready_check = true
export(ACTION_MODES) var PRIMARY_ACTION_MODE = ACTION_MODES.SEMI
export(ACTION_MODES) var SECONDARY_ACTION_MODE = ACTION_MODES.SEMI
export(Texture) var HELD_ITEM_TEXTURE
export(Vector2) var HELD_ITEM_ANCHOR = Vector2(8, 0)

export var my_item = "" 

export(Texture) var CURSOR
export(CURSOR_MODES) var CURSOR_MODE

export(AudioStream) var EQUIP_SOUND

onready var sound_player = $sound_player

var bar_max = 0.0
var bar_value = 0.0

# maybe make this a global signal??
signal update_ui(bar_max, bar_value, info_string)

func _ready():
	if my_item == "":
		push_error("my_time was not set")
		queue_free()
	
	if get_parent().truName != "player":
		push_error("thinker's parent was not a player")
		queue_free()
	
	get_parent().connect("swapped_item", self, "_check_if_selected")
	
	global.connect("unpaused", self,"_update_cursor_on_unpause")
	
	if get_parent().inventory[global.selection] == my_item: selected()
	if get_parent().get_name() == "player":
		global.emit_signal("update_item_bar", get_parent().inventory)
	
	if get_parent().inventory[global.selection] == my_item.to_lower(): selected()
	elif EQUIP_SOUND != null:
		sound_player.create_sound(EQUIP_SOUND)

func _check_if_selected(swapped_item):
	if swapped_item == my_item.to_lower():
		selected()
	else:
		unselected()

func _input(_event: InputEvent):
	if get_parent().inventory[global.selection] != my_item.to_lower(): return
	
	pre_input_action()
	
	if Input.is_action_just_pressed("reload_item"):
		reload()
		return
	
	if Input.is_action_pressed("drop_item"):
		if get_parent().inventory[global.selection] == null: return
		var newItemEntity = global.aquire(my_item)
		
		if newItemEntity == null: return
		var dir_vector = get_parent().global_position.direction_to(get_parent().get_global_mouse_position())
		newItemEntity.global_position = get_parent().global_position #+ dir_vector * 16
		newItemEntity.SOURCE = get_parent()
		var velo = dir_vector * 150
		velo += get_parent().velocity / 1.5
		newItemEntity.velocity = velo
		get_parent().get_parent().add_child(newItemEntity)
		get_parent().inventory[global.selection] = null
		
		global.emit_signal("update_item_info", # set a condition to null to hide it
			null, # current item
			null, # extra info 
			null, # item bar max 
			null, # item bar value 
			null # bar timer duration
		)
		if get_parent().get_name() == "player":
			global.emit_signal("update_item_bar", get_parent().inventory)
		
		queue_free()
		return
	
	if get_ready() == false && auto_ready_check == true: return
	
	match PRIMARY_ACTION_MODE:
		ACTION_MODES.SEMI:
			if Input.is_action_just_pressed("primary_action"): 
				primary()
				return
		ACTION_MODES.AUTOMATIC:
			if Input.is_action_pressed("primary_action"): 
				primary()
				return
		ACTION_MODES.RELEASE:
			if Input.is_action_just_released("primary_action"): 
				primary()
				return
	
	match SECONDARY_ACTION_MODE:
		ACTION_MODES.SEMI:
			if Input.is_action_just_pressed("secondary_action"): 
				secondary()
				return
		ACTION_MODES.AUTOMATIC:
			if Input.is_action_pressed("secondary_action"): 
				secondary()
				return
		ACTION_MODES.RELEASE:
			if Input.is_action_just_released("secondary_action"): 
				secondary()
				return

func get_ready():
	return true

func update_cursor(custom_img = CURSOR):
	var img = custom_img
	var hotspot
	match CURSOR_MODE:
		CURSOR_MODES.CENTERED: hotspot = Vector2(22.5, 22.5)
		CURSOR_MODES.POINTER: hotspot = Vector2.ZERO
	Input.set_custom_mouse_cursor(img, Input.CURSOR_ARROW, hotspot)

func selected(): 
	global.emit_signal("update_item_info", # set a condition to null to hide it
		my_item, # current item
		null, # extra info 
		null, # item bar max 
		null, # item bar value 
		null # bar timer duration
		)
	update_cursor()
	_update_held_item()
	
	if EQUIP_SOUND != null:
		sound_player.create_sound(EQUIP_SOUND)

func unselected(): pass

func pre_input_action(): pass

func primary(): pass

func secondary(): pass

func reload(): pass

func _quick_spawn(attack:String, type:String):
	var new_attack = global.aquire(attack)
	new_attack.setup(get_parent(), get_parent().get_global_mouse_position())
	get_parent().get_parent().call_deferred("add_child", new_attack)

func _update_held_item():
	get_parent().components["held_item"].sprite.texture = HELD_ITEM_TEXTURE
	get_parent().components["held_item"].anchor.position = HELD_ITEM_ANCHOR

func _update_cursor_on_unpause():
	if get_parent().inventory[global.selection] == my_item.to_lower():
		update_cursor()
