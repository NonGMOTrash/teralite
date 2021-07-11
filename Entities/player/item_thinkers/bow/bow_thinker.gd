extends Thinker

const ARROW = preload("res://Entities/Attacks/Projectile/arrow/arrow.tscn")

export var max_charge_time = 1.2
export var min_charge_time = 0.5
export var cooldown_time = 0.2
export var buffer_frames = 12

onready var cooldown = $cooldown
onready var charge = $charge
onready var buffer = $buffer

export(String) var CHARGE_ANIM

enum {
	IDLE,
	CHARGING
}

var state = IDLE
var buffering_shot = false
var buffer_time = buffer_frames * (1.0/60.0)

func _ready():
	cooldown.wait_time = cooldown_time
	charge.wait_time = max_charge_time

func selected():
	.selected()
	global.emit_signal("update_item_info", # set a condition to null to hide it
		display_name, # current item
		null, # extra info
		max_charge_time, # item bar max
		0.001, # item bar value
		null # bar timer duration
		)

func unselected():
	state = IDLE
	charge.stop()

func _process(_delta):
	# PROBLEM_NOTE: not ideal to check this every frame in _process()
	if state == IDLE: return
	global.emit_signal("update_item_info", # set a condition to null to hide it
		display_name, # current item
		null, # extra info
		max_charge_time, # item bar max
		abs(charge.time_left - max_charge_time), # item bar value
		null # bar timer duration
	)

func pre_input_action():
	if Input.is_action_just_pressed("primary_action") and cooldown.time_left == 0:
		charge.start()
		state = CHARGING
		if get_parent().components["held_item"] != null:
			get_parent().components["held_item"].animation.play(CHARGE_ANIM)

func get_ready():
	if cooldown.time_left > 0: return false
	elif state == IDLE: return false
	else: return true

func primary():
	.primary()
	
	var held_item = get_parent().components["held_item"]
	if held_item != null:
		held_item.animation.stop()
		held_item.sprite.texture = held_item.original_texture
		held_item.sprite.hframes = 1
		held_item.sprite.frame = 0
		held_item.sprite.frame_coords = Vector2.ZERO
	
	var charge_time = charge.wait_time - charge.time_left
	if charge_time < min_charge_time and buffering_shot == false:
		if min_charge_time - charge_time > buffer_time:
			charge.stop()
			cooldown.start()
			state = IDLE
#			global.emit_signal("update_item_info", # set a condition to null to hide it
#				display_name, # current item
#				null, # extra info
#				null, # item bar max
#				null, # item bar value
#				null # bar timer duration
#			)
			return
		
		buffering_shot = true
		buffer.wait_time = min_charge_time - charge_time
		buffer.start()
		return
	
	buffering_shot = false
	buffer.stop()
	
	var arrow = ARROW.instance()
	var charge_percent =  abs(charge.time_left - max_charge_time) / max_charge_time * 100.0
	var damage = 1
	if charge_percent > 45: damage += 1
	if charge_percent > 98: damage += 1
	
	#       \/ can't check components because arrow isn't in the scene tree yet
	arrow.find_node("stats").DAMAGE = damage
	arrow.SPEED = 50 + charge_percent * 3.5
	arrow.RANGE = arrow.SPEED / 1.8
	arrow.ACCELERATION = -((100 - charge_percent) * 1.8)
	arrow.setup(player, player.get_global_mouse_position())
	global.nodes["ysort"].add_child(arrow)
	cooldown.start()
	
	state = IDLE
	global.emit_signal("update_item_info", # set a condition to null to hide it
		display_name, # current item
		null, # extra info
		null, # item bar max
		null, # item bar value
		null # bar timer duration
	)

func _on_cooldown_timeout() -> void:
	global.emit_signal("update_item_info", # set a condition to null to hide it
		display_name, # current item
		null, # extra info
		max_charge_time, # item bar max
		0.001, # item bar value
		null # bar timer duration
		)
	if Input.is_action_pressed("primary_action"):
		charge.start()
		state = CHARGING
		if get_parent().components["held_item"] != null:
			get_parent().components["held_item"].animation.play(CHARGE_ANIM)

func _on_buffer_timeout() -> void:
	primary()
