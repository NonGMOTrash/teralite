extends "res://Components/stats/status_effects/speed/speed.gd"

var original_top_speed: int
var original_acceleration: int

func start():
	original_top_speed = entity.TOP_SPEED
	original_acceleration = entity.ACCELERATION
	original_slowdown = entity.SLOWDOWN
	
	entity.TOP_SPEED = max(entity.TOP_SPEED - top_speed_change, 0)
	entity.ACCELERATION = max(entity.ACCELERATION - acceleration_change, 0)
	entity.SLOWDOWN += slowdown_change
	
	if entity.truName == "player":
		entity.dash_strength = max(entity.dash_strength - dash_change, 0)

func depleted():
	entity.TOP_SPEED = min(entity.TOP_SPEED + top_speed_change, original_top_speed)
	entity.ACCELERATION = min(entity.ACCELERATION + acceleration_change, original_acceleration)
	entity.SLOWDOWN = min(entity.SLOWDOWN + slowdown_change, original_slowdown)
	
	if entity.truName == "player":
		entity.dash_strength = min(entity.dash_strength + dash_change, original_dash)
