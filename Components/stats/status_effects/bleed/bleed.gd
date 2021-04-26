extends Status_Effect

export(PackedScene) var blood_particles

var particles: Particles2D

func _ready():
	trigger.wait_time *= 1 / level
	
	particles = blood_particles.instance()
	particles.amount *= level
	get_parent().get_parent().add_child(particles)

func triggered():
	get_parent().change_health(0, -1, "bleed")

func depleted():
	if particles == null:
		push_error("bleed's particles == null")
		return
	
	particles.stop()
