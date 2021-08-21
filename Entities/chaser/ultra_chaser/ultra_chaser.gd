extends Entity

onready var brain := $brain
onready var animation := $AnimationPlayer

export(int) var dash_power

func _on_action_lobe_action(action, target) -> void:
	var dash_direction = Vector2.ZERO
	
	if action == "fdash": 
		dash_direction = global_position.direction_to(target.global_position)
	elif action == "sdash":
		# PROBLEM_NOTE: might be a better way to do this
		dash_direction = global_position.direction_to(target.global_position)
		var a = dash_direction.x
		var b = dash_direction.y
		dash_direction = Vector2(b, a)
	
	dash_direction = dash_direction.normalized()
	
	apply_force(dash_direction * dash_power)
	animation.play("dash")
	animation.queue("speed")
