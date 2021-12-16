extends "res://Components/stats/status_effects/speed/speed.gd"

export var infection_color: Color

onready var tween: Tween = $Tween

var sprite: Sprite
var original_modulate: Color

func _ready() -> void:
	sprite = entity.components["entity_sprite"]
	if sprite:
		original_modulate = sprite.self_modulate
		tween.interpolate_property(sprite, "self_modulate", sprite.self_modulate, infection_color, 
				TRIGGER_TIME, tween.TRANS_LINEAR, tween.EASE_IN)
		tween.start()

func triggered():
	var zombie := res.aquire_entity("zombie")
	zombie.global_position = entity.global_position
	var zombie_stats: Node = zombie.find_node("stats")
	if stats != null and zombie_stats != null:
		zombie_stats.MAX_HEALTH = stats.MAX_HEALTH
		zombie_stats.HEALTH = stats.HEALTH
	refs.ysort.get_ref().call_deferred("add_child", zombie)
	entity.death()
	depleted()

func _on_infection_tree_exiting() -> void:
	if sprite:
		sprite.self_modulate = original_modulate
