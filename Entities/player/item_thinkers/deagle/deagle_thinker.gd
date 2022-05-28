extends Thinker

const BULLET := preload("res://Entities/Attacks/Projectile/small_bullet/small_bullet.tscn")
const SHOOT_SOUND: AudioStream = preload("res://Entities/player/item_thinkers/deagle/deagle_shoot.wav")

export var max_ammo = 6
var ammo = max_ammo
export var cooldown_time = 0.3
export var reload_time = 1.25
export var ads_dist_ratio = 0.7
export var ads_dist_max = 80
export var ads_zoom = 0.9
export var ads_zoom_speed = 0.2
export var bonus_damage = 1

onready var cooldown = $cooldown
onready var reload = $reload
onready var spawner = $spawner

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

func unselected():
	reload.stop()
	var camera: Camera2D = refs.camera
	camera.distance_ratio = camera.DEFAULT_DISTANCE_RATIO
	camera.distance_max = camera.DEFAULT_DISTANCE_MAX
	camera.zoom_to(Vector2(1, 1), ads_zoom_speed)

func primary():
	.primary()
	if get_ready() == false:
		if ammo <= 0 && reload.time_left == 0:
			reload()
		return
	
	var bullet: Projectile = BULLET.instance()
	bullet.find_node("hitbox").DAMAGE += bonus_damage
	bullet.SPAWN_SOUND = SHOOT_SOUND
	bullet.SPEED += 60
	bullet.setup(player, global.get_look_pos())
	refs.ysort.add_child(bullet)
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
	spawner.spawn()

func secondary():
	var camera = refs.camera as Camera2D
	
	if Input.is_action_pressed("secondary_action"):
		camera.distance_ratio = ads_dist_ratio
		camera.distance_max = ads_dist_max
		camera.zoom_to(Vector2(ads_zoom, ads_zoom), ads_zoom_speed)
	else:
		camera.distance_ratio = camera.DEFAULT_DISTANCE_RATIO
		camera.distance_max = camera.DEFAULT_DISTANCE_MAX
		camera.zoom_to(Vector2(1, 1), ads_zoom_speed)

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
