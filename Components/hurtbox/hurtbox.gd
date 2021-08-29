extends Area2D

export(float) var iTime_multiplier = 1.0
export(AudioStream) var HURT_SOUND
export(AudioStream) var BLOCK_SOUND
export(AudioStream) var HEAL_SOUND
export(AudioStream) var KILLED_SOUND
export(float) var SPAWN_INVINCIBILITY := 0.0

onready var iTimer = $Timer
onready var entity = get_parent()

var the_area: Area2D
var the_area_path: NodePath
var the_area_used := false

signal got_hit(by_area, type)

func _on_hurtbox_tree_entered() -> void:
	get_parent().components["hurtbox"] = self

func _init() -> void:
	if SPAWN_INVINCIBILITY > 0.0:
		monitorable = false

func _ready():
	if SPAWN_INVINCIBILITY > 0.0:
		# triggers invincibility
		iTimer.wait_time = SPAWN_INVINCIBILITY
		iTimer.start()
		#set_deferred("monitorable", false)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	var area_entity = area.get_parent() as Entity
	
	if entity == area_entity:
		return
	
	# los check
	var ss = get_world_2d().direct_space_state
	var raycast = ss.intersect_ray(global_position, area.global_position, [], 1)
	if raycast and raycast.collider == refs.world_tiles.get_ref():
		return
	
	if global.get_relation(entity, area_entity) == "friendly":
		if area.TEAM_ATTACK == false: return
		elif area_entity is Melee and area_entity.SOURCE == entity: return
		elif area_entity is Projectile and area_entity.SOURCE == entity:
			if area_entity.has_left_src == false: return
	
	if area_entity is Projectile:
		if area_entity.get_speed() < area_entity.MIN_DAM_SPEED:
			return
	
	if (
		the_area == null or 
		the_area_path != null and get_node_or_null(the_area_path) != null
	): 
		the_area = area
		the_area_path = area.get_path()
	
	if area != the_area: return
	if the_area_used == true: return
	
	the_area_used = true
	
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
	
	if (
		area.get_name() == "hitbox" and
		monitorable == true
		):
			# triggers invincibility
			iTimer.wait_time = area.iTime * iTime_multiplier + 0.0001
			iTimer.start()
			set_deferred("monitorable", false)
	
func _on_Timer_timeout() -> void:
	the_area = null
	the_area_used = false
	set_deferred("monitorable", true)
