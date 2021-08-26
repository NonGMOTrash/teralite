extends Label

onready var timer = $Timer

var time = 0.0
var paused = false

func _ready():
	refs.stopwatch = weakref(self)
	visible = true

func _process(_delta):
	if paused == false:
		time = 999.9 - timer.time_left
	
	text = global.sec_to_time(time)

func set_pause(to: bool):
	paused = to
