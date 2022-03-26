extends Entity

const DRONE := preload("res://Entities/drone/drone.tscn")

onready var animation: AnimationPlayer = $AnimationPlayer

func _on_action_lobe_action(action, target) -> void:
	animation.play("spawn")

func spawn_drone():
	var drone: Entity = DRONE.instance()
	drone.global_position = global_position + Vector2(0, -4)
	refs.ysort.add_child(drone)
