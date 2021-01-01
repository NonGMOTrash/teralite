extends Thinker

export var max_charge_time = 1.2
export var uncharge_time = 0.1
export var cooldown_time = 0.2

onready var cooldown = $cooldown
onready var charge = $charge
onready var uncharge = $uncharge

enum {
	IDLE,
	CHARGING
}

var state = IDLE

func _ready():
	cooldown.wait_time = cooldown_time
	charge.wait_time = max_charge_time
	uncharge.wait_time = uncharge_time

func selected():
	global.emit_signal("update_item_info", # set a condition to null to hide it
		my_item, # current item
		null, # extra info 
		max_charge_time, # item bar max 
		0.001, # item bar value 
		null # bar timer duration
		)
	update_cursor()

func _process(_delta):
	# PROBLEM_NOTE: this is bad for optimization
	if state == IDLE: return
	global.emit_signal("update_item_info", # set a condition to null to hide it
		my_item, # current item
		null, # extra info 
		max_charge_time, # item bar max 
		abs(charge.time_left - max_charge_time), # item bar value 
		null # bar timer duration
		)

func pre_input_action():
	if Input.is_action_just_pressed("primary_action") and cooldown.time_left == 0:
		charge.start()
		state = CHARGING
	elif Input.is_action_just_released("primary_action"):
		uncharge.start()

func get_ready():
	if cooldown.time_left > 0: return false
	elif state == IDLE: return false
	else: return true

func primary():
	var arrow = global.aquire("Arrow")
	var charge_percent =  abs(charge.time_left - max_charge_time) / max_charge_time * 100.0
	var damage = 0
	if charge_percent > 15: damage += 1
	if charge_percent > 45: damage += 1
	if charge_percent == 100: damage += 1
	
	# PROBLEM_NOTE: I can't check the components dictionary here because that is only updated at _ready()
	# I can solve this if I have components add themselves to it at _init() 
	arrow.find_node("stats").DAMAGE = damage
	arrow.SPEED = charge_percent * 3.5
	arrow.RANGE = arrow.SPEED / 2
	arrow.ACCELERATION = -((100 - charge_percent) * 1.8)
	arrow.setup(get_parent(), get_parent().get_global_mouse_position())
	get_parent().get_parent().add_child(arrow)
	cooldown.start()
	
	state = IDLE
	global.emit_signal("update_item_info", # set a condition to null to hide it
		my_item, # current item
		null, # extra info 
		null, # item bar max 
		null, # item bar value 
		null # bar timer duration
		)

func _on_uncharge_timeout() -> void:
	charge.stop()
	state = IDLE
	global.emit_signal("update_item_info", # set a condition to null to hide it
		my_item, # current item
		null, # extra info 
		null, # item bar max 
		null, # item bar value 
		null # bar timer duration
		)

func _on_cooldown_timeout() -> void:
	global.emit_signal("update_item_info", # set a condition to null to hide it
		my_item, # current item
		null, # extra info 
		max_charge_time, # item bar max 
		0.001, # item bar value 
		null # bar timer duration
		)
	if Input.is_action_pressed("primary_action"):
		charge.start()
		state = CHARGING
