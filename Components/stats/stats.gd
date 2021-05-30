extends Node

# PROBLEM_NOTE: add these to global.gd, and have them preloaded in hitboxes instead of here
const burning = preload("res://Components/stats/status_effects/burning/burning.tscn")
const poison = preload("res://Components/stats/status_effects/poison/poison.tscn")
const bleed = preload("res://Components/stats/status_effects/bleed/bleed.tscn")
const speed = preload("res://Components/stats/status_effects/speed/speed.tscn")
const slowness = preload("res://Components/stats/status_effects/speed/slowness/slowness.tscn")
const regen = preload("res://Components/stats/status_effects/regeneration/regeneration.tscn")

var duration_timers = []
var effect_timers = []

signal health_changed(type, result, net)
signal status_recieved(status)

#stats
export var MAX_HEALTH = 1
export var HEALTH = 1
export var BONUS_HEALTH = 0
export var DEFENCE = 0
var armor = 0
var reset_armor = false
export var DAMAGE = 1
export var TRUE_DAMAGE = 0

var status_effects = {
	"poison": null,
	"bleed": null,
	"burning": null,
	"speed": null,
	"slowness": null,
	"regeneration": null,
}

export var modifiers = {
	"poison": 0, # changes the level of a given status effect by the value
	"burning": 0, 
	"bleeding": 0, 
	"speed": 0,
	"slowness": 0,
	"regeneration": 0,
}

func _on_stats_tree_entered():
	get_parent().components["stats"] = self

func _ready():
	if HEALTH > MAX_HEALTH:
		HEALTH = MAX_HEALTH
	armor = DEFENCE

func change_health(value, true_value, type: String = "hurt") -> String:
	BONUS_HEALTH = clamp(BONUS_HEALTH, 0, 99)
	var amount = value
	var true_amount = true_value
	var sum = amount + true_amount
	var result_type = type
	var net: int
	
	# PROBLEM_NOTE: i can probably do this same calculation with a lot less loops. try it maybe
	
	if sum < 0: 
		# if is an attack:
		# amount = move_toward(amount, 0, DEFENCE) # account for defence here OLD
		
		# NEW defence calculation
		if armor < 0 and amount < 0:
			amount += armor
		else:
			while amount != 0 and armor > 0:
				armor -= 1
				amount += 1
		
		if reset_armor == true:
			armor = DEFENCE
			reset_armor = false
		
		if armor <= 0: 
			reset_armor = true
		
		sum = amount + true_amount
		net = sum
		
		if sum == 0: 
			match type:
				"hurt": result_type = "block"
				_: result_type = ""
		
		for _i in range (abs(sum)):
			if BONUS_HEALTH > 0:
				BONUS_HEALTH -= 1
			elif HEALTH > 0:
				HEALTH -= 1
			sum -= 1
	elif sum == 0: # hit by a 0 damage attack
		result_type = ""
		# PROBLEM_NOTE, maybe i should make the type here block
	else:
		# not an attack
		HEALTH += value
		HEALTH = clamp(HEALTH, 0, MAX_HEALTH)
		BONUS_HEALTH += true_value
		result_type = "heal"
	
	if HEALTH <= 0:
		if get_parent().truName == "player" and type != "hurt":
			var msg: String
			match type:
				"burn": msg = "Death by fire."
				"poison": msg = "Death by poison."
				"bleed": msg = "Death by bleeding."
			get_parent().death_message = msg
			get_parent().force_death_msg = true
		
		get_parent().death()
		return "killed"
	
	# PROBLEM_NOTE: would be better to put this in the player script instead of here
	if get_parent().truName == "player": 
		global.emit_signal("update_health")
	
	if result_type != "":
		emit_signal("health_changed", type, result_type, net)
		return result_type
	else:
		return ""

func add_status_effect(new_status_effect:String, duration=2.5, level=1.0):
	var status_effect = new_status_effect
	match status_effect:
		"burning": status_effect = burning.instance()
		"poison": status_effect = poison.instance()
		"bleed": status_effect = bleed.instance()
		"speed": status_effect = speed.instance()
		"slowness": status_effect = slowness.instance()
		"regeneration": status_effect = regen.instance()
		_: 
			push_error("status effect '%s' does not exist" % status_effect)
			return
	
	var status_name = status_effect.get_name()
	
	emit_signal("status_recieved", status_name)
	
	if not status_name in status_effects.keys(): return
	
	if status_effects[status_name] == null and duration > 0 and level > 0: 
		status_effect.INIT_DURATION = duration
		status_effect.level = level
		call_deferred("add_child", status_effect)
	elif status_effects[status_name] != null:
		status_effect = status_effects[status_name]
		status_effect.duration.wait_time = max(status_effect.duration.wait_time + duration, 0.01)
		status_effect.level += level
	
