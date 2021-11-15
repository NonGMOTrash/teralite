extends Thinker

export var max_ammo = 2
var ammo = max_ammo
export var cooldown_time = 0.175
export var reload_time = 1.55
export var ads_dist_ratio = 0.6
export var ads_dist_max = 70
export var ads_zoom = 0.92
export var ads_zoom_speed = 0.2
export var pellets:int = 5
export var spread:int = 40

onready var cooldown = $cooldown
onready var reload = $reload
onready var spawner = $spawner

func _init() -> void:
	res.allocate("shotgun_shell")

func _ready() -> void:
	cooldown.wait_time = cooldown_time
	reload.wait_time = reload_time

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
	_update_held_item()
	
	# PROBLEM_NOTE: would be better if i could get this to inheireit \/
	if EQUIP_SOUND != null:
		sound_player.create_sound(EQUIP_SOUND)

func unselected():
	reload.stop()
	var camera: Camera2D = refs.camera.get_ref()
	camera.distance_ratio = camera.DEFAULT_DISTANCE_RATIO
	camera.distance_max = camera.DEFAULT_DISTANCE_MAX
	camera.zoom_to(Vector2(1, 1), ads_zoom_speed)

func primary():
	.primary()
	if get_ready() == false:
		if ammo <= 0 && reload.time_left == 0:
			reload()
		return
	
	var angles := []
	var spread_step: float = (spread * 2) / pellets
	var r: float = -(spread / 2) - (spread_step * floor(pellets/2.0))
	for i in pellets:
		r += spread_step
		angles.append(rad2deg(player.global_position.direction_to(player.get_global_mouse_position()).angle()) + r)
	
	var bullets := []
	for i in pellets:
		bullets.append(res.aquire_attack("shotgun_shell"))
	
	for i in pellets:
		var angle: float = deg2rad(angles[i])
		var direction := Vector2(cos(angle), sin(angle))
		var this_bullet: Projectile = bullets[i]
		this_bullet.setup(player, player.get_global_mouse_position())
		this_bullet.DIRECTION = direction
		this_bullet.velocity = Vector2(this_bullet.SPEED, this_bullet.SPEED) * direction
		for bullet in bullets:
			if bullet == this_bullet:
				continue
			else:
				this_bullet.get_node("hitbox").blacklist.append(bullet.get_node("hurtbox"))
		refs.ysort.get_ref().call_deferred("add_child", this_bullet)
	
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
	var camera = refs.camera.get_ref() as Camera2D
	
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
