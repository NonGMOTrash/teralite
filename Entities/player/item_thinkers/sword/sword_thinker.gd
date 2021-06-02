extends Thinker

export var cooldown_time = 0.45

onready var cooldown := $cooldown as Timer

func _init():
	res.allocate("slash")

func _ready() -> void:
	cooldown.wait_time = cooldown_time

func get_ready():
	if cooldown.time_left > 0:
		return false
	else:
		return true

func primary():
	.primary()
	quick_spawn("slash")
	cooldown.start()
