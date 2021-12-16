extends Entity

onready var stats: Node = $stats
onready var brain: Node2D = $brain
onready var animation: AnimationPlayer = $AnimationPlayer

func _on_hitbox_hit(area, type) -> void:
	if area.get_parent() is Entity and not area.get_parent() is Attack:
		stats.change_health(1, 0, "heal")

func _physics_process(delta: float) -> void:
	if input_vector == Vector2.ZERO:
		animation.play("stand")
	else:
		animation.play("run")
