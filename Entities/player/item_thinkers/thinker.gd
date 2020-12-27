extends Node
class_name Thinker

enum ACTION_MODES {
	SEMI,
	AUTOMATIC,
	RELEASE
}

export var auto_ready_check = true
export(ACTION_MODES) var PRIMARY_ACTION_MODE = ACTION_MODES.SEMI
export(ACTION_MODES) var SECONDARY_ACTION_MODE = ACTION_MODES.SEMI

export var my_item = "" 

var bar_max = 0.0
var bar_value = 0.0

# maybe make this a global signal??
signal update_ui(bar_max, bar_value, info_string)

func _ready():
	
	if my_item == "":
		global.var_debug_msg(self, 1, "my_item")
		queue_free()
	
	if get_parent().truName != "player":
		global.debug_msg(self, 1, "my parent was not player")
		queue_free()
	
	get_parent().connect("swapped_item", self, "_check_if_selected")
	
	if get_parent().inventory[global.selection] == my_item: selected()
	if get_parent().get_name() == "player":
		global.emit_signal("update_item_bar", get_parent().inventory)

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

func selected(): 
	global.emit_signal("update_item_info", # set a condition to null to hide it
		my_item, # current item
		null, # extra info 
		null, # item bar max 
		null, # item bar value 
		null # bar timer duration
		)

func unselected(): pass

func pre_input_action(): pass

func primary(): pass

func secondary(): pass

func reload(): pass

func _quick_spawn(thing:String, type:String):
	var new_thing = global.aquire(thing)
	new_thing.setup(get_parent(), get_parent().get_global_mouse_position())
	get_parent().get_parent().call_deferred("add_child", new_thing)
