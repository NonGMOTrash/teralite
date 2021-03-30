extends Area2D

export var COOLDOWN = 0.5
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

onready var timer = $Timer
var stats

signal hit(area, type)

func _on_hitbox_tree_entered() -> void:
	get_parent().components["hitbox"] = self

func _ready():
	timer.wait_time = COOLDOWN
	
	var node = get_parent().components["stats"]
	if node == null: return
	else: stats = node
	
	DAMAGE += stats.DAMAGE
	TRUE_DAMAGE += stats.TRUE_DAMAGE

func _on_hitbox_area_entered(area: Area2D) -> void:
	var area_entity = area.get_parent()
	if (
		area_entity is Attack or
		area.entity == get_parent() or
		TEAM_ATTACK == false and global.get_relation(get_parent(), area_entity) == "friendly"
		): return
	
	set_deferred("monitorable", false)
	timer.start()
	
	if get_parent().components["sound_player"] != null and TRIGGERED_SOUND != null:
		var sfx = Sound.new()
		sfx.stream = TRIGGERED_SOUND
		get_parent().components["sound_player"].add_sound(sfx)

func _on_Timer_timeout() -> void:
	set_deferred("monitorable", true)
