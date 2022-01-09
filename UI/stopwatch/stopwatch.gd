extends Label

onready var timer = $Timer

var time = 0.0
var paused = true

func _init() -> void:
	refs.stopwatch = weakref(self)

func _ready():
	visible = true
	refs.transition.get_ref().connect("finished", self, "start")

func start():
	timer.start()
	paused = false

func _process(_delta):
	if paused == false:
		time = timer.wait_time - timer.time_left
	
	text = global.sec_to_time(time)

func set_pause(to: bool):
	paused = to
