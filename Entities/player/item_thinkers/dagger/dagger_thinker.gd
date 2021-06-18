extends Thinker

const HITBOX := preload("res://Components/hitbox/hitbox.tscn")

export(float) var attack_cooldown := 0.55
export(float) var dash_cooldown := 1.2
export(float) var dash_startup := 0.2
export(float) var dash_distance := 100.0
export(float) var dash_damage := 1

onready var cooldown: Timer = $cooldown
onready var tween: Tween = $Tween
onready var timer: Timer = $Timer
onready var particles: Particles2D = $particles
onready var after_image: Particles2D = $after_image
onready var hitbox: Area2D = HITBOX.instance()
# /\ i have to add the hitbox as a child of the player because there's get_parent() checks in hurtbox.gd

var dash_recovering := false

func _init() -> void:
	res.allocate("swipe")

func _ready() -> void:
	hitbox.COOLDOWN = 0.001
	hitbox.COOLDOWN_ON_START = false
	hitbox.DAMAGE = dash_damage
	player.add_child(hitbox)
	
	assert(dash_cooldown > dash_startup)

func get_ready() -> bool:
	if cooldown.time_left > 0:
		return false
	else:
		return true

func primary():
	.primary()
	quick_spawn("swipe")
	cooldown.wait_time = attack_cooldown
	cooldown.start()

func secondary():
	.secondary()
	dash_recovering = false
	
	cooldown.wait_time = dash_cooldown
	cooldown.start()
	player.rooted = true
	
	player.components["entity_sprite"].play_effect("invincibility")
	player.animation.play("dash")
	
	timer.wait_time = dash_startup
	timer.start()

func _on_Timer_timeout() -> void:
	if dash_recovering == false:
		dash_recovering = true
		
		player.components["entity_sprite"].scale = Vector2(1, 1)
		
		var start := player.global_position
		player.move_and_slide(
				player.global_position.direction_to(player.get_global_mouse_position()).normalized() 
				* dash_distance / get_physics_process_delta_time()
		)
		
		after_image.global_position = start
		after_image.emitting = true
		
		particles.global_position = player.global_position
		particles.rotation = player.global_position.direction_to(start).angle()
		particles.emitting = true
		
		sound_player.play_sound("dash")
		
		var fin := false
		var ss := player.get_world_2d().direct_space_state
		var excludes := []
		
		while fin == false:#                               entity + item_pickups \/
			var ray := ss.intersect_ray(start, player.global_position, excludes, 18)
			if ray.size() > 0:
				var collider: Node2D = ray.collider
				
				if collider is Entity:
					if collider is Item:
						collider._on_Area2D_body_entered(player) # simulte pickup
					elif collider.components["hurtbox"] != null:
						# damage entity
						collider.components["hurtbox"]._on_hurtbox_area_entered(hitbox)
						sound_player.play_sound("dash_hit")
				
				excludes.append(collider)
				
			else:
				fin = true
		
		timer.wait_time = dash_cooldown - dash_startup
		timer.start()
	
	elif dash_recovering == true:
		player.rooted = false

func _on_dagger_thinker_tree_exiting() -> void:
	hitbox.queue_free()
