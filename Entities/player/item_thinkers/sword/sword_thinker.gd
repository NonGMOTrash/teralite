extends Thinker

export var cooldown_time = 0.45

onready var cooldown = $cooldown

func _ready() -> void:
	cooldown.wait_time = cooldown_time

func get_ready():
	if cooldown.time_left > 0:
		return false
	else:
		return true

func primary():
	_quick_spawn("slash", "melee")
	cooldown.start()
