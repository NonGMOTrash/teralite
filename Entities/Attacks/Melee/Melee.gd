extends Attack
class_name Melee

const BLOCK_SPARK = preload("res://Effects/block_spark/block_spark.tscn")

export(bool) var HOLDS := false
export(int, 0, 200) var BOOST = 50
export(int, 0, 200) var RECOIL = 70
export(bool) var ANIMATION_NEVER_BACKWARDS := false
export(bool) var HIDE_HELD_ITEM := true
export(bool) var REVERSE_HELD_ITEM := true

var recoiled = false

onready var animation := $animation as AnimationPlayer

func setup(new_source = Entity.new(), new_target_pos = Vector2.ZERO):
	.setup(new_source, new_target_pos)

func _ready():
	global_position.move_toward(target_pos, abs(RANGE - 6))
	
	if SOURCE == null: SOURCE = get_node_or_null(SOURCE_PATH)
	
	# boost
	if get_node_or_null(SOURCE_PATH) != null and SOURCE.is_queued_for_deletion() == false:
		SOURCE.apply_force(SOURCE.global_position.direction_to(target_pos).normalized() * BOOST)
	
	RECOIL += BOOST # < so the boost doesn't cancel out the RECOIL
	
	var held_item = SOURCE.components["held_item"]
	
	# hide held item
	if held_item != null and HIDE_HELD_ITEM == true:
		held_item.visible = false
	
	if held_item != null and held_item.sprite.flip_v == true and ANIMATION_NEVER_BACKWARDS == false:
		animation.play_backwards("animation")
	else:
		animation.play("animation")
	
	_physics_process(0.0)
	
	visible = true

func _physics_process(_delta):
	if get_node_or_null(SOURCE_PATH) != null and SOURCE.is_queued_for_deletion() == false:
		global_position = SOURCE.global_position + RANGE * DIRECTION

func death():
	emit_signal("death")
	
	# recoil
	if get_node_or_null(SOURCE_PATH) != null and SOURCE.is_queued_for_deletion() == false and recoiled == false:
		SOURCE.apply_force(target_pos.direction_to(SOURCE.global_position).normalized() * RECOIL)
		recoiled = true
	
	if components["hitbox"] != null:
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitorable", false)
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

func _on_collision_body_entered(body: Node) -> void:
	if visible == false: return
	if body.get_name() == "world_tiles":
		if COLLIDE_SOUND != null:
			var sfx = Sound.new()
			sfx.stream = COLLIDE_SOUND
			sound.add_sound(sfx)
		
		var spark: Effect = BLOCK_SPARK.instance()
		spark.rotation_degrees = rad2deg(SOURCE.global_position.direction_to(global_position).angle())
		global.nodes["ysort"].call_deferred("add_child", spark)
		yield(spark, "ready")
		spark.global_position = global_position
		
		# recoil
		#if get_node_or_null(SOURCE_PATH) != null and SOURCE.is_queued_for_deletion() == false:
		#	SOURCE.apply_force(global_position.direction_to(SOURCE.global_position).normalized() * RECOIL)
		
		death_free = true
		death()

func _on_Melee_tree_exiting() -> void:
	animation.stop()
	
	# make held item visible agian
	if get_node_or_null(SOURCE_PATH) != null and SOURCE.is_queued_for_deletion() == false:
		var held_item = SOURCE.components["held_item"]
		if held_item != null:
			if REVERSE_HELD_ITEM == true:
				held_item.reversed = not held_item.reversed
				# fixes flashing due to the held_item updating a frame late
				held_item.sprite.flip_v = not held_item.sprite.flip_v
				held_item.sprite.offset *= -1
			
			held_item.visible = true

func _on_animation_animation_finished(anim_name: String) -> void:
	if HOLDS == false:
		queue_free()
	else:
		animation.play("hold")
