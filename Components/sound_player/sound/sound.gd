extends AudioStreamPlayer2D
class_name Sound

enum MODES {ONESHOT, STANDBY, REPEATING}

export(MODES) var MODE = MODES.ONESHOT
export var SCENE_PERSIST = false
export(bool) var AUTO_PLAY = true

func _init():
	max_distance = 400
	attenuation = 2.5

func _ready() -> void:
	if MODE == MODES.ONESHOT:
		connect("finished", self, "queue_free")
	elif MODE == MODES.REPEATING:
		connect("finished", self, "play")
	
	if AUTO_PLAY == true:
		play()
