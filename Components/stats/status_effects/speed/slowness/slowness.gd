extends Status_Effect

onready var top_speed_change = entity.TOP_SPEED * (level / 5.0)
onready var acceleration_change = entity.ACCELERATION * (level / 4.0)
onready var slowdown_change = entity.SLOWDOWN * (level / 15.0)
var dash_change

func _ready() -> void:
	if entity.truName == "player":
		dash_change = entity.dash_strength * (level / 8.0)
	
	if top_speed_change > entity.TOP_SPEED:
		top_speed_change = entity.TOP_SPEED
	if acceleration_change > entity.ACCELERATION:
		acceleration_change = entity.ACCELERATION
	if slowdown_change > entity.SLOWDOWN:
		slowdown_change = entity.SLOWDOWN
	if entity.truName == "player":
		if dash_change > entity.dash_strength:
			dash_change = entity.dash_strength
	
	entity.TOP_SPEED -= top_speed_change
	entity.ACCELERATION -= acceleration_change
	entity.SLOWDOWN += slowdown_change
	
	if entity.truName == "player":
		entity.dash_strength = max(entity.dash_strength - dash_change, 0)

func depleted():
	entity.TOP_SPEED += top_speed_change
	entity.ACCELERATION += acceleration_change
	entity.SLOWDOWN -= slowdown_change
	
	if entity.truName == "player":
		entity.dash_strength += dash_change
