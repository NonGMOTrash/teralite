extends Status_Effect

onready var top_speed_change = entity.TOP_SPEED * (level / 5.0)
onready var acceleration_change = entity.ACCELERATION * (level / 4.0)
onready var slowdown_change = entity.SLOWDOWN * (level / 15.0)

func _ready() -> void:
	if top_speed_change > entity.TOP_SPEED:
		top_speed_change = entity.TOP_SPEED
	if acceleration_change > entity.ACCELERATION:
		acceleration_change = entity.ACCELERATION
	if slowdown_change > entity.SLOWDOWN:
		slowdown_change = entity.SLOWDOWN
	
	entity.TOP_SPEED += top_speed_change
	entity.ACCELERATION += acceleration_change
	entity.SLOWDOWN += slowdown_change

func depleted():
	entity.TOP_SPEED -= top_speed_change
	entity.ACCELERATION -= acceleration_change
	entity.SLOWDOWN -= slowdown_change

func _on_status_effect_tree_exiting() -> void:
	stats.status_effects[name] = null
