extends TextureProgress

onready var entity = get_parent()
onready var stats = entity.components["stats"]
onready var bonus = $bonus
onready var armors = $armors
onready var armors_missing = $armors_missing
onready var armor_meter = $armor_meter

export(Gradient) var PROGRESS_GRAD
export(Gradient) var BONUS_GRAD
export(Gradient) var ARMOR_GRAD

func _on_healthBar_tree_entered():
	get_parent().components["health_bar"] = self

func _ready(): 
	if stats == null:
		push_error("health_bar could not find stats")
		queue_free()
		return
	update_bar(0, 0, 0)
	stats.connect("health_changed", self, "update_bar")
	
	if stats.HEALTH + stats.BONUS_HEALTH != stats.MAX_HEALTH:
		visible = true
	else:
		visible = false
	
	bonus.max_value = max_value

func update_bar(_type, _result, _net) -> void:
	if entity.get_name() == "player":
		visible = false
		return
	else:
		visible = true
	
	# health
	max_value = stats.MAX_HEALTH
	#step = 9.5 * (max_value / 100)
	value = stats.HEALTH
	tint_progress = PROGRESS_GRAD.interpolate(ratio)
	
	# bonus health
	if stats.BONUS_HEALTH > 0:
		bonus.visible = true
		if stats.BONUS_HEALTH > bonus.max_value:
			bonus.max_value = stats.BONUS_HEALTH
		#bonus.step = 9.5 * (bonus.max_value / 100)
		bonus.value = stats.BONUS_HEALTH
		bonus.tint_progress = BONUS_GRAD.interpolate(bonus.ratio)
	else:
		bonus.visible = false
	
	# armor
	if stats.DEFENCE > 4: # armor meter
		armor_meter.visible = true
		armors.visible = false
		armors_missing.visible = false
		armor_meter.max_value = stats.DEFENCE
		armor_meter.value = stats.armor
		#armor_meter.tint_progress = ARMOR_GRAD.interpolate(armor_meter.ratio)
	elif stats.DEFENCE > 0: # armor icons
		armors_missing.visible = true
		if stats.armor > 0:
			armors.visible = true
		else:
			armors.visible = false
		armor_meter.visible = false
		armors.rect_position.x = (22 - stats.DEFENCE * 6) / 2
		armors_missing.rect_position = armors.rect_position
		armors.rect_size.x = stats.armor * 6
		armors_missing.rect_size.x = stats.DEFENCE * 6
	else: # no armor
		armor_meter.visible = false
		armors.visible = false
		armors_missing.visible = false
