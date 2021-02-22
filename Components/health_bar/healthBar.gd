extends TextureProgress

onready var stats = get_parent().components["stats"]
onready var bonus = $bonus
onready var armor = $armor
onready var timer = $Timer

export(Gradient) var PROGRESS_GRAD
export(Gradient) var BONUS_GRAD
export(Gradient) var ARMOR_GRAD

func _on_healthBar_tree_entered() -> void:
	get_parent().components["health_bar"] = self

func _ready(): 
	if stats == null:
		queue_free()
		return
	update()
	stats.connect("health_changed", self, "update_bar")
	
	visible = false
	
	bonus.max_value = max_value

func update_bar(_type) -> void:
	if get_parent().get_name() == "player":
		visible = false
		return
	else:
		visible = true
		timer.start()
	
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
	if stats.DEFENCE > 0:
		armor.visible = true
		armor.max_value = stats.DEFENCE
		#armor.step = 9.5 * (armor.max_value / 100)
		armor.value = stats.armor
		armor.tint_progress = ARMOR_GRAD.interpolate(armor.ratio)
	else:
		armor.visible = false

func _on_Timer_timeout() -> void:
	visible = false
