extends Attack
class_name Projectile

export var SPEED = 250
export var VELOCITY_ARMOR = 1
export var ONHIT_SPEED_MULTIPLIER = 0.8
export var MIN_DAM_SPEED = 30
export var RECOIL = 50

var has_left_src = false
var original_force_mult

func _init():
	visible = false
	original_force_mult = FORCE_MULT
	FORCE_MULT = 0.0

func _ready():
	if SOURCE != null:
		SOURCE.apply_force(target_pos.direction_to(SOURCE.global_position).normalized() * RECOIL)

func setup(new_source = Entity.new(), new_target_pos = Vector2.ZERO):
	# base Attack.gd setup
	SOURCE = new_source
	target_pos = new_target_pos
	faction = SOURCE.faction
	start_pos = SOURCE.global_position
	DIRECTION = start_pos.direction_to(target_pos).normalized()
	SOURCE_PATH = SOURCE.get_path()
	# PROBLEM_NOTE: might be better to try .setup(new_source, new_target_pos) (also applies to Melee.gd)
	# Projectile.gd setup
	velocity = Vector2(SPEED, SPEED) * DIRECTION
	visible = true

func _physics_process(delta):
	if visible == false: return
	
	# acceleration
	velocity = velocity.move_toward(Vector2.ZERO, -(ACCELERATION) * delta)
	
	#STATIC = false
	
	if global_position.distance_to(start_pos) > RANGE || velocity == Vector2.ZERO:
		queue_free()
	
	if auto_rotate == true:
		rotation += get_angle_to(global_position + velocity)

func death():
	velocity = velocity * ONHIT_SPEED_MULTIPLIER
	emit_signal("death")
	
	if components["hitbox"] != null: 
		hitbox.queue_free()
	
	if death_free == true:
		queue_free()
		
func _on_hitbox_hit(area: Area2D, type: String) -> void:
	._on_hitbox_hit(area, type)
	
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
