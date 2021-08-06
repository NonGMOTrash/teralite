extends Particles2D

export var auto_start = true
export var auto_free = true
var max_lifetime = (lifetime + lifetime * process_material.lifetime_randomness) / speed_scale
var stopping = false

func _ready():
	if global.settings["particles"] < 2:
		queue_free()
		visible = false
		return
	
	if auto_start == true:
		emitting = true
	
	if auto_free == true:
		stop(false)

func stop(cancel_emit:bool = true):
	if stopping == true:
		return
	
	stopping = true
	if cancel_emit == true:
		emitting = false
	get_tree().create_timer(max_lifetime).connect("timeout", self, "queue_free")
