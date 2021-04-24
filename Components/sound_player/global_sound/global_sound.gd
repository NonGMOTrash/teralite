extends AudioStreamPlayer
class_name Global_Sound

enum MODES {ONESHOT, STANDBY, REPEATING}

export(MODES) var MODE = MODES.ONESHOT
export var SCENE_PERSIST = false
export(bool) var AUTO_PLAY = true

func _ready() -> void:
	if stream == null:
		push_error("global_sound has no stream")
	
	if MODE == MODES.ONESHOT:
		connect("finished", self, "queue_free")
	elif MODE == MODES.REPEATING:
		connect("finished", self, "play")
	
	if AUTO_PLAY == true:
		play()
