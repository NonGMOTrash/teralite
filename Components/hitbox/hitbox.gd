extends Area2D

export var COOLDOWN = 0.5
export var iTime = 0.1
export var DAMAGE = 0
export var TRUE_DAMAGE = 0
export var DAM_TYPE = "null"
export var KNOCKBACK = 120
export var STATUS_EFFECT = {
	"type": "type_name",
	"duration": 0.0,
	"level": 0
}
export var TEAM_ATTACK = true

onready var timer = $Timer
var stats

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
	if area.get_parent() is Projectile or area.get_parent() is Melee or area.get_parent() == get_parent(): 
		return
	set_deferred("monitorable", false)
	timer.start()

func _on_Timer_timeout() -> void:
	set_deferred("monitorable", true)
