extends Thinker

export(float) var attack_cooldown := 0.55
export(float) var dash_cooldown := 1.2
export(float) var dash_startup := 0.2
export(float) var dash_distance := 100.0
export(float) var dash_damage := 1

export var HITBOX: PackedScene
export var SWIPE: PackedScene

onready var cooldown: Timer = $cooldown
onready var tween: Tween = $Tween
onready var timer: Timer = $Timer
onready var particles: Particles2D = $particles
onready var after_image: Particles2D = $after_image
onready var hitbox: Area2D = HITBOX.instance()
# /\ i have to add the hitbox as a child of the player because of get_parent() checks in hurtbox.gd

var dash_recovering := false

func _ready() -> void:
	hitbox.COOLDOWN = 0.001
	hitbox.COOLDOWN_ON_START = false
	hitbox.DAMAGE = dash_damage
	player.add_child(hitbox)

func get_ready() -> bool:
	if cooldown.time_left > 0:
		return false
	else:
		return true

func primary():
	.primary()
	var swipe: Melee = SWIPE.instance()
	swipe.setup(player, global.get_look_pos())
	refs.ysort.add_child(swipe)
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
		var original_layer: int = player.collision_layer
		var original_mask: int  = player.collision_mask
		player.collision_layer = 0
		player.collision_mask = 1
		player.move_and_slide(
				player.global_position.direction_to(global.get_look_pos()).normalized() 
				* dash_distance / get_physics_process_delta_time()
		)
		var low_walls: TileMap = refs.low_walls
		while low_walls.get_cellv(low_walls.world_to_map(player.global_position)) != -1:
			player.global_position = player.global_position.move_toward(start, 4)
			if player.global_position == start:
				break
		player.collision_layer = original_layer
		player.collision_mask = original_mask
		
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
						collider._on_Area2D_body_entered(player) # force item pickup
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
