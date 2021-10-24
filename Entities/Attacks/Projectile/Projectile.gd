extends Attack
class_name Projectile

export var SPEED = 250
export var VELOCITY_ARMOR = 1
export var ONHIT_SPEED_MULTIPLIER = 0.8
export var MIN_DAM_SPEED = 30
export var RECOIL = 50
export var VELOCITY_INHERITENCE := 0.5
export(float, -360, 360) var ROTATION_OFFSET := 0.0

var has_left_src := false
var original_force_mult
var distance_traveled := 0.0
var old_pos: Vector2

onready var original_damage: int = stats.DAMAGE
onready var original_true_damage: int = stats.TRUE_DAMAGE

func _init():
	visible = false
	original_force_mult = FORCE_MULT
	FORCE_MULT = 0.0

func _ready():
	old_pos = global_position
	
	# recoil
	if SOURCE != null:
		SOURCE.apply_force(target_pos.direction_to(SOURCE.global_position).normalized() * RECOIL)
		
		apply_force(SOURCE.velocity * VELOCITY_INHERITENCE)

func setup(new_source = Entity.new(), new_target_pos = Vector2.ZERO):
	# base Attack.gd setup
	SOURCE = new_source
	target_pos = new_target_pos
	faction = SOURCE.faction
	start_pos = SOURCE.global_position
	DIRECTION = start_pos.direction_to(target_pos).normalized()
	SOURCE_PATH = SOURCE.get_path()
	# PROBLEM_NOTE: probably better to try .setup(new_source, new_target_pos) (also applies to Melee.gd)
	# Projectile.gd setup
	velocity = Vector2(SPEED, SPEED) * DIRECTION
	visible = true

func _physics_process(delta):
	if visible == false: return
	
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
	
	if components["hitbox"] != null:
		hitbox.queue_free()

func _on_hitbox_hit(area: Area2D, type: String) -> void:
	._on_hitbox_hit(area, type)
	if truName == "shotgun_shell":
		prints(get_name(), area.get_parent().get_name(), (area.get_parent() in hitbox.blacklist))
	
	if visible == false: return
	if global.get_relation(self, area.get_parent()) == "friendly": return
	#if get_speed() < MIN_DAM_SPEED: return
	if "ONHIT_SELF_DAMAGE" in area.get_parent(): return
	
	stats.change_health(0, -(ONHIT_SELF_DAMAGE))
	
	VELOCITY_ARMOR -= ONHIT_SELF_DAMAGE
	if VELOCITY_ARMOR < 1:
		FORCE_MULT = original_force_mult
		velocity = velocity * ONHIT_SPEED_MULTIPLIER

func _on_src_collision_body_exited(body: Node) -> void:
	if body == SOURCE:
		has_left_src = true
		$src_collision.queue_free()
