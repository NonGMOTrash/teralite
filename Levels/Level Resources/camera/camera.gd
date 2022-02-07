extends Camera2D

const DEFAULT_TRANS = Tween.TRANS_ELASTIC
const DEFAULT_EASE = Tween.EASE_OUT_IN
const DEFAULT_DISTANCE_RATIO := 0.25
const DEFAULT_DISTANCE_MAX := 40
const DEFAULT_DISTANCE_MIN := 0

onready var tween = $tween 
onready var frequency_timer = $frequency
onready var duration_timer = $duration
onready var zoom_tween = $zoom_tween

var distance_ratio := DEFAULT_DISTANCE_RATIO # 1-0, higher = see further
var distance_max := DEFAULT_DISTANCE_MAX
var distance_min := DEFAULT_DISTANCE_MIN

var old_player_pos = null
var set_mouse_pos := Vector2.ZERO
var power = 0
var priority = -99
var target_pos := Vector2.ZERO
var auto_target := true

func _init() -> void:
	refs.update_ref("camera", self)
	smoothing_enabled = false

# this is called by the player when it spawns so the camera instantly warps to you
func startat(pos: Vector2):
	global_position = pos
	smoothing_enabled = global.settings["smooth_camera"]
	limit_smoothed = global.settings["smooth_camera"]
	global.connect("update_camera", self, "update_fov")

func update_fov():
	zoom = global.FOV

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		set_mouse_pos = global.get_look_pos()

func _physics_process(_delta: float) -> void:
	var player := refs.player
	if not is_instance_valid(player):
		return
	
	if player == null:
		if old_player_pos == null: return
		
		if auto_target == true:
			tween.interpolate_property(self, "global_position", global_position, target_pos, 4.0, 
					Tween.TRANS_EXPO, Tween.EASE_OUT)
		tween.start()
		set_physics_process(false)
		return
	
	old_player_pos = player.global_position
	
	if distance_min > 0 and global_position.distance_to(to_local(global.get_look_pos())) < 8:
		return
	
	global_position = player.global_position + (to_local(global.get_look_pos()) * distance_ratio)
	
	if global_position.distance_to(player.global_position) > distance_max:
		global_position = player.global_position.move_toward(global_position, distance_max)
	elif global_position.distance_to(player.global_position) < distance_min:
		global_position = player.global_position.move_toward(to_local(global.get_look_pos()) * 99, distance_min)

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

func zoom_to(new_zoom: Vector2, time: float = 0.2, trans:int = Tween.TRANS_LINEAR, eaze:int = DEFAULT_EASE):
	zoom_tween.interpolate_property(self, "zoom", zoom, new_zoom, time, trans, eaze) # ease is taken
	zoom_tween.start()
