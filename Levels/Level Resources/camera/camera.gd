extends Camera2D

const DEFAULT_TRANS = Tween.TRANS_ELASTIC
const DEFAULT_EASE = Tween.EASE_OUT_IN
const DEFAULT_DISTANCE_RATIO := 0.25
const DEFAULT_DISTANCE_MAX := 40

onready var tween = $tween 
onready var frequency_timer = $frequency
onready var duration_timer = $duration
onready var zoom_tween = $zoom_tween

var distance_ratio := DEFAULT_DISTANCE_RATIO # 1-0, higher = see further
var distance_max := DEFAULT_DISTANCE_MAX

var old_player_pos = null
var set_mouse_pos := Vector2.ZERO
var power = 0
var priority = -99

func _on_camera_tree_entered() -> void:
	refs.camera = weakref(self)

func _ready():
	smoothing_enabled = global.settings["smooth_camera"]
	limit_smoothed = global.settings["smooth_camera"]
	
	global.connect("update_camera", self, "update_fov")
	
	global_position = get_global_mouse_position()

func update_fov():
	zoom = global.FOV

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		set_mouse_pos = get_global_mouse_position()

func _physics_process(_delta: float) -> void:
	var player
	if refs.player.get_ref() == null: return
	player = refs.player.get_ref()
	
	if player == null:
		if old_player_pos == null: return
		
		tween.interpolate_property(self, "global_position", global_position, old_player_pos, 4.0, 
				Tween.TRANS_EXPO, Tween.EASE_OUT)
		tween.start()
		set_physics_process(false)
		return
	
	player = player as Entity
	
	old_player_pos = player.global_position
	
	global_position = player.global_position + (get_local_mouse_position() * distance_ratio)
	
	if global_position.distance_to(player.global_position) > distance_max:
		global_position = player.global_position.move_toward(global_position, distance_max)

func shake(power=10, frequency=10, duration=0.2):
	if not (power * frequency * duration) > priority: 
		return
	
	priority = power * frequency * duration
	power = power
	
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
#                                                                               \/ ease is taken lel
func zoom_to(new_zoom: Vector2, time: float = 0.2, trans:int = DEFAULT_TRANS, eaze:int = DEFAULT_EASE):
	zoom_tween.interpolate_property(self, "zoom", zoom, new_zoom, time, trans, eaze)
	zoom_tween.start()
