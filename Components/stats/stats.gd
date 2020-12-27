extends Node

onready var deplete_timer = $deplete_timer

#onready var poison_duration = $poison_duration
onready var poison_trigger = $poison_trigger
#onready var burning_duration = $burning_duration
onready var burning_trigger = $burning_trigger
#onready var bleeding_duration = $bleeding_duration
onready var bleeding_trigger = $bleeding_trigger

var duration_timers = []
var effect_timers = []

signal health_changed(type)
signal status_recieved(status)

#stats
export var MAX_HEALTH = 1
export var HEALTH = 1
export var BONUS_HEALTH = 0
export var DEFENCE = 0
export var DAMAGE = 1
export var TRUE_DAMAGE = 0

#status effects
var status_effects = {
	"poison": [0.0, 0], #duration, level (level 0 or below means no effect)
	"burning": [0.0, 0], 
	"bleeding": [0.0, 0] 
}

export var modifiers = {
	"poison": 0, # changes the level of a given status effect by the value
	"burning": 0, 
	"bleeding": 0, 
}

func _on_stats_tree_entered() -> void:
	get_parent().components["stats"] = self

func _ready():
	if HEALTH > MAX_HEALTH:
		HEALTH = MAX_HEALTH
	
	get_parent().connect("death", self, "entity_dies")

func entity_dies():
	if status_effects["burning"][0] != 0:
		var new_fire = global.aquire("Fire")
		new_fire.global_position = get_parent().global_position
		get_parent().get_parent().call_deferred("add_child", new_fire)

func change_health(value, true_value, type: String = "hurt"):
	BONUS_HEALTH = clamp(BONUS_HEALTH, 0, 99)
	var amount = value
	var true_amount = true_value
	var sum = amount + true_amount
	var final_type = type
	
	if sum < 0: 
		# if is an attack:
		amount = move_toward(amount, 0, DEFENCE) # account for defence here
		sum = amount + true_amount
		
		if sum == 0: 
			match type:
				"hurt": final_type = "block"
				_: final_type = ""
		
		for _i in range (abs(sum)):
			if BONUS_HEALTH > 0:
				BONUS_HEALTH -= 1
			elif HEALTH > 0:
				HEALTH -= 1
			sum -= 1
	elif sum == 0: # hit by a 0 damage attack
		final_type = ""
	else:
		#not an attack (i.e. healing):
		HEALTH += value
		HEALTH = clamp(HEALTH, 0, MAX_HEALTH)
		BONUS_HEALTH += true_value
		final_type = "heal"
	
	if get_parent() is Viewport: return
	if HEALTH <= 0:
		get_parent().death()
		return
	
	if get_parent().truName == "player": global.emit_signal("update_health")
	if final_type != "":
		emit_signal("health_changed", final_type)

func add_status_effect(status_effect="bleeding", duration=2.5, level=1.0):
	emit_signal("status_recieved", status_effect)
	if status_effects.keys().has(status_effect) == false: return
	status_effects[status_effect][0] += duration
	status_effects[status_effect][1] += level + modifiers.get(status_effect)
	if status_effects[status_effect][1] < 0: return
	
	match status_effect:
		"poison": 
			poison_trigger.wait_time = 2.2 / clamp(round(level + modifiers.get(status_effect)),1,9)
			if poison_trigger.time_left == 0: poison_trigger.start()
		"burning": 
			burning_trigger.wait_time = 0.7 / clamp(round(level + modifiers.get(status_effect)),1,9)
			if burning_trigger.time_left == 0: burning_trigger.start()
		"bleeding": 
			bleeding_trigger.wait_time = 1.5 / clamp(round(level + modifiers.get(status_effect)),1,9)
			if bleeding_trigger.time_left == 0: bleeding_trigger.start()
		_:
			global.var_debug_msg(self, 0, status_effect)

func _on_deplete_timer_timeout() -> void:
	for i in status_effects.keys().size():
		var se = status_effects.values()[i]
		# if duration is greater than 0, reduce duration by 0.1
		if se[0] > 0: se[0] -= deplete_timer.wait_time
		else:
			# if duration is less than or = to 0, set level to 0
			if se[0] <= 0: 
				se[1] = 0
			# if level is less than or equal to 0, set duration to 0 and stop timer
			if se[1] <= 0: 
				se[0] = 0
				match status_effects.keys()[i]:
					"poison": poison_trigger.stop()
					"burning": burning_trigger.stop()
					"bleeding": bleeding_trigger.stop()

func _on_poison_trigger_timeout() -> void: 
	if HEALTH + BONUS_HEALTH > 1: 
		change_health(0, -1, "poison")

func _on_burning_trigger_timeout() -> void: 
	change_health(0, -1, "burn")
	var fire = global.aquire("Fire")
	fire.global_position = get_parent().global_position + Vector2(rand_range(-8,8), rand_range(-8,8))
	fire.find_node("fuel").wait_time = 1.5
	fire.velocity = Vector2(rand_range(0,1), rand_range(0,1)).normalized() * 50
	get_parent().get_parent().call_deferred("add_child", fire)
	
	# the fire that spawns would inflict fire inself, meaning the status effect would last forever
	# to counteract this, I do this hack to reduce the status effect level and duration
	var fire_status = fire.find_node("hitbox").STATUS_EFFECT
	add_status_effect("burning", fire_status["duration"]*-1, fire_status["level"]*-1)

func _on_bleeding_trigger_timeout() -> void: 
	change_health(0, -1, "bleed")
