extends Melee

export var tipper_distance: float
export var tipper_damage: int

func _on_hitbox_hit(area, type) -> void:
	._on_hitbox_hit(area, type)
	
	if get_node_or_null(SOURCE_PATH) == null:
		return
	
	var distance: float = area.get_parent().global_position.distance_to(SOURCE.global_position)
	if distance >= tipper_distance:
		sound.play_sound("tipper")
		var area_entity: Entity = area.get_parent()
		if area_entity.components["stats"] != null:
			area_entity.components["stats"].change_health(0, -tipper_damage)
