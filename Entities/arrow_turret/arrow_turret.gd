extends Entity

const ARROW = preload("res://Entities/Attacks/Projectile/arrow/arrow.tscn")

onready var held_item = $held_item
onready var held_item_animation = $held_item/AnimationPlayer
onready var brain = $brain
onready var stats = $stats

func _on_brain_found_target() -> void:
	held_item_animation.play("custom")

func shoot():
	var pos
	if brain.get_closest_target() is Entity:
		pos = brain.get_closest_target().global_position
	else:
		pos = global_position + Vector2(cos(held_item.rotation), sin(held_item.rotation))
		#                         /\ converts the held_item.rotation from radians to a vector2
	
	var arrow = ARROW.instance()
	arrow.setup(self, pos)
	global.nodes["ysort"].add_child(arrow)
	if stats.DAMAGE != 2 and stats.TRUE_DAMAGE != 0:
		yield(arrow, "ready")
		arrow.components["stats"].DAMAGE = stats.DAMAGE
		arrow.components["stats"].TRUE_DAMAGE = stats.TRUE_DAMAGE

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if brain.get_closest_target() is Entity:
		held_item_animation.play("custom")
