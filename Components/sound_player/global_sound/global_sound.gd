extends AudioStreamPlayer
class_name Global_Sound

enum MODES {ONESHOT, STANDBY, REPEATING}

export(MODES) var MODE = MODES.ONESHOT
export var SCENE_PERSIST = false
export(bool) var AUTO_PLAY = true

func _ready() -> void:
	autoplay = AUTO_PLAY
	
	if stream == null and get_name() != "ambiance":
		push_error("global_sound (%s) has no stream" % get_name())
	
	if MODE == MODES.ONESHOT:
		connect("finished", self, "queue_free")
	elif MODE == MODES.REPEATING:
		connect("finished", self, "play")
