extends Melee

const SHINE_PARTICLES = preload("res://Effects/Particles/shine_particles.tscn")

export(float, 0.0, 10.0) var REFLECTION_MULT

func _on_hitbox_area_entered(area: Area2D) -> void:
	if visible == false: return
	
	var area_entity = area.get_parent()
	
	if area_entity is Projectile:
		area_entity.velocity *= -REFLECTION_MULT
		sound.play_sound("reflect")
	else:
		._on_hitbox_area_entered(area)
	
	var particles: Particles2D = SHINE_PARTICLES.instance()
	refs.ysort.get_ref().call_deferred("add_child", particles)
	yield(particles, "tree_entered")
	particles.global_position = global_position
