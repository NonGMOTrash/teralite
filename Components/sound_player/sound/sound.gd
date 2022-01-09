extends AudioStreamPlayer2D
class_name Sound

enum MODES {ONESHOT, STANDBY, REPEATING}

export(MODES) var MODE = MODES.ONESHOT
export(bool) var AUTO_PLAY = true
export var SCENE_PERSIST = false
export var AUTO_SET_PHYSICAL = true # auto set max_distance and attenuation
export var TRACKING_TARGET: NodePath 

func _init():
	autoplay = AUTO_PLAY
	
	if AUTO_SET_PHYSICAL == true:
		max_distance = 400
		attenuation = 2.5
		
		if volume_db != 0: 
			var mult = volume_db
			if volume_db < 0: mult = 1.0 / (1.0 + abs(volume_db))
			
			max_distance += 400 * mult
			attenuation = 2.5 * mult

func _ready() -> void:
	autoplay = AUTO_PLAY
	
	if stream == null:
		push_error("sound has no stream")
	
	if MODE == MODES.ONESHOT:
		connect("finished", self, "queue_free")
	elif MODE == MODES.REPEATING:
		connect("finished", self, "play")
	
	# moving to sound_player (putting it in here causes an error sometimes
	# resume: Resumed function '_ready()' after yield, but class instance is gone. 
	# At script: res://Components/sound_player/sound/sound.gd:34
	
#	yield(get_tree().create_timer(0.1), "timeout")
#	if global_position == Vector2.ZERO:
#		push_warning("sound '"+get_name()+"' created at (0, 0), possibly an error.")

func _physics_process(delta: float) -> void:
	var target: Node = get_node_or_null(TRACKING_TARGET)
	if target != null:
		global_position = target.global_position
