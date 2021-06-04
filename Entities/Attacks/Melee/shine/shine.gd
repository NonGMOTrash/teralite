extends Melee

export(float, 0.0, 10.0) var REFLECTION_MULT

func _on_hitbox_area_entered(area: Area2D) -> void:
	if visible == false: return
	
	var area_entity = area.get_parent()
	if area_entity is Projectile:
		area_entity.velocity *= -REFLECTION_MULT
	else:
		._on_hitbox_area_entered(area)
