extends Area2D

export(float, 0.001, 99) var COOLDOWN: float = 0.2
export var COOLDOWN_ON_START := false
export var iTime = 0.1
export var MULTIHITS := true
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
var blacklist := []

var ready := false

signal hit(area, type)

func _on_hitbox_tree_entered() -> void:
	get_parent().components["hitbox"] = self

func _ready():
	ready = true
	timer.wait_time = COOLDOWN
	
	if COOLDOWN_ON_START == true:
		set_deferred("monitorable", false)
		timer.start()
	
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
		area_entity == entity or
		entity is Attack and area_entity == entity.SOURCE or
		TEAM_ATTACK == false and global.get_relation(entity, area_entity) == "friendly" or
		area in blacklist and area.processing_hit == false or area_entity
	):
		return
	
	# los check
	var ss = get_world_2d().direct_space_state
	var raycast = ss.intersect_ray(global_position, area.global_position, [], 1)
	if raycast and raycast.collider == refs.world_tiles.get_ref():
		return
	
	timer.start()
	if MULTIHITS == false:
		set_deferred("monitorable", false)
	
	if entity.components["sound_player"] != null and TRIGGERED_SOUND != null:
		var sfx = Sound.new()
		sfx.stream = TRIGGERED_SOUND
		entity.components["sound_player"].add_sound(sfx)

func _on_Timer_timeout() -> void:
	blacklist = []
	set_deferred("monitorable", true)
	
	if monitoring == true:
		for area in get_overlapping_areas():
			if "the_area" in area:
				_on_hitbox_area_entered(area)
				area._on_hurtbox_area_entered(self)
