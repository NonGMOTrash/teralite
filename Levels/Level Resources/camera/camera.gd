extends Camera2D

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
	if global.nodes["player"] == null: return
	if get_node_or_null(global.nodes["player"]) == null: return
	
	# PROBLEM_NOTE: i can do this faster by using a weighted average calculation
	for i in global.cam_zoom.x:
		array.append(get_tree().current_scene.get_node(global.nodes["player"]).global_position)
	for i in global.cam_zoom.y:
		array.append(get_global_mouse_position())
	
	var sum = Vector2.ZERO
	for element in array:
		sum += element
	sum /= array.size()
	
	global_position = sum
