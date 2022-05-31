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
export var ITEM_BAR_TEXTURE: Texture

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
var item_scene: Entity
var max_frame := HELD_ITEM_FRAMES.x * HELD_ITEM_FRAMES.y - 1
var accurate_mouse_pos := Vector2.ZERO
var times_used: int = 0

# maybe make this a global signal??
signal update_ui(bar_max, bar_value, info_string)

func _ready():
	# error checking stuff
	if my_item == "":
		push_error("my_item was not set")
		queue_free()
	if player.truName != "player":
		push_error("thinker's parent was not a player")
		queue_free()
	if CURSOR == null:
		push_warning("%s does not have a cursor" % get_name())
	
	player.connect("swapped_item", self, "_check_if_selected")
	player.connect("death", self, "_death_drop")
	global.connect("unpaused", self,"_update_cursor_on_unpause")
	
	if global.selection == slot:
		selected()
		if EQUIP_SOUND != null:
			sound_player.create_sound(EQUIP_SOUND)
	
	if player.get_name() == "player":
		global.emit_signal("update_item_bar", player.inventory)

# PROBLEM_NOTE: this is kinda bad because the name implies a return value
func _check_if_selected(swapped_item) -> void:
	if global.selection == slot:
		selected()
	else:
		unselected()

# PROBLEM_NOTE: i have to have this be _process() instead of _input() because automatic weapons won't
# work otherwise. i guess godot doesn't count holding a mouse button as an input. i tried fixing this
# by having a holding_primary variable but i couldn't get it to work.
func _process(_delta: float):
	if global.selection != slot:
		return
	
	var held_item: Node2D = player.components["held_item"]
	if held_item.sprite.flip_v == false:
		held_item.sprite.rotation_degrees = HELD_ITEM_ROTATION
	else:
		held_item.sprite.rotation_degrees = -HELD_ITEM_ROTATION
	
	pre_input_action()
	
	if Input.is_action_just_pressed("reload_item"):
		reload()
		return
	
	if Input.is_action_pressed("drop_item"):
		if player.inventory[global.selection] == null: return
		var new_item_entity: Entity = item_scene.duplicate()
		
		if new_item_entity == null: return
		var dir_vector = player.global_position.direction_to(global.get_look_pos())
		new_item_entity.global_position = player.global_position #+ dir_vector * 16
		new_item_entity.SOURCE = player
		var velo = dir_vector * 150
		velo += player.velocity / 1.5
		new_item_entity.velocity = velo + player.velocity / 3
		new_item_entity.times_used = times_used
		refs.ysort.add_child(new_item_entity)
		
		delete()
		return
	
	if get_ready() == false and auto_ready_check == true:
		return
	
	match PRIMARY_ACTION_MODE:
		ACTION_MODES.SEMI:
			if Input.is_action_just_pressed("primary_action"):
				primary()
		ACTION_MODES.AUTOMATIC:
			if Input.is_action_pressed("primary_action"):
				primary()
		ACTION_MODES.RELEASE:
			if Input.is_action_just_released("primary_action"):
				primary()
		ACTION_MODES.HOLD:
			if (
				Input.is_action_just_pressed("primary_action") or
				Input.is_action_just_released("primary_action")
			):
				primary()
	
	match SECONDARY_ACTION_MODE:
		ACTION_MODES.SEMI:
			if Input.is_action_just_pressed("secondary_action"):
				secondary()
		ACTION_MODES.AUTOMATIC:
			if Input.is_action_pressed("secondary_action"):
				secondary()
		ACTION_MODES.RELEASE:
			if Input.is_action_just_released("secondary_action"):
				secondary()
		ACTION_MODES.HOLD:
			if (
				Input.is_action_just_pressed("secondary_action") or
				Input.is_action_just_released("secondary_action")
			):
				secondary()

func get_ready() -> bool:
	return true

func update_cursor(texture: Texture = null):
	if texture != null:
		CURSOR = texture
	var hotspot
	match CURSOR_MODE:
		CURSOR_MODES.CENTERED: hotspot = Vector2(13.5, 13.5)
		CURSOR_MODES.POINTER: hotspot = Vector2.ZERO
	Input.set_custom_mouse_cursor(CURSOR, Input.CURSOR_ARROW, hotspot)

func selected():
	global.emit_signal("update_item_info", # set a condition to null to hide it
		display_name, # current item
		null, # extra info
		null, # item bar max
		null, # item bar value
		null # bar timer duration
	)
	
	if player.components["held_item"].sprite.frame > max_frame:
		player.components["held_item"].sprite.frame = max_frame
	
	player.components["held_item"].sprite.hframes = HELD_ITEM_FRAMES.x
	player.components["held_item"].sprite.vframes = HELD_ITEM_FRAMES.y
	if EQUIP_ANIM == null:
		player.components["held_item"].animation.stop()
	
	if RESET_HELD_ITEM_FLIPPING == true:
		player.components["held_item"].reversed = false
	
	if player.inventory[global.selection] == my_item.to_lower():
		update_cursor()
		_update_held_item()
	
	if EQUIP_SOUND != null:
		sound_player.create_sound(EQUIP_SOUND)
	if EQUIP_ANIM != "":
		player.components["held_item"].animation.play(EQUIP_ANIM)

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

func _update_held_item():
	if HELD_ITEM_TEXTURE == null:
		HELD_ITEM_TEXTURE = load("res://Misc/generic.png")
	
	var held_item: Node2D = player.components["held_item"]
	held_item.sprite.texture = HELD_ITEM_TEXTURE
	held_item.original_offset = HELD_ITEM_OFFSET
	if held_item.sprite.flip_v == false:
		held_item.sprite.offset = HELD_ITEM_OFFSET
		held_item.sprite.rotation_degrees = HELD_ITEM_ROTATION
	else:
		held_item.sprite.offset = -HELD_ITEM_OFFSET
		held_item.sprite.rotation_degrees = -HELD_ITEM_ROTATION
	held_item.anchor.position = HELD_ITEM_ANCHOR

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
	
	refs.item_bar.replace_icon(slot, null)
	
	queue_free()

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		accurate_mouse_pos = global.get_look_pos()
	
	if not Input.is_action_pressed("drop_item"):
		if ITEM_BAR_TEXTURE != null:
			refs.item_bar.replace_icon(slot, ITEM_BAR_TEXTURE)
		else:
			refs.item_bar.replace_icon(slot, HELD_ITEM_TEXTURE)

func _death_drop():
	var item = item_scene.duplicate()
	item.SOURCE = player
	item.global_position = player.global_position
	item.velocity = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0)).normalized() * 100
	refs.ysort.call_deferred("add_child", item)
