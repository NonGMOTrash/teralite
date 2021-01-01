extends Area2D

export(float) var iTime_multiplier = 1.0

onready var iTimer = $Timer

var entity

var the_area = null
var the_area_used = false

signal triggered(body)

func _on_hurtbox_tree_entered() -> void:
	get_parent().components["hurtbox"] = self

func _ready():
	entity = get_parent()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if get_parent() == area.get_parent(): return
	
	var area_entity = area.get_parent()
	
	if global.get_relation(get_parent(), area_entity) == "friendly":
		if area.TEAM_ATTACK == false: return
		elif area_entity is Melee and area_entity.SOURCE == get_parent(): return
		elif area_entity is Projectile and area_entity.SOURCE == get_parent():
			if area_entity.has_left_src == false: return
	
	if the_area == null: the_area = area
	
	if area != the_area: return
	if the_area_used == true: return
	
	the_area_used = true
	emit_signal("triggered", area)
	
	# applies damage
	
	var type = "hurt"
	if area.DAMAGE + area.TRUE_DAMAGE < 0: type = "heal"
	if area.DAM_TYPE != "null": 
		type = area.DAM_TYPE
	entity.components["stats"].change_health(-(area.DAMAGE), -(area.TRUE_DAMAGE), type)
	
	# applies status effect
	
	var effect = area.STATUS_EFFECT
	if effect.get("duration") > 0 and effect.get("level") > 0:
		entity.components["stats"].add_status_effect(
			effect.get("type"),
			effect.get("duration"),
			effect.get("level")
		)
	
	if area.KNOCKBACK > 0:
		var source_pos = area.global_position
		if area.get_parent() is Melee and get_node_or_null(area.get_parent().SOURCE_PATH) != null: 
			source_pos = area.get_parent().SOURCE.global_position
		
		# knockback
		entity.apply_force((source_pos.direction_to(global_position) * area.KNOCKBACK))
	
	if (
		area.get_name() == "hitbox" && 
		monitorable == true #&& 
		#global.get_relation(get_parent(), area_entity) != "friendly"
		):
			# triggers invincibility
			iTimer.wait_time = area.iTime * iTime_multiplier + 0.0001
			iTimer.start()
			set_deferred("monitorable", false)
	
func _on_Timer_timeout() -> void:
	the_area = null
	the_area_used = false
	set_deferred("monitorable", true)
