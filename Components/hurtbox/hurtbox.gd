extends Area2D

export(AudioStream) var HURT_SOUND
export(AudioStream) var BLOCK_SOUND
export(AudioStream) var HEAL_SOUND
export(AudioStream) var KILLED_SOUND

onready var iTimer = $Timer
onready var entity = get_parent()

var the_area: Area2D
var the_area_path: NodePath
var the_area_used := false
var processing_hit := false

signal got_hit(by_area, type)

func _on_hurtbox_tree_entered() -> void:
	get_parent().components["hurtbox"] = self

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.IGNORE_ATTACKS == true and entity is Attack:
		return
	
	var area_entity: Entity = area.entity
	
	if entity == area_entity:
		return
	if entity.FLYING == true and not area_entity.FLYING:
		return
	
	# los check
	var ss = get_world_2d().direct_space_state
	var raycast = ss.intersect_ray(global_position, area.global_position, [], 1)
	if raycast and raycast.collider == refs.world_tiles:
		return
	if global.get_relation(entity, area_entity) == "friendly":
		if area.TEAM_ATTACK == false:
			return
		elif (
			area_entity is Attack and
			area_entity.SOURCE == entity and
			not (area_entity is Projectile and area_entity.has_left_src == true)
		):
			return
	
	if area_entity is Projectile:
		if area_entity.get_speed() < area_entity.MIN_DAM_SPEED:
			return
	
	if area.MULTIHITS == false:
		if (
			the_area == null or
			the_area_path != null and get_node_or_null(the_area_path) != null
		): 
			the_area = area
			the_area_path = area.get_path()
		
		if area != the_area:
			return
		if the_area_used == true:
			return
	
	if self in area.blacklist:
		return
	
	the_area_used = true
	
	if area.MULTIHITS == true:
		processing_hit = true
		area.blacklist.append(self)
		area.timer.start()
	
	# applies damage
	
	var type = "hurt"
	if area.DAMAGE + area.TRUE_DAMAGE < 0: type = "heal"
	if area.DAM_TYPE != "null":
		type = area.DAM_TYPE
	
	var result_type = entity.components["stats"].change_health(-(area.DAMAGE), -(area.TRUE_DAMAGE), type)
	
	# signals
	
	if result_type != "":
		emit_signal("got_hit", area, result_type)
		
		# for sfx
		if HURT_SOUND != null or BLOCK_SOUND != null or HEAL_SOUND != null or KILLED_SOUND != null:
			if entity.components["sound_player"] != null:
				var sfx = Sound.new()
				match result_type:
					"hurt": sfx.stream = HURT_SOUND
					"block": sfx.stream = BLOCK_SOUND
					"heal": sfx.stream = HEAL_SOUND
					"killed": sfx.stream = KILLED_SOUND
				
				if sfx.stream != null:
					entity.components["sound_player"].add_sound(sfx)
				else:
					sfx.queue_free()
			
			else:
				push_warning("hurtbox can not play sounds because "+entity.truName+" has no sound_player")
		
	area.emit_signal("hit", self, result_type)
	
	# applies status effect
	
	if area.STATUS_EFFECT != "":
		entity.components["stats"].add_status_effect(
			area.STATUS_EFFECT,
			area.STATUS_DURATION,
			area.STATUS_LEVEL
		)
	
	if area.KNOCKBACK > 0:
		var source_pos = area.global_position - area_entity.velocity
		if area_entity is Melee and get_node_or_null(area_entity.SOURCE_PATH) != null: 
			source_pos = area_entity.SOURCE.global_position
		
		# knockback
		entity.apply_force((source_pos.direction_to(global_position) * area.KNOCKBACK))
	
	processing_hit = false
	
	if area.iTime == 0:
		the_area = null
		the_area_used = false
		set_deferred("monitorable", true)
	elif (
		area.get_name() == "hitbox" and
		monitorable == true
	):
		# triggers invincibility
		iTimer.wait_time = area.iTime
		iTimer.start()
		set_deferred("monitorable", false)

func _on_Timer_timeout() -> void:
	the_area = null
	the_area_used = false
	set_deferred("monitorable", true)
