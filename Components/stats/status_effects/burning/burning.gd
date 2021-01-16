extends Status_Effect

func _ready() -> void:
	get_parent().get_parent().connect("death", self, "entity_dies")

func entity_dies():
	var new_fire = global.aquire("Fire")
	new_fire.global_position = get_parent().get_parent().global_position
	get_parent().get_parent().get_parent().call_deferred("add_child", new_fire)

func triggered():
	get_parent().change_health(0, -1, "burn")
	var fire = global.aquire("Fire")
	fire.global_position = get_parent().get_parent().global_position + Vector2(rand_range(-8,8), rand_range(-8,8))
	fire.find_node("fuel").wait_time = 1.5
	fire.velocity = Vector2(rand_range(0,1), rand_range(0,1)).normalized() * 50
	get_parent().get_parent().call_deferred("add_child", fire)
	
	# the fire that spawns would inflict fire inself, meaning the status effect would last forever
	# to counteract this, I do this hack to reduce the status effect level and duration
	var hitbox = fire.find_node("hitbox")
	get_parent().add_status_effect("burning", hitbox.STATUS_DURATION*-1, hitbox.STATUS_LEVEL*-1)
