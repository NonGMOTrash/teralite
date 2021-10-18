extends Node

onready var action_lobe := get_parent() as Node
onready var brain := action_lobe.get_parent() as Node2D
onready var entity := brain.get_parent() as Entity
onready var cooldown_timer = $cooldown_timer

enum relations { hostile, friendly, myself }

enum tags { attack, defend, support }

export(relations) var target_type = relations.hostile
export(tags) var tag = tags.attack
export var custom_tag = ""
export(int, 0, 200) var best_distance = -1
export(int, 0, 10) var distance_weight = 1
export(int, 0, 100) var best_health_percent = -1
export(int, 0, 10) var health_weight = 0
export var status_effect = "null"
export(int, 0, 10) var status_weight = 0
export var respond_to_warning = false
export(int, 0, 10) var warning_weight = 0
export(float, 0, 1) var default_score = 1

export(float, 0.0, 60.0) var COOLDOWN = 1.2
export var GLOBAL_COOLDOWN = false
export(int, 0, 100) var ENERGY_COST = 0

var weight = stepify(rand_range(0, 1), 0.1)

var target_relation: String

func return_score(current: float, best: float, max_difference: float):
	var difference = abs(current-best)
	return range_lerp(difference, 0, max_difference, 1, 0)

func _ready(): 
	if custom_tag == "":
		tag = custom_tag
	else:
		match tag:
			tags.attack: tag = "attack"
			tags.defend: tag = "defend"
			tags.support: tag = "support"
	
	match target_type:
		relations.hostile: target_relation = "hostile"
		relations.friendly, relations.myself: target_relation = "friendly"
	
	action_lobe.actions.append(self)
	
	if action_lobe.AUTO_ACTION_WEIGHTING == false or action_lobe.actions.size() == 1:
		weight = 0
	
	if COOLDOWN == 0.0:
		cooldown_timer.queue_free()
	else:
		cooldown_timer.wait_time = COOLDOWN
		cooldown_timer.start()
		if GLOBAL_COOLDOWN == true:
			action_lobe.on_global_cooldown = true
	
	if target_type == relations.myself:
		action_lobe.acts_on_self = true

func evaluate(warned = false) -> Array: #-> [score, target]
	if COOLDOWN > 0 and cooldown_timer.time_left > 0:
		if target_type != relations.myself and brain.targets.size() > 0:
			return [-1, brain.targets[0]]
		else:
			return [-1, entity]
	
	var scores = []
	var targets = []
	
	var targets_to_check: Array
	if target_type == relations.myself:
		targets_to_check.append(entity)
	else:
		targets_to_check = brain.targets
	
	for i in targets_to_check.size():
		var target: Entity = targets_to_check[i]
		
		if (
			target_type == relations.myself and target == entity or
			global.get_relation(brain.entity, target) == target_relation
		):
			
			var stats = target.components["stats"]
			var score = []
			
			# adjusting for distance
			if distance_weight != 0:
				var distance = brain.global_position.distance_to(target.global_position)
				var distance_score = return_score(distance, best_distance, brain.SIGHT_RANGE)
				for x in distance_weight: score.append(distance_score)
			
			# adjusting for health percent
			if health_weight != 0 and stats != null:
				var percent = stats.HEALTH / stats.MAX_HEALTH * 100
				var health_score = return_score(percent, best_health_percent, 100.0)
				for x in health_weight: score.append(health_score)
			
			# adjusting for status effect
			if status_weight != 0 and stats != null and status_effect in stats.status_effects:
				var status_score = 0
				
				var the_status_effect = stats.status_effects[status_effect]
				if the_status_effect != null and the_status_effect.level != 0:
					status_score = 1
				
				for x in status_weight: score.append(status_score)
			
			# adjusting for warning
			if warning_weight != 0:
				var warning_score = 0
				if warned == true: warning_score = 1
				for x in warning_weight: score.append(warning_score)
			
			# adjusting for tag
			var my_tag = custom_tag
			if my_tag == "": my_tag = tag
			if action_lobe.tag_weight != 0 and action_lobe.tag_modifiers.has(my_tag) == true:
				for x in action_lobe.tag_weight: score.append(action_lobe.tag_modifiers[my_tag])
			
			# adjusting for custom score modification
			score = score_modification(score)
			
			if score.size() == 0: scores.append(default_score)
			else:
				var new_score = 0
				for num in score: new_score += num
				new_score /= score.size()
				# adjusting for weight
				new_score -= weight
				if new_score < 0: new_score = 0
				scores.append(new_score)
			
			targets.append(target)
	
	var final_score = -999
	var final_target
	
	for i in scores.size():
		if scores[i] > final_score:
			final_score = scores[i]
			final_target = targets[i]
	if get_name() == "shoot": print(final_score)
	return [final_score, final_target]

func score_modification(score): # for custom score modification
	return score

func _on_deweight_timer_timeout() -> void:
	weight *= 0.8

func _on_cooldown_timer_timeout() -> void:
	if GLOBAL_COOLDOWN == true:
		action_lobe.on_global_cooldown = false

func _on_action_tree_exiting() -> void:
	var index: int = action_lobe.actions.find(self)
	if index != -1:
		action_lobe.actions.remove(index)
