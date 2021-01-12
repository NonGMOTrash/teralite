extends Thing
class_name Projectile

# vars -------------------------------------------------------------------------------------------
export var SPEED = 250
export var VELOCITY_ARMOR = 1
export var ONHIT_SPEED_MULTIPLIER = 0.8

var has_left_src = false
var original_force_mult

# basic funcions -------------------------------------------------------------------------------------------
func _init():
	visible = false
	original_force_mult = FORCE_MULT
	FORCE_MULT = 0.0

func setup(new_source = Entity.new(), new_target_pos = Vector2.ZERO):
	# base Thing.gd setup
	SOURCE = new_source
	target_pos = new_target_pos
	faction = SOURCE.faction
	start_pos = SOURCE.global_position
	DIRECTION = start_pos.direction_to(target_pos).normalized()
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
	

# other functions -------------------------------------------------------------------------------------------
func death():
	velocity = velocity * ONHIT_SPEED_MULTIPLIER
	
	if components["hitbox"] != null: 
		hitbox.queue_free()
	
	if sprite_persist == false:
		queue_free()
		

# signal functions -------------------------------------------------------------------------------------------
func _on_collision_body_entered(body: Node) -> void:
	if visible == false: return
	if body.get_name() == "WorldTiles":
		queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if visible == false: return
	if global.get_relation(self, area.get_parent()) == "friendly": return
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
