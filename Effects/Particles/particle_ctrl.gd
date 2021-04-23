extends Particles2D

export var auto_start = true
export var auto_free = true
var max_lifetime = lifetime + lifetime * process_material.lifetime_randomness
var stopping = false

func _ready():
	if auto_start == true:
		emitting = true
	
	if auto_free == true:
		stop()

func stop():
	if stopping == true:
		return
	
	stopping = true
	get_tree().create_timer(max_lifetime).connect("timeout", self, "queue_free")
