extends Entity

export(float, 0.0, 1000.0) var throw_strength := 150.0

onready var stats = $stats

func _init():
	res.allocate("heart")

func _on_action_lobe_action(action, target) -> void:
	if target.components["stats"].HEALTH == target.components["stats"].MAX_HEALTH:
		return
	
	var heart = res.aquire_entity("heart")
	heart.player_only = false
	heart.healing = stats.DAMAGE * -1
	refs.ysort.get_ref().call_deferred("add_child", heart)
	
	yield(heart, "tree_entered")
	
	if action == "heal":
		heart.global_position = global_position.move_toward(target.global_position, 16)
		heart.apply_force(global_position.direction_to(target.global_position).normalized() * throw_strength)
	elif action == "heal_self":
		heart.global_position = global_position

