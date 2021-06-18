extends Label

onready var timer = $Timer

var time = 0.0
var paused = false

func _ready():
	global.nodes["stopwatch"] = self
	visible = true

func _process(_delta):
	if paused == false:
		time = 999.9 - timer.time_left
	
	var minute = int(floor(time / 60))
	var second = int(floor(time - (minute * 60)))
	var tenth = stepify(time - ((minute*60) + second), 0.1) * 10
	if tenth == 10: tenth = 0
	
	if second < 10: 
		second = str(second)
		second = "0"+second
	
	text = (
		str(minute) +
		":" +
		str(second) +
		"." +
		str(tenth)
		)

func set_pause(to: bool):
	paused = to
