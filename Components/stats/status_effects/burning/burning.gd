extends Status_Effect

const FIRE = preload("res://Entities/fire/fire.tscn")

func _ready() -> void:
	entity.connect("death", self, "entity_dies")

func entity_dies():
	var new_fire = FIRE.instance()
	new_fire.global_position = entity.global_position
	global.nodes["ysort"].call_deferred("add_child", new_fire)

func triggered():
	stats.change_health(0, -1, "burn")
	var fire = FIRE.instance()
	fire.global_position = entity.global_position + Vector2(rand_range(-8,8), rand_range(-8,8))
	fire.find_node("fuel").wait_time = 1.5
	fire.velocity = Vector2(rand_range(0,1), rand_range(0,1)).normalized() * 50
	stats.get_parent().call_deferred("add_child", fire)
	
	# the fire that spawns would inflict fire inself, meaning the status effect would last forever
	# to counteract this, I do this hack to reduce the status effect level and duration
	var hitbox = fire.find_node("hitbox")
	stats.add_status_effect("burning", hitbox.STATUS_DURATION*-1, hitbox.STATUS_LEVEL*-1)
