extends Status_Effect

const FIRE = preload("res://Entities/fire/fire.tscn")

export(float) var spread_time: float

var entity_died := false
var entity_pos := Vector2.ZERO

func _ready() -> void:
	# for some reason, entity_dies will trigger multiple times if i have it connected to the entity
	# death() or tree_exiting, so i have to save the entity_pos in tree_exiting, and then use it to spawn
	# the fire in tree_exited 
	entity.connect("tree_exiting", self, "set_entity_pos")
	entity.connect("tree_exited", self, "entity_dies")
	$spread.wait_time = spread_time

func set_entity_pos():
	entity_pos = entity.global_position

func entity_dies():
	if entity_died:
		return
	
	entity_died = true
	var fire = FIRE.instance()
	fire.global_position = entity_pos#entity.global_position
	fire.find_node("fuel").wait_time = 1.5
	refs.ysort.get_ref().call_deferred("add_child", fire)

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

func _on_spread_timeout() -> void:
	return
	
