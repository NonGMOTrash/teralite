extends Entity

const PISTOL_TEXTURE := preload("res://Entities/Item_Pickups/pistol/pistol.png")
const MEDKIT_TEXTURE := preload("res://Entities/Item_Pickups/medkit/medkit.png")

export var warnings: int
export(PackedScene) var PROJECTILE
export var regen_duration: float
export var regen_level: float
export var heal_animation_speed: float

var actionable := false
var targit: Entity
var targit_path: NodePath
var queued_action: String
var bullets: int = 10

onready var brain := $brain
onready var held_item := $held_item
onready var stats := $stats
onready var medkit_action := $brain/action_lobe/medkit
onready var friend_timer := $friend_timer
onready var animation := $AnimationPlayer

#func _init() -> void:
#	refs.ysort.get_ref().get_node("entity_spawns").connect("finished_batching", self, "make_friends")
#	prints(get_name(), "connected")

func _ready() -> void:
	held_item.animation.connect("animation_finished", self, "attack")
	actionable = true

# sets all nearby survivors as friendly :DDD
func _on_friend_timer_timeout() -> void:
	prints(get_name(), "start")
	var n := []
	# should mak0e this trigger on a "all_entites_spawned" signal from entity spawns
	for body in brain.sight.get_overlapping_bodies():
		n.append(body.get_name())
		if body is Entity and body.truName == "survivor" and brain.los_check(body):
			marked_allies.append(body)
	prints(get_name(), "available_targets:", n)
	
	var n2 := []
	for ally in marked_allies:
		n2.append(ally.get_name())
	prints(get_name(), ":", n2)
	prints(get_name(), "end")

func _on_action_lobe_action(action, target) -> void:
	if actionable == false:
		return
	
	if action == "shoot":
		held_item.sprite.texture = PISTOL_TEXTURE
		
		if bullets == 0:
			queued_action = "reload"
			held_item.animation.clear_queue()
			held_item.animation.play("spin", -1, 0.9)
			actionable = false
			return
		
		queued_action = "shoot"
		held_item.sprite.texture = PISTOL_TEXTURE
		targit = target
		targit_path = target.get_path()
		for _i in warnings:
			held_item.animation.queue("warn")
	elif action == "medkit":
		queued_action = "medkit"
		held_item.sprite.texture = MEDKIT_TEXTURE
		held_item.animation.play("spin", -1, heal_animation_speed)
		actionable = false

func attack(finished_animation:String):
	if held_item.animation.get_queue().size() > 0:
		return
	
	if queued_action == "shoot":
		if get_node_or_null(targit_path) == null:
			return
		
		var bullet: Projectile = PROJECTILE.instance()
		bullet.marked_allies.append(self)
		marked_allies.append(bullet)
		bullet.setup(self, targit.global_position)
		refs.ysort.get_ref().add_child(bullet)
		bullets -= 1
	elif queued_action == "medkit":
		stats.change_health(1, 0, "heal")
		stats.add_status_effect("regeneration", regen_duration, regen_level)
		held_item.sprite.texture = null
		medkit_action.queue_free()
		actionable = true
	elif queued_action == "reload":
		bullets = 10
		actionable = true


func _physics_process(delta: float) -> void:
	if input_vector == Vector2.ZERO:
		animation.play("stand")
	else:
		animation.play("walk")
