extends Melee

export var tipper_distance: float
export var tipper_damage: int

func _on_hitbox_hit(area, type) -> void:
	._on_hitbox_hit(area, type)
	
	if get_node_or_null(SOURCE_PATH) == null:
		return
	
	var area_entity: Entity = area.entity
	var distance: float = area_entity.global_position.distance_to(SOURCE.global_position)
	if distance >= tipper_distance:
		print(area_entity.get_name())
		sound.play_sound("tipper")
		if area_entity.components["stats"] != null:
			area_entity.components["stats"].change_health(0, -tipper_damage)
