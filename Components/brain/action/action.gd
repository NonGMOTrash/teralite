extends Node

enum tags {
	attack,
	defend,
	support
}

export(tags) var tag = tags.attack
export var custom_tag = ""
export(int, 0, 200) var best_distance = -1
export(int, 0, 10) var distance_weight = 1
export(int, 0, 100) var best_health_percent = -1
export(int, 0, 10) var health_weight = 1
export var status_effect = "null"
export(int, 0, 10) var status_weight = 1
export var respond_to_warning = false
export(int, 0, 10) var warning_weight = 1

var weight = stepify(rand_range(0, 1), 0.1)

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
	
	get_parent().actions.append(self)
	
	if get_parent().actions.size() == 1:
		weight == 0

func get_score(warned = false):
	var scores = []
	var targets = []
	
	for i in get_parent().targets.size():
		var target = get_parent().targets[i]
		var stats = target.components["stats"]
		var score = []
		
		# adjusting for distance
		if distance_weight != 0:
			var distance = get_parent().global_position.distance_to(target.global_position)
			var distance_score = return_score(distance, best_distance, get_parent().SIGHT_RANGE)
			for x in distance_weight: score.append(distance_score)
		
		# adjusting for health percent
		if health_weight != 0 and stats != null:
			var percent = stats.HEALTH / stats.MAX_HEALTH * 100
			var health_score = return_score(percent, best_health_percent, 100.0)
			for x in health_weight: score.append(health_score)
		
		# adjusting for status effect
		if status_weight != 0 and stats != null:
			var status_score = 0
			if stats.status_effects.has(status_effect) and stats.status_effects[status_effect][0] != 0:
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
		if get_parent().tag_weight != 0 and get_parent().tag_modifiers.has(my_tag) == true:
			for x in get_parent().tag_weight: score.append(get_parent().tag_modifiers[my_tag])
		
		
		# adjusting for custom score modification
		score = score_modification(score)
		
		if score.size() == 0: scores.append(0)
		else:
			var new_score = 0
			for x in score.size(): new_score += score[i]
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
	
	#prints(get_name(), "->", final_target.get_name(), "score:"+str(final_score), "(weight:"+str(weight)+")")
	return [final_score, final_target]

func score_modification(score): # for custom score modification
	return score

#var w = 1
#func _process(_delta):
#	if get_name() != "archer": return
#	if w > 15:
#		print(weight)
#		w = 1
#	else:
#		w += 1

func _on_deweight_timer_timeout() -> void:
	weight *= 0.8
