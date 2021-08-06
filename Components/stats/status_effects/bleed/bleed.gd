extends Status_Effect

export(PackedScene) var blood_particles

var particles: Particles2D

func _ready():
	trigger.wait_time *= 1.0 / level
	
	if global.settings["particles"] >= 2:
		particles = blood_particles.instance()
		particles.amount *= round(level)
		stats.get_parent().add_child(particles)

func triggered():
	stats.change_health(0, -1, "bleed")

func depleted():
	if particles == null:
		if global.settings["particles"] >= 2:
			push_error("bleed's particles == null")
		return
	
	particles.stop()
