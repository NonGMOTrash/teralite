extends Particles2D

var max_lifetime = lifetime + lifetime * process_material.lifetime_randomness

func _ready():
	emitting = true
	yield(get_tree().create_timer(max_lifetime), "timeout")
	queue_free()
