extends Thinker

const CRIT_SOUND: AudioStream = preload("res://Entities/player/item_thinkers/awp/awp_shoot_crit.wav")

export var max_ammo = 3
onready var ammo = max_ammo
export var cooldown_time = 0.175
export var reload_time = 1.25
export var ads_dist_ratio = 0.6
export var ads_dist_max = 70
export var ads_dist_min = 50
export var ads_zoom = 0.92
export var ads_zoom_speed = 0.2
export var mlg_damage_bonus = 2

onready var cooldown = $cooldown
onready var reload = $reload
onready var spawner = $spawner
onready var mlg_window = $mlg_window

var rotations := []
var rotation_direction: int = 1 # 1 = positive -1 = negative
var old_angle: float = 0.0

func _init() -> void:
	res.allocate("bullet")
	for i in range(1, 60):
		rotations.append(0.0)

func _ready() -> void:
	cooldown.wait_time = cooldown_time
	reload.wait_time = reload_time
	#cooldown.start()

func _on_reload_timeout() -> void:
	ammo = max_ammo
	
	global.emit_signal("update_item_info", # set a condition to null to hide it
		display_name, # current item
		str(ammo) + " / " + str(max_ammo), # extra info
		null, # item bar max
		null, # item bar value
		null # bar timer duration
	)

func get_ready():
	if cooldown.time_left > 0: return false
	elif ammo <= 0: return false
	else: return true

func selected():
	.selected()
	global.emit_signal("update_item_info", # set a condition to null to hide it
		display_name, # current item
		str(ammo) + " / " + str(max_ammo), # extra info 
		null, # item bar max 
		null, # item bar value 
		null # bar timer duration
	)
	update_cursor()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_update_held_item()
	
	# PROBLEM_NOTE: would be better if i could get this to inheireit \/
	if EQUIP_SOUND != null:
		sound_player.create_sound(EQUIP_SOUND)

func unselected():
	reload.stop()
	var camera: Camera2D = refs.camera.get_ref()
	camera.distance_ratio = camera.DEFAULT_DISTANCE_RATIO
	camera.distance_max = camera.DEFAULT_DISTANCE_MAX
	camera.distance_min = camera.DEFAULT_DISTANCE_MIN
	camera.zoom_to(Vector2(1, 1), ads_zoom_speed)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func primary():
	.primary()
	if get_ready() == false:
		if ammo <= 0 && reload.time_left == 0:
			reload()
		return
	
	if mlg_window.time_left == 0:
		quick_spawn("big_bullet")
	else:
		print("crit!!")
		var bullet: Projectile = res.aquire_attack("big_bullet")
		bullet.get_node("stats").DAMAGE += mlg_damage_bonus
		bullet.SPAWN_SOUND = CRIT_SOUND
		bullet.setup(player, player.get_global_mouse_position())
		refs.ysort.get_ref().call_deferred("add_child", bullet)
	
	ammo -= 1
	cooldown.start()
	reload.stop()
	global.emit_signal("update_item_info", # set a condition to null to hide it
		display_name, # current item
		str(ammo) + " / " + str(max_ammo), # extra info 
		null, # item bar max 
		null, # item bar value 
		null # bar timer duration
	)
	$spawner.spawn()

func secondary():
	var camera = refs.camera.get_ref() as Camera2D
	
	if Input.is_action_pressed("secondary_action"):
		camera.distance_ratio = ads_dist_ratio
		camera.distance_max = ads_dist_max
		camera.distance_min = ads_dist_min
		camera.zoom_to(Vector2(ads_zoom, ads_zoom), ads_zoom_speed)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		sound_player.play_sound("scope")
	else:
		camera.distance_ratio = camera.DEFAULT_DISTANCE_RATIO
		camera.distance_max = camera.DEFAULT_DISTANCE_MAX
		camera.distance_min = camera.DEFAULT_DISTANCE_MIN
		camera.zoom_to(Vector2(1, 1), ads_zoom_speed)
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		sound_player.play_sound("unscope")

func reload():
	.reload()
	if reload.time_left > 0: return
	reload.start()
	global.emit_signal("update_item_info", # set a condition to null to hide it
		display_name, # current item
		null, # extra info 
		reload.wait_time, # item bar max 
		reload.time_left, # item bar value 
		reload.wait_time # bar timer duration
	)
	
	sound_player.play_sound("reload")

func _physics_process(delta: float) -> void:
	if global.selection != slot:
		return
	
	var angle := rad2deg(player.global_position.direction_to(player.get_global_mouse_position()).angle()) + 180
	var rotation: float = angle - old_angle
	old_angle = angle
	rotations.remove(0)
	rotations.append(rotation)
	
	var total_rotation: float = 0
	for i in rotations.size():
		total_rotation += rotations[i]
	
	if total_rotation >= 330 or total_rotation < 1:
		rotations.clear()
		for i in range(1, 60):
			rotations.append(0.0)
		
		if total_rotation >= 330:
			sound_player.play_sound("360")
			mlg_window.start()
