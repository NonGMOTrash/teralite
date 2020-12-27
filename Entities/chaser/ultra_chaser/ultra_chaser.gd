extends "res://Entities/chaser/Chaser.gd"

onready var cooldown = $dash_cooldown
export var dash_cooldown = 1.0
export var dash_power = 5000

func _ready():
	cooldown.wait_time = dash_cooldown

func _on_brain_entity_input(input) -> void:
	if cooldown.time_left > 0: return
	
	var dash_direction = input_vector
	if input == "sdash": 
		# PROBLEM_NOTE: might be a better way to do this
		var a = dash_direction.x
		var b = dash_direction.y
		dash_direction = Vector2(b, a)
	elif input == "rdash":
		dash_direction = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0))
	
	dash_direction = dash_direction.normalized()
	
	apply_force(dash_direction * dash_power)
	cooldown.start()
