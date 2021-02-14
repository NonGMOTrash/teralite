extends Node

export(int, 0, 200) var DISTANCE = 0
export var INVERT_DISTANCE = false
export(int, 0, 200) var DEADZONE = 0
export var USE_DEADZONE = false
export(int, 0, 200) var FARZONE = 0
export var USE_FARZONE = false
export var STRAFING = false
export(int, 1, 600) var STAFE_STUTTER = 90

func _ready():
	DISTANCE = clamp(DISTANCE, 0, get_parent().get_parent().SIGHT_RANGE)
