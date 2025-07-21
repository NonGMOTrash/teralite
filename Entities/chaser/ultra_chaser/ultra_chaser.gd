extends Entity

const DASH_EFFECT := preload("res://Effects/dash_effect/dash_effect.tscn")

onready var brain := $brain
onready var animation := $AnimationPlayer

export(int) var dash_power

func _on_action_lobe_action(action, target) -> void:
	if action == "fdash":
		attack_flash()
		get_tree().create_timer(0.5).connect("timeout", self, "action", ["fdash", target])
	else:
		action("sdash", target)

func action(action: String = "fdash", target: Entity = null) -> void:
	if !is_instance_valid(target):
		return
	
	var dash_direction := Vector2.ZERO
	
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
	
	var dash_effect = DASH_EFFECT.instance()
	dash_effect.rotation_degrees = rad2deg(dash_direction.angle())
	refs.ysort.call_deferred("add_child", dash_effect)
	yield(dash_effect, "ready")
	dash_effect.global_position = global_position + Vector2(0, 6)
