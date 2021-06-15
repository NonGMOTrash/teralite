extends Node

onready var brain := get_parent() as Node2D
onready var entity := brain.get_parent() as Entity
onready var action_timer = $action_timer
onready var energy_timer = $energy_timer

export(int, 0, 1000) var STARTING_ENERGY = 0
export(float, 0, 100) var ENERGY_REGEN = 0
export(int, 0, 1000) var MAX_ENERGY = 0
export var AUTO_ACT = true
export(float, 0.0, 0.99) var PATIENCE = 0.4
export(float, 0.0, 1.0) var ACTION_WEIGHTING = 0.2
export(float, 0.0, 1.0) var ACTION_DEWEIGHTING = 0.1
export var AUTO_ACTION_WEIGHTING = false
export var tag_modifiers = {
	"attack": 0.5,
	"defend": 0.5,
	"support": 0.5
}
export(int, 0, 10) var tag_weight = 0

var ACT_ON_WARNING = false

var on_cooldown = false
var energy = 50
var actions = []
var last_action_str = "idk lol"
var acts_on_self := false

signal action(action, target)

func _on_action_lobe_tree_entered():
	get_parent().action_lobe = self
	#if entity is Entity:
	get_parent().get_parent().components["action_lobe"] = self

func _ready() -> void:
	for action in actions:
		if action.respond_to_warning == true:
			ACT_ON_WARNING = true
			break
	
	energy = clamp(STARTING_ENERGY, 0, MAX_ENERGY)
	if ENERGY_REGEN == 0: 
		energy_timer.queue_free()
	else:
		energy_timer.wait_time = 1 / ENERGY_REGEN
		energy_timer.start()

func _on_energy_timer_timeout() -> void:
	energy = clamp(energy+1, 0, MAX_ENERGY)

func _on_action_timer_timeout() -> void:
	on_cooldown = false
	
	if AUTO_ACT == false:
		action_timer.stop()
		return
	
	if actions == []:
		action_timer.stop()
	elif brain.targets != [] or acts_on_self == true:
		act()
		yield(self, "action")
		
		# deciding optimal time for action_timer
		var last_action
		
		for action in actions:
			if action.get_name() == last_action_str:
				last_action = action
				break
		
		if last_action.COOLDOWN > 0 and actions.size() == 1 or last_action.GLOBAL_COOLDOWN == true:
			action_timer.wait_time = last_action.COOLDOWN
			return
		
		if last_action.ENERGY_COST != 0:
			action_timer.wait_time = last_action.ENERGY_COST / ENERGY_REGEN
			return
		
		if actions.size() > 1:
			var lowest_cooldown = 999
			for action in actions:
				if action.COOLDOWN != 0 and action.COOLDOWN < lowest_cooldown:
					lowest_cooldown = action.COOLDOWN
			action_timer.wait_time = lowest_cooldown
			return
		
		action_timer.wait_time = 1

func act(warned = false):
	if on_cooldown == true: return
	
	var chosen_action = null
	var target = null
	var highscore = -1
	
	for i in actions.size():
		var action = actions[i]
		var action_score = action.get_score(warned)
		
		if action_score[0] > highscore:
			chosen_action = action.get_name()
			highscore = action_score[0]
			target = action_score[1]
	
	if highscore <= PATIENCE: return
	
	if AUTO_ACTION_WEIGHTING == true: weight_actions(chosen_action)
	
	last_action_str = chosen_action
	emit_signal("action", chosen_action, target)

func weight_actions(chosen_action: String):
	for i in actions.size():
		var action = actions[i]
		if action.get_name() == chosen_action:
			action.weight += ACTION_WEIGHTING
		else:
			action.weight -= ACTION_DEWEIGHTING
		action.weight = clamp(action.weight, 0, 1)
