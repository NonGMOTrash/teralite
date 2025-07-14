extends Status_Effect

export(PackedScene) var blood_particles

var particles: Particles2D

func _ready():
	trigger.wait_time *= max(1.0 / level, 0.01)
	
	if global.settings["particles"] >= 2:
		particles = blood_particles.instance()
		particles.amount *= max(round(level), 1.0)
		stats.get_parent().add_child(particles)

func triggered():
	if entity.truName == "player" && (stats.HEALTH + stats.BONUS_HEALTH) == 1:
		stats.add_status_effect("slowness", 1.0, 1.5)
	else:
		stats.change_health(0, -1, "bleed")

func depleted():
	if particles == null:
		if global.settings["particles"] >= 2:
			push_error("bleed's particles == null")
		return
	
	particles.stop()
