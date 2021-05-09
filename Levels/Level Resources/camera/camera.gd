extends Camera2D

const DEFAULT_TRANS = Tween.TRANS_ELASTIC
const DEFAULT_EASE = Tween.EASE_OUT_IN

onready var tween = $tween 
onready var frequency_timer = $frequency
onready var duration_timer = $duration

var old_player_pos = null
var power = 0
var priority = -99

func _on_camera_tree_entered() -> void:
	global.nodes["camera"] = self

func _ready():
	global.nodes["camera"] = self
	
	smoothing_enabled = global.settings["smooth_camera"]
	limit_smoothed = global.settings["smooth_camera"]
	
	global.connect("update_camera", self, "update_fov")
	
	if global.nodes["player"] != null and get_node_or_null(global.nodes["player"]) != null:
		global_position = get_node(global.nodes["player"]).global_position
	else:
		global_position = get_global_mouse_position()

func update_fov():
	zoom = global.FOV

func _physics_process(_delta: float) -> void:
	var array = []
	var player
	if global.nodes["player"] == null: return
	player = get_node_or_null(global.nodes["player"])
	
	if player == null:
		if old_player_pos == null: return
		
		tween.interpolate_property(self, "global_position", global_position, old_player_pos, 4.0, 
				Tween.TRANS_EXPO, Tween.EASE_OUT)
		tween.start()
		set_physics_process(false)
		return
	
	old_player_pos = player.global_position
	
	# PROBLEM_NOTE: i can do this faster by using a weighted average calculation
	for i in global.cam_zoom.x:
		array.append(player.global_position)
	for i in global.cam_zoom.y:
		array.append(get_global_mouse_position())
	
	var sum = Vector2.ZERO
	for element in array:
		sum += element
	sum /= array.size()
	
	global_position = sum

func shake(power=10, frequency=10, duration=0.2):
	if not (power * frequency * duration) > priority: 
		return
	
	priority = power * frequency * duration
	self.power = power
	
	duration_timer.wait_time = duration
	frequency_timer.wait_time = 1.0 / frequency
	duration_timer.start()
	frequency_timer.start()

func single_shake(TRANS = DEFAULT_TRANS, EASE = DEFAULT_EASE):
	var final_offset = Vector2( rand_range(-power,power) , rand_range(-power,power) )
	tween.interpolate_property(self, "offset", offset, final_offset, frequency_timer.wait_time, 
			TRANS, EASE)
	tween.start()

func stop_shaking(TRANS = DEFAULT_TRANS, EASE = DEFAULT_EASE):
	tween.interpolate_property(self, "offset", offset, Vector2.ZERO, frequency_timer.wait_time, 
			TRANS, EASE)
	tween.start()
	priority = -99

func _on_frequency_timeout() -> void:
	single_shake()

func _on_duration_timeout() -> void:
	frequency_timer.stop()
	stop_shaking()
