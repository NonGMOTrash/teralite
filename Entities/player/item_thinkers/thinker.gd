extends Node
class_name Thinker

enum ACTION_MODES { SEMI, AUTOMATIC, RELEASE, HOLD }

enum CURSOR_MODES { POINTER, CENTERED }

export var auto_ready_check = true
export(ACTION_MODES) var PRIMARY_ACTION_MODE = ACTION_MODES.SEMI
export(ACTION_MODES) var SECONDARY_ACTION_MODE = ACTION_MODES.SEMI
export(Texture) var HELD_ITEM_TEXTURE
export(Vector2) var HELD_ITEM_OFFSET
export(Vector2) var HELD_ITEM_ANCHOR = Vector2(8, 0)
export(float, -360.0, 360.0) var HELD_ITEM_ROTATION := 0.0
export(Vector2) var HELD_ITEM_FRAMES := Vector2(1, 1)
export(bool) var RESET_HELD_ITEM_FLIPPING := true

export(String) var PRIMARY_ANIM
export(String) var SECONDARY_ANIM
export(String) var RELOAD_ANIM
export(String) var EQUIP_ANIM

export var my_item := ""
export var display_name := "NAME_MISSING"

export(Texture) var CURSOR
export(CURSOR_MODES) var CURSOR_MODE

export(AudioStream) var EQUIP_SOUND

onready var sound_player = $sound_player
onready var player := get_parent() as Entity

var slot := 0
var bar_max = 0.0
var bar_value = 0.0
var item_scene = res.aquire(my_item)
var max_frame := HELD_ITEM_FRAMES.x * HELD_ITEM_FRAMES.y - 1

# maybe make this a global signal??
signal update_ui(bar_max, bar_value, info_string)


func _ready():
	# error checking stuff
	if my_item == "":
		push_error("my_item was not set")
		queue_free()
	
	if not my_item in res.data:
		push_error("%s is not in res.gd" % my_item)
	
	if player.truName != "player":
		push_error("thinker's parent was not a player")
		queue_free()
	
	if CURSOR == null:
		push_warning("%s does not have a cursor" % get_name())
	
	player.connect("swapped_item", self, "_check_if_selected")
	
	global.connect("unpaused", self,"_update_cursor_on_unpause")
	
	if player.inventory[global.selection] == my_item: selected()
	if player.get_name() == "player":
		global.emit_signal("update_item_bar", player.inventory)
	
	if player.inventory[global.selection] == my_item.to_lower():
		selected()
	elif EQUIP_SOUND != null:
		sound_player.create_sound(EQUIP_SOUND)

# PROBLEM_NOTE: this is kinda bad because the name implies a return value
func _check_if_selected(swapped_item) -> void:
	if swapped_item == my_item.to_lower():
		selected()
	else:
		unselected()

# PROBLEM_NOTE: i have to have this be _process() instead of _input() because automatic weapons won't
# work otherwise. i guess godot doesn't count holding a mouse button as an input. i tried fixing this
# by having a holding_primary variable but i couldn't get it to work.
func _process(_delta: float):
	if global.selection != slot:
		return
	
	pre_input_action()
	
	if Input.is_action_just_pressed("reload_item"):
		reload()
		return
	
	if Input.is_action_pressed("drop_item"):
		if player.inventory[global.selection] == null: return
		var new_item_entity = res.aquire_entity(my_item)
		
		if new_item_entity == null: return
		var dir_vector = player.global_position.direction_to(player.get_global_mouse_position())
		new_item_entity.global_position = player.global_position #+ dir_vector * 16
		new_item_entity.SOURCE = player
		var velo = dir_vector * 150
		velo += player.velocity / 1.5
		new_item_entity.velocity = velo
		refs.ysort.get_ref().add_child(new_item_entity)
		
		delete()
		return
	
	if get_ready() == false and auto_ready_check == true:
		return
	
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
		ACTION_MODES.HOLD:
			if (
				Input.is_action_just_pressed("primary_action") or
				Input.is_action_just_released("primary_action")
			):
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
		ACTION_MODES.HOLD:
			if (
				Input.is_action_just_pressed("secondary_action") or
				Input.is_action_just_released("secondary_action")
			):
				secondary()
				return

func get_ready() -> bool:
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
		display_name, # current item
		null, # extra info
		null, # item bar max
		null, # item bar value
		null # bar timer duration
		)

	if player.inventory[global.selection] == my_item.to_lower():
		update_cursor()
		_update_held_item()
	
	if EQUIP_SOUND != null:
		sound_player.create_sound(EQUIP_SOUND)
	if EQUIP_ANIM != "":
		player.components["held_item"].animation.play(EQUIP_ANIM)
	
	if player.components["held_item"].sprite.frame > max_frame:
		player.components["held_item"].sprite.frame = max_frame
	
	player.components["held_item"].sprite.hframes = HELD_ITEM_FRAMES.x
	player.components["held_item"].sprite.vframes = HELD_ITEM_FRAMES.y
	if EQUIP_ANIM == null:
		player.components["held_item"].animation.stop()
	
	if RESET_HELD_ITEM_FLIPPING == true:
		player.components["held_item"].reversed = false

func unselected():
	pass

func pre_input_action():
	pass

func primary():
	if PRIMARY_ANIM != "":
		player.components["held_item"].animation.play(PRIMARY_ANIM)

func secondary():
	if SECONDARY_ANIM != "":
		player.components["held_item"].animation.play(SECONDARY_ANIM)

func reload():
	if RELOAD_ANIM != "":
		player.components["held_item"].animation.play(RELOAD_ANIM)

func quick_spawn(attack:String, deferred:=true) -> void:
	var new_attack = res.aquire_attack(attack)#.instance()
	new_attack.setup(player, player.get_global_mouse_position())
	if deferred == true:
		refs.ysort.get_ref().call_deferred("add_child", new_attack)
	else:
		refs.ysort.get_ref().add_child(new_attack)

func _update_held_item():
	if HELD_ITEM_TEXTURE == null:
		push_error("HELD_ITEM_TEXTURE is null")
		HELD_ITEM_TEXTURE = load("res://Misc/generic.png")
	
	player.components["held_item"].sprite.texture = HELD_ITEM_TEXTURE
	player.components["held_item"].sprite.rotation_degrees = HELD_ITEM_ROTATION
	player.components["held_item"].anchor.position = HELD_ITEM_ANCHOR

func _update_cursor_on_unpause():
	if player.inventory[global.selection] == my_item.to_lower():
		update_cursor()

func delete():
	player.inventory[global.selection] = null
	player.held_item.sprite.texture = null
	player.held_item.sprite.rotation_degrees = 0
	global.emit_signal("update_item_info", # set a condition to null to hide it
		null, # current item
		null, # extra info
		null, # item bar max
		null, # item bar value
		null # bar timer duration
	)
	
	if player.get_name() == "player":
		global.emit_signal("update_item_bar", player.inventory)
	
	queue_free()
