extends Position2D

onready var cam = $Camera2D

func _ready():
	cam.smoothing_enabled = global.settings["smooth_camera"]
	cam.limit_smoothed = global.settings["smooth_camera"]
	
	global.connect("update_camera", self, "update_fov")
	
	if global.players_path != null and get_node_or_null(global.players_path) != null:
		global_position = get_node(global.players_path).global_position
	else:
		global_position = get_global_mouse_position()

func update_fov():
	cam.zoom = global.FOV

func _physics_process(_delta: float) -> void:
	var array = []
	if global.players_path == null: return
	if get_node_or_null(global.players_path) == null: return
	
	for i in global.cam_zoom.x:
		array.append(get_tree().current_scene.get_node(global.players_path).global_position)
	for i in global.cam_zoom.y:
		array.append(get_global_mouse_position())
	
	var sum = Vector2.ZERO
	for element in array:
		sum += element
	sum /= array.size()
	
	global_position = sum
