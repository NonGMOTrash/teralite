extends Node

enum tags {
	attack,
	defend,
	support
}

export(tags) var tag = tags.attack
export var custom_tag = ""
export var best_distance = -1
export(int, -1, 100) var best_health_percent = -1
export var status_effect = "null"
export(float, 0.0, 3.0) var status_effect_multiplier = 2.0
export(float, 0.0, 3.0) var warning_multiplier = 1.0

func _ready(): 
	if custom_tag == "":
		tag = custom_tag
	else:
		match tag:
			tags.attack: tag = "attack"
			tags.defend: tag = "defend"
			tags.support: tag = "support"
	get_parent().actions.append(self)

func get_score(warned = false):
	var scores = []
	var targets = []
	
	for i in get_parent().targets.size():
		if get_parent().is_target_valid(i) == true:
			var score = 0
			var scorez = []
			
			var target = get_parent().targets[i]
			var pos = target.global_position
			var stats = target.components.get("stats")
			
			# adjusting for position
			if best_distance != -1:
				var distance = get_parent().global_position.distance_to(pos)
				scorez.append(range_lerp(distance, best_distance, get_parent().SIGHT_RANGE, 1, 0))
			
			# adjusting for best_health_percent
			if stats != null:
				if best_health_percent != -1:
					var health_percent = ((stats.HEALTH + stats.BONUS_HEALTH) / stats.MAX_HEALTH) * 100
					scorez.append(range_lerp(health_percent, best_health_percent, 100, 1, 0))
			
			for x in scorez.size(): score += scorez[x]
			if scorez.size() != 0: score /= scorez.size()
			
			# adjusting for tag multipler
			if get_parent().tag_favors.has(tag): score *= get_parent().tag_favors[tag]
			
			# adjusting for warning multipler
			if warned == true: score *= warning_multiplier
			
			# adjusting for status effect multipler
			if stats != null:
				if stats.status_effects.has(status_effect):
					if stats.status_effects[status_effect][0] > 0:
						score *= status_effect_multiplier
			
			# adjusting for custom score modification
			score = score_modification(score)
			
			# PROBLEM_NOTE: the scores are naturally always between 0 and 1, maybe fix?
			score = clamp(score, 0, 1)
			
			scores.append(score)
			targets.append(target)
	
	var final_score = -999
	var final_target
	
	for i in scores.size():
		if scores[i] > final_score:
			final_score = scores[i]
			final_target = targets[i]
	
	prints(get_name(), final_score)
	return [final_score, final_target]

func score_modification(score):
	return score
