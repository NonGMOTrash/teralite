extends Thing
class_name Melee

export(int, 0, 200) var BOOST = 50
export(int, 0, 200) var RECOIL = 70

var recoiled = false

func _ready():
	global_position.move_toward(target_pos, abs(RANGE - 6))
	
	if SOURCE == null: SOURCE = get_node_or_null(SOURCE_PATH)
	
	# boost
	if get_node_or_null(SOURCE_PATH) != null and SOURCE.is_queued_for_deletion() == false:
		SOURCE.apply_force(SOURCE.global_position.direction_to(target_pos).normalized() * BOOST)
	
	RECOIL += BOOST # < so the boost doesn't cancel out the RECOIL

func _physics_process(_delta):
	if get_node_or_null(SOURCE_PATH) != null and SOURCE.is_queued_for_deletion() == false:
		global_position = SOURCE.global_position + RANGE * DIRECTION

func death():
	# recoil
	if get_node_or_null(SOURCE_PATH) != null and SOURCE.is_queued_for_deletion() == false and recoiled == false:
		SOURCE.apply_force(target_pos.direction_to(SOURCE.global_position).normalized() * RECOIL)
		recoiled = true
	
	if components["hitbox"] != null: 
		hitbox.queue_free()
	if death_free == true:
		queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if visible == false: return
	if global.get_relation(self, area.get_parent()) == "friendly": return
	if "ONHIT_SELF_DAMAGE" in area.get_parent(): return
	
	stats.change_health(0, -(ONHIT_SELF_DAMAGE))
	
	# recoil
	if get_node_or_null(SOURCE_PATH) != null and SOURCE.is_queued_for_deletion() == false and recoiled == false:
		SOURCE.apply_force(global_position.direction_to(SOURCE.global_position).normalized() * RECOIL)
		recoiled = true

# PROBLEM_NOTE: this is really bad (overwriting function from Thing.gd)
# i really need to figure out how function inheiritance works
func _on_collision_body_entered(body: Node) -> void:
	if visible == false: return
	if body.get_name() == "WorldTiles":
		if COLLIDE_SOUND != null:
			var sfx = Sound.new()
			sfx.stream = COLLIDE_SOUND
			sound.add_sound(sfx)
		
		# recoil
		#if get_node_or_null(SOURCE_PATH) != null and SOURCE.is_queued_for_deletion() == false:
		#	SOURCE.apply_force(global_position.direction_to(SOURCE.global_position).normalized() * RECOIL)
		
		death_free = true
		death()
