extends Melee

const SHINE_PARTICLES = preload("res://Effects/Particles/shine_particles.tscn")

export(float, 0.0, 10.0) var REFLECTION_MULT

signal reflect

func _on_reflection_area_entered(area: Area2D) -> void:
	var body: Entity = area.get_parent()
	
	if not body is Projectile or visible == false:
		return
	
	body.velocity *= -REFLECTION_MULT
	emit_signal("reflect")
	
	sound.play_sound("reflect")
	
	var particles: Particles2D = SHINE_PARTICLES.instance()
	refs.ysort.get_ref().call_deferred("add_child", particles)
	yield(particles, "tree_entered")
	particles.global_position = global_position
