extends Entity

const ARROW = preload("res://Entities/Attacks/Projectile/arrow/arrow.tscn")

export var charge_speed := 1.0

onready var held_item = $held_item
onready var held_item_animation = $held_item/AnimationPlayer
onready var brain = $brain
onready var stats = $stats

func _on_brain_found_target() -> void:
	held_item_animation.play("custom", -1, charge_speed)

func shoot():
	var pos
	if brain.get_closest_target() is Entity:
		pos = brain.get_closest_target().global_position
	else:
		pos = global_position + Vector2(cos(held_item.rotation), sin(held_item.rotation))
		#                         /\ converts the held_item.rotation from radians to a vector2
	
	var arrow: Projectile = ARROW.instance()
	arrow.setup(self, pos)
	refs.ysort.add_child(arrow)

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if brain.get_closest_target() is Entity:
		held_item_animation.play("custom", -1, charge_speed)
