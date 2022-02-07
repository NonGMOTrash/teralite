extends Entity

const MAGIC = preload("res://Entities/Attacks/Projectile/magic/magic.tscn")

onready var delay = $delay
onready var brain = $brain
onready var stats = $stats

var saved_pos := Vector2.ZERO

func _on_brain_found_target() -> void:
	delay.start()

func _on_delay_timeout() -> void:
	var pos: Vector2
	if brain.get_closest_target() is Entity:
		pos = brain.get_closest_target().global_position
		saved_pos = pos
	else:
		pos = saved_pos
	
	var magic = MAGIC.instance()
	magic.setup(self, pos)
	refs.ysort.add_child(magic)
	if stats.DAMAGE != 0 and stats.TRUE_DAMAGE != 1:
		yield(magic, "ready")
		magic.components["stats"].DAMAGE = stats.DAMAGE
		magic.components["stats"].TRUE_DAMAGE = stats.TRUE_DAMAGE
	
	if brain.get_closest_target() is Entity:
		delay.start()
