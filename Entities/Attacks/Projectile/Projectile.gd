extends Attack
class_name Projectile

export var SPEED = 250
export var VELOCITY_ARMOR = 1
export var ONHIT_SPEED_MULTIPLIER = 0.8
export var MIN_DAM_SPEED = 30
export var RECOIL = 50
export var VELOCITY_INHERITENCE := 0.5
export(float, -360, 360) var ROTATION_OFFSET := 0.0
export(float, 0, 32) var SPAWN_OFFSET := 16

var spawned_in_wall := false
var has_left_src := false
var original_force_mult
var distance_traveled := 0.0
var old_pos: Vector2

onready var original_damage: int = hitbox.DAMAGE
onready var original_true_damage: int = hitbox.TRUE_DAMAGE
onready var src_collision: Area2D = $src_collision

func _init():
	visible = false
	original_force_mult = FORCE_MULT
	FORCE_MULT = 0.0

func _ready():
	if spawned_in_wall == true:
		collided()
	
	old_pos = global_position
	
	# recoil
	if SOURCE != null:
		SOURCE.apply_force(target_pos.direction_to(SOURCE.global_position).normalized() * RECOIL)
		
		apply_force(SOURCE.velocity * VELOCITY_INHERITENCE)
	
	# destroy src_collision if not needed (which it shouldn't be now but who nows)
	if not SOURCE in src_collision.get_overlapping_bodies():
		src_collision.queue_free()
		has_left_src = true

func setup(new_source = Entity.new(), new_target_pos = Vector2.ZERO):
	# base Attack.gd setup
	SOURCE = new_source
	target_pos = new_target_pos
	faction = SOURCE.faction
	SOURCE_PATH = SOURCE.get_path()
	# PROBLEM_NOTE: probably better to try .setup(new_source, new_target_pos) (also applies to Melee.gd)
	# Projectile.gd setup
	visible = true
	
	DIRECTION = SOURCE.global_position.direction_to(target_pos).normalized()
	start_pos = SOURCE.global_position + SPAWN_OFFSET * DIRECTION
	velocity = Vector2(SPEED, SPEED) * DIRECTION
	
	# los check to the center of the source entity, prevents projectiles from spawning through walls
	if collision_mask == 0:
		return
	var ss = SOURCE.get_world_2d().direct_space_state
	var raycast = ss.intersect_ray(start_pos, SOURCE.global_position, [], 1)
	print(raycast)
	if raycast and not raycast.collider == SOURCE:
		spawned_in_wall = true

func _physics_process(delta):
	if visible == false: return # idk why this is here... but im scared to remove it
	
	# acceleration
	velocity = velocity.move_toward(Vector2.ZERO, -(ACCELERATION) * delta)
	
	#STATIC = false
	
	distance_traveled += global_position.distance_to(old_pos)
	old_pos = global_position
	
	if distance_traveled >= RANGE or velocity == Vector2.ZERO:
		death_free = true
		death()
	
	if auto_rotate == true:
		rotation += get_angle_to(global_position + velocity) + deg2rad(ROTATION_OFFSET)

func death():
	.death()
	if death_free == true:
		queue_free()
		return
	
	velocity = velocity * ONHIT_SPEED_MULTIPLIER
	emit_signal("death")
	
	if components["hitbox"] != null and is_instance_valid(components["hitbox"]):
		hitbox.queue_free()

func _on_hitbox_hit(area: Area2D, type: String) -> void:
	._on_hitbox_hit(area, type)
	
	if visible == false: return
	if global.get_relation(self, area.get_parent()) == "friendly": return
	#if get_speed() < MIN_DAM_SPEED: return
	if "PENETRATES" in area.get_parent(): return
	
	VELOCITY_ARMOR -= 1
	if VELOCITY_ARMOR < 1:
		FORCE_MULT = original_force_mult
		velocity = velocity * ONHIT_SPEED_MULTIPLIER

func _on_src_collision_body_exited(body: Node) -> void:
	if body == SOURCE:
		has_left_src = true
		$src_collision.queue_free()
