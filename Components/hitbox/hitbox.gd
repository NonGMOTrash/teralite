extends Area2D

export var COOLDOWN = 0.5
export var COOLDOWN_ON_START := true
export var COOLDOWN_SHARE := false
export var iTime = 0.1
export var DAMAGE = 0
export var TRUE_DAMAGE = 0
export var DAM_TYPE = "null"
export var KNOCKBACK = 120
export(String) var STATUS_EFFECT = ""
export var STATUS_DURATION = 5.0
export var STATUS_LEVEL = 1.0
export var TEAM_ATTACK = true
export(AudioStream) var TRIGGERED_SOUND

onready var entity = get_parent()
onready var timer = $Timer
var stats: Node

var other_hitboxes := []

signal hit(area, type)

func _on_hitbox_tree_entered() -> void:
	get_parent().components["hitbox"] = self

func _ready():
	timer.wait_time = COOLDOWN
	
	var node = entity.components["stats"]
	if node == null: return
	else: stats = node
	
	DAMAGE += stats.DAMAGE
	TRUE_DAMAGE += stats.TRUE_DAMAGE
	
	for child in entity.get_children():
		if child is Area2D and "COOLDOWN" in child:
			other_hitboxes.append(child)

func _on_hitbox_area_entered(area: Area2D) -> void:
	var area_entity = area.get_parent()
	if (
		area_entity is Attack or
		area.entity == entity or
		TEAM_ATTACK == false and global.get_relation(entity, area_entity) == "friendly"
	):
		return
	
	# los check
	var ss = get_world_2d().direct_space_state
	var raycast = ss.intersect_ray(global_position, area.global_position, [], 1)
	if raycast and raycast.collider == refs.world_tiles.get_ref():
		return
	
	if COOLDOWN_ON_START == true:
		set_deferred("monitorable", false)
		timer.start()
	
	if COOLDOWN_SHARE == true:
		for hitbox in other_hitboxes:
			hitbox.set_deferred("monitorable", false)
			hitbox.timer.start()
	
	if entity.components["sound_player"] != null and TRIGGERED_SOUND != null:
		var sfx = Sound.new()
		sfx.stream = TRIGGERED_SOUND
		entity.components["sound_player"].add_sound(sfx)

func _on_Timer_timeout() -> void:
	set_deferred("monitorable", true)
