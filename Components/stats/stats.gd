extends Node

# PROBLEM_NOTE: add these to global.gd, and have them preloaded in hitboxes instead of here
const burning := preload("res://Components/stats/status_effects/burning/burning.tscn")
const poison := preload("res://Components/stats/status_effects/poison/poison.tscn")
const bleed := preload("res://Components/stats/status_effects/bleed/bleed.tscn")
const speed := preload("res://Components/stats/status_effects/speed/speed.tscn")
const slowness := preload("res://Components/stats/status_effects/speed/slowness/slowness.tscn")
const regen := preload("res://Components/stats/status_effects/regeneration/regeneration.tscn")
const resistance := preload("res://Components/stats/status_effects/resistance/resistance.tscn")
const infection := preload("res://Components/stats/status_effects/infection/infection.tscn")
const ZOMBIE_PATH := "res://Entities/zombie/zombie.tscn"
# /\ this is terrible, but i have to do it to prevent cyclic reference

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
export var DAMAGE = 1
export var TRUE_DAMAGE = 0

var status_effects = {
	"poison": null,
	"bleed": null,
	"burning": null,
	"speed": null,
	"slowness": null,
	"regeneration": null,
	"resistance": null,
	"infection": null,
}

# PROBLEM_NOTE: should add a 'ALL' modifier
export(float) var poison_modifier: float = 0
export(float) var burning_modifier: float = 0
export(float) var bleed_modifier: float = 0
export(float) var speed_modifier: float = 0
export(float) var slowness_modifier: float = 0
export(float) var regeneration_modifier: float = 0
export(float) var resistance_modifier: float = 0
export(float) var infection_modifier: float = 0

export var DAMAGE_NUMBER: PackedScene

onready var entity = get_parent()
var damage_number: Node2D
var damage_number_block: Node2D

func _on_stats_tree_entered():
	get_parent().components["stats"] = self

func _ready():
	if HEALTH > MAX_HEALTH:
		HEALTH = MAX_HEALTH
	armor = DEFENCE

func change_health(value: int, true_value: int, type: String = "hurt") -> String:
	BONUS_HEALTH = clamp(BONUS_HEALTH, 0, 99)
	var amount = value
	var true_amount = true_value
	var sum = amount + true_amount
	var result_type = type
	var net: int
	
	# PROBLEM_NOTE: i can probably do this same calculation with a lot less loops. try it maybe
	
	if sum < 0: 
		# defence calculation
		if armor < 0 and amount < 0:
			amount += armor # << for negative defence
		else:
			var new_amount: int = amount
			for i in abs(amount):
				if armor == 0:
					if amount != 0:
						armor = DEFENCE
					continue
				else:
					armor -= 1
					new_amount += 1 # adding because damage is negative
			amount = new_amount
		
		sum = amount + true_amount
		net = sum
		
		if sum == 0: 
			match type:
				"hurt": result_type = "block"
				"infect": result_type = "block"
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
	
	# damage number
	if entity.name != "player" and global.settings["damage_numbers"] == true and not entity is Attack:
		if is_instance_valid(damage_number) and damage_number.type == result_type:
			damage_number.animation.seek(0, true)
			damage_number.amount += abs(amount + true_amount)
			damage_number._ready()
			damage_number.global_position = entity.global_position
			if is_instance_valid(damage_number_block):
				damage_number.global_position.x -= 8
		else:
			var number := DAMAGE_NUMBER.instance()
			number.amount = abs(amount + true_amount)
			number.type = result_type
			number.position = entity.global_position
			damage_number = number
			refs.ysort.get_ref().add_child(number)
		
		var blocked: int = abs((value + true_value) - (amount + true_amount))
		if blocked > 0:
			damage_number.position.x -= 8
			damage_number.type = "hurt"
			damage_number._ready()
			
			if is_instance_valid(damage_number_block):
				damage_number_block.animation.seek(0, true)
				damage_number_block.amount += abs(blocked)
				damage_number_block._ready()
				damage_number_block.global_position = entity.global_position + Vector2(8, 0)
			else:
				var blocked_number := DAMAGE_NUMBER.instance()
				blocked_number.amount = abs(blocked)
				blocked_number.type = "block"
				blocked_number.position = entity.global_position + Vector2(8, 0)
				damage_number_block = blocked_number
				refs.ysort.get_ref().add_child(blocked_number)
	
	if HEALTH <= 0:
		if entity.truName == "player" and type != "hurt":
			var msg: String
			match type:
				"burn": msg = "burned to death"
				"poison": msg = "died of poison"
				"bleed": msg = "bleed out"
				"infect": msg = "joined the horde"
			entity.death_message = msg
			entity.force_death_msg = true
		
		if type == "infect" and not entity.INANIMATE:
			var zombie: Entity = load(ZOMBIE_PATH).instance()
			zombie.global_position = entity.global_position
			var stats = entity.components["stats"]
			if stats != null:
				zombie.find_node("stats").MAX_HEALTH = stats.MAX_HEALTH
				zombie.find_node("stats").HEALTH = stats.HEALTH
			refs.ysort.get_ref().call_deferred("add_child", zombie)
		
		entity.death()
		return "killed"
	
	# PROBLEM_NOTE: would be better to put this in the player script instead of here
	if entity.truName == "player": 
		global.emit_signal("update_health")
	
	if result_type != "":
		emit_signal("health_changed", type, result_type, net)
		return result_type
	else:
		return ""

func add_status_effect(new_status_name:String, duration=2.5, level=1.0):
	var existing_status: Status_Effect = status_effects[new_status_name]
	
	if not new_status_name in status_effects.keys():
		push_error("status name '%s' not found in keys" % new_status_name)
		return
	
	var modded_level: float = level + get_modifier(new_status_name)
	
	if not is_instance_valid(existing_status):
		# no existing status
		if duration <= 0 or modded_level <= 0:
			return
		
		var status_effect: Status_Effect
		match new_status_name:
			"burning": status_effect = burning.instance()
			"poison": status_effect = poison.instance()
			"bleed": status_effect = bleed.instance()
			"speed": status_effect = speed.instance()
			"slowness": status_effect = slowness.instance()
			"regeneration": status_effect = regen.instance()
			"resistance": status_effect = resistance.instance()
			"infection": status_effect = infection.instance()
			_:
				push_error("status effect '%s' does not exist" % status_effect)
				return
		
		status_effect.DURATION_TIME = duration
		status_effect.level = modded_level
		call_deferred("add_child", status_effect)
		yield(status_effect, "ready")
		emit_signal("status_recieved", new_status_name)
	else:
		# existing status
		existing_status.level += modded_level
		
		if existing_status.level <= 0:
			existing_status.depleted()
			existing_status.queue_free()
			return
		existing_status.duration.wait_time = max(existing_status.duration.wait_time + duration, 0.01)
		existing_status.duration.start()

func get_modifier(status:String) -> float:
	match status:
		"poison": return poison_modifier
		"burning": return burning_modifier
		"bleed": return bleed_modifier
		"speed": return speed_modifier
		"slowness": return slowness_modifier
		"regeneration": return regeneration_modifier
		"resistance": return resistance_modifier
		"infection": return infection_modifier
		_:
			push_error("%s is not a valid status")
			return 0.0
		
